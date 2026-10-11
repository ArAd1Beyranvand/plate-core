"""Everything the GUI and CLI share: Ollama client, work units, prompts,
validation, the conflict guard and report writing.

The prepass JSON is the source of truth. The model is asked small questions
about one unit at a time; its answers are stored next to the facts and checked
against them, never substituted for them.
"""

import hashlib
import json
import queue
import subprocess
import threading
import time
import urllib.error
import urllib.request
from dataclasses import dataclass, field
from pathlib import Path

from .prepass import fields_from

TOOL = Path(__file__).resolve().parent.parent
ROOT = TOOL.parent.parent
OUT = TOOL / 'out'
SPECS, PREPASS, REPORTS, UNITS = OUT / 'specs', OUT / 'prepass', OUT / 'reports', OUT / 'units'
PROGRESS = OUT / 'progress.log'

TOKEN_BUDGET = 6000          # per prompt, approximate
FACT_BUDGET = 3500           # tokens of facts per TYPE-1 batch


def approx_tokens(text):
    return len(text) // 3 + 1


# ---------------------------------------------------------------- settings / events

@dataclass
class Settings:
    endpoint: str = 'http://localhost:11434'
    model: str = ''
    num_ctx: int = 8192
    temperature: float = 0.1
    think: bool = False
    retries: int = 2
    max_near_misses: int = 20
    timeout: float = 600


class Stopped(Exception):
    pass


@dataclass
class Sink:
    """Callbacks the runner reports through; the GUI routes them to a queue."""
    log: callable = print
    token: callable = lambda t: print(t, end='', flush=True)
    prompt: callable = lambda p: None
    stop_requested: callable = lambda: False


# ---------------------------------------------------------------- Ollama

def list_models(endpoint, timeout=10):
    with urllib.request.urlopen(endpoint.rstrip('/') + '/api/tags', timeout=timeout) as r:
        return sorted(m['name'] for m in json.load(r).get('models', []))


def chat(settings, messages, schema, sink):
    """Stream one /api/chat call; returns the full content string.

    The HTTP read runs on a helper thread so this loop can report while
    Ollama is silent (loading the model, evaluating the prompt)."""
    body = {
        'model': settings.model, 'messages': messages, 'stream': True, 'format': schema,
        'options': {'num_ctx': settings.num_ctx, 'temperature': settings.temperature},
        'think': settings.think,
    }
    url = settings.endpoint.rstrip('/') + '/api/chat'
    req = urllib.request.Request(url, data=json.dumps(body).encode(),
                                 headers={'Content-Type': 'application/json'})
    lines = queue.Queue()

    def reader():
        try:
            with urllib.request.urlopen(req, timeout=settings.timeout) as r:
                lines.put(('status', f'HTTP {r.status}, streaming'))
                for line in r:
                    lines.put(('line', line))
        except Exception as e:  # handed to the caller's thread
            lines.put(('error', e))
        lines.put(('end', None))

    sink.log(f'  POST {url} model={settings.model} num_ctx={settings.num_ctx} '
             f'think={settings.think} ({approx_tokens(json.dumps(messages))} tokens in)')
    threading.Thread(target=reader, daemon=True).start()
    parts, n_tokens, n_think = [], 0, 0
    t0 = time.time()
    first = last_report = None
    while True:
        if sink.stop_requested():
            raise Stopped()
        try:
            kind, value = lines.get(timeout=1)
        except queue.Empty:
            now = time.time()
            if now - (last_report or t0) >= 5:
                last_report = now
                if first is None:
                    sink.log(f'  waiting {now - t0:.0f}s for first token (model load / prompt evaluation)')
                else:
                    rate = (n_tokens + n_think) / max(now - first, 1e-6)
                    sink.log(f'  {n_tokens} answer + {n_think} thinking tokens, {rate:.1f} tok/s')
            continue
        if kind == 'status':
            sink.log(f'  {value} after {time.time() - t0:.1f}s')
            continue
        if kind == 'error':
            raise RuntimeError(value) if not isinstance(value, OSError) else value
        if kind == 'end':
            break
        if not value.strip():
            continue
        chunk = json.loads(value)
        if 'error' in chunk:
            raise RuntimeError(chunk['error'])
        msg = chunk.get('message', {})
        if first is None and (msg.get('thinking') or msg.get('content')):
            first = time.time()
            sink.log(f'  first token after {first - t0:.1f}s')
        if msg.get('thinking'):
            if n_think == 0:
                sink.token('[thinking] ')
            n_think += 1
            sink.token(msg['thinking'])
        if msg.get('content'):
            if n_tokens == 0 and n_think:
                sink.token('\n[answer] ')
            n_tokens += 1
            parts.append(msg['content'])
            sink.token(msg['content'])
        if chunk.get('done'):
            ns = 1e9
            sink.log(f'  done: load {chunk.get("load_duration", 0) / ns:.1f}s, prompt '
                     f'{chunk.get("prompt_eval_count", "?")} tok in {chunk.get("prompt_eval_duration", 0) / ns:.1f}s, '
                     f'output {chunk.get("eval_count", "?")} tok in {chunk.get("eval_duration", 0) / ns:.1f}s, '
                     f'total {chunk.get("total_duration", 0) / ns:.1f}s, reason {chunk.get("done_reason")}')
            break
    sink.token('\n')
    return ''.join(parts)


