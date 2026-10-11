"""Everything the GUI and CLI share: Ollama client, work units, prompts,
validation, the conflict guard and report writing.

The prepass JSON is the source of truth. The model is asked small questions
about one unit at a time; its answers are stored next to the facts and checked
against them, never substituted for them.
"""

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
    'type': 'object',
    'required': ['verdict', 'unifiedId', 'registers', 'excludeMembers', 'preserve', 'lostOnMerge', 'risks', 'notes'],
    'properties': {
        'verdict': {'type': 'string', 'enum': ['one_structure', 'partial', 'keep_separate']},
        'unifiedId': STR,
        'registers': _arr({'type': 'object', 'required': ['group', 'min', 'max'],
                           'properties': {'group': STR, 'min': INT, 'max': INT}}),
        'excludeMembers': _arr(STR), 'preserve': _arr(STR), 'lostOnMerge': _arr(STR),
        'risks': _arr(STR), 'notes': STR,
    },
}

NEAR_SCHEMA = {
    'type': 'object', 'required': ['verdict', 'reason', 'risks'],
    'properties': {'verdict': {'type': 'string', 'enum': ['merge', 'keep_separate', 'unclear']},
                   'reason': STR, 'risks': _arr(STR)},
}

TYPE1_SCHEMA = {
    'type': 'object', 'required': ['id', 'boundaries', 'notes'],
    'properties': {
        'id': STR, 'notes': STR,
        'boundaries': _arr({'type': 'object', 'required': ['between', 'decision', 'reason'],
                            'properties': {'between': _arr(INT),
                                           'decision': {'type': 'string', 'enum': ['merge', 'split']},
                                           'reason': STR}}),
    },
}

