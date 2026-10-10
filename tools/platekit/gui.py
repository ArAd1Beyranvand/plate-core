#!/usr/bin/env python3
"""platekit GUI — run `before` / `after` (or any command) and watch each
step land on a timeline: text output, and every image the step wrote.
One tab per country; each tab has its own process, timeline and log.

    python3 tools/platekit/gui.py [url ...]   (from the workspace root)
"""
from __future__ import annotations

import json
import os
import queue
import re
import subprocess
import sys
import threading
import time
import tkinter as tk
import urllib.parse
from pathlib import Path
from tkinter import ttk

from PIL import Image, ImageTk

ROOT = Path.cwd()
PK = Path(__file__).resolve().parent / 'pk.py'
HISTORY = Path(os.environ.get('XDG_CONFIG_HOME') or Path.home() / '.config') / 'platekit' / 'history.json'
IMG = re.compile(r'\.(png|jpe?g|webp)$', re.I)

BG, CARD, FG, DIM, ACCENT, OK, BAD = '#0f1115', '#181b22', '#e6e6e6', '#8a8f98', '#7aa2f7', '#9ece6a', '#f7768e'
GROUPS = ('#e0af68', '#bb9af7', '#7dcfff', '#ff9e64', '#73daca', '#f7768e')  # one border colour per group
MONO = ('JetBrains Mono', 10) if sys.platform != 'darwin' else ('Menlo', 11)


class Timeline(tk.Frame):
    """A scrollable column of step cards."""

    def __init__(self, master):
        super().__init__(master, bg=BG)
        self.canvas = tk.Canvas(self, bg=BG, highlightthickness=0)
        bar = ttk.Scrollbar(self, orient='vertical', command=self.canvas.yview)
        self.inner = tk.Frame(self.canvas, bg=BG)
        self.inner.bind('<Configure>', lambda e: self.canvas.configure(scrollregion=self.canvas.bbox('all')))
        self.win = self.canvas.create_window((0, 0), window=self.inner, anchor='nw')
        self.canvas.bind('<Configure>', lambda e: self.canvas.itemconfigure(self.win, width=e.width))
        self.canvas.configure(yscrollcommand=bar.set)
        self.canvas.pack(side='left', fill='both', expand=True)
        bar.pack(side='right', fill='y')
        # every tab has a timeline; only the one under the pointer scrolls
        self.bind('<Enter>', lambda e: self._grab_wheel(True))
        self.bind('<Leave>', lambda e: self._grab_wheel(False))
        self.photos = []  # keep PhotoImage references alive
        self.records: list[dict] = []  # what each card showed, for the history file

    def _grab_wheel(self, on: bool):
        for seq in ('<MouseWheel>', '<Button-4>', '<Button-5>'):
            if on:
                self.canvas.bind_all(seq, self._wheel)
            else:
                self.canvas.unbind_all(seq)

    def _wheel(self, e):
        self.canvas.yview_scroll(-1 if (e.num == 4 or e.delta > 0) else 1, 'units')

    def card(self, title: str, colour: str = ACCENT, stamp: str = '') -> 'Card':
        c = Card(self, title, colour, stamp)
        c.pack(fill='x', padx=14, pady=6)
        self.after(50, lambda: self.canvas.yview_moveto(1.0))
        return c

    def clear(self):
        for w in self.inner.winfo_children():
            w.destroy()
        self.photos.clear()
        self.records.clear()

    def restore(self, records: list[dict]):
        for rec in records:
            c = self.card(rec['title'], rec.get('colour', ACCENT), rec.get('time', ''))
            for line in rec.get('lines', []):
                c.write(line)
            for img in rec.get('images', []):
                if Path(img).exists():
                    c.image(Path(img))
            if rec.get('ok') is not None:
                c.done(rec['ok'], restored=True)