# ---------------------------------------------------------------- schemas + validation

def _arr(items):
    return {'type': 'array', 'items': items}


STR, INT, BOOL = {'type': 'string'}, {'type': 'integer'}, {'type': 'boolean'}

CLUSTER_SCHEMA = {
    'type': 'object', 'required': ['reason', 'verdict', 'excludeMembers', 'unifiedId', 'risks'],
    'properties': {
        'reason': STR,
        'verdict': {'type': 'string', 'enum': ['one_structure', 'partial', 'keep_separate']},
        'excludeMembers': _arr(STR), 'unifiedId': STR, 'risks': _arr(STR),
    },
}

NEAR_SCHEMA = {
    'type': 'object', 'required': ['reason', 'verdict', 'risks'],
    'properties': {'reason': STR, 'verdict': {'type': 'string', 'enum': ['merge', 'keep_separate', 'unclear']},
                   'risks': _arr(STR)},
}

def type1_schema(t1):
    """One required key per soft boundary (b1, b2, ...), so the model can
    neither skip a boundary nor invent indices."""
    one = {'type': 'object', 'required': ['reason', 'decision'],
           'properties': {'reason': STR, 'decision': {'type': 'string', 'enum': ['merge', 'split']}}}
    keys = [f'b{n + 1}' for n in range(len(t1['softBoundaries']))]
    return {'type': 'object', 'required': ['decisions', 'notes'],
            'properties': {'decisions': {'type': 'object', 'required': keys,
                                         'properties': {k: one for k in keys}},
                           'notes': STR}}


def type1_normalize(t1, answer):
    return {'id': t1['id'], 'notes': answer['notes'],
            'boundaries': [dict(between=b['between'], **answer['decisions'][f'b{n + 1}'])
                           for n, b in enumerate(t1['softBoundaries'])]}


SYNTH_SCHEMA = {
    'type': 'object', 'required': ['summary', 'knockOn', 'openQuestions'],
    'properties': {
        'summary': STR,
        'knockOn': _arr({'type': 'object', 'required': ['area', 'note'],
                         'properties': {'area': STR, 'note': STR}}),
        'openQuestions': _arr(STR),
    },
}

_TYPES = {'string': str, 'integer': int, 'boolean': bool, 'array': list, 'object': dict}


def validate(value, schema, path='$'):
    """The subset of JSON Schema used above. Returns a list of error strings."""
    t = schema.get('type')
    if t and (not isinstance(value, _TYPES[t]) or (t == 'integer' and isinstance(value, bool))):
        return [f'{path}: expected {t}, got {type(value).__name__}']
    errs = []
    if 'enum' in schema and value not in schema['enum']:
        errs.append(f'{path}: {value!r} not in {schema["enum"]}')
    if t == 'object':
        for k in schema.get('required', []):
            if k not in value:
                errs.append(f'{path}: missing "{k}"')
        for k, sub in schema.get('properties', {}).items():
            if k in value:
                errs += validate(value[k], sub, f'{path}.{k}')
    if t == 'array':
        for i, v in enumerate(value):
            errs += validate(v, schema['items'], f'{path}[{i}]')
    return errs


# ---------------------------------------------------------------- prompts

BACKGROUND = """You review a planned refactor of licence-plate specs. Facts below come from a deterministic analysis; treat them as correct and do not invent others.

TYPE 1 - today every character is its own input cell. Neighbouring cells that a person reads as one number become ONE input field holding several characters. Cells on different lines, or with a divider/label between them, always stay separate.
TYPE 2 - specs that are the same plate and differ ONLY in how many cells a register has become ONE spec whose field accepts min..max characters. Any other difference (alphabet, colours, labels, vehicle, layout not explained by the cell count) keeps them separate.

Answer only with JSON matching the requested schema. Write "reason" first, then the decision. Keep strings short."""


def compact_spec(spec, t1):
    """A spec in run-length notation: enough to judge, small enough to batch."""
    groups = []
    for g in spec['textGroups']:
        cells = [spec['slots'][i] for i in g['indices'] if i < len(spec['slots'])]
        runs, last = [], None
        for c in cells:
            if last and last[0] == c['alphabet']:
                last[1] += 1
            else:
                last = [c['alphabet'], 1]
                runs.append(last)
        groups.append({'key': g['key'], 'indices': f'{g["indices"][0]}..{g["indices"][-1]}' if g['indices'] else '',
                       'cells': ' '.join(f'{a}x{n}' for a, n in runs),
                       'box0': cells[0]['box'] if cells else None})
    rules = spec['rules']
    return {
        'id': spec['id'], 'canvas': spec['canvas'], 'direction': spec['direction'],
        'groups': groups,
        'mirrors': [f'slot {m["source"]} -> {m["alphabet"] or "same"}' for m in spec['mirrors']],
        'labels': [l['text'] for l in spec['labels']],
        'rules': rules['summary'] if isinstance(rules, dict) else f'{len(rules)} rules',
        'type1': t1,
    }


