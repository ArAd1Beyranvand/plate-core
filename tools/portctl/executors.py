"""The three workers: shell/python functions, ollama (qwen) and `claude -p`. Every one streams what it
does through `log(source, text)` so the GUI shows it as it happens."""
import json, os, re, signal, subprocess, threading, time, urllib.request
from pathlib import Path

import config as C
import plan
from context import compact_error, dart_block, tokens


# ---- shell ----------------------------------------------------------------------------------

def sh(cmd, cwd, log, timeout=C.ORACLE_TIMEOUT, source='python'):
    """Runs a shell command, streaming each line. Returns (ok, full output)."""
    log(source, f'$ {cmd}   (in {cwd})')
    p = subprocess.Popen(cmd, shell=True, cwd=str(cwd), stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
                         text=True, bufsize=1, start_new_session=True)
    out, start = [], time.time()
    for line in p.stdout:
        out.append(line)
        log(source, line.rstrip('\n'))
        if time.time() - start > timeout:
            os.killpg(p.pid, signal.SIGKILL)
            out.append(f'\n[portctl] timeout after {timeout}s\n')
            break
    p.wait()
    log(source, f'exit {p.returncode} · {time.time() - start:.1f}s')
    return p.returncode == 0, ''.join(out)


def contract(lang):
    c = plan.lang_contract(lang)
    return {'oracle_all': C.ORACLE_ALL[lang], 'oracle_unit': C.ORACLE[lang].replace('{test}', '{unit_test}'),
            **c}


def unit_vars(dart_rel):
    """Names a unit's target paths are built from, for the portctl.json path templates."""
    parts = Path(dart_rel).parts
    pkg, stem = parts[0], Path(dart_rel).stem
    pascal = lambda s: ''.join(w[:1].upper() + w[1:] for w in s.split('_'))
    return {'pkg': pkg, 'country': pkg[:-len('_plate')], 'stem': stem, 'Stem': pascal(stem),
            'Country': pascal(pkg[:-len('_plate')]), 'dart': dart_rel}


def fill(template, v):
    return re.sub(r'\{(\w+)\}', lambda m: str(v.get(m.group(1), m.group(0))), template)


def oracle_all(lang, log):
    return sh(contract(lang)['oracle_all'], C.PORTS / lang, log, source='oracle')


def oracle_unit(lang, dart_rel, log):
    c, v = contract(lang), unit_vars(dart_rel)
    v['unit_test'] = fill(c.get('unit_test_path', '{stem}'), v)
    v['unit'] = fill(c.get('unit_path', '{stem}'), v)
    return sh(fill(c['oracle_unit'], v), C.PORTS / lang, log, source='oracle')


def unit_paths(lang, dart_rel):
    c, v = contract(lang), unit_vars(dart_rel)
    if 'unit_path' not in c:
        raise RuntimeError(f'ports/{lang}/portctl.json has no unit_path (written by s2.{lang}.setup)')
    return C.PORTS / lang / fill(c['unit_path'], v), C.PORTS / lang / fill(c.get('unit_test_path', ''), v)


# ---- python task functions ------------------------------------------------------------------
# fn(engine, task, log, **args) -> result dict; raise to fail the task.

HOLDER = C.ROOT / 'plate_number_holder'


def run_s1(eng, task, log):
    ok, out = sh('flutter test --no-pub test/port_export_test.dart test/port_vectors_test.dart', HOLDER, log,
                 timeout=1800)
    if not ok: raise RuntimeError(compact_error(out))
    return {'data': len(list((C.PORTS / 'data').rglob('*.json'))),
            'vectors': len(list((C.PORTS / 'vectors').rglob('*.json')))}


def validator_classes():
    out = {}
    for pkg, rel, fam in plan.units():
        for m in re.finditer(r'class (\w+) extends (?:Gated)?PlateValidator', (C.ROOT / rel).read_text('utf8')):
            out[m.group(1)] = rel
    return out


def check_s1(eng, task, log):
    bad = []
    for d in ('data', 'vectors'):
        files = list((C.PORTS / d).rglob('*.json'))
        log('python', f'{d}: {len(files)} json files')
        if not files: bad.append(f'ports/{d} is empty')
        for f in files:
            try: json.loads(f.read_text('utf8'))
            except Exception as e: bad.append(f'{f.relative_to(C.ROOT)}: {e}')
    # core_plate is a deprecated stub ("published by mistake"), not a country package.
    for pkg in sorted(p.name for p in C.ROOT.glob('*_plate') if (p / 'pubspec.yaml').exists() and p.name != 'core_plate'):
        if not (C.PORTS / 'data' / 'countries' / f'{pkg}.json').exists(): bad.append(f'no data for {pkg}')
    for cls, rel in validator_classes().items():
        f = C.PORTS / 'vectors' / 'validators' / f'{cls}.json'
        if not f.exists() or f.stat().st_size < 10: bad.append(f'no vectors for {cls} ({rel})')
    for b in bad[:200]: log('python', '  ✗ ' + b)
    if bad: raise RuntimeError(f'{len(bad)} problems; first: {bad[0]}')
    log('python', '✓ S1 output complete')
    return {'ok': True}


