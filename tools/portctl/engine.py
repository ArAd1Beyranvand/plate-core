"""Scheduler: phase gates, lanes, the router, the qwen ladder, the escalation batcher and the
handlers for every task kind. Runs in its own thread; the GUI only reads the store and calls the
control methods."""
import json, os, re, threading, time, traceback
from pathlib import Path

import config as C
import executors as X
import plan
from context import render, cited, compact_error, tokens

DONE = ('done', 'skipped')
OPEN = ('pending', 'running', 'awaiting')
LANE_OF = {'python': 'python', 'claude': 'claude', 'fixlist': 'claude', 'repair': 'claude', 'question': 'qwen'}
LANE_SIZE = {'python': 3, 'qwen': 1, 'claude': 1}


class Engine:
    def __init__(self, store):
        self.store = store
        self.claude = X.Claude()
        self.running = False
        self.step_once = False
        self.inflight = {}           # task id -> lane
        self.stops = set()           # task ids asked to stop
        self.last_route = {}         # task id -> reason, so a waiting unit logs once
        self.lock = threading.RLock()
        self.alive = True
        threading.Thread(target=self._loop, daemon=True, name='portctl-engine').start()

    # ---- logging ------------------------------------------------------------------------------
    def logger(self, tid):
        return lambda source, text: self.store.event(tid, source, 'info', text)

    def say(self, tid, source, text, level='info'):
        self.store.event(tid, source, level, text)

    # ---- controls (GUI thread) ----------------------------------------------------------------
    @property
    def auto_approve(self): return bool(self.store.get('auto_approve', False))

    def set_auto_approve(self, on): self.store.put('auto_approve', bool(on))

    def start(self): self.running, self.step_once = True, False; self.say(None, 'engine', '▶ started')

    def pause(self): self.running = False; self.say(None, 'engine', '⏸ paused (running tasks finish)')

    def step(self): self.running, self.step_once = True, True; self.say(None, 'engine', '⏭ step')

    def approve(self, pid):
        self.store.x("update phases set gate='approved' where id=?", pid)
        self.say(None, 'gate', f'✓ {pid} approved')

    def retry(self, tid):
        if tid in self.inflight: return
        self.store.set_task(tid, status='pending', result={})
        self.last_route.pop(tid, None)
        self.say(tid, 'engine', '↻ retry')

    def skip(self, tid):
        if tid in self.inflight: return
        self.store.set_task(tid, status='skipped')
        self.say(tid, 'engine', '⤼ skipped')

    def force(self, tid, route):
        t = self.store.task(tid)
        self.store.set_task(tid, forced=route or None)
        if t['status'] in ('failed', 'escalated') and tid not in self.inflight:
            self.store.set_task(tid, status='pending')
        self.last_route.pop(tid, None)
        self.say(tid, 'router', f'forced → {route or "auto"}')

    def returned(self, tid):
        """You ran a handed-off prompt in Claude Code: verify it on the next tick."""
        t = self.store.task(tid)
        if t['status'] != 'awaiting': return
        self.store.set_task(tid, status='pending', result={**t['result'], 'stage': 'returned'})
        self.say(tid, 'claude', f'✓ marked done in Claude Code → verifying')

    def kill(self, tid):
        lane = self.inflight.get(tid)
        self.stops.add(tid)
        if lane == 'claude': self.claude.kill()
        self.say(tid, 'engine', '■ stop requested')

    # ---- loop ---------------------------------------------------------------------------------
    def _loop(self):
        while self.alive:
            try:
                if self.running: self.tick()
            except Exception:
                self.say(None, 'engine', traceback.format_exc(), 'error')
                self.running = False
            time.sleep(0.5)

    def current_phase(self):
        for ph in self.store.q('select * from phases order by ord'):
            if ph['gate'] == 'approved': continue
            if ph['gate'] == 'closed':
                self.store.x("update phases set gate='open' where id=?", ph['id'])
                self.say(None, 'gate', f'▶ {ph["id"]} open · {ph["title"]}')
            ts = self.store.tasks('phase=?', ph['id'])
            if ts and all(t['status'] in DONE for t in ts) and not any(t['id'] in self.inflight for t in ts):
                if self.auto_approve:
                    self.approve(ph['id']); continue
                if ph['gate'] != 'waiting':
                    self.store.x("update phases set gate='waiting' where id=?", ph['id'])
                    self.say(None, 'gate', f'⏳ {ph["id"]} complete — waiting for approval')
                return None
            return ph['id']
        if self.running:
            self.say(None, 'engine', '✓ every phase approved'); self.running = False
        return None

    def tick(self):
        pid = self.current_phase()
        if not pid: return
        self.batch_escalations(pid)
        tasks = self.store.tasks('phase=? and status=?', pid, 'pending')
        status = {r['id']: r['status'] for r in self.store.q('select id, status from tasks')}
        tasks.sort(key=lambda t: -t['priority'])
        for t in tasks:
            if t['id'] in self.inflight: continue
            if not all(status.get(d) in DONE for d in t['deps']): continue
            lane = LANE_OF.get(t['kind'])
            if t['kind'] == 'unit':
                lane = self.route(t)
                if lane in (None, 'batch'): continue
            # Manual Claude tasks only prepare a prompt or verify your work: cheap, so the python lane.
            if lane == 'claude' and C.CLAUDE_MODE == 'manual': lane = 'python'
            if sum(1 for l in self.inflight.values() if l == lane) >= LANE_SIZE[lane]: continue
            self.dispatch(t, lane)
            if self.step_once:
                self.running = self.step_once = False
                return

    def dispatch(self, t, lane):
        with self.lock: self.inflight[t['id']] = lane
        self.store.set_task(t['id'], status='running')
        threading.Thread(target=self._run, args=(t, lane), daemon=True, name=t['id']).start()

    def _run(self, t, lane):
        tid, log = t['id'], self.logger(t['id'])
        self.say(tid, 'engine', f'▶ {t["kind"]} on {lane} lane · {t["title"]}')
        start = time.time()
        try:
            status, result = getattr(self, 'do_' + t['kind'])(self.store.task(tid), log, lane)
        except Exception as e:
            self.say(tid, 'engine', traceback.format_exc(), 'error')
            status, result = 'failed', {'error': str(e)[:4000]}
        if tid in self.stops:
            self.stops.discard(tid)
            if status != 'done': status = 'failed'
        self.store.set_task(tid, status=status, result=result)
        self.say(tid, 'engine', f'{"✓" if status == "done" else "•"} {status} · {time.time() - start:.1f}s',
                 'info' if status in DONE + ('escalated', 'awaiting', 'pending') else 'error')
        with self.lock: self.inflight.pop(tid, None)

    # ---- router -------------------------------------------------------------------------------
    def rates(self, model):
        return self.store.get('rate:' + model) or list(C.QWEN_RATES[model])

    def note_rates(self, model, st):
        r = self.rates(model)
        if st['tok_in'] > 50: r[0] = 0.7 * r[0] + 0.3 * st['rate_in']
        if st['tok_out'] > 20: r[1] = 0.7 * r[1] + 0.3 * st['rate_out']
        self.store.put('rate:' + model, r)

    def route(self, t):
        """'qwen' | 'claude' (exemplar, run alone) | 'batch' (escalated to a repair batch) | None (wait)."""
        fam, lang = t['family'], t['lang']
        def decide(lane, reason):
            if self.last_route.get(t['id']) != reason:
                self.last_route[t['id']] = reason
                self.say(t['id'], 'router', f'{t["id"]} → {lane or "wait"}: {reason}')
            if lane == 'batch':
                self.store.set_task(t['id'], status='escalated', route='claude', result={'reason': reason})
            return lane
        if t['forced'] == 'qwen': return decide('qwen', 'forced')
        if t['forced'] == 'claude':
            if t['route'] != 'exemplar': self.store.set_task(t['id'], route='claude')
            return decide('claude', 'forced')
        ex = len(self.store.exemplars(fam, lang))
        busy = self.store.q("select count(*) n from tasks where kind='unit' and family=? and lang=? and "
                            "status in ('running', 'awaiting') and route='exemplar'", fam, lang)[0]['n']
        if ex + busy < C.EXEMPLARS_PER_FAMILY:
            self.store.set_task(t['id'], route='exemplar')
            return decide('claude', f'exemplar {ex + busy + 1}/{C.EXEMPLARS_PER_FAMILY} for {fam}·{lang}')
        if ex == 0: return decide(None, f'waiting for the first {fam}·{lang} exemplar')
        prompt = self.unit_prompt(t)
        out = min(C.QWEN_MAX_OUTPUT, int(tokens(self.dart_source(t['payload']['dart'])) * 1.3) + 60)
        rin, rout = self.rates(C.QWEN_SMALL)
        est = tokens(prompt) / rin + out / rout
        if tokens(prompt) + out > C.QWEN_CTX:
            return decide('batch', f'{tokens(prompt)}+{out} tokens exceed num_ctx {C.QWEN_CTX}')
        if est > C.QWEN_MAX_SECONDS:
            return decide('batch', f'estimated {est:.0f}s on {C.QWEN_SMALL} > {C.QWEN_MAX_SECONDS}s')
        s = self.store.family_stats().get((fam, lang), {})
        if s.get('qwen_tried', 0) >= C.FAMILY_MIN_SAMPLES and s['qwen_ok'] / s['qwen_tried'] < C.FAMILY_MIN_SUCCESS:
            return decide('batch', f'qwen {s["qwen_ok"]}/{s["qwen_tried"]} in {fam}·{lang} '
                                   f'< {C.FAMILY_MIN_SUCCESS:.0%}')
        return decide('qwen', f'~{tokens(prompt)} tokens, est {est:.0f}s on {C.QWEN_SMALL}')

    def batch_escalations(self, pid):
        units = self.store.tasks("phase=? and kind='unit'", pid)
        groups = {}
        for u in units: groups.setdefault(u['family'], []).append(u)
        for fam, us in groups.items():
            esc = [u for u in us if u['status'] == 'escalated']
            open_ = [u for u in us if u['status'] in OPEN and u['id'] not in self.last_route_wait()]
            if not esc or (len(esc) < C.CLAUDE_BATCH and open_): continue
            pack = esc[:C.CLAUDE_BATCH]
            lang = pack[0]['lang']
            n = self.store.get(f'repairs:{pid}', 0) + 1
            self.store.put(f'repairs:{pid}', n)
            rid = f'{pid.lower()}.repair.{n}'
            self.store.add_task({'id': rid, 'phase': pid, 'lang': lang, 'kind': 'repair', 'family': fam,
                                 'title': f'{fam} batch of {len(pack)}', 'priority': 1,
                                 'payload': {'units': [u['id'] for u in pack]}})
            for u in pack: self.store.set_task(u['id'], status='batched', result={**u['result'], 'repair': rid})
            self.say(rid, 'router', f'batched {len(pack)} {fam} units → {rid}: ' + ', '.join(u['id'] for u in pack))

    def last_route_wait(self):
        return {k for k, v in self.last_route.items() if v.startswith('waiting')}

    # ---- prompt facts -------------------------------------------------------------------------
    @staticmethod
    def dart_source(rel):
        """A Dart file without its TODO lines: the unit prompt lists them once, and on CPU every
        prompt token costs qwen time."""
        return re.sub(r'(?m)^\s*// TODO\(\w+\):.*\n', '', (C.ROOT / rel).read_text('utf8'))

    def exemplar(self, t):
        ex = self.store.exemplars(t['family'], t['lang'])
        return min(ex, key=lambda e: len(e['dart']) + len(e['target'])) if ex else None

    def unit_prompt(self, t, error=None, previous=None):
        lang, rel = t['lang'], t['payload']['dart']
        src = self.dart_source(rel)
        todo = sorted(set(re.findall(rf'TODO\({lang}\):\s*(.*)', (C.ROOT / rel).read_text('utf8'))))
        ex = self.exemplar(t)
        target, _ = X.unit_paths(lang, rel)
        return render('unit', lang_name=plan.NAMES[lang], lang=lang, dart_path=rel, dart=src,
                      todos='\n'.join('- ' + x for x in todo) or '- (none)',
                      roadmap=cited(todo, skip=('D4', 'D9')),
                      ex_dart=self.dart_source(ex['dart']) if ex else '',
                      ex_target=ex['target'] if ex else '',
                      ex_path=ex['dart'] if ex else '', target_path=target.relative_to(C.PORTS / lang),
                      fence=C.EXT[lang] if lang != 'kt' else 'kotlin',
                      retry=render('unit_retry', error=error, previous=previous) if error else '')

    def claude_vars(self, t):
        lang = t['lang']
        v = dict(t['payload'].get('vars', {}))
        v.update(root=C.ROOT, ports=C.PORTS, lang=lang, lang_name=plan.NAMES.get(lang, ''),
                 lang_dir=C.PORTS / lang if lang else '', task=t['id'], title=t['title'],
                 contract=json.dumps(plan.lang_contract(lang), indent=1) if lang else '')
        files = v.get('files')
        if files:
            paths = [(C.ROOT / 'plate_core' / 'lib' / 'src' / f).resolve() for f in files]
            v['files'] = '\n'.join(f'- {p.relative_to(C.ROOT)}' for p in paths)
            lines = []
            for p in paths:
                for i, text, decl in plan.todos(p, lang):
                    lines.append(f'- {p.name}:{i + 1} `{decl[:70]}` — {text}')
            v['todos'] = '\n'.join(lines) or '- (none)'
        return v

    # ---- handlers: return (status, result) ----------------------------------------------------
    def do_python(self, t, log, lane):
        p = t['payload']
        return 'done', X.FUNCS[p['fn']](self, t, log, **p.get('args', {})) or {}

    def spend(self, cost):
        self.store.put('claude_spend', self.store.get('claude_spend', 0.0) + (cost or 0.0))

    def hint(self, t, template):
        """Suggested (model, effort) for a Claude prompt."""
        if template == 'fixlist':
            return ('haiku', 'medium') if t['result'].get('items', 99) <= 6 else ('sonnet', 'medium')
        if template == 'unit_claude':
            return ('opus', 'medium') if t['route'] == 'exemplar' else ('haiku', 'medium')
        part = t['payload'].get('vars', {}).get('part')
        return C.HINTS.get(f'{template}:{part}') or C.HINTS.get(template) or ('sonnet', 'medium')

    def handoff(self, t, log, template, make_prompt, finish):
        """One Claude step. Manual: write the prompt for you and wait ('awaiting'); after you press
        Done, `finish` verifies. Auto: run `claude -p` (resuming on fix rounds), then `finish`."""
        r = t['result'] or {}
        if r.get('stage') == 'returned': return finish(t, log)
        prompt = r.get('next_prompt') or make_prompt()
        model, effort = r.get('next_hint') or self.hint(t, template)
        n = len(self.store.attempts(t['id'])) + 1
        if C.CLAUDE_MODE == 'manual':
            C.HANDOFFS.mkdir(parents=True, exist_ok=True)
            f = C.HANDOFFS / f'{t["id"]}.r{r.get("round", 0)}.md'
            f.write_text(f'<!-- portctl {t["id"]} · model: {model} · effort: {effort} -->\n\n{prompt}', 'utf8')
            self.store.add_attempt(task=t['id'], n=n, worker='handoff', model=f'{model} · {effort}', prompt=prompt,
                                   output='', ok=0)
            log('claude', f'⧉ prompt ready · {model} · effort {effort} · {tokens(prompt)} tokens · '
                          f'{os.path.relpath(f, C.ROOT)} — run it in Claude Code, then press Done')
            return 'awaiting', {**r, 'stage': 'awaiting', 'prompt': prompt, 'model': model, 'effort': effort,
                                'file': os.path.relpath(f, C.ROOT), 'template': template}
        res = self.claude.run(prompt, log, resume=r.get('session'))
        self.spend(res['cost'])
        self.store.add_attempt(task=t['id'], n=n, worker='claude', model=C.CLAUDE_MODEL or 'default',
                               prompt=prompt, output=res['text'], ok=int(res['ok']), cost=res['cost'])
        if t['id'] in self.stops: return 'failed', {'error': 'stopped'}
        if not res['ok']: return 'failed', {'error': res['text'][:2000] or 'claude session failed'}
        return finish({**t, 'result': {**r, 'session': res['session'], 'summary': res['text'][-3000:]}}, log)

    def again(self, t, log, error, oracle):
        """Red oracle: queue a fix prompt for the same task (a new handoff, or a resumed session)."""
        r = t['result'] or {}
        rnd = r.get('round', 0) + 1
        if rnd > (C.MANUAL_ROUNDS if C.CLAUDE_MODE == 'manual' else 2):
            return 'failed', {'error': error}
        model = r.get('model') or self.hint(t, r.get('template', ''))[0]
        fix = render('verify_fix', task=t['id'], title=t['title'], error=error, oracle=oracle,
                     lang=t['lang'], lang_name=plan.NAMES.get(t['lang'], ''))
        log('engine', f'oracle red → fix prompt, round {rnd}')
        return 'pending', {**{k: v for k, v in r.items() if k in ('session', 'template', 'model')},
                           'round': rnd, 'next_prompt': fix, 'next_hint': (model, 'medium'), 'error': error}

    def finish_all(self, t, log):
        """Done when the language's whole oracle is green (or when the task has no oracle)."""
        if t['lang'] and not (C.PORTS / t['lang'] / 'portctl.json').exists():
            return self.again(t, log, f'ports/{t["lang"]}/portctl.json does not exist yet', '(the contract)')
        if t['payload'].get('verify') != 'all': return 'done', {'summary': t['result'].get('summary', '')}
        ok, out = X.oracle_all(t['lang'], log)
        self.store.add_attempt(task=t['id'], n=len(self.store.attempts(t['id'])) + 1, worker='oracle', model='',
                               prompt='', output='', oracle=out[-20000:], ok=int(ok))
        if ok: return 'done', {'summary': t['result'].get('summary', ''), 'rounds': t['result'].get('round', 0)}
        return self.again(t, log, compact_error(out, 60), X.contract(t['lang'])['oracle_all'])

    def do_claude(self, t, log, lane):
        p = t['payload']
        return self.handoff(t, log, p['template'], lambda: render(p['template'], **self.claude_vars(t)),
                            self.finish_all)

    def do_fixlist(self, t, log, lane):
        if t['result'].get('stage') == 'returned' or t['result'].get('next_prompt'):
            return self.handoff(t, log, 'fixlist', None, self.finish_all)
        items = []
        for qid in t['deps']:
            q = self.store.task(qid)
            if q['status'] == 'skipped' or q['result'].get('answer') == 'yes': continue
            pl, r = q['payload'], q['result']
            where = pl['target'] or 'not found in the port'
            items.append(f'- [{r.get("answer")}] {pl["dart"]}:{pl["line"]} `{pl["decl"][:70]}` — {pl["todo"]}\n'
                         f'  target: {where}' + (f'\n  qwen: {r["why"]}' if r.get('why') else ''))
        log('engine', f'{len(items)} of {len(t["deps"])} audit items need a fix')
        if not items: return 'done', {'fixes': 0}
        t = {**t, 'result': {**t['result'], 'items': len(items)}}
        return self.handoff(t, log, 'fixlist',
                            lambda: render('fixlist', items='\n'.join(items), **self.claude_vars(t)), self.finish_all)

    def do_question(self, t, log, lane):
        p = t['payload']
        if not p['target_code']:
            log('python', f'no definition of {p["name"]!r} found in ports/{t["lang"]} → fix list')
            return 'done', {'answer': 'missing'}
        prompt = render('question', lang_name=plan.NAMES[t['lang']], todo=p['todo'], roadmap=cited([p['todo']]),
                        dart=p['dart_code'], target=p['target'], target_code=p['target_code'])
        for n, model in enumerate((C.QWEN_SMALL, C.QWEN_LARGE)):
            text, st = X.qwen(model, prompt, log, num_predict=160, stop=lambda: t['id'] in self.stops)
            self.note_rates(model, st)
            m = re.match(r'\W*(YES|NO)\b[\s:.,-]*(.*)', text.strip(), re.I | re.S)
            self.store.add_attempt(task=t['id'], n=n + 1, worker='qwen', model=model, prompt=prompt, output=text,
                                   ok=int(bool(m)), seconds=st['seconds'], tok_in=st['tok_in'], tok_out=st['tok_out'])
            if m: return 'done', {'answer': m.group(1).lower(), 'why': m.group(2).strip()[:300]}
        return 'done', {'answer': 'unclear', 'why': text.strip()[:300]}

    def do_unit(self, t, log, lane):
        lang, rel = t['lang'], t['payload']['dart']
        target, test = X.unit_paths(lang, rel)
        if t['route'] in ('exemplar', 'claude'):
            return self.handoff(t, log, 'unit_claude', lambda: self.unit_claude_prompt(t), self.finish_unit)
        # qwen ladder
        self.store.set_task(t['id'], route='qwen')
        stub = target.read_text('utf8') if target.exists() else None
        error = previous = None
        for n, model in enumerate(C.LADDER):
            if t['id'] in self.stops: break
            prompt = self.unit_prompt(t, error, previous)
            log('engine', f'rung {n + 1}/{len(C.LADDER)} · {model}')
            out_tokens = min(C.QWEN_MAX_OUTPUT, int(tokens(self.dart_source(rel)) * 1.5) + 120)
            text, st = X.qwen(model, prompt, log, num_predict=out_tokens, stop=lambda: t['id'] in self.stops)
            self.note_rates(model, st)
            code = X.code_block(text)
            target.parent.mkdir(parents=True, exist_ok=True)
            target.write_text(code, 'utf8')
            ok, out = X.oracle_unit(lang, rel, log)
            self.store.add_attempt(task=t['id'], n=n + 1, worker='qwen', model=model, prompt=prompt, output=text,
                                   oracle=out[-20000:], ok=int(ok), seconds=st['seconds'], tok_in=st['tok_in'],
                                   tok_out=st['tok_out'])
            if ok: return 'done', {'model': model, 'rung': n + 1}
            error, previous = compact_error(out), code
        # A broken unit would break every other unit's compile (Kotlin compiles the module), so the stub
        # goes back until Claude repairs it.
        if stub is not None: target.write_text(stub, 'utf8')
        self.store.set_task(t['id'], route='escalated')
        return 'escalated', {'last_code': previous, 'error': error}

    def unit_claude_prompt(self, t):
        lang, rel = t['lang'], t['payload']['dart']
        target, test = X.unit_paths(lang, rel)
        ex = self.exemplar(t)
        v = self.claude_vars(t)
        v.update(dart_path=rel, target_path=target.relative_to(C.ROOT), test_path=test.relative_to(C.ROOT),
                 oracle=self.unit_oracle(lang, rel),
                 exemplar=f'{ex["dart"]} → its port (already accepted)' if ex else
                 'none yet: this unit becomes the exemplar for every later unit of the family, so keep it '
                 'idiomatic and minimal.')
        return render('unit_claude', **v)

    @staticmethod
    def unit_oracle(lang, rel):
        _, test = X.unit_paths(lang, rel)
        return X.fill(X.contract(lang)['oracle_unit'], {**X.unit_vars(rel), 'unit_test': test.relative_to(C.PORTS / lang)})

    def finish_unit(self, t, log):
        lang, rel = t['lang'], t['payload']['dart']
        target, _ = X.unit_paths(lang, rel)
        ok, out = X.oracle_unit(lang, rel, log)
        if not ok: return self.again(t, log, compact_error(out), self.unit_oracle(lang, rel))
        if len(self.store.exemplars(t['family'], lang)) < C.EXEMPLARS_PER_FAMILY:
            self.store.add_exemplar(t['family'], lang, rel, target.read_text('utf8'))
            log('engine', f'★ exemplar for {t["family"]}·{lang}: {rel}')
        return 'done', {'rounds': t['result'].get('round', 0)}

    def do_repair(self, t, log, lane):
        return self.handoff(t, log, 'repair', lambda: self.repair_prompt(t), self.finish_repair)

    def repair_prompt(self, t):
        lang = t['lang']
        blocks = []
        for uid in t['payload']['units']:
            u = self.store.task(uid)
            target, test = X.unit_paths(lang, u['payload']['dart'])
            r = u['result']
            b = (f'### {u["payload"]["dart"]}\n- target: {target.relative_to(C.ROOT)}\n'
                 f'- test: {test.relative_to(C.ROOT)}\n')
            if r.get('last_code'):
                b += (f'- qwen\'s last attempt (rejected by the oracle):\n```\n{r["last_code"][:4000]}```\n'
                      f'- oracle error:\n```\n{r.get("error") or ""}\n```\n')
            else:
                b += f'- routed straight to you: {r.get("reason", "")}\n'
            blocks.append(b)
        v = self.claude_vars(t)
        ex = self.exemplar({'family': t['family'], 'lang': lang})
        v.update(units='\n'.join(blocks), n=len(blocks), oracle_unit=X.contract(lang)['oracle_unit'],
                 exemplar=ex['dart'] if ex else '(none)')
        return render('repair', **v)

    def finish_repair(self, t, log):
        bad = []
        for uid in t['payload']['units']:
            u = self.store.task(uid)
            if u['status'] == 'done': continue
            ok, out = X.oracle_unit(t['lang'], u['payload']['dart'], self.logger(uid))
            self.store.set_task(uid, status='done' if ok else 'batched',
                                result={**u['result'], **({} if ok else {'error': compact_error(out)})})
            if not ok: bad.append(f'{u["payload"]["dart"]}:\n{compact_error(out, 15)}')
        n = len(t['payload']['units'])
        log('engine', f'{n - len(bad)}/{n} units green')
        if not bad: return 'done', {}
        st, res = self.again(t, log, '\n\n'.join(bad), X.contract(t['lang'])['oracle_unit'])
        if st == 'failed':   # give the still-red units back to the router (force them as you like)
            for uid in t['payload']['units']:
                if self.store.task(uid)['status'] == 'batched': self.store.set_task(uid, status='failed')
        return st, res