def validator_hint(country, limit=6000):
    p = OUT / 'validators' / f'{country}.txt'
    if not p.exists():
        return ''
    text = p.read_text()
    return text if len(text) <= limit else text[:limit] + '\n... [truncated]'


def cluster_prompt(country, cluster, specs_by_id, hint):
    """Shrinks in steps until it fits: drop the validator hint, then list
    fewer members in full, then clip the per-attribute difference values."""
    def member(i):
        m = compact_spec(specs_by_id[i], None)
        m.pop('type1')
        return m

    def clip(v, n):
        t = json.dumps(v, ensure_ascii=False)
        return v if len(t) <= n else t[:n] + '...'

    base = {k: cluster[k] for k in ('id', 'members', 'registers', 'observedCombinations',
                                    'differs', 'catalogues', 'confidence', 'confidenceNote')}
    for shown, clip_at, use_hint in ((99, 10**6, True), (99, 10**6, False), (4, 600, False), (2, 200, False)):
        facts = {'cluster': dict(base, differs={k: clip(v, clip_at) for k, v in base['differs'].items()},
                                 catalogues={k: v[:3] for k, v in base['catalogues'].items()}),
                 'members': [member(i) for i in cluster['members'][:shown]]}
        if shown < len(cluster['members']):
            facts['membersOmitted'] = len(cluster['members']) - shown
        prompt = (f'{BACKGROUND}\n\nCountry: {country}. TYPE 2 cluster (identical structure signature).\n'
                  f'FACTS:\n{json.dumps(facts, ensure_ascii=False)}\n\n'
                  + (f'VALIDATOR SOURCE (hint):\n{hint}\n\n' if hint and use_hint else '')
                  + 'The members already have identical structure except register cell counts (see "registers"). '
                    '"differs" lists every other value that is not equal between them. Decide:\n'
                    '- one_structure: every value in "differs" follows from the cell count (more cells -> wider '
                    'canvas, shifted starts, longer serial). excludeMembers must be [].\n'
                    '- partial: one or more members are a different plate; list ONLY those in excludeMembers '
                    '(at least two members must remain).\n'
                    '- keep_separate: they are different plates.\n'
                    'unifiedId: a spec id for the merged spec, in the style of the member ids. '
                    'risks: what could break (validators, catalogue lookups by id, generators), max 3.')
        if approx_tokens(prompt) <= TOKEN_BUDGET:
            break
    return prompt


def near_prompt(country, near, specs_by_id):
    facts = {'nearMiss': near,
             'a': compact_spec(specs_by_id[near['a'][0]], None),
             'b': compact_spec(specs_by_id[near['b'][0]], None)}
    facts['a'].pop('type1')
    facts['b'].pop('type1')
    return (f'{BACKGROUND}\n\nCountry: {country}. NEAR MISS: two spec groups whose signatures differ in exactly '
            f'one attribute ("{near["attribute"]}").\nFACTS:\n{json.dumps(facts, ensure_ascii=False)}\n\n'
            'Is that difference explained by the number of cells alone (e.g. a wider canvas or background '
            'because one register has more cells)? If yes, verdict merge; if it is a real difference between two '
            'plates, keep_separate; unclear only if the facts cannot tell. Max 2 risks.')


_SOURCE_CACHE = {}


def package_files(package, sub):
    key = (package, sub)
    if key not in _SOURCE_CACHE:
        base = ROOT / package / sub
        _SOURCE_CACHE[key] = [(p, p.read_text(errors='replace').splitlines())
                              for p in sorted(base.rglob('*.dart'))] if base.exists() else []
    return _SOURCE_CACHE[key]


def spec_source(package, spec, limit=2500):
    """The declaration of the spec in lib/, found by its id literal (else by
    the catalogue member name), plus test lines mentioning either."""
    needles = [f"'{spec['id']}'", f'"{spec["id"]}"']
    names = [p.split('[')[0].split('(')[0].split('.')[-1] for p in spec.get('catalogues', [])]
    snippet = ''
    for pats in (needles, [n for n in names if len(n) > 2]):
        for path, lines in package_files(package, 'lib'):
            for n, line in enumerate(lines):
                if any(p in line for p in pats):
                    lo, hi = max(0, n - 15), min(len(lines), n + 40)
                    snippet = f'// {path.relative_to(ROOT)}:{n + 1}\n' + '\n'.join(lines[lo:hi])
                    break
            if snippet:
                break
        if snippet:
            break
    if len(snippet) > limit:
        snippet = snippet[:limit] + '\n... [truncated]'
    tests = []
    for path, lines in package_files(package, 'test'):
        for n, line in enumerate(lines):
            if any(p in line for p in needles + [n_ for n_ in names if len(n_) > 2]):
                tests.append(f'{path.relative_to(ROOT)}:{n + 1}: {line.strip()[:160]}')
                if len(tests) >= 5:
                    return snippet, tests
    return snippet, tests


