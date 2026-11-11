#!/usr/bin/env python3
"""Package Builder: build the TypeScript, Kotlin (Gradle: JS + Wasm) and Python web components into deploy/.

    python3 tools/package_builder.py

A country is rebuilt only when its sources, or the shared core of that language, changed since its last
successful build here (fingerprints in tools/package_builder_state.json) or its output is missing.
Flutter is not built here: the website build does it.
"""
import hashlib, json, os, re, subprocess, sys
from pathlib import Path

from PySide6.QtCore import QObject, QProcess, QProcessEnvironment, Qt, QThread, Signal
from PySide6.QtGui import QColor, QFont
from PySide6.QtWidgets import (QApplication, QCheckBox, QFrame, QHBoxLayout, QLabel, QLineEdit, QMainWindow,
                               QPlainTextEdit, QProgressBar, QPushButton, QTableWidget, QTableWidgetItem,
                               QVBoxLayout, QWidget, QHeaderView, QSpinBox)

ROOT = Path(__file__).resolve().parents[1]
CORE = ROOT / "plate_core"
DEPLOY = ROOT / "deploy" / "components"
STATE = Path(__file__).with_name("package_builder_state.json")
SKIP = {"__pycache__", "node_modules", ".gen", "build", "dist", ".gradle"}
COUNTRIES = "countries"


def _lang(key, label, tagline, accent, cwd, cmd, shared, country_dir, extra, out, stamps=()):
    return dict(key=key, label=label, tagline=tagline, accent=accent, cwd=CORE / cwd, cmd=cmd, shared=shared,
                country=country_dir, extra=extra, out=out, stamps=stamps)


LANGS = [
    _lang("ts", "TypeScript", "Vite · shared runtime chunk", "#3b82f6", "typescript",
          lambda cs: ["node", "web/build.mjs", *cs],
          [("typescript/src", COUNTRIES), ("typescript/web", ".gen"), ("web/embed-client", None)],
          lambda c: CORE / "typescript/src/countries" / c, lambda c: [CORE / "data/countries" / f"{c}_plate.json"],
          "typescript", ["typescript/web/.gen/stamps/{c}"]),
    _lang("kt", "Kotlin", "Gradle · JS + Wasm", "#a855f7", "kotlin",
          lambda cs: ["node", "web/build.mjs", *cs],
          [("kotlin/src/commonMain", COUNTRIES), ("kotlin/src/webMain", None), ("kotlin/web/index.html", None),
           ("kotlin/build.gradle.kts", None), ("kotlin/settings.gradle.kts", None), ("kotlin/gradle.properties", None)],
          lambda c: CORE / "kotlin/src/commonMain/kotlin/plates/countries" / c,
          lambda c: [CORE / "data/countries" / f"{c}_plate.json"], "kotlin", ["kotlin/build/web-stamps/{c}"]),
    _lang("py", "Python", "Pyodide · zipped sources", "#f59e0b", "python",
          lambda cs: ["python3", "web/build.py", ",".join(cs)],
          [("python/plates", COUNTRIES), ("python/web/boot.js", None), ("python/web/build.py", None),
           ("python/web/index.html", None)],
          lambda c: CORE / "python/plates/countries" / c, lambda c: [CORE / "data/countries" / f"{c}_plate.json"],
          "python"),
]


# Per-asset webpack/yarn chatter that drowns the one line per country the log is for.
NOISE = re.compile(r"\s*(\./kotlin/|asset |runtime modules|cacheable modules|webpack \d|warning (Waiting for the other yarn|Ignored scripts))")


def files_in(path, prune=None):
    path = Path(path)
    if path.is_file():
        yield path
        return
    for d, dirs, names in os.walk(path, followlinks=True):
        dirs[:] = sorted(x for x in dirs if x not in SKIP and x != prune)
        for n in sorted(names):
            yield Path(d) / n