class Card(tk.Frame):
    def __init__(self, tl: Timeline, title: str, colour: str, stamp: str = ''):
        super().__init__(tl.inner, bg=CARD, highlightthickness=1, highlightbackground='#262a33')
        self.tl = tl
        self.rec = {'title': title, 'colour': colour, 'time': stamp or time.strftime('%Y-%m-%d %H:%M:%S'),
                    'lines': [], 'images': [], 'ok': None}
        tl.records.append(self.rec)
        head = tk.Frame(self, bg=CARD)
        head.pack(fill='x', padx=10, pady=(8, 4))
        self.dot = tk.Label(head, text='●', fg=colour, bg=CARD, font=('Sans', 11))
        self.dot.pack(side='left')
        tk.Label(head, text=title, fg=FG, bg=CARD, font=('Sans', 11, 'bold')).pack(side='left', padx=6)
        self.clock = tk.Label(head, text=self.rec['time'], fg=DIM, bg=CARD, font=('Sans', 9))
        self.clock.pack(side='right')
        self.text = tk.Text(self, bg=CARD, fg=FG, font=MONO, relief='flat', height=1, wrap='word',
                            insertbackground=FG, highlightthickness=0)
        self.text.tag_configure('bad', foreground=BAD)
        self.text.tag_configure('ok', foreground=OK)
        self.text.tag_configure('dim', foreground=DIM)
        self.text.pack(fill='x', padx=10)
        self.gallery = tk.Frame(self, bg=CARD)
        self.gallery.pack(fill='x', padx=10, pady=(4, 8))
        self.lines = 0
        self.shown: set[Path] = set()

    def write(self, line: str):
        tag = ('bad' if re.search(r'FAIL|CHECK|error|Traceback|issues', line)
               else 'ok' if re.search(r'\bok\b|clean|pass|Done', line, re.I) else '')
        self.rec['lines'].append(line)
        self.text.insert('end', line + '\n', tag)
        self.lines += 1
        self.text.configure(height=min(self.lines, 18))
        self.text.see('end')

    def image(self, path: Path, max_w: int = 360, max_h: int = 220):
        if path in self.shown:
            return
        try:
            im = Image.open(path)
            im.thumbnail((max_w, max_h))
        except Exception:
            return
        self.shown.add(path)
        self.rec['images'].append(str(path))
        ph = ImageTk.PhotoImage(im)
        self.tl.photos.append(ph)
        cell = tk.Frame(self.gallery, bg=CARD)
        lbl = tk.Label(cell, image=ph, bg=CARD, cursor='hand2')
        lbl.pack()
        lbl.bind('<Button-1>', lambda e: subprocess.Popen(['xdg-open', str(path)]))
        tk.Label(cell, text=path.name[:48], fg=DIM, bg=CARD, font=('Sans', 8)).pack()
        n = len(self.gallery.winfo_children()) - 1
        cell.grid(row=n // 3, column=n % 3, padx=4, pady=4, sticky='nw')

    def pick(self, paths: list[str], checked: list[str], groups: list[list[str]], answer):
        """Thumbnails with checkboxes. Click a picture to tick it, drag it
        onto another to put both in one group, right-click to take it out
        of its group. Continue sends the ticked paths and the groups."""
        ticks, cells, tags = {}, {}, {}
        group = {p: i for i, g in enumerate(groups) for p in g}   # path -> group id
        drag = {}

        def paint():
            ids = sorted({g for p, g in group.items() if list(group.values()).count(g) > 1})
            for p, cell in cells.items():
                g = group.get(p)
                if g in ids:
                    k = ids.index(g)
                    colour = GROUPS[k % len(GROUPS)]
                    cell.configure(highlightbackground=colour, highlightthickness=3)
                    tags[p].configure(text=f'group {chr(65 + k)}', fg=colour)
                else:
                    cell.configure(highlightbackground=CARD, highlightthickness=3)
                    tags[p].configure(text='')

        def press(e, p):
            drag.update(src=p, x=e.x_root, y=e.y_root, moved=False)

        def motion(e):
            if abs(e.x_root - drag['x']) + abs(e.y_root - drag['y']) > 8 and not drag['moved']:
                drag['moved'] = True
                self.configure(cursor='fleur')

        def release(e, p):
            self.configure(cursor='')
            if not drag.get('moved'):
                ticks[p].set(not ticks[p].get())
                return
            w = self.winfo_containing(e.x_root, e.y_root)
            while w is not None and w not in cells.values():
                w = w.master
            dst = next((q for q, c in cells.items() if c is w), None)
            if dst is None or dst == p:
                return
            if dst not in group:
                group[dst] = max(group.values(), default=-1) + 1
            group[p] = group[dst]
            ticks[p].set(True)
            ticks[dst].set(True)
            paint()

        def ungroup(p):
            group.pop(p, None)
            paint()

        for n, p in enumerate(paths):
            path = Path(p)
            cell = tk.Frame(self.gallery, bg=CARD, highlightthickness=3, highlightbackground=CARD)
            cells[p] = cell
            try:
                im = Image.open(path)
                im.thumbnail((240, 160))
                ph = ImageTk.PhotoImage(im)
                self.tl.photos.append(ph)
                lbl = tk.Label(cell, image=ph, bg=CARD, cursor='hand2')
            except Exception:
                lbl = tk.Label(cell, text='(no preview)', fg=DIM, bg=CARD, width=30, height=8)
            lbl.pack()
            lbl.bind('<ButtonPress-1>', lambda e, p=p: press(e, p))
            lbl.bind('<B1-Motion>', motion)
            lbl.bind('<ButtonRelease-1>', lambda e, p=p: release(e, p))
            lbl.bind('<Button-3>', lambda e, p=p: ungroup(p))
            lbl.bind('<Double-Button-1>', lambda e, p=path: subprocess.Popen(['xdg-open', str(p)]))
            ticks[p] = tk.BooleanVar(value=p in checked)
            tk.Checkbutton(cell, text=path.name[5:40], variable=ticks[p], fg=FG, bg=CARD, selectcolor=BG,
                           activebackground=CARD, activeforeground=FG, highlightthickness=0,
                           font=('Sans', 8)).pack()
            tags[p] = tk.Label(cell, text='', bg=CARD, font=('Sans', 8, 'bold'))
            tags[p].pack()
            cell.grid(row=n // 4, column=n % 4, padx=4, pady=4, sticky='nw')
        paint()
        tk.Label(self, text='click: tick · drag onto another plate: same group (asked once) · '
                            'right-click: out of its group · double-click: open',
                 fg=DIM, bg=CARD, font=('Sans', 8)).pack(anchor='w', padx=10)
        bar = tk.Frame(self, bg=CARD)
        bar.pack(fill='x', padx=10, pady=(0, 8))

        def every(on: bool):
            for v in ticks.values():
                v.set(on)

        def go():
            keep = [p for p in paths if ticks[p].get()]
            by_id: dict[int, list[str]] = {}
            for p in keep:
                if p in group:
                    by_id.setdefault(group[p], []).append(p)
            out = [g for g in by_id.values() if len(g) > 1]
            for w in bar.winfo_children():
                w.configure(state='disabled')
            self.write(f'{len(keep)} of {len(paths)} pictures continue, {len(out)} group(s)')
            answer({'keep': keep, 'groups': out})

        ttk.Button(bar, text='Continue', style='Accent.TButton', command=go).pack(side='left')
        ttk.Button(bar, text='All', command=lambda: every(True)).pack(side='left', padx=(8, 0))
        ttk.Button(bar, text='None', command=lambda: every(False)).pack(side='left', padx=(8, 0))
        ttk.Button(bar, text='Ungroup all', command=lambda: (group.clear(), paint())
                   ).pack(side='left', padx=(8, 0))

    def paste(self, dest: str, url: str, answer):
        """Open the file page, copy the picture, Ctrl+V (or Paste) here,
        Continue. Skip gives up on it and lets the run fail as before."""
        dest = Path(dest)
        self.write(url)
        zone = tk.Label(self.gallery, text='Ctrl+V a picture here', fg=DIM, bg=BG, width=48, height=8,
                        takefocus=1, highlightthickness=2, highlightbackground='#262a33',
                        highlightcolor=ACCENT)
        zone.pack(anchor='w')
        bar = tk.Frame(self, bg=CARD)
        bar.pack(fill='x', padx=10, pady=(0, 8))
        got = {}

        def grab(_=None):
            from PIL import ImageGrab
            try:
                im = ImageGrab.grabclipboard()
            except Exception as e:
                self.write(f'clipboard: {e}')
                return
            if isinstance(im, list):  # copied files
                im = next((Image.open(p) for p in im if IMG.search(str(p))), None)
            if im is None:
                self.write('no picture on the clipboard')
                return
            got['im'] = im
            th = im.copy()
            th.thumbnail((360, 220))
            ph = ImageTk.PhotoImage(th)
            self.tl.photos.append(ph)
            zone.configure(image=ph, width=0, height=0)
            go_btn.configure(state='normal')

        def finish(ok: bool):
            if ok:
                im = got['im']
                if dest.suffix.lower() in ('.jpg', '.jpeg'):
                    im = im.convert('RGB')
                im.save(dest)
                self.write(f'pasted → {dest.name}')
            for w in bar.winfo_children():
                w.configure(state='disabled')
            answer({'ok': ok})

        zone.bind('<Button-1>', lambda e: zone.focus_set())
        zone.bind('<Control-v>', grab)
        ttk.Button(bar, text='Open page', command=lambda: subprocess.Popen(['xdg-open', url])).pack(side='left')
        ttk.Button(bar, text='Paste', command=grab).pack(side='left', padx=(8, 0))
        go_btn = ttk.Button(bar, text='Continue', style='Accent.TButton', state='disabled',
                            command=lambda: finish(True))
        go_btn.pack(side='left', padx=(8, 0))
        ttk.Button(bar, text='Skip', command=lambda: finish(False)).pack(side='left', padx=(8, 0))
        zone.focus_set()

    def done(self, ok: bool, restored: bool = False):
        self.dot.configure(fg=OK if ok else BAD)
        self.rec['ok'] = ok
        if not restored:
            self.rec['time'] += ' → ' + time.strftime('%H:%M:%S')
            self.clock.configure(text=self.rec['time'])


def _scope(url: str) -> tuple[str, str]:
    """(tab title, package) for a url; ('new', '') until it parses."""
    m = re.search(r'/wiki/Vehicle_registration_plates_of_([^#?]+)', url)
    if not m:
        return 'new', ''
    country = re.sub(r'^the ', '', urllib.parse.unquote(m.group(1)).replace('_', ' '), flags=re.I)
    return country, re.sub(r'[^a-z0-9]+', '_', country.lower()).strip('_') + '_plate'


def _size(n: float, unit: str) -> str:
    if unit != 'B':
        return f'{n:g} {unit}'.strip()
    for u in ('B', 'kB', 'MB', 'GB'):
        if n < 1024 or u == 'GB':
            return f'{n:.0f} {u}' if u == 'B' else f'{n:.1f} {u}'
        n /= 1024


def _dur(s: float) -> str:
    s = int(s)
    return f'{s // 60}m{s % 60:02d}s' if s >= 60 else f'{s}s'


class CountryTab(tk.Frame):
    """One country: its own url, flags, process, queue, timeline, progress
    and log. Nothing here is shared with the other tabs."""

    def __init__(self, app: 'App', url: str = ''):
        super().__init__(app.book, bg=BG)
        self.app = app
        row = tk.Frame(self, bg=BG)
        row.pack(fill='x', padx=14, pady=(10, 4))
        tk.Label(row, text='Wikipedia URL', fg=DIM, bg=BG).pack(side='left')
        self.url = tk.Entry(row, bg=CARD, fg=FG, insertbackground=FG, relief='flat', font=MONO)
        self.url.insert(0, url or 'https://en.wikipedia.org/wiki/Vehicle_registration_plates_of_')
        self.url.pack(side='left', fill='x', expand=True, padx=8, ipady=6)
        self.url.bind('<KeyRelease>', lambda e: self.retitle())
        tk.Label(row, text='flags', fg=DIM, bg=BG).pack(side='left')
        self.flags = tk.Entry(row, bg=CARD, fg=FG, insertbackground=FG, relief='flat', font=MONO, width=28)
        self.flags.insert(0, '--github --push')
        self.flags.pack(side='left', padx=(8, 0), ipady=6)

        row = tk.Frame(self, bg=BG)
        row.pack(fill='x', padx=14, pady=(0, 6))
        for text, cmd, style in (('Before', lambda: self.pk('before'), 'Accent.TButton'),
                                 ('After', lambda: self.pk('after'), 'Accent.TButton'),
                                 ('Stop', self.stop, 'TButton'),
                                 ('Clear', lambda: self.tl.clear(), 'TButton')):
            ttk.Button(row, text=text, style=style, command=cmd).pack(side='left', padx=(0, 8))
        self.log_btn = ttk.Button(row, text='Log ▾', command=self.toggle_log)
        self.log_btn.pack(side='right')

        # two bars: the whole run (step n of total, moved on by the step's
        # items) and the thing happening right now (bytes, tokens, items)
        bars = tk.Frame(self, bg=BG)
        bars.pack(fill='x', padx=14)
        self.prog = ttk.Progressbar(bars, style='P.Horizontal.TProgressbar', maximum=1000)
        self.prog.pack(fill='x')
        self.status = tk.Label(bars, text='idle', fg=DIM, bg=BG, font=('Sans', 9), anchor='w')
        self.status.pack(fill='x', pady=(2, 4))
        self.tbar = ttk.Progressbar(bars, style='T.Horizontal.TProgressbar', maximum=1000)
        self.tbar.pack(fill='x')
        self.tstatus = tk.Label(bars, text='', fg=DIM, bg=BG, font=MONO, anchor='w')
        self.tstatus.pack(fill='x', pady=(2, 0))
        self.step = (0, 1, '')   # n, total, title
        self.sub = 0.0           # fraction of the current step
        self.started = self.step_started = 0.0
        self.task = None         # (label, t0, first done) for the rate
        self.pulsing = False

        term = tk.Frame(self, bg=BG)
        term.pack(side='bottom', fill='x', padx=14, pady=(4, 10))
        tk.Label(term, text='$', fg=ACCENT, bg=BG, font=MONO).pack(side='left')
        self.cmd = tk.Entry(term, bg=CARD, fg=FG, insertbackground=FG, relief='flat', font=MONO)
        self.cmd.pack(side='left', fill='x', expand=True, padx=8, ipady=6)
        self.cmd.bind('<Return>', lambda e: self.shell(self.cmd.get()))
        tk.Label(term, text=str(ROOT), fg=DIM, bg=BG, font=('Sans', 8)).pack(side='left')

        # timeline above, this tab's full log below; drag the sash to resize
        self.split = tk.PanedWindow(self, orient='vertical', bg='#262a33', sashwidth=5,
                                    borderwidth=0, sashrelief='flat')
        self.split.pack(fill='both', expand=True, padx=14, pady=4)
        self.tl = Timeline(self.split)
        self.split.add(self.tl, minsize=120, stretch='always')
        self.logbox = tk.Frame(self.split, bg=BG)
        self.log = make_log(self.logbox)
        self.split.add(self.logbox, minsize=60, height=220, stretch='never')

        self.q: queue.Queue = queue.Queue()
        self.proc: subprocess.Popen | None = None
        self.current: Card | None = None
        self.code = ''   # set from pk's first line; scopes the image scan
        self.after(60, self.pump)
        self.after(250, self.tick)

    def state(self) -> dict:
        return {'url': self.url.get(), 'flags': self.flags.get(), 'cards': self.tl.records,
                'log': self.log.get('1.0', 'end-1c').splitlines()[-3000:]}

    def restore(self, st: dict):
        self.flags.delete(0, 'end')
        self.flags.insert(0, st.get('flags', ''))
        self.tl.restore(st.get('cards', []))
        if st.get('log'):
            self.log.insert('end', '\n'.join(st['log']) + '\n')
            self.log.see('end')

    def retitle(self):
        title, _ = _scope(self.url.get())
        self.app.book.tab(self, text=('● ' if self.busy() else '') + title)

    def busy(self) -> bool:
        return bool(self.proc and self.proc.poll() is None)

    def toggle_log(self):
        if str(self.logbox) in self.split.panes():
            self.split.forget(self.logbox)
            self.log_btn.configure(text='Log ▸')
        else:
            self.split.add(self.logbox, minsize=60, height=220, stretch='never')
            self.log_btn.configure(text='Log ▾')
            self.log.see('end')

    # --------------------------------------------------------------- running
    def pk(self, stage: str):
        url = self.url.get().strip()
        _, pkg = _scope(url)
        for other in self.app.tabs():
            if other is not self and other.busy() and _scope(other.url.get())[1] == pkg:
                self.tl.card(f'{pkg} is already running in another tab', BAD).done(False)
                return
        before_only = {'--no-ask', '--no-archive', '--github', '--public'}
        after_only = {'--push', '--full'}
        drop = after_only if stage == 'before' else before_only
        flags = [f for f in self.flags.get().split() if f not in drop]
        self.run([sys.executable, '-u', str(PK), stage, url, *flags], f'pk {stage}', watch=True)

    def shell(self, line: str):
        if line.strip():
            self.cmd.delete(0, 'end')
            self.run(['bash', '-lc', line], f'$ {line}', watch=False)

    def run(self, argv: list[str], title: str, watch: bool):
        if self.busy():
            self.tl.card('busy — stop the running command in this tab first', BAD).done(False)
            return
        self.code = ''
        self.q.put(('card', title))
        self.q.put(('log', '== ' + title + '   ' + ' '.join(argv)))
        self.proc = subprocess.Popen(argv, cwd=ROOT, stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
                                     text=True, bufsize=1, env={**os.environ, **self.app.model_env()})
        self.retitle()
        threading.Thread(target=self._read, args=(self.proc, self.q, watch), daemon=True).start()

    @staticmethod
    def _read(proc: subprocess.Popen, q: queue.Queue, watch: bool):
        since = time.time()
        for raw in proc.stdout:
            line = raw.rstrip('\n')
            if line.startswith('\x1e'):  # a progress event, see platekit/progress.py
                try:
                    q.put(('ev', json.loads(line[1:])))
                except ValueError:
                    pass
                continue
            q.put(('log', line))
            if line.startswith('│ '):  # verbose model stream: log pane only
                continue
            if line.startswith('== '):  # a pk step boundary
                if watch:
                    q.put(('images', since))
                since = time.time()
                q.put(('card', line[3:]))
                continue
            q.put(('line', line))
        code = proc.wait()
        if watch:
            q.put(('images', since))
        q.put(('end', code))

    def stop(self):
        if self.busy():
            self.proc.terminate()

    # -------------------------------------------------------------- progress
    def set_progress(self):
        n, total, _ = self.step
        if n:
            self.prog.configure(value=1000 * ((n - 1) + min(self.sub, 1)) / total)

    def on_event(self, ev: dict):
        k = ev['k']
        if k == 'step':
            self.step, self.sub, self.step_started = (ev['n'], ev['total'], ev['title']), 0.0, time.time()
            self.set_progress()
        elif k == 'sub':
            self.sub = ev['n'] / max(ev['total'], 1)
            self.set_progress()
        elif k == 'task':
            self.show_task(ev)
        elif k == 'task_done':
            self.task = None
            self.pulse(False)
            self.tbar.configure(value=0)
            self.tstatus.configure(text='')
        elif k == 'pick':
            self.status.configure(text='waiting for you: ' + ev['title'], fg=ACCENT)
            self.tl.card(ev['title']).pick(ev['paths'], ev['checked'], ev.get('groups', []), self.answer)
        elif k == 'paste':
            self.status.configure(text='waiting for you: ' + ev['title'], fg=ACCENT)
            self.tl.card(ev['title']).paste(ev['path'], ev['url'], self.answer)
        elif k == 'image':
            p = Path(ev['path'])
            if self.current and p.exists():
                self.current.image(p)

    def answer(self, keep: dict):
        if self.busy():
            self.proc.stdin.write(json.dumps(keep) + '\n')
            self.proc.stdin.flush()

    def show_task(self, ev: dict):
        label, done, total, unit = ev['label'], ev['done'], ev['total'], ev.get('unit', '')
        now = time.time()
        key = label.split(' · ')[0]
        if not self.task or self.task[0] != key or done < self.task[2]:
            self.task = (key, now, done)
        _, t0, d0 = self.task
        rate = (done - d0) / (now - t0) if now - t0 > 0.5 else 0
        bits = [label]
        if total:
            self.pulse(False)
            self.tbar.configure(value=1000 * done / total)
            bits.append(f'{_size(done, unit)} / {_size(total, unit)}' if unit in ('B', 'tok')
                        else f'{done / total:.0%}')
            if rate > 0 and done < total:
                bits.append(f'{_size(rate, unit)}/s · {_dur((total - done) / rate)} left'
                            if unit == 'B' else f'{_dur((total - done) / rate)} left')
        else:
            self.pulse(True)
            if done:
                bits.append(_size(done, unit) + (f' · {rate:.1f} {unit}/s' if rate > 0 else ''))
        self.tstatus.configure(text='  ·  '.join(bits), fg=FG)

    def pulse(self, on: bool):
        if on and not self.pulsing:
            self.tbar.configure(mode='indeterminate')
            self.tbar.start(15)
        elif not on and self.pulsing:
            self.tbar.stop()
            self.tbar.configure(mode='determinate')
        self.pulsing = on

    def tick(self):
        if self.started:
            n, total, title = self.step
            now = time.time()
            where = f'step {n}/{total} · {title} · {_dur(now - self.step_started)}' if n else title
            eta = ''
            frac = self.prog['value'] / 1000
            if n and 0.05 < frac < 1:
                eta = f' · about {_dur((now - self.started) * (1 - frac) / frac)} left'
            self.status.configure(text=f'{where}   ·   total {_dur(now - self.started)}{eta}', fg=FG)
        self.after(250, self.tick)

    # ---------------------------------------------------------- ui updates
    def pump(self):
        try:
            for _ in range(500):  # keep the window responsive under a flood
                kind, val = self.q.get_nowait()
                if kind == 'ev':
                    self.on_event(val)
                elif kind == 'card':
                    if self.current:
                        self.current.done(True)
                    self.current = self.tl.card(val)
                    if val.startswith(('pk ', '$ ')):
                        self.step, self.sub = (0, 1, val), 0.0
                        self.started = self.step_started = time.time()
                        self.prog.configure(value=0)
                    elif not re.match(r'\d+/\d+', val):
                        self.step = (self.step[0], self.step[1], val)
                elif kind == 'line':
                    self.current.write(val)
                    m = re.match(r'.+ · code (\S+) · package ', val)
                    if m and not self.code:
                        self.code = m.group(1)
                    for m in re.finditer(r'(\S+\.(?:png|jpe?g|webp))', val):
                        p = (ROOT / m.group(1)).resolve()
                        if p.exists() and self._mine(p):
                            self.current.image(p)
                elif kind == 'log':
                    log_line(self.log, val)
                elif kind == 'images':
                    for p in self._new_images(val):
                        self.current.image(p)
                elif kind == 'end':
                    log_line(self.log, f'exit {val}')
                    self.current.write(f'exit {val}')
                    self.current.done(val == 0)
                    self.on_event({'k': 'task_done'})
                    if val == 0:
                        self.prog.configure(value=1000)
                    self.status.configure(text=f"{'done' if val == 0 else 'FAILED' if val > 0 else 'stopped'}"
                                               f" in {_dur(time.time() - self.started)}",
                                          fg=OK if val == 0 else BAD)
                    self.started = 0.0
                    self.current = None
                    self.after(100, self.retitle)
                    self.app.save()
        except queue.Empty:
            pass
        self.after(60, self.pump)

    def _dirs(self) -> list[Path]:
        """Where this tab's images live: its own .plateref/<code> and its
        own package's goldens — never another country's."""
        _, pkg = _scope(self.url.get())
        dirs = [ROOT / pkg / 'test' / 'goldens'] if pkg else []
        if self.code:
            dirs.append(ROOT / '.plateref' / self.code)
        return dirs

    def _mine(self, p: Path) -> bool:
        return any(p.is_relative_to(d.resolve()) for d in self._dirs())

    def _new_images(self, since: float) -> list[Path]:
        """Fallback for commands that send no image events (shell, flutter)."""
        found = []
        for base in self._dirs():
            if not base.exists():
                continue
            for p in base.rglob('*'):
                if IMG.search(p.name) and p.stat().st_mtime >= since - 1:
                    found.append(p)
        # sheets first, then the rest; originals last (they are huge)
        found.sort(key=lambda p: ('sheet' not in p.name, p.name.startswith('orig_'), p.name))
        return found


def make_log(box: tk.Frame) -> tk.Text:
    log = tk.Text(box, bg='#0b0d11', fg=DIM, font=MONO, relief='flat', height=16,
                  wrap='none', highlightthickness=0, insertbackground=FG)
    sb = ttk.Scrollbar(box, orient='vertical', command=log.yview)
    log.configure(yscrollcommand=sb.set)
    sb.pack(side='right', fill='y')
    log.pack(side='left', fill='both', expand=True)
    for tag, colour in (('think', '#bb9af7'), ('answer', OK), ('prompt', '#565f89'),
                        ('server', '#e0af68'), ('step', ACCENT), ('bad', BAD)):
        log.tag_configure(tag, foreground=colour)
    return log


def log_line(log: tk.Text, line: str):
    tag = ('server' if line.startswith('[server]') else 'step' if line.startswith('== ')
           else 'bad' if re.search(r'FAIL|error|Traceback', line) else '')
    m = re.match(r'│ ollama  (think|answer|prompt)', line)
    if m:
        tag = m.group(1)
    at_end = log.yview()[1] > 0.999
    log.insert('end', time.strftime('%H:%M:%S ') + line + '\n', tag)
    if int(log.index('end-1c').split('.')[0]) > 20000:
        log.delete('1.0', '2000.0')
    if at_end:
        log.see('end')


class App(tk.Tk):
    """The window: shared model settings and the ollama server, plus one
    CountryTab per country."""

    def __init__(self, urls: list[str]):
        super().__init__()
        self.title('platekit')
        self.geometry('1180x860')
        self.configure(bg=BG)
        style = ttk.Style(self)
        style.theme_use('clam')
        style.configure('TButton', background='#262a33', foreground=FG, borderwidth=0, padding=(14, 7))
        style.map('TButton', background=[('active', '#323846'), ('disabled', '#1c1f26')])
        style.configure('Accent.TButton', background=ACCENT, foreground='#0f1115')
        style.map('Accent.TButton', background=[('active', '#99b8ff')])
        style.configure('Vertical.TScrollbar', background='#262a33', troughcolor=BG, borderwidth=0, arrowsize=0)
        style.configure('P.Horizontal.TProgressbar', troughcolor=CARD, background=ACCENT,
                        bordercolor=CARD, lightcolor=ACCENT, darkcolor=ACCENT, thickness=10)
        style.configure('T.Horizontal.TProgressbar', troughcolor=CARD, background=OK,
                        bordercolor=CARD, lightcolor=OK, darkcolor=OK, thickness=5)
        style.configure('TNotebook', background=BG, borderwidth=0)
        style.configure('TNotebook.Tab', background=CARD, foreground=DIM, padding=(14, 5))
        style.map('TNotebook.Tab', background=[('selected', '#262a33')], foreground=[('selected', FG)])

        top = tk.Frame(self, bg=BG)
        top.pack(fill='x', padx=14, pady=(14, 4))
        ttk.Button(top, text='+ Country', style='Accent.TButton', command=self.add_tab).pack(side='left')
        ttk.Button(top, text='Close tab', command=self.close_tab).pack(side='left', padx=(8, 0))
        ttk.Button(top, text='Ollama', command=self.ollama).pack(side='left', padx=(8, 0))
        self.think = tk.BooleanVar(value=False)
        tk.Checkbutton(top, text='Think', variable=self.think, fg=DIM, bg=BG, selectcolor=CARD,
                       activebackground=BG, activeforeground=FG, highlightthickness=0
                       ).pack(side='left', padx=(8, 0))
        # which ollama model takes the simple / the harder questions
        try:
            out = subprocess.run(['ollama', 'list'], capture_output=True, text=True).stdout
        except FileNotFoundError:
            out = ''
        models = [l.split()[0] for l in out.splitlines()[1:] if l.strip()]
        self.small = tk.StringVar(value='qwen3.5:0.8b')
        self.big = tk.StringVar(value='qwen3.5:4b')
        for label, var in (('small', self.small), ('big', self.big)):
            tk.Label(top, text=label, fg=DIM, bg=BG).pack(side='left', padx=(8, 2))
            ttk.Combobox(top, textvariable=var, values=models, width=13).pack(side='left')
        self.srv_btn = ttk.Button(top, text='Server log ▸', command=self.toggle_server)
        self.srv_btn.pack(side='left', padx=(8, 0))

        # the ollama server is shared by every tab, so its log is too
        self.srvbox = tk.Frame(self, bg=BG)
        self.srvlog = make_log(self.srvbox)
        self.srvlog.configure(height=10)
        self.srvq: queue.Queue = queue.Queue()

        self.book = ttk.Notebook(self)
        self.book.pack(fill='both', expand=True)
        for st in self.load():
            self.add_tab(st.get('url', '')).restore(st)
        for url in urls or ([] if self.book.tabs() else ['']):
            self.add_tab(url)
        self.after(5000, self.autosave)
        self.protocol('WM_DELETE_WINDOW', self.quit_all)
        self.after(100, self.pump_server)
        self.tail_ollama()

    def tabs(self) -> list[CountryTab]:
        return [self.nametowidget(t) for t in self.book.tabs()]

    def add_tab(self, url: str = '') -> CountryTab:
        tab = CountryTab(self, url)
        self.book.add(tab)
        tab.retitle()
        self.book.select(tab)
        tab.url.focus_set()
        return tab

    # --------------------------------------------------------------- history
    @staticmethod
    def load() -> list[dict]:
        try:
            return json.loads(HISTORY.read_text()).get('tabs', [])
        except (OSError, ValueError):
            return []

    def save(self):
        try:
            HISTORY.parent.mkdir(parents=True, exist_ok=True)
            tmp = HISTORY.with_suffix('.tmp')
            tmp.write_text(json.dumps({'tabs': [t.state() for t in self.tabs()]}))
            tmp.replace(HISTORY)
        except (OSError, tk.TclError) as e:
            print(f'platekit: could not save history: {e}', file=sys.stderr)

    def autosave(self):
        self.save()
        self.after(5000, self.autosave)

    def close_tab(self):
        if not self.book.tabs():
            return
        tab = self.nametowidget(self.book.select())
        tab.stop()
        tab.destroy()
        if not self.book.tabs():
            self.add_tab()
        self.save()

    def quit_all(self):
        for tab in self.tabs():
            tab.stop()
        self.save()
        self.destroy()

    def model_env(self) -> dict[str, str]:
        return {'PYTHONUNBUFFERED': '1', 'PLATEKIT_PROGRESS': '1',
                'PLATEKIT_THINK': '1' if self.think.get() else '0',
                'PLATEKIT_SMALL': self.small.get().strip(),
                'PLATEKIT_BIG': self.big.get().strip()}

    def toggle_server(self):
        if self.srvbox.winfo_ismapped():
            self.srvbox.pack_forget()
            self.srv_btn.configure(text='Server log ▸')
        else:
            self.srvbox.pack(fill='x', padx=14, pady=(0, 4), before=self.book)
            self.srv_btn.configure(text='Server log ▾')
            self.srvlog.see('end')

    def pump_server(self):
        try:
            while True:
                log_line(self.srvlog, self.srvq.get_nowait())
        except queue.Empty:
            pass
        self.after(100, self.pump_server)

    def ollama(self):
        """Use the ollama that is already serving; start `ollama serve` only
        when nothing answers. Either way, tail its log into the server log."""
        say = self.srvq.put

        def up() -> bool:
            return subprocess.run(['ollama', 'ps'], capture_output=True).returncode == 0

        def work():
            if up():
                say('ollama: already running — using it')
            else:
                say('ollama: not running — starting ollama serve (log: /tmp/ollama.log)')
                try:
                    subprocess.Popen(['ollama', 'serve'], stdout=open('/tmp/ollama.log', 'ab'),
                                     stderr=subprocess.STDOUT, stdin=subprocess.DEVNULL,
                                     start_new_session=True)
                except FileNotFoundError:
                    say('error: ollama not found on PATH')
                    return
                for _ in range(100):  # up to 10s for the API to answer
                    if up():
                        break
                    time.sleep(0.1)
                else:
                    say('error: did not come up, see /tmp/ollama.log')
                    return
            for cmd in (['ollama', 'list'], ['ollama', 'ps']):
                out = subprocess.run(cmd, capture_output=True, text=True).stdout.rstrip()
                for l in ['$ ' + ' '.join(cmd), *out.splitlines()]:
                    say(l)
            self.tail_ollama()

        if not self.srvbox.winfo_ismapped():
            self.toggle_server()
        threading.Thread(target=work, daemon=True).start()

    def tail_ollama(self):
        """Follow the server log: the systemd journal when it runs as a
        service, else the file our own `ollama serve` writes to."""
        if getattr(self, 'tail', None) and self.tail.poll() is None:
            return
        if subprocess.run(['systemctl', 'is-active', '--quiet', 'ollama']).returncode == 0:
            argv = ['journalctl', '-u', 'ollama', '-f', '-n', '20', '-o', 'cat']
        else:
            argv = ['tail', '-n', '20', '-F', '/tmp/ollama.log']
        self.tail = subprocess.Popen(argv, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True)

        def read():
            for raw in self.tail.stdout:
                self.srvq.put('[server] ' + raw.rstrip('\n'))
        threading.Thread(target=read, daemon=True).start()


if __name__ == '__main__':
    App(sys.argv[1:]).mainloop()