def type1_layout(t1):
    """The cells in order with every boundary drawn: hard ones as their
    reason, soft ones as bN for the model to decide."""
    hard = {tuple(h['between']): h['reasons'] for h in t1['hardSplits']}
    soft = {tuple(b['between']): f'b{n + 1}' for n, b in enumerate(t1['softBoundaries'])}
    order = [i for seg in t1['segments'] for i in seg['indices']]
    out = [t1['chars'][str(order[0])]]
    for prev, cur in zip(order, order[1:]):
        if (prev, cur) in soft:
            out.append(f' {soft[(prev, cur)]} ')
        elif 'different line/row height' in hard.get((prev, cur), []):
            out.append(' / ')
        else:
            out.append(' | ')
        out.append(t1['chars'][str(cur)])
    return ''.join(out)


def type1_prompt(country, package, spec, t1, hint):
    groups = ', '.join(f'{g["key"] or "#" + str(n)} = slots {g["indices"][0]}..{g["indices"][-1]}'
                       for n, g in enumerate(spec['textGroups']) if g['indices'])
    lines = [f'Country: {country}. Spec "{spec["id"]}" ({spec["direction"]}). Text groups: {groups}.',
             f'Sample, cells in slot order: {type1_layout(t1)}',
             '  "|" = fixed split, "/" = new line (fixed), bN = boundary you decide.']
    if t1['hardSplits']:
        lines.append('Fixed splits: ' + '; '.join(f'{h["between"][0]}|{h["between"][1]} {", ".join(h["reasons"])}'
                                                  for h in t1['hardSplits']))
    lines.append('Boundaries to decide:')
    for n, b in enumerate(t1['softBoundaries']):
        a, c = b['between']
        where = (f'both in group "{b["groups"][0]}"' if b['groups'][0] == b['groups'][1]
                 else f'group "{b["groups"][0]}" -> group "{b["groups"][1]}"')
        lines.append(f'  b{n + 1}: slot {a} "{t1["chars"][str(a)]}" | slot {c} "{t1["chars"][str(c)]}", {where}; '
                     f'{", ".join(b["evidence"]) or "touching"}')
    body = '\n'.join(lines) + '\n\n'
    src, tests = spec_source(package, spec)
    extra = ''
    if src:
        extra += f'SPEC SOURCE:\n{src}\n\n'
    if tests:
        extra += 'TESTS MENTIONING IT:\n' + '\n'.join(tests) + '\n\n'
    tail = ('For every bN decide:\n'
            '- merge: both characters are part of ONE number/code that people read and type together '
            '(e.g. the digits of a serial). Two cells of the SAME group: merge, unless the source shows those two '
            'cells as separate values; then quote that line in the reason. A neighbouring group (e.g. a letter) '
            'is not a reason.\n'
            '- split: they are different registers with different meanings (region vs serial, type vs year). '
            'Cells of different groups are usually split unless the source/validator treats them as one number.\n'
            'The gap/padding between cells is NOT evidence either way. Each reason: max 12 words, naming the '
            'group meaning or the source/validator line that decides it. notes: one sentence or "".')
    prompt = f'{BACKGROUND}\n\n{body}{extra}' + (f'VALIDATOR SOURCE (hint):\n{hint}\n\n' if hint else '') + tail
    if approx_tokens(prompt) > TOKEN_BUDGET:
        prompt = f'{BACKGROUND}\n\n{body}{extra}{tail}'
    return prompt


def type1_plan(t, results):
    """(fields as "[..][..]", 'model' | 'default', answer) for one spec."""
    ans, _ = _model(results, f'T1-{t["id"]}')
    order = [(0, i) for seg in t['segments'] for i in seg['indices']]
    decisions = {tuple(b['between']): b['default'] for b in t['softBoundaries']}
    if ans:
        decisions.update({tuple(b['between']): b['decision'] for b in ans['boundaries']
                          if tuple(b['between']) in decisions})
    fields = fields_from(order, decisions, t['hardSplits'])
    plan = ''.join('[' + ''.join(t['chars'].get(str(i), '?') for i in f) + ']' for f in fields)
    return plan, len(fields), ('model' if ans else 'default'), ans


SYNTH_BACKGROUND = """You summarise a planned refactor of one country's licence-plate specs for the developer doing it. TYPE 1 merges neighbouring single-character cells into multi-character fields; TYPE 2 collapses specs that differ only in a register's cell count into one spec with a min..max field. Use only the facts given; do not mention other countries. Answer only with JSON matching the schema."""