def digest(paths):
    h = hashlib.sha256()
    for p in paths:
        if p.is_file():
            h.update(p.name.encode() + b"\0" + p.read_bytes())
    return h.hexdigest()


def country_names():
    return sorted(p.name for p in (CORE / "typescript/src/countries").iterdir() if (p / "index.ts").exists())


def fingerprints(lang):
    """{country: fingerprint}: shared core of [lang] plus the country's own files and data."""
    shared = digest(f for rel, prune in lang["shared"] for f in files_in(CORE / rel, prune))
    return {c: hashlib.sha256((shared + digest(files_in(lang["country"](c))) + digest(lang["extra"](c))).encode()).hexdigest()
            for c in country_names()}


class Scan(QThread):
    done = Signal(dict)

    def run(self):
        saved = json.loads(STATE.read_text()) if STATE.exists() else {}
        out = {}
        for lang in LANGS:
            now, was = fingerprints(lang), saved.get(lang["key"], {})
            out[lang["key"]] = {c: ("fresh" if was.get(c) == fp and (DEPLOY / c.replace("_", "-") / lang["out"] / "index.html").exists()
                                    else "new" if c not in was else "stale") for c, fp in now.items()}
            out[lang["key"] + ":fp"] = now
        self.done.emit(out)


CSS = """
* { font-family: 'Inter','Segoe UI',sans-serif; font-size: 13px; color: #e6e8ee; }
QMainWindow, QWidget#root { background: #0f1117; }
QFrame#card { background: #171a23; border: 1px solid #262b38; border-radius: 12px; }
QFrame#card[on="true"] { border: 1px solid %s; }
QLabel#title { font-size: 22px; font-weight: 700; } QLabel#sub, QLabel#hint { color: #8a91a5; }
QLabel#cardTitle { font-size: 15px; font-weight: 600; }
QLineEdit { background: #171a23; border: 1px solid #262b38; border-radius: 8px; padding: 8px 10px; }
QLineEdit:focus { border-color: #4f8cff; }
QTableWidget { background: #131620; border: 1px solid #262b38; border-radius: 10px; gridline-color: transparent; }
QHeaderView::section { background: #131620; color: #8a91a5; border: none; padding: 6px; }
QTableWidget::item:selected { background: #1f2536; }
QPushButton { background: #1f2433; border: 1px solid #2c3346; border-radius: 8px; padding: 8px 14px; }
QPushButton:hover { background: #262d40; } QPushButton:disabled { color: #5b6377; }
QPushButton#primary { background: #4f8cff; border: none; color: white; font-weight: 600; padding: 10px 22px; }
QPushButton#primary:hover { background: #6a9fff; } QPushButton#primary:disabled { background: #2a3350; color: #7d86a0; }
QPlainTextEdit { background: #0b0d12; border: 1px solid #262b38; border-radius: 10px; font-family: 'JetBrains Mono','DejaVu Sans Mono',monospace; font-size: 12px; }
QProgressBar { background: #171a23; border: none; border-radius: 4px; max-height: 8px; }
QProgressBar::chunk { background: #4f8cff; border-radius: 4px; }
QCheckBox::indicator { width: 16px; height: 16px; border-radius: 4px; border: 1px solid #3a4258; background: #131620; }
QCheckBox::indicator:checked { background: #4f8cff; border-color: #4f8cff; }
"""
BADGE = {"fresh": ("Up to date", "#34d399"), "stale": ("Changed", "#fbbf24"), "new": ("Not built", "#f87171")}