SYNTH_SCHEMA = {
    'type': 'object', 'required': ['summary', 'mustStaySeparate', 'knockOn', 'openQuestions'],
    'properties': {
        'summary': STR,
        'mustStaySeparate': _arr({'type': 'object', 'required': ['id', 'reason'],
                                  'properties': {'id': STR, 'reason': STR}}),
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

The migration:
TYPE 1 - merge adjacent slots. Today every character is its own slot with its own FocusNode. Neighbouring cells that a person reads as one group become ONE input field (one FocusNode) holding n characters, e.g. Iran "9 8 ه 8 8 6 ایران 4 0" -> [98][ه][886][40].
Hard boundaries are certain splits and are already applied: different line, a divider, a label/rule/decal between cells, alphabet or ink change.
Soft boundaries are your judgement. Padding between cells is NOT a reason to split by itself: teams often padded every cell. Decide from how the real plate is read and written (source comments, ids, validators, tests, sample values): if the characters form one number/register, merge; if they are distinct registers (e.g. a region code next to a serial), split.
TYPE 2 - variable-length fields. Specs that are the same plate and differ only in how many cells a register has collapse into ONE spec whose field accepts min..max characters. They must NOT be merged if they differ in anything else: panel, labels, rules, alphabets, mirrors, group keys, vehicle type, validators, or canvas proportions beyond what cell pitch explains.

Answer only with JSON matching the requested schema. Be concise; every string short."""


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
                  + 'Judge: is this truly one structure? Propose a unified spec id and per-register min/max '
                    '(registers must use the group keys above, and min/max must lie within observed counts). '
                    'List what must be preserved, what would be lost on merge (pitch/width rules, mirrors, rules, '
                    'labels, validators, catalogue lookups by id), risks, and any members to exclude.')
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
            'Judge: should they become one TYPE 2 spec despite that difference (verdict merge), stay separate, '
            'or is it unclear? Give the reason and risks.')


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


def type1_facts(t1):
    return {k: t1[k] for k in ('rendering', 'segments', 'hardSplits', 'softBoundaries')}


def type1_prompt(country, package, spec, t1, hint):
    facts = compact_spec(spec, type1_facts(t1))
    src, tests = spec_source(package, spec)
    body = (f'Country: {country}. TYPE 1 decision for spec "{spec["id"]}".\nFACTS:\n'
            f'{json.dumps(facts, ensure_ascii=False)}\n\n')
    tail = ('Decide EVERY soft boundary (copy its "between" pair): merge or split, with a short reason. '
            '"default" is only a guess from geometry. Do not list hard splits; they are fixed.')
    extra = ''
    if src:
        extra += f'SPEC SOURCE:\n{src}\n\n'
    if tests:
        extra += 'TESTS MENTIONING IT:\n' + '\n'.join(tests) + '\n\n'
    prompt = f'{BACKGROUND}\n\n{body}{extra}' + (f'VALIDATOR SOURCE (hint):\n{hint}\n\n' if hint else '') + tail
    if approx_tokens(prompt) > TOKEN_BUDGET:
        prompt = f'{BACKGROUND}\n\n{body}{extra}{tail}'
    return prompt


def synth_prompt(country, pre, results):
    brief = {
        'specs': [{'id': s['id'], 'groups': s['groups'], 'vehicle': s['vehicle'], 'catalogues': s['catalogues'][:3]}
                  for s in pre['specs']],
        'clusters': [{'id': c['id'], 'members': c['members'], 'confidence': c['confidence'],
                      'model': results.get(c['id'], {}).get('answer')} for c in pre['type2']['clusters']],
        'nearMisses': [{'id': n['id'], 'attribute': n['attribute'],
                        'model': results.get(n['id'], {}).get('answer', {}).get('verdict')}
                       for n in pre['type2']['nearMisses'][:20]],
        'galleryDuplicates': [[e['id'] for e in d['entries']] for d in pre.get('gallery', {}).get('duplicates', [])],
        'warnings': pre['warnings'][:10],
        'validatorFiles': pre['validatorFiles'],
    }
    text = json.dumps(brief, ensure_ascii=False)
    if approx_tokens(text) > FACT_BUDGET:
        for c in brief['clusters']:
            if c['model']:
                c['model'] = {k: c['model'].get(k) for k in ('verdict', 'unifiedId', 'registers')}
        brief['specs'] = [s['id'] for s in pre['specs']]
        text = json.dumps(brief, ensure_ascii=False)
    return (f'{BACKGROUND}\n\nCountry: {country}. Synthesis from the unit results below.\nFACTS:\n{text}\n\n'
            'Write: a short summary; specs that must stay separate and why; knock-on impact (areas: validators, '
            'serial generators (draw order / seeded reproducibility), catalogue lookups such as byDigits or car/moto '
            'maps, themes/country coupling, example/gallery usage); open questions for the human.')


# ---------------------------------------------------------------- units

@dataclass
class Unit:
    id: str
    kind: str            # cluster | near | type1 | synth
    schema: dict
    build: callable      # () -> prompt; synth needs earlier results
    subject: list = field(default_factory=list)


def load(country):
    pre = json.loads((PREPASS / f'{country}.json').read_text())
    specs = json.loads((SPECS / f'{country}.json').read_text())['specs']
    return pre, {s['id']: s for s in specs}


def make_units(country, pre, specs_by_id, settings, results):
    hint = validator_hint(country, 4000)
    units = []
    for c in pre['type2']['clusters']:
        units.append(Unit(c['id'], 'cluster', CLUSTER_SCHEMA,
                          lambda c=c: cluster_prompt(country, c, specs_by_id, hint), c['members']))
    for n in pre['type2']['nearMisses'][:settings.max_near_misses]:
        units.append(Unit(n['id'], 'near', NEAR_SCHEMA,
                          lambda n=n: near_prompt(country, n, specs_by_id), n['a'] + n['b']))
    hint1 = validator_hint(country, 1500)
    for t1 in pre['type1']:
        if not t1['softBoundaries']:
            continue  # every boundary is hard: nothing to decide
        spec = specs_by_id[t1['id']]
        units.append(Unit(f'T1-{t1["id"]}', 'type1', TYPE1_SCHEMA,
                          lambda s=spec, t=t1: type1_prompt(country, pre['package'], s, t, hint1), [t1['id']]))
    units.append(Unit('SYNTH', 'synth', SYNTH_SCHEMA, lambda: synth_prompt(country, pre, results)))
    return units


# ---------------------------------------------------------------- conflict guard

def conflicts(unit, answer, pre):
    """Where the model contradicts the prepass facts."""
    out = []
    ids = {s['id'] for s in pre['specs']}
    if unit.kind == 'cluster':
        c = next(c for c in pre['type2']['clusters'] if c['id'] == unit.id)
        regs = {r['group']: r for r in c['registers']}
        for r in answer['registers']:
            fact = regs.get(r['group'])
            if not fact:
                out.append(f'register "{r["group"]}" is not a group of this cluster')
            elif r['min'] < fact['min'] or r['max'] > fact['max'] or r['min'] > r['max']:
                out.append(f'register "{r["group"]}" {r["min"]}..{r["max"]} outside observed '
                           f'{fact["min"]}..{fact["max"]}')
        for m in answer['excludeMembers']:
            if m not in c['members']:
                out.append(f'excludes "{m}", which is not a cluster member')
    elif unit.kind == 'near' and answer['verdict'] == 'merge':
        n = next(n for n in pre['type2']['nearMisses'] if n['id'] == unit.id)
        if n['attribute'] in ('registers', 'direction', 'vehicle', 'restrictions'):
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
    elif unit.kind == 'synth':
        for s in answer['mustStaySeparate']:
            if s['id'] not in ids:
                out.append(f'mustStaySeparate names unknown spec "{s["id"]}"')
    return out


# ---------------------------------------------------------------- running

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
            c = conflicts(unit, answer, pre)
            sink.log(f'[{country}] {unit.id} ok in {dt:.1f}s'
                     + (f'; {len(c)} CONFLICT(s) with prepass' if c else ''))
            return {'unit': unit.id, 'kind': unit.kind, 'subject': unit.subject, 'status': 'ok',
                    'answer': answer, 'conflicts': c, 'seconds': round(dt, 1), 'promptTokens': tokens}
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
    results = {}
    units = make_units(country, pre, specs_by_id, settings, results)
    (UNITS / country).mkdir(parents=True, exist_ok=True)
    sink.log(f'[{country}] {len(units)} units: '
             f'{sum(u.kind == "cluster" for u in units)} clusters, {sum(u.kind == "near" for u in units)} near-misses, '
             f'{sum(u.kind == "type1" for u in units)} type-1 batches, 1 synthesis')
    t0 = time.time()
    for unit in units:
        cache = unit_cache(country, unit.id)
        if cache.exists():
            cached = json.loads(cache.read_text())
            if cached['status'] == 'ok' and unit.kind != 'synth':
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
        ans, err = _model(results, uid)
        order = [(0, i) for seg in t['segments'] for i in seg['indices']]
        decisions = {tuple(b['between']): b['default'] for b in t['softBoundaries']}
        if ans:
            decisions.update({tuple(b['between']): b['decision'] for b in ans['boundaries']
                              if tuple(b['between']) in decisions})
        fields = fields_from(order, decisions, t['hardSplits'])
        plan = ''.join('[' + ''.join(t['chars'].get(str(i), '?') for i in f) + ']' for f in fields)
        who = 'model' if ans else 'default'
        L.append(f'- `{t["id"]}`: {t["rendering"].split(" → ")[0]} → **{plan}** '
                 f'({t["slotCount"]} slots → {len(fields)} fields, {who})')
        for h in t['hardSplits']:
            L.append(f'  - hard split {h["between"]}: {"; ".join(h["reasons"])}')
        for seg in t['segments']:
            if seg['caveats']:
                L.append(f'  - segment {seg["indices"][0]}..{seg["indices"][-1]}: {"; ".join(seg["caveats"])}')
        if ans:
            for b in ans['boundaries']:
                L.append(f'  - **Model** {b["between"]} {b["decision"]}: {_md_escape(b["reason"])}')
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
            L += [f'**Model:** verdict `{ans["verdict"]}`, unified id `{ans["unifiedId"]}`, registers '
                  + ', '.join(f'{r["group"]} {r["min"]}..{r["max"]}' for r in ans['registers'])]
            for label, key in (('Preserve', 'preserve'), ('Lost on merge', 'lostOnMerge'),
                               ('Risks', 'risks'), ('Exclude', 'excludeMembers')):
                if ans[key]:
                    L.append(f'- {label}: ' + '; '.join(_md_escape(x) for x in ans[key]))
            if ans['notes']:
                L.append(f'- Notes: {_md_escape(ans["notes"])}')
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
            if results.get(n['id'], {}).get('conflicts'):
                model = '**CONFLICT** ' + model
            L.append(f'| {n["id"]} | {", ".join(n["a"])} | {", ".join(n["b"])} | {n["attribute"]} | {model} |')

    synth, err = _model(results, 'SYNTH')
    L += ['', '## 4. Specs that must stay separate', '',
          f'Singletons by signature (prepass): {", ".join(f"`{s}`" for s in pre["type2"]["singletons"]) or "none"}', '']
    if synth:
        L += [f'- **Model:** `{s["id"]}` — {_md_escape(s["reason"])}' for s in synth['mustStaySeparate']]
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