def synth_prompt(country, pre, results):
    brief = {
        'type1': {t['id']: type1_plan(t, results)[0] for t in pre['type1']},
        'type2': ('none: no specs are merged, every spec keeps its own fixed field lengths'
                  if not pre['type2']['clusters'] else 'see type2Clusters'),
        'type2Clusters': [{'members': c['members'], 'verdict': (_model(results, c['id'])[0] or {}).get('verdict')}
                          for c in pre['type2']['clusters']],
        'nearMissesToMerge': [n['a'] + n['b'] for n in pre['type2']['nearMisses']
                              if (_model(results, n['id'])[0] or {}).get('verdict') == 'merge'],
        'galleryDuplicates': [[e['id'] for e in d['entries']] for d in pre.get('gallery', {}).get('duplicates', [])],
        'catalogueMembers': sorted({p.split('[')[0] for s in pre['specs'] for p in s['catalogues']})[:30],
        'validatorFiles': pre['validatorFiles'],
        'warnings': pre['warnings'][:10],
    }
    text = json.dumps(brief, ensure_ascii=False)
    if approx_tokens(text) > FACT_BUDGET:
        plans = {}
        for k, v in brief['type1'].items():
            plans.setdefault(v, []).append(k)
        brief['type1'] = {v: ks[:5] + ([f'+{len(ks) - 5} more'] if len(ks) > 5 else []) for v, ks in plans.items()}
        text = json.dumps(brief, ensure_ascii=False)
    return (f'{SYNTH_BACKGROUND}\n\nCountry: {country}.\nFACTS ("type1" maps spec id -> planned fields; '
            f'"[..]" is one input field):\n{text}\n\n'
            'Write: summary (2-3 sentences: what changes for this country); knockOn (max 5; areas: validators, '
            'serial generators, catalogue lookups, gallery/examples, tests; say concretely what changes); '
            'openQuestions (max 3, only real decisions the developer must make). '
            'If "type2" is none, do not propose merging specs, unified specs or min..max lengths.')


# ---------------------------------------------------------------- units

@dataclass
class Unit:
    id: str
    kind: str            # cluster | near | type1 | synth
    schema: dict
    build: callable      # () -> prompt; synth needs earlier results
    subject: list = field(default_factory=list)
    normalize: callable = None   # answer -> stored answer (after validation)


def load(country):
    pre = json.loads((PREPASS / f'{country}.json').read_text())
    specs = json.loads((SPECS / f'{country}.json').read_text())['specs']
    return pre, {s['id']: s for s in specs}


# Near misses differing in these can never be TYPE 2: the number of cells
# does not change alphabets, groups, colours, labels or vehicle type. They are
# decided here instead of asking the model.
NEAR_FIXED = {'registers', 'direction', 'vehicle', 'restrictions', 'ink', 'countryPanel',
              'labels', 'mirrors', 'bands', 'decals'}


def fixed_results(pre):
    out = {}
    for n in pre['type2']['nearMisses']:
        if n['attribute'] in NEAR_FIXED:
            out[n['id']] = {'unit': n['id'], 'kind': 'near', 'subject': n['a'] + n['b'], 'status': 'ok',
                            'fixed': True, 'conflicts': [],
                            'answer': {'verdict': 'keep_separate', 'risks': [],
                                       'reason': f'differ in {n["attribute"]}, which cell count cannot explain '
                                                 '(decided by the prepass)'}}
    return out


def make_units(country, pre, specs_by_id, settings, results):
    hint = validator_hint(country, 4000)
    units = []
    for c in pre['type2']['clusters']:
        units.append(Unit(c['id'], 'cluster', CLUSTER_SCHEMA,
                          lambda c=c: cluster_prompt(country, c, specs_by_id, hint), c['members']))
    asked = [n for n in pre['type2']['nearMisses'] if n['attribute'] not in NEAR_FIXED]
    for n in asked[:settings.max_near_misses]:
        units.append(Unit(n['id'], 'near', NEAR_SCHEMA,
                          lambda n=n: near_prompt(country, n, specs_by_id), n['a'] + n['b']))
    hint1 = validator_hint(country, 1500)
    for t1 in pre['type1']:
        if not t1['softBoundaries']:
            continue  # every boundary is hard: nothing to decide
        spec = specs_by_id[t1['id']]
        units.append(Unit(f'T1-{t1["id"]}', 'type1', type1_schema(t1),
                          lambda s=spec, t=t1: type1_prompt(country, pre['package'], s, t, hint1), [t1['id']],
                          normalize=lambda a, t=t1: type1_normalize(t, a)))
    units.append(Unit('SYNTH', 'synth', SYNTH_SCHEMA, lambda: synth_prompt(country, pre, results)))
    return units


# ---------------------------------------------------------------- conflict guard

def conflicts(unit, answer, pre):
    """Where the model contradicts the prepass facts."""
    out = []
    ids = {s['id'] for s in pre['specs']}
    if unit.kind == 'cluster':
        c = next(c for c in pre['type2']['clusters'] if c['id'] == unit.id)
        ex = answer['excludeMembers']
        for m in ex:
            if m not in c['members']:
                out.append(f'excludes "{m}", which is not a cluster member')
        if answer['verdict'] == 'one_structure' and ex:
            out.append(f'verdict one_structure but excludes {ex}')
        if answer['verdict'] == 'partial' and not 0 < len(set(ex) & set(c['members'])) <= len(c['members']) - 2:
            out.append(f'verdict partial must exclude some members and keep at least two (excludes {ex})')
    elif unit.kind == 'near' and answer['verdict'] == 'merge':
        n = next(n for n in pre['type2']['nearMisses'] if n['id'] == unit.id)
        if n['attribute'] in NEAR_FIXED:
            out.append(f'proposes merging specs whose signature differs in "{n["attribute"]}" '
                       '(alphabet/group/direction/vehicle/validation structure)')
    elif unit.kind == 'type1':
        t1 = next(t for t in pre['type1'] if t['id'] == unit.subject[0])
        if answer['id'] != t1['id']:
            out.append(f'answer is for "{answer["id"]}", not "{t1["id"]}"')
        soft = {tuple(b['between']) for b in t1['softBoundaries']}
        hard = {tuple(h['between']): h['reasons'] for h in t1['hardSplits']}
        seen = set()
        for b in answer['boundaries']:
            pair = tuple(b['between'])
            seen.add(pair)
            if pair in hard and b['decision'] == 'merge':
                out.append(f'merges {list(pair)} across a hard boundary ({"; ".join(hard[pair])})')
            elif pair not in soft and pair not in hard:
                out.append(f'{list(pair)} is not a boundary of this spec')
        missing = soft - seen
        if missing:
            out.append(f'soft boundaries left undecided (default used): {sorted(map(list, missing))}')
    return out


