"""Machine-readable progress for the GUI.

Each event is one stdout line: RS (\\x1e) then JSON. The GUI turns them
into its progress bars and image gallery and never shows them as text;
in a terminal they are silent unless PLATEKIT_PROGRESS=1 is set (the GUI
sets it), so plain `pk.py` output is unchanged.

    step(2, 6, 'photos')                 the big bar: stage n of total
    task('download', 3, 17, unit='file') the small bar: item n of total
    task('orig_x.jpg', 81920, 204800, unit='B')   bytes, for rate and ETA
    task('ollama 4b', 120, None, unit='tok')      no total: an activity bar
    image(path)                          a picture was written; show it now
    pick(paths, checked, title)          wait for the user to tick and group
                                         pictures; the GUI answers on stdin with
                                         {"keep": [path], "groups": [[path]]}
    paste(dest, url, title)              a download failed; wait for the user to
                                         paste the picture, answered {"ok": bool}
"""
from __future__ import annotations

import json
import os
import sys
import time
from pathlib import Path

ON = os.environ.get('PLATEKIT_PROGRESS') == '1'
RS = '\x1e'
_last = 0.0


def _emit(kind: str, **kw) -> None:
    if ON:
        sys.stdout.write(RS + json.dumps({'k': kind, **kw}) + '\n')
        sys.stdout.flush()


def step(n: int, total: int, title: str) -> None:
    _emit('step', n=n, total=total, title=title)


def task(label: str, done: float, total: float | None, unit: str = '', force: bool = False) -> None:
    """Throttled to ten a second; the last call of a task should force."""
    global _last
    now = time.monotonic()
    if not force and now - _last < 0.1 and (total is None or done < total):
        return
    _last = now
    _emit('task', label=label, done=done, total=total, unit=unit)


def step_items(n: int, total: int) -> None:
    """How far through its items the current step is (moves the big bar)."""
    _emit('sub', n=n, total=total)


def done() -> None:
    _emit('task_done')


def image(path) -> None:
    _emit('image', path=str(Path(path).resolve()))


def items(seq, label: str, unit: str = 'item'):
    """`for x in items(xs, 'flatten')`: a task bar that follows the loop."""
    seq = list(seq)
    for i, x in enumerate(seq):
        step_items(i, len(seq))
        task(f'{label} {i + 1}/{len(seq)}', i, len(seq), unit, force=True)
        yield x
    task(label, len(seq), len(seq), unit, force=True)


def paste(dest, url: str, title: str) -> bool:
    """A download failed: ask the user to paste the picture in by hand. The
    GUI writes it to `dest` and answers {"ok": bool}; elsewhere, False."""
    if not ON:
        return False
    _emit('paste', path=str(Path(dest).resolve()), url=url, title=title)
    line = sys.stdin.readline()
    return bool(line) and json.loads(line).get('ok', False) and Path(dest).exists()


def pick(paths: list[str], checked: list[str], title: str,
         groups: list[list[str]] = ()) -> tuple[list[str], list[list[str]]]:
    """(the paths the user wants to go on with, groups of paths the user
    says share one layout). In the GUI a card of checkboxes whose pictures
    can be dragged onto each other; in a terminal a numbered list (no
    groups); without either, `checked` and `groups` as given."""
    if not paths:
        return [], []
    if ON:
        real = {str(Path(p).resolve()): p for p in paths}
        _emit('pick', paths=list(real), checked=[str(Path(p).resolve()) for p in checked],
              groups=[[str(Path(p).resolve()) for p in g] for g in groups], title=title)
        line = sys.stdin.readline()
        if not line:
            return checked, list(groups)
        ans = json.loads(line)
        keep = {real[p] for p in ans['keep'] if p in real}
        return ([p for p in paths if p in keep],
                [[real[p] for p in g if real.get(p) in keep] for g in ans.get('groups', [])])
    if not sys.stdin.isatty():
        return checked, list(groups)
    print(title)
    for i, p in enumerate(paths, 1):
        print(f"  {i:2}. [{'x' if p in checked else ' '}] {Path(p).name}")
    raw = input('numbers to keep (blank = the ticked ones, "all" = every one): ').strip()
    if not raw:
        return checked, list(groups)
    if raw == 'all':
        return list(paths), list(groups)
    nums = {int(n) for n in raw.replace(',', ' ').split() if n.isdigit()}
    keep = [p for i, p in enumerate(paths, 1) if i in nums]
    return keep, [[p for p in g if p in keep] for g in groups]
