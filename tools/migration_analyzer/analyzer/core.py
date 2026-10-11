"""Everything the GUI and CLI share: Ollama client, work units, prompts,
validation, the conflict guard and report writing.

The prepass JSON is the source of truth. The model is asked small questions
about one unit at a time; its answers are stored next to the facts and checked
against them, never substituted for them.
"""

import json
import subprocess
import time
import urllib.error
import urllib.request
from dataclasses import dataclass, field
from pathlib import Path

TOOL = Path(__file__).resolve().parent.parent
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
    """Stream one /api/chat call; returns the full content string."""
    body = {
        'model': settings.model, 'messages': messages, 'stream': True, 'format': schema,
        'options': {'num_ctx': settings.num_ctx, 'temperature': settings.temperature},
        'think': settings.think,
    }
    req = urllib.request.Request(settings.endpoint.rstrip('/') + '/api/chat',
                                 data=json.dumps(body).encode(), headers={'Content-Type': 'application/json'})
    parts = []
    with urllib.request.urlopen(req, timeout=settings.timeout) as r:
        for line in r:
            if sink.stop_requested():
                raise Stopped()
            if not line.strip():
                continue
            chunk = json.loads(line)
            if 'error' in chunk:
                raise RuntimeError(chunk['error'])
            msg = chunk.get('message', {})
            if msg.get('thinking'):
                sink.token(msg['thinking'])
            if msg.get('content'):
                parts.append(msg['content'])
                sink.token(msg['content'])
            if chunk.get('done'):
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
    'type': 'object', 'required': ['specs'],
    'properties': {'specs': _arr({
        'type': 'object', 'required': ['id', 'agree', 'exceptions', 'extraMerges', 'notes'],
        'properties': {
            'id': STR, 'agree': BOOL, 'notes': STR,
            'exceptions': _arr({'type': 'object', 'required': ['indices', 'reason'],
                                'properties': {'indices': _arr(INT), 'reason': STR}}),
            'extraMerges': _arr({'type': 'object', 'required': ['indices', 'reason'],
                                 'properties': {'indices': _arr(INT), 'reason': STR}}),
        }})},
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
TYPE 1 - merge adjacent slots. Today every character is its own slot. Contiguous slots in the same text group, with the same alphabet, adjacent and evenly pitched, become ONE input field with length n (e.g. Iran "9 8 ه 8 8 6 4 0" -> [98][ه][886][40]). A run must stay split only for a real reason: a visual divider, a different box style, a label between cells, a mirror that depends on per-cell geometry.
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
        'type1': {'rendering': t1['rendering'],
                  'runs': [{'group': r['group'], 'indices': [r['indices'][0], r['indices'][-1]],
                            'length': r['proposedLength'], 'caveats': r['caveats']} for r in t1['runs']],
                  'refused': t1['refused']},
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
        m = compact_spec(specs_by_id[i], {'rendering': '', 'runs': [], 'refused': []})
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
             'a': compact_spec(specs_by_id[near['a'][0]], {'rendering': '', 'runs': [], 'refused': []}),
             'b': compact_spec(specs_by_id[near['b'][0]], {'rendering': '', 'runs': [], 'refused': []})}
    facts['a'].pop('type1')
    facts['b'].pop('type1')
    return (f'{BACKGROUND}\n\nCountry: {country}. NEAR MISS: two spec groups whose signatures differ in exactly '
            f'one attribute ("{near["attribute"]}").\nFACTS:\n{json.dumps(facts, ensure_ascii=False)}\n\n'
            'Judge: should they become one TYPE 2 spec despite that difference (verdict merge), stay separate, '
            'or is it unclear? Give the reason and risks.')


def type1_prompt(country, batch):
    return (f'{BACKGROUND}\n\nCountry: {country}. TYPE 1 review of these specs. "runs" are the merges the '
            f'analysis proposes; "refused" are boundaries it would keep.\nFACTS:\n'
            f'{json.dumps(batch, ensure_ascii=False)}\n\n'
            'For each spec: agree (true) if the proposed runs are right. List exceptions: proposed runs that '
            'must stay split (give their slot indices and why). List extraMerges only if a refused boundary '
            'should merge anyway. One entry per spec id.')