# ---------------------------------------------------------------- running

def schema_stamp(unit):
    """Cached answers are reused only while the unit's schema is unchanged."""
    return hashlib.sha1(json.dumps(unit.schema, sort_keys=True).encode()).hexdigest()[:12]


def unit_cache(country, unit_id):
    return UNITS / country / f'{unit_id}.json'


def run_unit(unit, pre, settings, sink, country):
    prompt = unit.build()
    tokens = approx_tokens(prompt)
    sink.log(f'[{country}] {unit.id} ({unit.kind}, {len(unit.subject)} subjects) prompt ≈{tokens} tokens')
    if tokens > TOKEN_BUDGET:
        sink.log(f'[{country}] {unit.id} WARNING prompt over the {TOKEN_BUDGET}-token target')
    sink.prompt(f'===== {country} / {unit.id}\n{prompt}\n')
    messages = [{'role': 'user', 'content': prompt}]
    error = None
    for attempt in range(settings.retries + 1):
        if sink.stop_requested():
            raise Stopped()
        t0 = time.time()
        try:
            text = chat(settings, messages, unit.schema, sink)
        except (urllib.error.URLError, RuntimeError, TimeoutError, OSError) as e:
            error = f'request failed: {e}'
            sink.log(f'[{country}] {unit.id} attempt {attempt + 1}: {error}')
            continue
        dt = time.time() - t0
        try:
            answer = json.loads(text)
            errs = validate(answer, unit.schema)
        except json.JSONDecodeError as e:
            answer, errs = None, [f'invalid JSON: {e}']
        if not errs:
            if unit.normalize:
                answer = unit.normalize(answer)
            c = conflicts(unit, answer, pre)
            sink.log(f'[{country}] {unit.id} ok in {dt:.1f}s'
                     + (f'; {len(c)} CONFLICT(s) with prepass' if c else ''))
            return {'unit': unit.id, 'kind': unit.kind, 'subject': unit.subject, 'status': 'ok',
                    'answer': answer, 'conflicts': c, 'seconds': round(dt, 1), 'promptTokens': tokens,
                    'schema': schema_stamp(unit)}
        error = '; '.join(errs[:5])
        sink.log(f'[{country}] {unit.id} attempt {attempt + 1} invalid after {dt:.1f}s: {error}')
        messages += [{'role': 'assistant', 'content': text},
                     {'role': 'user', 'content': f'Your answer did not validate: {error}. '
                                                 'Reply again with only JSON matching the schema.'}]
    return {'unit': unit.id, 'kind': unit.kind, 'subject': unit.subject, 'status': 'failed',
            'error': error, 'promptTokens': tokens}


def run_country(country, settings, sink, redo_failed_only=False):
    """Run every unit, reusing cached successes; write the report at the end."""
    pre, specs_by_id = load(country)
    results = fixed_results(pre)
    units = make_units(country, pre, specs_by_id, settings, results)
    (UNITS / country).mkdir(parents=True, exist_ok=True)
    sink.log(f'[{country}] {len(units)} units: '
             f'{sum(u.kind == "cluster" for u in units)} clusters, {sum(u.kind == "near" for u in units)} near-misses, '
             f'{sum(u.kind == "type1" for u in units)} type-1 specs, 1 synthesis; '
             f'{len(results)} near misses decided without the model')
    t0 = time.time()
    for unit in units:
        cache = unit_cache(country, unit.id)
        if cache.exists():
            cached = json.loads(cache.read_text())
            if cached['status'] == 'ok' and unit.kind != 'synth' and cached.get('schema') == schema_stamp(unit):
                results[unit.id] = cached
                sink.log(f'[{country}] {unit.id} cached')
                continue
        result = run_unit(unit, pre, settings, sink, country)
        results[unit.id] = result
        cache.write_text(json.dumps(result, indent=1, ensure_ascii=False))
    write_report(country, pre, results, settings)
    failed = sum(r['status'] != 'ok' for r in results.values())
    line = (f'{time.strftime("%Y-%m-%d %H:%M:%S")} {country} model={settings.model} units={len(results)} '
            f'failed={failed} seconds={time.time() - t0:.0f}')
    with PROGRESS.open('a') as f:
        f.write(line + '\n')
    write_index()
    sink.log(f'[{country}] report written ({failed} failed units)')
    return failed