def run_codegen(eng, task, log):
    lang = task['lang']
    c = contract(lang)
    if 'codegen' not in c: raise RuntimeError(f'ports/{lang}/portctl.json has no "codegen" command')
    ok, out = sh(c['codegen'], C.PORTS / lang, log, timeout=1800)
    if not ok: raise RuntimeError(compact_error(out))
    # Stubs for unported units are expected to fail their own tests, so only a compile check gates here.
    if 'compile' in c:
        ok, out = sh(c['compile'], C.PORTS / lang, log, source='oracle')
        if not ok: raise RuntimeError(compact_error(out))
    return {'ok': True}


def decl_name(decl):
    m = re.search(r'\b(?:class|enum|mixin|extension|typedef)\s+(\w+)', decl) or \
        re.search(r'(\w+)\s*(?:<[^>]*>)?\s*(?:\(|=|;|\{)', decl)
    return m.group(1).lstrip('_') if m else ''


def snake(s):
    return re.sub(r'(?<!^)(?=[A-Z])', '_', s).lower()


def find_target(lang, name, span=60, stem=None):
    """The target-language code around the first definition of `name` (or its snake_case form)."""
    if not name: return None
    names = [re.escape(n) for n in {name, snake(name), name[:1].lower() + name[1:]}]
    pats = [re.compile(rf'\b(class|interface|type|enum|object|fun|function|def|const|val|var|let)\s+_?{n}\b')
            for n in names]
    # Members: TS `get rect()`, `  static parse(`, `  readonly width:`.
    pats += [re.compile(rf'^\s*(?:(?:public|private|protected|static|readonly|override|async|get|set|abstract)\s+)*'
                        rf'_?{n}\s*[(:<]') for n in names]
    root = C.PORTS / lang
    for f in sorted(root.rglob(f'*.{C.EXT[lang]}')):
        if any(p in f.parts for p in ('node_modules', 'build', '.gradle', '__pycache__', 'test', 'tests')): continue
        lines = f.read_text('utf8', errors='replace').split('\n')
        for i, l in enumerate(lines):
            if any(p.search(l) for p in pats):
                return str(f.relative_to(C.PORTS.parent)), '\n'.join(lines[max(0, i - 3):i + span])
    # Dart widgets are often ported under another name (class -> function); the same-named file still holds it.
    for f in [g for n in ({stem, ''.join(w.capitalize() for w in stem.split('_'))} if stem else ()) for g in sorted(root.rglob(f'{n}.{C.EXT[lang]}'))]:
        if any(p in f.parts for p in ('node_modules', 'build', '.gradle', '__pycache__', 'test', 'tests')): continue
        return str(f.relative_to(C.PORTS.parent)), '\n'.join(f.read_text('utf8', errors='replace').split('\n')[:150])
    return None


def expand_audit(eng, task, log, files):
    """One yes/no question per TODO(<lang>) in the Dart files a phase covered, plus a fix-list task
    that collects the "no" answers. Questions whose target can't be found go straight to the list."""
    lang, phase = task['lang'], task['phase']
    base = C.ROOT / 'plate_core' / 'lib' / 'src'
    qids = []
    for rel in files:
        # Bare names are under plate_core/lib/src; 'pkg/...' paths start at the repo root.
        path = (C.ROOT / rel if '/' in rel and (C.ROOT / rel.split('/')[0]).is_dir() else base / rel).resolve()
        for line, text, decl in plan.todos(path, lang):
            name = decl_name(decl)
            hit = find_target(lang, name, stem=path.stem)
            qid = f'{task["id"]}.q.{path.stem}.{line + 1}'
            dart_lines = path.read_text('utf8').split('\n')
            eng.store.add_task({
                'id': qid, 'phase': phase, 'lang': lang, 'kind': 'question', 'family': 'audit',
                'title': f'{path.name}:{line + 1} {name or decl[:30]} · {text[:60]}',
                'payload': {'dart': str(path.relative_to(C.ROOT)), 'line': line + 1, 'todo': text, 'decl': decl,
                            'name': name, 'dart_code': re.sub(r'(?m)^\s*// TODO\(\w+\):.*\n', '',
                                                                   dart_block(dart_lines, line + 1))[:2500],
                            'target': hit[0] if hit else None, 'target_code': hit[1] if hit else None}})
            qids.append(qid)
    eng.store.add_task({'id': f'{task["id"]}.fixlist', 'phase': phase, 'lang': lang, 'kind': 'fixlist',
                        'title': 'fix every "no" from the TODO audit', 'deps': qids, 'priority': -1,
                        'payload': {'template': 'fixlist', 'verify': 'compile'}})
    log('python', f'+ {len(qids)} audit questions, 1 fix-list task')
    return {'questions': len(qids)}


