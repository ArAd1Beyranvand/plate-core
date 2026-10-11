"""tkinter front end for analyzer/core.py. Run: python3 analyzer_gui.py

All work happens on one worker thread; it talks to the UI only through a
queue that the UI drains with after().
"""

import queue
import threading
import time
import tkinter as tk
from tkinter import messagebox, ttk

from analyzer import core


class App:
    def __init__(self, root):
        self.root = root
        self.q = queue.Queue()
        self.stop = threading.Event()
        self.worker = None
        root.title('Plate migration analyzer')
        root.geometry('1300x850')

        top = ttk.Frame(root, padding=4)
        top.pack(fill='x')
        self.endpoint = tk.StringVar(value=core.Settings.endpoint)
        self.model = tk.StringVar()
        self.num_ctx = tk.StringVar(value=str(core.Settings.num_ctx))
        self.temperature = tk.StringVar(value=str(core.Settings.temperature))
        self.retries = tk.StringVar(value=str(core.Settings.retries))
        self.think = tk.BooleanVar(value=False)
        self.skip_done = tk.BooleanVar(value=True)
        self.show_prompt = tk.BooleanVar(value=False)
        for label, var, width in (('Endpoint', self.endpoint, 26), ('num_ctx', self.num_ctx, 7),
                                  ('temp', self.temperature, 5), ('retries', self.retries, 3)):
            ttk.Label(top, text=label).pack(side='left', padx=(6, 2))
            ttk.Entry(top, textvariable=var, width=width).pack(side='left')
        ttk.Label(top, text='Model').pack(side='left', padx=(6, 2))
        self.model_box = ttk.Combobox(top, textvariable=self.model, width=28)
        self.model_box.pack(side='left')
        ttk.Button(top, text='Refresh models', command=self.refresh_models).pack(side='left', padx=4)
        ttk.Checkbutton(top, text='think', variable=self.think).pack(side='left')
        ttk.Checkbutton(top, text='skip countries with reports', variable=self.skip_done).pack(side='left', padx=6)
        ttk.Checkbutton(top, text='show prompts', variable=self.show_prompt).pack(side='left')

        body = ttk.PanedWindow(root, orient='horizontal')
        body.pack(fill='both', expand=True)

        left = ttk.Frame(body, padding=4)
        body.add(left, weight=1)
        self.tree = ttk.Treeview(left, columns=('status',), selectmode='none', height=30)
        self.tree.heading('#0', text='country')
        self.tree.heading('status', text='status')
        self.tree.column('#0', width=200)
        self.tree.column('status', width=90)
        self.tree.pack(fill='both', expand=True)
        self.tree.bind('<Button-1>', self.toggle)
        self.checked = set()
        sel = ttk.Frame(left)
        sel.pack(fill='x')
        ttk.Button(sel, text='All', command=lambda: self.check_all(True)).pack(side='left')
        ttk.Button(sel, text='None', command=lambda: self.check_all(False)).pack(side='left')
        for text, cmd in (('Run selected', self.run_selected), ('Run all', self.run_all),
                          ('Re-run failed', self.rerun_failed), ('Stop', self.request_stop),
                          ('Rebuild dumps/prepass', self.rebuild)):
            ttk.Button(left, text=text, command=cmd).pack(fill='x', pady=1)

        right = ttk.PanedWindow(body, orient='vertical')
        body.add(right, weight=4)
        self.stream = self._text(right, 'Model output (streamed)', 3)
        self.log = self._text(right, 'Log', 2)
        self.prompt = self._text(right, 'Prompts sent', 2)

        self.redo = set()
        self.reload_countries()
        self.offer_resume()
        self.refresh_models()
        root.after(100, self.drain)

    def _text(self, parent, title, weight):
        frame = ttk.LabelFrame(parent, text=title)
        parent.add(frame, weight=weight)
        text = tk.Text(frame, wrap='word', height=8, font=('TkFixedFont', 9))
        bar = ttk.Scrollbar(frame, command=text.yview)
        text.configure(yscrollcommand=bar.set)
        bar.pack(side='right', fill='y')
        text.pack(fill='both', expand=True)
        return text

    # ------------------------------------------------------------ country list

    def reload_countries(self):
        self.tree.delete(*self.tree.get_children())
        for c in core.countries():
            self.tree.insert('', 'end', iid=c, text=self._label(c), values=(self._status(c),))

    def _label(self, c):
        return ('☑ ' if c in self.checked else '☐ ') + c

    def _status(self, c):
        s = core.report_status(c)
        return '' if s is None else 'done' if s == 0 else f'{s} failed'

    def toggle(self, event):
        c = self.tree.identify_row(event.y)
        if c:
            self.checked ^= {c}
            self.tree.item(c, text=self._label(c))

    def check_all(self, on):
        self.checked = set(self.tree.get_children()) if on else set()
        for c in self.tree.get_children():
            self.tree.item(c, text=self._label(c))

    def offer_resume(self):
        done = [c for c in core.countries() if core.report_status(c) is not None]
        if not done:
            return
        answer = messagebox.askyesnocancel(
            'Existing reports',
            f'{len(done)} countries already have reports.\n\n'
            'Yes: skip them on Run all (resume).\n'
            'No: redo them (cached unit results are discarded when a country runs).\n'
            'Cancel: decide per run with the "skip countries with reports" box.')
        if answer is True:
            self.skip_done.set(True)
        elif answer is False:
            self.skip_done.set(False)
            self.redo = set(done)

    # ------------------------------------------------------------ actions

    def settings(self):
        try:
            return core.Settings(endpoint=self.endpoint.get().strip(), model=self.model.get().strip(),
                                 num_ctx=int(self.num_ctx.get()), temperature=float(self.temperature.get()),
                                 think=self.think.get(), retries=int(self.retries.get()))
        except ValueError as e:
            messagebox.showerror('Settings', str(e))
            return None

    def refresh_models(self):
        endpoint = self.endpoint.get()

        def work():
            try:
                models = core.list_models(endpoint)
                self.q.put(('models', models))
            except OSError as e:
                self.q.put(('log', f'cannot list models at {endpoint}: {e}'))
        threading.Thread(target=work, daemon=True).start()

    def start(self, fn):
        if self.worker and self.worker.is_alive():
            messagebox.showinfo('Busy', 'A run is in progress; press Stop first.')
            return
        self.stop.clear()
        self.worker = threading.Thread(target=self._guard, args=(fn,), daemon=True)
        self.worker.start()

    def _guard(self, fn):
        try:
            fn()
        except core.Stopped:
            self.q.put(('log', 'stopped'))
        except Exception as e:  # report anything; the UI must survive
            self.q.put(('log', f'ERROR {type(e).__name__}: {e}'))
        finally:
            self.q.put(('idle', None))

    def _run(self, todo, failed_only=False):
        s = self.settings()
        if not s:
            return
        if not s.model:
            messagebox.showerror('Model', 'Pick a model first (Refresh models).')
            return
        skip = self.skip_done.get() and not failed_only
        sink = self._sink()

        def work():
            for c in todo:
                if self.stop.is_set():
                    raise core.Stopped()
                if skip and core.report_status(c) is not None:
                    self.q.put(('log', f'[{c}] skipped: report exists'))
                    continue
                if c in self.redo:
                    core.reset_country(c)
                    self.redo.discard(c)
                self.q.put(('status', (c, 'running')))
                start = time.time()
                core.run_country(c, s, sink)
                self.q.put(('log', f'[{c}] finished in {time.time() - start:.0f}s'))
                self.q.put(('status', (c, None)))
        self.start(work)

    def run_selected(self):
        self._run(sorted(self.checked))

    def run_all(self):
        self._run(core.countries())

    def rerun_failed(self):
        # Cached successes are reused, so rerunning a country only redoes
        # the units that failed (plus the synthesis).
        self._run([c for c in core.countries() if (core.report_status(c) or 0) > 0], failed_only=True)

    def request_stop(self):
        self.stop.set()
        self.q.put(('log', 'stop requested; finishing the current token stream...'))

    def rebuild(self):
        sink = self._sink()

        def work():
            ok = core.rebuild(sink)
            self.q.put(('log', 'rebuild ' + ('done' if ok else 'FAILED')))
            self.q.put(('reload', None))
        self.start(work)

    def _sink(self):
        return core.Sink(
            log=lambda m: self.q.put(('log', m)),
            token=lambda t: self.q.put(('token', t)),
            prompt=lambda p: self.q.put(('prompt', p)),
            stop_requested=self.stop.is_set,
        )

    # ------------------------------------------------------------ queue

    def drain(self):
        try:
            for _ in range(2000):
                kind, value = self.q.get_nowait()
                if kind == 'token':
                    self._append(self.stream, value)
                elif kind == 'log':
                    self._append(self.log, f'{time.strftime("%H:%M:%S")} {value}\n')
                    if value.startswith('[') and ' prompt ≈' in value:
                        self._append(self.stream, f'\n--- {value}\n')
                elif kind == 'prompt':
                    # Filtered here: Tk variables are main-thread only.
                    if self.show_prompt.get():
                        self._append(self.prompt, value)
                elif kind == 'models':
                    self.model_box['values'] = value
                    if value and not self.model.get():
                        self.model.set(value[0])
                    self._append(self.log, f'{len(value)} models available\n')
                elif kind == 'status':
                    c, st = value
                    if self.tree.exists(c):
                        self.tree.set(c, 'status', st or self._status(c))
                elif kind == 'reload':
                    self.reload_countries()
                elif kind == 'idle':
                    self._append(self.log, f'{time.strftime("%H:%M:%S")} idle\n')
        except queue.Empty:
            pass
        self.root.after(100, self.drain)

    @staticmethod
    def _append(widget, text):
        at_end = widget.yview()[1] > 0.98
        widget.insert('end', text)
        if int(widget.index('end-1c').split('.')[0]) > 20000:
            widget.delete('1.0', '5000.0')
        if at_end:
            widget.see('end')


def main():
    root = tk.Tk()
    App(root)
    root.mainloop()


if __name__ == '__main__':
    main()