def reset_country(country):
    for p in (UNITS / country).glob('*.json'):
        p.unlink()


def countries():
    return sorted(p.stem for p in PREPASS.glob('*.json')) or sorted(p.stem for p in SPECS.glob('*.json'))


def report_status(country):
    p = REPORTS / f'{country}.json'
    if not p.exists():
        return None
    try:
        return json.loads(p.read_text()).get('failedUnits', 0)
    except (json.JSONDecodeError, OSError):
        return None


def rebuild(sink, countries_=None):
    """Regenerate the registry, run the Dart dump and the prepass."""
    steps = [
        (['python3', 'analyzer/gen_registry.py'], TOOL),
        (['flutter', 'pub', 'get'], TOOL),
        (['flutter', 'test', 'dump_specs.dart'], TOOL),
        (['python3', 'analyzer/prepass.py', *(countries_ or [])], TOOL),
    ]
    for cmd, cwd in steps:
        if sink.stop_requested():
            raise Stopped()
        sink.log('$ ' + ' '.join(cmd))
        proc = subprocess.Popen(cmd, cwd=cwd, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True)
        for line in proc.stdout:
            sink.log(line.rstrip())
        if proc.wait() != 0:
            sink.log(f'step failed with exit code {proc.returncode}')
            return False
    return True


# ---------------------------------------------------------------- reports

def _md_escape(s):
    return str(s).replace('|', '\\|').replace('\n', ' ')


def write_report(country, pre, results, settings):
    REPORTS.mkdir(parents=True, exist_ok=True)
    failed = [r for r in results.values() if r['status'] != 'ok']
    all_conflicts = [(r['unit'], c) for r in results.values() if r['status'] == 'ok' for c in r['conflicts']]
    payload = {'country': country, 'model': settings.model, 'generated': time.strftime('%Y-%m-%d %H:%M:%S'),
               'failedUnits': len(failed), 'conflicts': len(all_conflicts), 'prepass': pre, 'units': results}
    (REPORTS / f'{country}.json').write_text(json.dumps(payload, indent=1, ensure_ascii=False))
    (REPORTS / f'{country}.md').write_text(render_markdown(country, pre, results, settings, failed, all_conflicts))


def _model(results, uid):
    r = results.get(uid)
    if not r:
        return None, '_not run_'
    if r['status'] != 'ok':
        return None, f'_model failed: {_md_escape(r.get("error"))}_'
    return r['answer'], ''


def _conflict_lines(results, uid):
    r = results.get(uid)
    return [f'> **CONFLICT** (model vs prepass, prepass wins): {c}' for c in (r or {}).get('conflicts', [])]


