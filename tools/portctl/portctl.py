#!/usr/bin/env python3
"""portctl: python3 tools/portctl/portctl.py [--headless] [--auto] [--reset] [--done TASK]

--headless  no window; print every event to stdout and run until all phases are approved
--auto      auto-approve phase gates
--reset     delete the state database first (start the whole port over)
--done T    mark handed-off task T as run in Claude Code (for --headless; the GUI has a button)"""
import sys, time
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import config as C
import plan
from store import Store


def main(argv):
    if '--reset' in argv and C.DB.exists(): C.DB.unlink()
    store = Store(C.DB, recover='--done' not in argv)
    plan.seed(store)
    if '--done' in argv:
        tid = argv[argv.index('--done') + 1]
        t = store.task(tid)
        if not t or t['status'] != 'awaiting': return print(f'{tid} is not waiting for you') or 1
        store.set_task(tid, status='pending', result={**t['result'], 'stage': 'returned'})
        return print(f'{tid}: will be verified by the running portctl') or 0
    from engine import Engine
    eng = Engine(store)
    if '--auto' in argv: eng.set_auto_approve(True)
    if '--headless' not in argv:
        import gui
        return gui.run(store, eng)
    eng.start()
    last = 0
    while True:
        for e in store.events(after=last):
            last = e['id']
            print(f'{time.strftime("%H:%M:%S", time.localtime(e["t"]))} {e["source"]:<13} '
                  f'{e["task"] or "—"} {e["text"]}', flush=True)
        if not eng.running and not eng.inflight: return 0
        time.sleep(0.5)


if __name__ == '__main__':
    sys.exit(main(sys.argv[1:]))
