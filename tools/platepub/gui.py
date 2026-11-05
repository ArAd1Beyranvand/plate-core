"""Tk dashboard over the engine: pick rows, pick registries and steps, run; the daily button drives the quota loop."""
import queue
import threading
import tkinter as tk
from tkinter import messagebox, ttk

from . import pyweb
from .areas import describe
from .engine import Engine, Options
from .registries import REGISTRIES
from .util import Sh, default_proxy, packages


class App(tk.Tk):
    def __init__(self):
        super().__init__()
        self.title("Plate package manager")
        self.geometry("1500x820")
        self.q, self.stop = queue.Queue(), threading.Event()
        self.eng = Engine(log=lambda s: self.q.put(("log", s)), stop=self.stop)
        self.pkgs = packages()
        self.reg_vars = {k: tk.BooleanVar(value=k == "pubdev") for k in REGISTRIES}
        self.step_vars = {s: tk.BooleanVar(value=s in ("check", "publish")) for s in ("commit", "push", "check", "publish")}
        self.mode, self.full, self.republish = tk.StringVar(value="dry-run"), tk.BooleanVar(), tk.BooleanVar()
        self.filter, self.only_pending = tk.StringVar(), tk.BooleanVar()
        self.proxy, self.workers, self.batch = tk.StringVar(value=default_proxy()), tk.IntVar(value=4), tk.IntVar(value=4)
        self.build()
        for v in (*self.reg_vars.values(), self.filter, self.only_pending):
            v.trace_add("write", lambda *_: self.fill())
        self.fill()
        self.bg(self.eng.refresh_git)
        self.after(150, self.pump)
        self.after(1000, self.tick)

    def build(self):
        pad = dict(side="left", padx=3)
        row1 = ttk.Frame(self)
        row1.pack(fill="x", padx=6, pady=(6, 2))
        ttk.Label(row1, text="Filter").pack(**pad)
        ttk.Entry(row1, textvariable=self.filter, width=18).pack(**pad)
        ttk.Checkbutton(row1, text="only pending", variable=self.only_pending).pack(**pad)
        ttk.Separator(row1, orient="vertical").pack(side="left", fill="y", padx=8)
        ttk.Label(row1, text="Registries").pack(**pad)
        for k, r in REGISTRIES.items():
            ttk.Checkbutton(row1, text=r.label, variable=self.reg_vars[k]).pack(**pad)
        ttk.Separator(row1, orient="vertical").pack(side="left", fill="y", padx=8)
        ttk.Label(row1, text="Steps").pack(**pad)
        for s, v in self.step_vars.items():
            ttk.Checkbutton(row1, text=s, variable=v).pack(**pad)

        row2 = ttk.Frame(self)
        row2.pack(fill="x", padx=6, pady=2)
        ttk.Label(row2, text="Check").pack(**pad)
        ttk.Combobox(row2, textvariable=self.mode, values=("dry-run", "pana", "both"), width=8, state="readonly").pack(**pad)
        ttk.Checkbutton(row2, text="full points only", variable=self.full).pack(**pad)
        ttk.Checkbutton(row2, text="republish (bump)", variable=self.republish).pack(**pad)
        ttk.Label(row2, text="Proxy").pack(**pad)
        ttk.Entry(row2, textvariable=self.proxy, width=24).pack(**pad)
        ttk.Label(row2, text="Parallel").pack(**pad)
        ttk.Spinbox(row2, from_=1, to=16, textvariable=self.workers, width=3).pack(**pad)

        row3 = ttk.Frame(self)
        row3.pack(fill="x", padx=6, pady=2)
        self.buttons = [
            ttk.Button(row3, text="▶ Run on selection", command=lambda: self.start(self.selected())),
            ttk.Button(row3, text="▶ Run all pending", command=lambda: self.start(None)),
            ttk.Button(row3, text="▶ Daily pub.dev", command=self.start_daily),
            ttk.Button(row3, text="Sync with registries", command=self.sync),
            ttk.Button(row3, text="Build Python web", command=self.start_pyweb),
            ttk.Button(row3, text="Refresh git", command=lambda: self.bg(self.eng.refresh_git)),
        ]
        for b in self.buttons:
            b.pack(**pad)
        ttk.Label(row3, text="burst").pack(**pad)
        ttk.Spinbox(row3, from_=1, to=12, textvariable=self.batch, width=3).pack(**pad)
        self.stop_btn = ttk.Button(row3, text="■ Stop", command=self.stop.set, state="disabled")
        self.stop_btn.pack(side="right", padx=3)
        self.quota = ttk.Label(row3, text="")
        self.quota.pack(side="right", padx=12)

        paned = ttk.PanedWindow(self, orient="vertical")
        paned.pack(fill="both", expand=True, padx=6, pady=4)
        frame = ttk.Frame(paned)
        self.cols = ("pkg", "country", "git", *REGISTRIES)
        self.tree = ttk.Treeview(frame, columns=self.cols, show="headings", selectmode="extended")
        for c, h in zip(self.cols, ("Package", "Country / area", "Git", *(r.label for r in REGISTRIES.values()))):
            wide = c in ("pkg", "country")
            self.tree.heading(c, text=h)
            self.tree.column(c, width=190 if wide else 100, anchor="w" if wide else "center")
        sb = ttk.Scrollbar(frame, command=self.tree.yview)
        self.tree.configure(yscrollcommand=sb.set)
        self.tree.pack(side="left", fill="both", expand=True)
        sb.pack(side="right", fill="y")
        paned.add(frame, weight=3)
        self.logbox = tk.Text(paned, height=12, state="disabled", wrap="none")
        paned.add(self.logbox, weight=1)
        self.status = ttk.Label(self, text="Select rows, tick registries and steps, then run.")
        self.status.pack(fill="x", padx=6)

    # ---- table -----------------------------------------------------------
    def shown_regs(self):
        return [k for k, v in self.reg_vars.items() if v.get()]

    def cell(self, p, r):
        reg = REGISTRIES[r]
        if not reg.present(p):
            return "–"
        st = self.eng.state.reg(p, r)
        if st.get("published"):
            return "✔ " + (st.get("version") or reg.version(p) or "")
        return "✖ check" if str(st.get("checked", "")).endswith("FAIL") else "·"

    def values(self, p):
        g = self.eng.state.git(p)
        git = "?" if g.get("dirty") is None else ("dirty" if g["dirty"] else "clean") + (f" ↑{g['unpushed']}" if g.get("unpushed") else "")
        country, area = describe(p)
        return (p, f"{country} / {area}" if area else country, git, *(self.cell(p, r) for r in REGISTRIES))

    def fill(self):
        f, regs = self.filter.get().lower(), self.shown_regs()
        keys = list(REGISTRIES)
        self.tree.delete(*self.tree.get_children())
        for p in self.pkgs:
            v = self.values(p)
            if f and f not in (v[0] + v[1]).lower():
                continue
            if self.only_pending.get() and not any(v[3 + keys.index(r)].startswith(("·", "✖")) for r in regs):
                continue
            self.tree.insert("", "end", iid=p, values=v)

    def selected(self):
        return list(self.tree.selection())

    def tick(self):
        (day, dn, _), (burst, bn, _) = self.eng.quota.used("pubdev")
        w = self.eng.quota.wait("pubdev")
        self.quota.configure(text=f"pub.dev new packages: {day}/{dn} today, {burst}/{bn} in burst" + (f", next slot in {int(w // 60) + 1} min" if w else ""))
        self.after(5000, self.tick)

    # ---- running ---------------------------------------------------------
    def bg(self, fn):
        def job():
            fn()
            self.q.put(("fill",))
        threading.Thread(target=job, daemon=True).start()

    def sync(self):
        self.status.configure(text="Syncing with the registries...")
        self.bg(lambda: self.eng.sync(self.shown_regs() or list(REGISTRIES), proxy=self.proxy.get().strip()))

    def options(self):
        return Options(steps={s for s, v in self.step_vars.items() if v.get()}, regs=self.shown_regs(),
                       check_mode=self.mode.get(), need_full=self.full.get(), republish=self.republish.get(),
                       workers=max(1, self.workers.get()), proxy=self.proxy.get().strip())

    def busy(self, on):
        for b in self.buttons:
            b.configure(state="disabled" if on else "normal")
        self.stop_btn.configure(state="normal" if on else "disabled")
        if on:
            self.stop.clear()

    def start(self, pkgs):
        o = self.options()
        if not o.regs or not o.steps:
            return messagebox.showinfo("Nothing selected", "Tick at least one registry and one step.")
        units = self.eng.units(o.regs, pkgs)
        if "publish" in o.steps and not o.republish:
            units = [u for u in units if not self.eng.state.published(*u)]
        targets = sorted({p for p, _ in units})
        if not targets:
            return messagebox.showinfo("Nothing to do", "Everything selected is already published.")
        if "publish" in o.steps and not messagebox.askyesno(
                "Publish", f"{len(units)} unit(s) will be REALLY published to {', '.join(o.regs)} (irreversible). Continue?"):
            return
        self.busy(True)

        def job():
            failed = self.eng.run(targets, o)
            self.q.put(("done", f"Done. {len(failed)} failed: {', '.join(sorted(failed))}" if failed else "Done, no failures."))
        threading.Thread(target=job, daemon=True).start()

    def start_pyweb(self):
        pkgs = self.selected()
        self.busy(True)

        def job():
            code = pyweb.build(Sh(lambda m: self.q.put(("log", m)), self.proxy.get().strip(), self.stop), pkgs or None)
            self.q.put(("done", "Python web built." if code == 0 else "Python web build failed, see the log."))
        threading.Thread(target=job, daemon=True).start()

    def start_daily(self):
        o = self.options()
        todo = self.eng.pending("pubdev")
        if not todo or not messagebox.askyesno(
                "Daily pub.dev", f"{len(todo)} package(s) pending. Publish in bursts of {self.batch.get()} until the day limit, "
                "waiting between bursts? Irreversible."):
            return
        self.busy(True)

        def job():
            n, msg = self.eng.daily(o, "pubdev", max(1, self.batch.get()),
                                    poll=lambda s: self.q.put(("status", f"Waiting for the burst window: {int(s)}s")))
            self.q.put(("done", f"Published {n}. {msg}"))
        threading.Thread(target=job, daemon=True).start()

    def pump(self):
        try:
            while True:
                m = self.q.get_nowait()
                if m[0] == "log":
                    self.logbox.configure(state="normal")
                    self.logbox.insert("end", m[1] + "\n")
                    self.logbox.see("end")
                    self.logbox.configure(state="disabled")
                elif m[0] == "fill":
                    self.fill()
                elif m[0] == "status":
                    self.status.configure(text=m[1])
                elif m[0] == "done":
                    self.busy(False)
                    self.fill()
                    self.status.configure(text=m[1])
        except queue.Empty:
            pass
        self.after(150, self.pump)


def main():
    App().mainloop()