def expand_units(eng, task, log):
    lang, phase = task['lang'], task['phase']
    ids = []
    for pkg, rel, fam in plan.units():
        src = (C.ROOT / rel).read_text('utf8')
        uid = f's4.{lang}.u.{Path(rel).stem}'
        eng.store.add_task({'id': uid, 'phase': phase, 'lang': lang, 'kind': 'unit', 'family': fam,
                            'title': f'{rel} ({fam}, {src.count(chr(10))} lines)',
                            'payload': {'dart': rel}})
        ids.append(uid)
        # Units the codegen session already hand-ported are done, and are the first exemplars.
        target, _ = unit_paths(lang, rel)
        if target.exists() and 'not ported' not in target.read_text('utf8'):
            ok, _ = oracle_unit(lang, rel, log)
            if ok:
                eng.store.set_task(uid, status='done', route='exemplar')
                if len(eng.store.exemplars(fam, lang)) < C.EXEMPLARS_PER_FAMILY:
                    eng.store.add_exemplar(fam, lang, rel, target.read_text('utf8'))
                    log('python', f'★ exemplar for {fam}·{lang}: {rel}')
    eng.store.add_task({'id': f's4.{lang}.final', 'phase': phase, 'lang': lang, 'kind': 'python',
                        'title': 'full oracle over every country', 'deps': ids, 'priority': -2,
                        'payload': {'fn': 'verify_all', 'args': {}}})
    log('python', f'+ {len(ids)} units, 1 final verify')
    return {'units': len(ids)}


def verify_all(eng, task, log):
    ok, out = oracle_all(task['lang'], log)
    if not ok: raise RuntimeError(compact_error(out))
    return {'ok': True}


ARCH_SECTIONS = ('Current gallery', 'Reuse', 'Decisions', 'Registry', 'Protocol', 'Browser limits',
                 'Build and deploy', 'Migration', 'Open questions')


def check_arch(eng, task, log):
    """A0: WEB_ARCH.md has every section and W-decisions, and the two drafts exist."""
    f = C.ROOT / 'claude' / 'port' / 'WEB_ARCH.md'
    if not f.exists(): raise RuntimeError(f'{f.relative_to(C.ROOT)} does not exist')
    s = f.read_text(encoding='utf8')
    missing = [h for h in ARCH_SECTIONS if not re.search(rf'^## {h}\b', s, re.M)]
    if missing: raise RuntimeError(f'WEB_ARCH.md lacks sections: {", ".join(missing)}')
    if not re.search(r'\*\*W1\b', s): raise RuntimeError('WEB_ARCH.md has no **W1** decision')
    for d in ('components.schema.json', 'protocol.md'):
        if not (C.ROOT / 'claude' / 'port' / 'web' / d).exists(): raise RuntimeError(f'claude/port/web/{d} missing')
    json.loads((C.ROOT / 'claude' / 'port' / 'web' / 'components.schema.json').read_text())
    n = len(re.findall(r'\*\*W\d+', s))
    log('python', f'WEB_ARCH.md: {n} decisions')
    return {}