def render_markdown(country, pre, results, settings, failed, all_conflicts):
    L = [f'# Migration report — {country}', '',
         f'Package `{pre["package"]}` · model `{settings.model}` · generated {time.strftime("%Y-%m-%d %H:%M")}', '',
         'Tables are prepass facts (deterministic). Text under **Model** is advisory LLM commentary; '
         '**CONFLICT** marks where it contradicts the facts.', '']
    if failed or all_conflicts:
        L += [f'**{len(failed)} failed unit(s), {len(all_conflicts)} conflict(s).**', '']
    if pre['warnings']:
        L += ['**Dump warnings (specs possibly unreached):**', ''] + [f'- {_md_escape(w)}' for w in pre['warnings']] + ['']

    L += ['## 1. Current specs', '', '| id | slots | groups | vehicle | clone of |', '|---|---|---|---|---|']
    for s in pre['specs']:
        L.append(f'| `{s["id"]}` | {s["slots"]} | {" ".join(s["groups"])} | {s["vehicle"]} | {s["cloneOf"] or ""} |')

    L += ['', '## 2. TYPE 1 plan', '']
    L += ['Brackets are input fields (one FocusNode each). Hard splits are certain; soft boundaries '
          'are decided by the model, or by the geometric default where it gave no answer.', '']
    for t in pre['type1']:
        uid = f'T1-{t["id"]}'
        _, err = _model(results, uid)
        plan, n_fields, who, ans = type1_plan(t, results)
        L.append(f'- `{t["id"]}`: {t["rendering"].split(" → ")[0]} → **{plan}** '
                 f'({t["slotCount"]} slots → {n_fields} fields, {who})')
        for h in t['hardSplits']:
            L.append(f'  - hard split {h["between"]}: {"; ".join(h["reasons"])}')
        for seg in t['segments']:
            if seg['caveats']:
                L.append(f'  - segment {seg["indices"][0]}..{seg["indices"][-1]}: {"; ".join(seg["caveats"])}')
        if ans:
            defaults = {tuple(b['between']): b['default'] for b in t['softBoundaries']}
            for b in ans['boundaries']:
                flag = ' (overrides default — check)' if defaults.get(tuple(b['between'])) != b['decision'] else ''
                L.append(f'  - **Model** {b["between"]} {b["decision"]}{flag}: {_md_escape(b["reason"])}')
            if ans['notes']:
                L.append(f'  - **Model notes:** {_md_escape(ans["notes"])}')
        elif t['softBoundaries'] and uid in results:
            L.append(f'  - {err}')
        L += _conflict_lines(results, uid)

    dups = pre.get('gallery', {}).get('duplicates', [])
    L += ['', '## 2b. Gallery duplicates', '']
    if not dups:
        L.append('None: every gallery entry differs in spec, theme, panel country or validator.')
    for d in dups:
        L.append(f'- spec `{d["specId"]}`, theme {d["themeColors"]}: '
                 + ', '.join(f'`{e["id"]}` ({_md_escape(e["label"])})' for e in d['entries'])
                 + f' — {_md_escape(d["reason"])}')

    L += ['', '## 3. TYPE 2 plan', '']
    clusters = pre['type2']['clusters']
    if not clusters:
        L.append('No clusters: no two specs share a structure signature.')
    for c in clusters:
        ans, err = _model(results, c['id'])
        L += [f'### {c["id"]} — {c["confidence"]} ({_md_escape(c["confidenceNote"])})', '',
              f'Members: {", ".join(f"`{m}`" for m in c["members"])}', '',
              '| register | min | max | observed |', '|---|---|---|---|']
        L += [f'| {r["group"]} | {r["min"]} | {r["max"]} | {r["observed"]} |' for r in c['registers']]
        if c['observedCombinations']:
            L += ['', f'Observed combinations of varying registers: {c["observedCombinations"]} — '
                      'independent ranges would admit more.']
        if c['differs']:
            L += ['', 'Differs between members:']
            L += [f'- `{k}`: {_md_escape(json.dumps(v, ensure_ascii=False))}' for k, v in c['differs'].items()]
        L += ['', 'Catalogue paths that resolve to these ids:']
        L += [f'- `{m}`: {", ".join(p)}' for m, p in c['catalogues'].items()]
        L.append('')
        if ans:
            L += [f'**Model:** verdict `{ans["verdict"]}`, unified id `{ans["unifiedId"]}`. '
                  f'{_md_escape(ans["reason"])}']
            for label, key in (('Exclude', 'excludeMembers'), ('Risks', 'risks')):
                if ans[key]:
                    L.append(f'- {label}: ' + '; '.join(_md_escape(x) for x in ans[key]))
        else:
            L.append(err)
        L += _conflict_lines(results, c['id']) + ['']

    near = pre['type2']['nearMisses']
    if near:
        L += ['### Near misses (signature differs in one attribute)', '',
              '| id | a | b | attribute | model |', '|---|---|---|---|---|']
        for n in near:
            ans, err = _model(results, n['id'])
            model = f'{ans["verdict"]}: {_md_escape(ans["reason"])}' if ans else err
            if results.get(n['id'], {}).get('fixed'):
                model = model.replace(' (decided by the prepass)', '') + ' _(prepass)_'
            if results.get(n['id'], {}).get('conflicts'):
                model = '**CONFLICT** ' + model
            L.append(f'| {n["id"]} | {", ".join(n["a"])} | {", ".join(n["b"])} | {n["attribute"]} | {model} |')

    synth, err = _model(results, 'SYNTH')
    L += ['', '## 4. Specs that must stay separate', '',
          f'Singletons by signature (prepass): {", ".join(f"`{s}`" for s in pre["type2"]["singletons"]) or "none"}', '']
    L += ['', '## 5. Knock-on impact', '',
          f'Validator files: {", ".join(f"`{v}`" for v in pre["validatorFiles"]) or "none"}', '']
    lookups = sorted({p.split('[')[0] for s in pre['specs'] for p in s['catalogues']})
    L += [f'Catalogue members exposing these specs: {", ".join(f"`{x}`" for x in lookups)}', '']
    if synth:
        L += [f'- **Model** ({_md_escape(k["area"])}): {_md_escape(k["note"])}' for k in synth['knockOn']]
    L += ['', '## 6. Open questions', '']
    if synth:
        L += [f'- {_md_escape(q)}' for q in synth['openQuestions']]
        L += ['', f'**Model summary:** {_md_escape(synth["summary"])}']
    else:
        L.append(err)
    L += _conflict_lines(results, 'SYNTH')
    if failed:
        L += ['', '## Failed units', ''] + [f'- {r["unit"]}: {_md_escape(r.get("error"))}' for r in failed]
    return '\n'.join(L) + '\n'


def write_index():
    REPORTS.mkdir(parents=True, exist_ok=True)
    L = ['# Migration reports', '', '| country | specs | type-1 merges | type-2 clusters | near misses | '
         'failed units | conflicts | model | generated |', '|---|---|---|---|---|---|---|---|---|']
    for p in sorted(REPORTS.glob('*.json')):
        d = json.loads(p.read_text())
        pre = d['prepass']
        L.append(f'| [{d["country"]}]({d["country"]}.md) | {len(pre["specs"])} | '
                 f'{sum(t["mergeableRuns"] for t in pre["type1"])} | {len(pre["type2"]["clusters"])} | '
                 f'{len(pre["type2"]["nearMisses"])} | {d["failedUnits"]} | {d["conflicts"]} | {d["model"]} | '
                 f'{d["generated"]} |')
    (REPORTS / 'INDEX.md').write_text('\n'.join(L) + '\n')