def synth_prompt(country, pre, results):
    brief = {
        'specs': [{'id': s['id'], 'groups': s['groups'], 'vehicle': s['vehicle'], 'catalogues': s['catalogues'][:3]}
                  for s in pre['specs']],
        'clusters': [{'id': c['id'], 'members': c['members'], 'confidence': c['confidence'],
                      'model': results.get(c['id'], {}).get('answer')} for c in pre['type2']['clusters']],
        'nearMisses': [{'id': n['id'], 'attribute': n['attribute'],
                        'model': results.get(n['id'], {}).get('answer', {}).get('verdict')}
                       for n in pre['type2']['nearMisses'][:20]],
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
    batch, size, k = [], 0, 0
    for t1 in pre['type1']:
        item = compact_spec(specs_by_id[t1['id']], t1)
        cost = approx_tokens(json.dumps(item, ensure_ascii=False))
        if batch and (size + cost > FACT_BUDGET or len(batch) >= 4):
            k += 1
            units.append(Unit(f'T1-{k}', 'type1', TYPE1_SCHEMA, lambda b=batch: type1_prompt(country, b),
                              [b['id'] for b in batch]))
            batch, size = [], 0
        batch.append(item)
        size += cost
    if batch:
        k += 1
        units.append(Unit(f'T1-{k}', 'type1', TYPE1_SCHEMA, lambda b=batch: type1_prompt(country, b),
                          [b['id'] for b in batch]))
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
        t1 = {t['id']: t for t in pre['type1']}
        for s in answer['specs']:
            if s['id'] not in t1:
                out.append(f'unknown spec id "{s["id"]}"')
                continue
            runs = [set(r['indices']) for r in t1[s['id']]['runs']]
            for e in s['exceptions']:
                if not any(set(e['indices']) <= r for r in runs):
                    out.append(f'{s["id"]}: exception {e["indices"]} is not inside a proposed run')
            for e in s['extraMerges']:
                runs_hit = [r for r in t1[s['id']]['runs'] if set(r['indices']) & set(e['indices'])]
                if len({r['alphabet'] for r in runs_hit}) > 1 or len({r['group'] for r in runs_hit}) > 1:
                    out.append(f'{s["id"]}: extra merge {e["indices"]} crosses alphabets or text groups')
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
    t1_answers = {}
    for r in results.values():
        if r['kind'] == 'type1' and r['status'] == 'ok':
            for s in r['answer']['specs']:
                t1_answers[s['id']] = (s, r['unit'])
    for t in pre['type1']:
        L.append(f'- `{t["id"]}`: {t["rendering"]}  ({t["slotCount"]} slots → {t["fieldCount"]} fields)')
        for x in t['refused']:
            L.append(f'  - kept split between {x["between"]} ({x["group"]}): {"; ".join(x["reasons"])}')
        for r in t['runs']:
            if r['caveats']:
                L.append(f'  - run {r["indices"][0]}..{r["indices"][-1]}: {"; ".join(r["caveats"])}')
        ans = t1_answers.get(t['id'])
        if ans:
            s, uid = ans
            if not s['agree'] or s['exceptions'] or s['extraMerges'] or s['notes']:
                L.append(f'  - **Model:** {"agrees" if s["agree"] else "disagrees"}. {_md_escape(s["notes"])}')
                for e in s['exceptions']:
                    L.append(f'    - exception {e["indices"]}: {_md_escape(e["reason"])}')
                for e in s['extraMerges']:
                    L.append(f'    - extra merge {e["indices"]}: {_md_escape(e["reason"])}')
    for r in results.values():
        if r['kind'] == 'type1':
            if r['status'] != 'ok':
                L.append(f'- _model failed for {", ".join(r["subject"])}: {_md_escape(r.get("error"))}_')
            L += _conflict_lines(results, r['unit'])

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