def web_smoke(eng, task, log, countries=('germany', 'india')):
    """S5 build: two countries build on their own, neither carries the other, the registry lists both."""
    lang, c = task['lang'], contract(task['lang'])
    for k in ('web_build', 'web_build_all', 'web_out'):
        if not c.get(k): raise RuntimeError(f'portctl.json has no "{k}"')
    for country in countries:
        ok, out = sh(c['web_build'].replace('{country}', country), C.PORTS / lang, log, timeout=1800)
        if not ok: raise RuntimeError(compact_error(out))
    out_dir = C.ROOT / c['web_out'] / 'components'
    for country in countries:
        d = out_dir / country / plan.WEB_LANG[lang]
        if not (d / 'index.html').exists(): raise RuntimeError(f'{d.relative_to(C.ROOT)}/index.html missing')
        for other in countries:
            if other == country: continue
            hits = [f.name for f in d.rglob('*') if f.is_file() and f.stat().st_size < 50_000_000
                    and other.encode() in f.read_bytes().lower()]
            if hits: raise RuntimeError(f'{country}/{lang} contains "{other}": {", ".join(hits[:5])}')
        log('python', f'{country}/{lang}: {sum(f.stat().st_size for f in d.rglob("*") if f.is_file()) // 1024} KiB')
    ok, out = sh('python3 ports/web/registry.py && python3 ports/web/registry.py --check', C.ROOT, log)
    if not ok: raise RuntimeError(compact_error(out))
    return {}


def expand_retrofit(eng, task, log):
    """A1: a Claude task per port that existed before WEB_ARCH.md, to bring it in line."""
    ids = []
    for lang in C.LANGS:
        if not (C.PORTS / lang / 'portctl.json').exists(): continue
        tid = f'a1.{lang}.retrofit'
        eng.store.add_task(plan.claude(tid, 'A1', f'align existing {plan.NAMES[lang]} port with WEB_ARCH.md',
                                       'a1_retrofit', lang=lang, verify='all'))
        ids.append(tid)
    log('python', f'+ retrofit: {", ".join(ids) or "none (no port exists yet)"}')
    return {'tasks': ids}


FUNCS = {f.__name__: f for f in (expand_retrofit, run_s1, check_s1, run_codegen, expand_audit, expand_units, verify_all,
                                 check_arch, web_smoke)}


# ---- ollama ---------------------------------------------------------------------------------

_server = None
_server_lock = threading.Lock()


def ensure_ollama(log, model):
    """Starts portctl's own `ollama serve` (OLLAMA_NUM_PARALLEL slots) if nothing answers on C.OLLAMA."""
    def up():
        try: urllib.request.urlopen(C.OLLAMA + '/api/version', timeout=2); return True
        except OSError: return False
    with _server_lock: _start(up, log)
    return C.OLLAMA if model in _models(C.OLLAMA) else C.OLLAMA_SYSTEM


def _models(url):
    try: return {m['name'] for m in json.load(urllib.request.urlopen(url + '/api/tags', timeout=5))['models']}
    except OSError: return set()


def _start(up, log):
    global _server
    if up(): return
    host = C.OLLAMA.split('//')[1]
    env = {**os.environ, 'OLLAMA_HOST': host, 'OLLAMA_NUM_PARALLEL': str(C.OLLAMA_PARALLEL),
           'OLLAMA_MAX_LOADED_MODELS': '2'}
    _server = subprocess.Popen(['ollama', 'serve'], env=env, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL,
                               start_new_session=True)
    log('python', f'started ollama on {host} with {C.OLLAMA_PARALLEL} parallel slots')
    for _ in range(40):
        if up(): return
        time.sleep(0.5)
    raise RuntimeError('ollama did not start')


def qwen(model, prompt, log, num_predict=C.QWEN_MAX_OUTPUT, stop=lambda: False, system=None):
    """Streams one /api/generate. Returns (text, stats) with measured rates in tok/s."""
    body = {'model': model, 'prompt': prompt, 'stream': True, 'think': False,
            'options': {'num_ctx': C.QWEN_CTX, 'num_predict': num_predict, 'temperature': 0.1}}
    if system: body['system'] = system
    url = ensure_ollama(log, model)
    req = urllib.request.Request(url + '/api/generate', json.dumps(body).encode(),
                                 {'Content-Type': 'application/json'})
    text, buf, last, start, first = [], '', time.time(), time.time(), None
    final = {}
    log('qwen', f'▶ {model} · ~{tokens(prompt)} prompt tokens · num_predict {num_predict}')
    with urllib.request.urlopen(req, timeout=1800) as r:
        for raw in r:
            if stop(): log('qwen', '■ stopped'); break
            m = json.loads(raw)
            piece = m.get('response', '')
            if piece and first is None:
                first = time.time()
                log('qwen', f'… prompt evaluated in {first - start:.1f}s')
            text.append(piece); buf += piece
            # Tokens are batched into lines (or 0.7 s) so the event log stays readable.
            if '\n' in buf or time.time() - last > 0.7:
                *done, buf = buf.split('\n') if '\n' in buf else ([buf] + [''])
                for d in done: log('qwen.out', d)
                last = time.time()
            if m.get('done'): final = m; break
    if buf: log('qwen.out', buf)
    ns = 1e9
    st = {'tok_in': final.get('prompt_eval_count', 0), 'tok_out': final.get('eval_count', 0),
          'seconds': time.time() - start, 'truncated': final.get('done_reason') == 'length'}
    st['rate_in'] = st['tok_in'] / (final.get('prompt_eval_duration', 0) / ns or 1e9)
    st['rate_out'] = st['tok_out'] / (final.get('eval_duration', 0) / ns or 1e9)
    log('qwen', f'■ {st["tok_in"]} in @ {st["rate_in"]:.1f}/s · {st["tok_out"]} out @ {st["rate_out"]:.1f}/s · '
                f'{st["seconds"]:.1f}s')
    return ''.join(text), st