class Card(QFrame):
    def __init__(self, lang, toggled):
        super().__init__()
        self.lang = lang
        self.setObjectName("card")
        self.check = QCheckBox()
        self.check.setChecked(True)
        self.check.toggled.connect(lambda _: (self._paint(), toggled()))
        self.stat = QLabel("scanning…")
        self.stat.setObjectName("hint")
        title = QLabel(lang["label"])
        title.setObjectName("cardTitle")
        sub = QLabel(lang["tagline"])
        sub.setObjectName("hint")
        col = QVBoxLayout()
        col.setSpacing(2)
        for w in (title, sub, self.stat):
            col.addWidget(w)
        row = QHBoxLayout(self)
        row.addWidget(self.check, 0, Qt.AlignTop)
        row.addLayout(col, 1)
        self._paint()

    def mousePressEvent(self, e):
        self.check.toggle()

    def _paint(self):
        self.setStyleSheet(f"QFrame#card[on='true']{{border:1px solid {self.lang['accent']};}}")
        self.setProperty("on", self.check.isChecked())
        self.style().unpolish(self)
        self.style().polish(self)


class Window(QMainWindow):
    def __init__(self):
        super().__init__()
        self.setWindowTitle("Package Builder")
        self.resize(1180, 820)
        self.status, self.fps, self.queue, self.pending, self.procs = {}, {}, [], [], set()
        root = QWidget()
        root.setObjectName("root")
        self.setCentralWidget(root)
        page = QVBoxLayout(root)
        page.setContentsMargins(28, 24, 28, 24)
        page.setSpacing(14)
        title, sub = QLabel("Package Builder"), QLabel("Builds only what changed since the last build. Flutter is built with the website.")
        title.setObjectName("title")
        sub.setObjectName("sub")
        page.addWidget(title)
        page.addWidget(sub)

        cards = QHBoxLayout()
        cards.setSpacing(12)
        self.cards = [Card(l, self.refresh) for l in LANGS]
        for c in self.cards:
            cards.addWidget(c)
        page.addLayout(cards)

        bar = QHBoxLayout()
        self.all_langs = QCheckBox("Select all targets")
        self.all_langs.setChecked(True)
        self.all_langs.toggled.connect(lambda on: [c.check.setChecked(on) for c in self.cards])
        self.search = QLineEdit(placeholderText="Search countries…")
        self.search.textChanged.connect(self.filter)
        bar.addWidget(self.all_langs)
        bar.addWidget(self.search, 1)
        for text, fn in (("All", lambda c, s: True), ("Changed", lambda c, s: s != "fresh"), ("None", lambda c, s: False)):
            b = QPushButton(text)
            b.clicked.connect(lambda _=0, fn=fn: self.pick(fn))
            bar.addWidget(b)
        page.addLayout(bar)

        self.table = QTableWidget(0, 4)
        self.table.setHorizontalHeaderLabels(["Country"] + [l["label"] for l in LANGS])
        self.table.verticalHeader().hide()
        self.table.setShowGrid(False)
        self.table.setSelectionMode(QTableWidget.NoSelection)
        self.table.setEditTriggers(QTableWidget.NoEditTriggers)
        self.table.horizontalHeader().setSectionResizeMode(QHeaderView.Stretch)
        self.table.itemChanged.connect(lambda _: self.refresh())
        page.addWidget(self.table, 3)

        foot = QHBoxLayout()
        self.force = QCheckBox("Force rebuild (ignore up-to-date)")
        self.jobs = QSpinBox()
        self.jobs.setRange(1, os.cpu_count() or 4)
        self.jobs.setValue(min(3, max(1, (os.cpu_count() or 4) // 4)))
        self.jobs.setPrefix("Parallel jobs: ")
        self.summary = QLabel("")
        self.summary.setObjectName("hint")
        self.go, self.stop = QPushButton("Build"), QPushButton("Cancel")
        self.go.setObjectName("primary")
        self.go.clicked.connect(self.build)
        self.stop.clicked.connect(self.cancel)
        self.stop.setEnabled(False)
        self.rescan = QPushButton("Rescan")
        self.rescan.clicked.connect(self.scan)
        for w in (self.force, self.jobs, self.summary):
            foot.addWidget(w)
        foot.addStretch(1)
        for w in (self.rescan, self.stop, self.go):
            foot.addWidget(w)
        page.addLayout(foot)
        self.progress = QProgressBar()
        self.progress.setTextVisible(False)
        page.addWidget(self.progress)
        self.log = QPlainTextEdit(readOnly=True)
        page.addWidget(self.log, 2)
        self.scan()

    # --- scanning -------------------------------------------------------------------------------
    def scan(self):
        self.go.setEnabled(False)
        self.summary.setText("Scanning sources…")
        self.scanner = Scan()
        self.scanner.done.connect(self.scanned)
        self.scanner.start()

    def scanned(self, out):
        self.status = {l["key"]: out[l["key"]] for l in LANGS}
        self.fps = {l["key"]: out[l["key"] + ":fp"] for l in LANGS}
        names = country_names()
        self.table.blockSignals(True)
        self.table.setRowCount(len(names))
        for r, c in enumerate(names):
            it = QTableWidgetItem(c.replace("_", " ").title())
            it.setData(Qt.UserRole, c)
            it.setFlags(Qt.ItemIsEnabled | Qt.ItemIsUserCheckable)
            it.setCheckState(Qt.Checked if any(self.status[l["key"]][c] != "fresh" for l in LANGS) else Qt.Unchecked)
            self.table.setItem(r, 0, it)
            for i, l in enumerate(LANGS, 1):
                text, color = BADGE[self.status[l["key"]][c]]
                cell = QTableWidgetItem("●  " + text)
                cell.setForeground(QColor(color))
                self.table.setItem(r, i, cell)
        self.table.blockSignals(False)
        self.refresh()

    def countries(self):
        t = self.table
        return [t.item(r, 0).data(Qt.UserRole) for r in range(t.rowCount()) if t.item(r, 0).checkState() == Qt.Checked]

    def pick(self, fn):
        self.table.blockSignals(True)
        for r in range(self.table.rowCount()):
            c = self.table.item(r, 0).data(Qt.UserRole)
            on = any(fn(c, self.status[l["key"]][c]) for l in LANGS if self.cards[LANGS.index(l)].check.isChecked())
            self.table.item(r, 0).setCheckState(Qt.Checked if on else Qt.Unchecked)
        self.table.blockSignals(False)
        self.refresh()

    def filter(self, text):
        for r in range(self.table.rowCount()):
            self.table.setRowHidden(r, text.lower() not in self.table.item(r, 0).text().lower())

    def plan(self):
        """[(lang, [countries])]: ticked targets x ticked countries, minus the up-to-date ones."""
        picked, jobs = self.countries(), []
        for l, card in zip(LANGS, self.cards):
            if card.check.isChecked():
                todo = [c for c in picked if self.force.isChecked() or self.status[l["key"]][c] != "fresh"]
                if todo:
                    jobs.append((l, todo))
        return jobs

    def refresh(self):
        if not self.status:
            return
        for l, card in zip(LANGS, self.cards):
            s = self.status[l["key"]]
            card.stat.setText(f"{sum(v != 'fresh' for v in s.values())} to build · {sum(v == 'fresh' for v in s.values())} up to date")
        jobs = self.plan()
        n = sum(len(cs) for _, cs in jobs)
        self.summary.setText(f"{n} build{'s' * (n != 1)} queued" if n else "Nothing to build — everything selected is up to date")
        self.go.setEnabled(bool(n) and not self.procs)

    # --- building -------------------------------------------------------------------------------
    def build(self):
        self.queue = self.plan()
        self.total = sum(len(cs) for _, cs in self.queue)
        self.done_count = 0
        self.progress.setRange(0, self.total)
        self.progress.setValue(0)
        self.log.clear()
        self.stop.setEnabled(True)
        self.go.setEnabled(False)
        self.pending = self.tasks()
        self.next_job()

    def tasks(self):
        """Plan -> processes. TypeScript is split into one chunk per job; Kotlin links `jobs` countries at once inside
        its own build.mjs (PLATE_KT_JOBS); Python rewrites its shared archive on every run, so it stays one process."""
        n, out = self.jobs.value(), []
        for lang, cs in self.queue:
            if lang["key"] == "ts":
                out += [(lang, cs[i::n], {}) for i in range(min(n, len(cs)))]
            else:
                out.append((lang, cs, {"PLATE_KT_JOBS": str(n)} if lang["key"] == "kt" else {}))
        return sorted(out, key=lambda t: t[0]["key"] != "kt")

    def next_job(self):
        while self.pending and len(self.procs) < self.jobs.value() + 1:
            lang, cs, env = self.pending.pop(0)
            if self.force.isChecked():
                for c in cs:
                    for s in lang["stamps"]:
                        (CORE / s.format(c=c)).unlink(missing_ok=True)
            cmd = lang["cmd"](cs)
            self.say(f"\n▶ {lang['label']}: {len(cs)} countr{'ies' if len(cs) != 1 else 'y'}\n$ {' '.join(cmd[:3])}{' …' if len(cmd) > 3 else ''}\n")
            proc, ok = QProcess(self), set()
            e = QProcessEnvironment.systemEnvironment()
            for k, v in env.items():
                e.insert(k, v)
            proc.setProcessEnvironment(e)
            proc.setWorkingDirectory(str(lang["cwd"]))
            proc.setProcessChannelMode(QProcess.MergedChannels)
            proc.readyReadStandardOutput.connect(lambda proc=proc, cs=cs, ok=ok: self.read(proc, cs, ok))
            proc.finished.connect(lambda code, _s, proc=proc, lang=lang, cs=cs, ok=ok: self.job_done(proc, lang, cs, ok, code))
            proc.errorOccurred.connect(lambda err: self.say(f"✖ could not start: {err}\n") if err == QProcess.FailedToStart else None)
            self.procs.add(proc)
            proc.start(cmd[0], cmd[1:])
        if not self.pending and not self.procs:
            self.finish()

    def read(self, proc, cs, ok):
        text = bytes(proc.readAllStandardOutput()).decode(errors="replace")
        self.say("".join(l for l in text.splitlines(True) if not NOISE.match(l)))
        for m in re.finditer(r"^(\w+): (?:built|up to date)", text, re.M):
            if m[1] in cs and m[1] not in ok:
                ok.add(m[1])
                self.tick()

    def job_done(self, proc, lang, cs, ok, code):
        if code == 0:
            for c in cs:
                if c not in ok:
                    ok.add(c)
                    self.tick()
        saved = json.loads(STATE.read_text()) if STATE.exists() else {}
        saved.setdefault(lang["key"], {}).update({c: self.fps[lang["key"]][c] for c in ok})
        STATE.write_text(json.dumps(saved, indent=1))
        self.say(f"{'✔' if code == 0 else '✖'} {lang['label']} {'done' if code == 0 else f'failed (exit {code}); {len(ok)} of {len(cs)} recorded'}\n")
        self.procs.discard(proc)
        if code != 0:
            self.pending.clear()
        self.next_job()

    def tick(self):
        self.done_count += 1
        self.progress.setValue(self.done_count)

    def finish(self):
        self.stop.setEnabled(False)
        # The site reads components/index.json for each component's hash; without a fresh one it serves stale builds.
        done = subprocess.run([sys.executable, str(CORE / "web/registry.py"), "--deploy", str(ROOT / "deploy")], capture_output=True, text=True)
        self.say(f"\n{(done.stdout or done.stderr).strip()}\nFinished.\n")
        self.scan()

    def cancel(self):
        self.pending.clear()
        for p in list(self.procs):
            p.kill()

    def say(self, text):
        self.log.moveCursor(self.log.textCursor().MoveOperation.End)
        self.log.insertPlainText(text)
        self.log.ensureCursorVisible()


def main():
    app = QApplication(sys.argv)
    app.setStyleSheet(CSS % "#4f8cff")
    app.setFont(QFont("Inter", 10))
    w = Window()
    w.show()
    return app.exec()


if __name__ == "__main__":
    sys.exit(main())