def code_block(text):
    """The longest fenced block of a model answer, or the whole answer if it has none."""
    blocks = re.findall(r'```[\w+-]*\n(.*?)```', text, re.S)
    return (max(blocks, key=len) if blocks else text).strip() + '\n'


def tidy(lang, code):
    """Mechanical slips qwen repeats: Dart raw strings and `extends` on an interface."""
    if lang != 'ts': return code
    code = re.sub(r"\br(['\"])([^'\"\n]*)\1", lambda m: 'String.raw`' + m.group(2) + '`', code)
    return re.sub(r'\bextends PlateValidator\b', 'implements PlateValidator', code)


# ---- claude ---------------------------------------------------------------------------------

class Claude:
    def __init__(self):
        self.proc = None

    def kill(self):
        if self.proc and self.proc.poll() is None:
            os.killpg(self.proc.pid, signal.SIGTERM)

    def run(self, prompt, log, resume=None, budget=C.CLAUDE_BUDGET_USD):
        """One `claude -p` session. Returns {ok, text, cost, turns, session}."""
        cmd = [C.CLAUDE, '-p', prompt, '--output-format', 'stream-json', '--verbose',
               '--permission-mode', 'acceptEdits', '--allowedTools', *C.CLAUDE_TOOLS,
               '--max-turns', str(C.CLAUDE_MAX_TURNS), '--max-budget-usd', str(budget),
               '--add-dir', str(C.PORTS)]
        if C.CLAUDE_MODEL: cmd += ['--model', C.CLAUDE_MODEL]
        if resume: cmd += ['--resume', resume]
        C.PORTS.mkdir(exist_ok=True)
        log('claude', f'▶ claude -p ({tokens(prompt)} prompt tokens){" · resume " + resume if resume else ""}')
        self.proc = subprocess.Popen(cmd, cwd=str(C.ROOT), stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
                                     text=True, bufsize=1, start_new_session=True, stdin=subprocess.DEVNULL)
        res = {'ok': False, 'text': '', 'cost': 0.0, 'turns': 0, 'session': resume}
        for line in self.proc.stdout:
            try: m = json.loads(line)
            except ValueError:
                log('claude', line.rstrip()); continue
            t = m.get('type')
            if t == 'system' and m.get('subtype') == 'init':
                res['session'] = m.get('session_id')
                log('claude', f'session {res["session"]} · model {m.get("model")}')
            elif t == 'assistant':
                for c in m.get('message', {}).get('content', []):
                    if c.get('type') == 'text': log('claude.out', c['text'])
                    elif c.get('type') == 'tool_use':
                        inp = c.get('input', {})
                        arg = inp.get('command') or inp.get('file_path') or inp.get('pattern') or json.dumps(inp)[:200]
                        log('claude.tool', f'{c.get("name")} {arg}')
            elif t == 'user':
                for c in m.get('message', {}).get('content', []) if isinstance(m.get('message', {}).get('content'), list) else []:
                    if c.get('type') == 'tool_result':
                        body = c.get('content')
                        if isinstance(body, list): body = ' '.join(x.get('text', '') for x in body if isinstance(x, dict))
                        body = str(body or '')
                        log('claude.result', body[:600] + (f' … (+{len(body) - 600} chars)' if len(body) > 600 else ''))
            elif t == 'result':
                res.update(ok=not m.get('is_error') and m.get('subtype') == 'success', text=m.get('result') or '',
                           cost=m.get('total_cost_usd') or 0.0, turns=m.get('num_turns') or 0)
                log('claude', f'■ {m.get("subtype")} · {res["turns"]} turns · ${res["cost"]:.3f} · '
                              f'{(m.get("duration_ms") or 0) / 1000:.0f}s')
        self.proc.wait()
        if self.proc.returncode not in (0, None) and not res['ok']:
            log('claude', f'exit {self.proc.returncode}')
        return res
