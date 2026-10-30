"""Black PySide6 front end. It only reads the store (polling) and calls Engine control methods, so the
engine thread never touches Qt."""
import html, json, time

from PySide6.QtCore import Qt, QTimer
from PySide6.QtGui import QColor, QFont, QTextCursor, QBrush
from PySide6.QtWidgets import (QApplication, QCheckBox, QComboBox, QHBoxLayout, QHeaderView, QLabel,
                               QLineEdit, QMainWindow, QPlainTextEdit, QPushButton, QSplitter, QTableWidget,
                               QTableWidgetItem, QTabWidget, QTextEdit, QTreeWidget, QTreeWidgetItem,
                               QVBoxLayout, QWidget, QFrame)

import config as C

BG, PANEL, LINE, TEXT, DIM = '#09090b', '#111114', '#24252c', '#d8dae2', '#6b6f7b'
SOURCE = {'python': '#9aa0a6', 'oracle': '#7fd18b', 'qwen': '#3fd4dc', 'qwen.out': '#8fe9ee',
          'claude': '#f5b041', 'claude.out': '#ffd38a', 'claude.tool': '#d49a3a', 'claude.result': '#8a7a5c',
          'router': '#b48cff', 'engine': '#e6e6e6', 'gate': '#ff7ad9'}
STATUS = {'pending': DIM, 'running': '#3fd4dc', 'done': '#7fd18b', 'failed': '#ff5c6c',
          'escalated': '#f5b041', 'batched': '#ff9f43', 'skipped': '#4a4d57'}
GLYPH = {'pending': '○', 'running': '◐', 'done': '●', 'failed': '✕', 'escalated': '▲', 'batched': '◆',
         'skipped': '–'}
GATE = {'closed': '·', 'open': '▶', 'waiting': '⏳', 'approved': '✓'}

QSS = f'''
* {{ background: {BG}; color: {TEXT}; font-family: "JetBrains Mono", "DejaVu Sans Mono", monospace;
     font-size: 12px; }}
QMainWindow, QWidget#root {{ background: {BG}; }}
QFrame#card {{ background: {PANEL}; border: 1px solid {LINE}; border-radius: 8px; }}
QLabel#h {{ color: {DIM}; font-size: 10px; letter-spacing: 2px; background: transparent; }}
QLabel#title {{ font-size: 15px; font-weight: 600; letter-spacing: 1px; }}
QLabel {{ background: transparent; }}
QPushButton {{ background: #17181d; border: 1px solid {LINE}; border-radius: 6px; padding: 5px 12px; }}
QPushButton:hover {{ border-color: #3fd4dc; color: #ffffff; }}
QPushButton:pressed {{ background: #1f2128; }}
QPushButton#go {{ border-color: #2c6b45; color: #7fd18b; }}
QPushButton#warn {{ border-color: #6b4a1c; color: #f5b041; }}
QLineEdit, QComboBox {{ background: #0d0d10; border: 1px solid {LINE}; border-radius: 6px; padding: 4px 8px; }}
QComboBox QAbstractItemView {{ background: {PANEL}; selection-background-color: #1d2a33; }}
QTreeWidget, QTableWidget, QPlainTextEdit, QTextEdit {{ background: {PANEL}; border: 1px solid {LINE};
     border-radius: 8px; selection-background-color: #1d2a33; alternate-background-color: #131317; }}
QHeaderView::section {{ background: {PANEL}; color: {DIM}; border: none; border-bottom: 1px solid {LINE};
     padding: 4px; }}
QTabWidget::pane {{ border: none; }}
QTabBar::tab {{ background: transparent; color: {DIM}; padding: 6px 14px; border-bottom: 2px solid transparent; }}
QTabBar::tab:selected {{ color: #ffffff; border-bottom: 2px solid #3fd4dc; }}
QSplitter::handle {{ background: {BG}; width: 6px; }}
QScrollBar:vertical {{ background: {BG}; width: 8px; }}
QScrollBar::handle:vertical {{ background: #2a2c34; border-radius: 4px; min-height: 30px; }}
QScrollBar::add-line, QScrollBar::sub-line {{ height: 0; }}
QCheckBox::indicator {{ width: 14px; height: 14px; border: 1px solid {LINE}; border-radius: 3px; }}
QCheckBox::indicator:checked {{ background: #3fd4dc; }}
'''


def card(title, *widgets):
    f = QFrame(objectName='card')
    v = QVBoxLayout(f)
    v.setContentsMargins(10, 8, 10, 10)
    v.setSpacing(6)
    if title: v.addWidget(QLabel(title.upper(), objectName='h'))
    for w in widgets: v.addWidget(w)
    return f


def mono(read_only=True):
    w = QPlainTextEdit(readOnly=read_only)
    w.setLineWrapMode(QPlainTextEdit.WidgetWidth)
    w.setMaximumBlockCount(20000)
    return w


class Window(QMainWindow):
    def __init__(self, store, engine):
        super().__init__()
        self.store, self.engine = store, engine
        self.last_event = 0
        self.selected = None
        self.items = {}
        self.setWindowTitle('portctl · plate port orchestrator')
        self.resize(1680, 980)

        root = QWidget(objectName='root')
        self.setCentralWidget(root)
        outer = QVBoxLayout(root)
        outer.setContentsMargins(12, 10, 12, 12)

        # top bar
        bar = QHBoxLayout()
        bar.addWidget(QLabel('portctl', objectName='title'))
        self.state = QLabel('')
        bar.addWidget(self.state)
        bar.addStretch(1)
        def button(text, fn, name=None, tip=''):
            b = QPushButton(text, objectName=name or '')
            b.clicked.connect(fn); b.setToolTip(tip); bar.addWidget(b); return b
        button('▶ Start', self.engine.start, 'go', 'run tasks of the open phase')
        button('⏸ Pause', self.engine.pause, tip='dispatch nothing new; running tasks finish')
        button('⏭ Step', self.engine.step, tip='dispatch one task, then pause')
        button('✓ Approve gate', self.approve, 'go', 'approve the phase that waits')
        self.auto = QCheckBox('auto-approve')
        self.auto.setChecked(self.engine.auto_approve)
        self.auto.toggled.connect(self.engine.set_auto_approve)
        bar.addWidget(self.auto)
        bar.addSpacing(16)
        button('↻ Retry', lambda: self.on_task(self.engine.retry))
        button('⤼ Skip', lambda: self.on_task(self.engine.skip), 'warn')
        button('■ Stop task', lambda: self.on_task(self.engine.kill), 'warn')
        self.force = QComboBox()
        self.force.addItems(['route: auto', 'route: qwen', 'route: claude'])
        self.force.activated.connect(self.on_force)
        bar.addWidget(self.force)
        outer.addLayout(bar)

        split = QSplitter(Qt.Horizontal)
        outer.addWidget(split, 1)

        # left: phases + tasks
        left = QWidget(); lv = QVBoxLayout(left); lv.setContentsMargins(0, 0, 0, 0)
        frow = QHBoxLayout()
        self.filter = QLineEdit(placeholderText='filter tasks…')
        self.filter.textChanged.connect(self.refresh_tree)
        self.status_filter = QComboBox()
        self.status_filter.addItems(['all', 'pending', 'running', 'done', 'failed', 'escalated', 'batched',
                                     'skipped', 'not done'])
        self.status_filter.currentTextChanged.connect(self.refresh_tree)
        frow.addWidget(self.filter, 1); frow.addWidget(self.status_filter)
        lv.addLayout(frow)
        self.tree = QTreeWidget()
        self.tree.setHeaderLabels(['task', 'kind', 'route', 'status'])
        self.tree.header().setStretchLastSection(False)
        self.tree.header().setSectionResizeMode(0, QHeaderView.Stretch)
        for i in (1, 2, 3): self.tree.header().setSectionResizeMode(i, QHeaderView.ResizeToContents)
        self.tree.setUniformRowHeights(True)
        self.tree.itemSelectionChanged.connect(self.on_select)
        lv.addWidget(self.tree, 1)
        split.addWidget(left)

        # centre: tabs
        centre = QWidget(); cv = QVBoxLayout(centre); cv.setContentsMargins(0, 0, 0, 0)
        head = QHBoxLayout()
        self.task_title = QLabel('all tasks', objectName='title')
        self.follow_all = QCheckBox('stream every task')
        self.follow_all.setChecked(True)
        self.follow_all.toggled.connect(self.reload_live)
        self.wrap = QCheckBox('tokens'); self.wrap.setChecked(True)
        self.wrap.setToolTip('show model output (qwen.out / claude.out)')
        self.wrap.toggled.connect(self.reload_live)
        head.addWidget(self.task_title, 1); head.addWidget(self.wrap); head.addWidget(self.follow_all)
        cv.addLayout(head)
        self.tabs = QTabWidget()
        self.live = QTextEdit(readOnly=True)
        self.live.document().setMaximumBlockCount(30000)
        self.prompt = mono()
        self.output = mono()
        self.oracle = mono()
        self.result = mono()
        self.attempts = QTableWidget(0, 8)
        self.attempts.setHorizontalHeaderLabels(['#', 'worker', 'model', 'ok', 's', 'in', 'out', '$'])
        self.attempts.horizontalHeader().setSectionResizeMode(QHeaderView.Stretch)
        self.attempts.verticalHeader().hide()
        self.attempts.itemSelectionChanged.connect(self.on_attempt)
        att = QSplitter(Qt.Vertical); att.addWidget(self.attempts); att.addWidget(self.output)
        for w, name in ((self.live, 'Live'), (self.prompt, 'Prompt'), (att, 'Attempts'),
                        (self.oracle, 'Oracle'), (self.result, 'Task')):
            self.tabs.addTab(w, name)
        cv.addWidget(self.tabs, 1)
        split.addWidget(centre)

        # right: dashboard
        right = QWidget(); rv = QVBoxLayout(right); rv.setContentsMargins(0, 0, 0, 0)
        self.lanes = QLabel(); self.lanes.setTextFormat(Qt.RichText); self.lanes.setWordWrap(True)
        self.rates = QLabel(); self.rates.setTextFormat(Qt.RichText)
        self.spend = QLabel(); self.spend.setTextFormat(Qt.RichText)
        self.families = QTableWidget(0, 6)
        self.families.setHorizontalHeaderLabels(['family', 'lang', 'qwen ok', 'tried', 'claude', 'left'])
        self.families.horizontalHeader().setSectionResizeMode(QHeaderView.Stretch)
        self.families.verticalHeader().hide()
        self.families.setMaximumHeight(170)
        self.router = mono(); self.router.setMaximumBlockCount(3000)
        rv.addWidget(card('lanes', self.lanes))
        rv.addWidget(card('qwen · measured', self.rates))
        rv.addWidget(card('claude', self.spend))
        rv.addWidget(card('families', self.families))
        rv.addWidget(card('router decisions', self.router), 1)
        split.addWidget(right)
        split.setSizes([430, 840, 410])

        self.timer = QTimer(self, interval=400, timeout=self.poll)
        self.timer.start()
        self.slow = QTimer(self, interval=1500, timeout=self.refresh_all)
        self.slow.start()
        self.refresh_all()
        self.reload_live()

    # ---- controls -----------------------------------------------------------------------------
    def approve(self):
        for ph in self.store.q("select id from phases where gate='waiting' order by ord"):
            self.engine.approve(ph['id']); return

    def on_task(self, fn):
        if self.selected and self.selected.startswith('task:'): fn(self.selected[5:])
        elif self.selected and self.selected.startswith('phase:') and fn == self.engine.retry:
            for t in self.store.tasks("phase=? and status='failed'", self.selected[6:]): fn(t['id'])

    def on_force(self, i):
        self.on_task(lambda tid: self.engine.force(tid, [None, 'qwen', 'claude'][i]))
        self.force.setCurrentIndex(0)

    # ---- tree ---------------------------------------------------------------------------------
    def refresh_all(self):
        self.refresh_tree(); self.refresh_dash()
        if self.selected and self.selected.startswith('task:'): self.show_task(self.selected[5:], tabs_only=True)

    def refresh_tree(self, *_):
        text, sf = self.filter.text().lower(), self.status_filter.currentText()
        tasks = self.store.q('select id, phase, kind, route, status, title, forced from tasks order by rowid')
        by_phase = {}
        for t in tasks: by_phase.setdefault(t['phase'], []).append(t)
        seen = set()
        for ph in self.store.q('select * from phases order by ord'):
            ts = by_phase.get(ph['id'], [])
            n = {s: sum(t['status'] == s for t in ts) for s in STATUS}
            key = 'phase:' + ph['id']
            it = self.items.get(key)
            if not it:
                it = self.items[key] = QTreeWidgetItem(self.tree); it.setData(0, Qt.UserRole, key)
                f = it.font(0); f.setBold(True); it.setFont(0, f)
            it.setText(0, f'{GATE[ph["gate"]]} {ph["id"]}  {ph["title"]}')
            it.setText(3, f'{n["done"] + n["skipped"]}/{len(ts)}' + (f' ✕{n["failed"]}' if n['failed'] else ''))
            it.setForeground(0, QBrush(QColor({'open': '#ffffff', 'waiting': '#ff7ad9', 'approved': '#7fd18b'}
                                              .get(ph['gate'], DIM))))
            seen.add(key)
            for t in ts:
                k = 'task:' + t['id']
                show = (not text or text in t['id'].lower() or text in (t['title'] or '').lower()) and \
                       (sf == 'all' or t['status'] == sf or (sf == 'not done' and t['status'] not in ('done', 'skipped')))
                c = self.items.get(k)
                if not c:
                    c = self.items[k] = QTreeWidgetItem(it); c.setData(0, Qt.UserRole, k)
                c.setHidden(not show)
                c.setText(0, f'{GLYPH[t["status"]]} {t["id"]}')
                c.setToolTip(0, t['title'] or '')
                c.setText(1, t['kind'])
                c.setText(2, (t['route'] or '') + (f' ⚑{t["forced"]}' if t['forced'] else ''))
                c.setText(3, t['status'])
                col = QColor(STATUS[t['status']])
                for i in (0, 3): c.setForeground(i, QBrush(col))
                seen.add(k)
            if ph['gate'] in ('open', 'waiting') and not it.isExpanded() and not getattr(it, '_auto', False):
                it.setExpanded(True); it._auto = True
        for k in list(self.items):
            if k not in seen:
                it = self.items.pop(k)
                (it.parent() or self.tree.invisibleRootItem()).removeChild(it)

    def on_select(self):
        sel = self.tree.selectedItems()
        if not sel: return
        self.selected = sel[0].data(0, Qt.UserRole)
        if self.selected.startswith('task:'):
            self.follow_all.setChecked(False)
            self.show_task(self.selected[5:])
        else:
            self.task_title.setText(self.selected[6:])
        self.reload_live()

    def show_task(self, tid, tabs_only=False):
        t = self.store.task(tid)
        if not t: return
        self.task_title.setText(f'{t["id"]}  ·  {t["title"]}')
        self.result.setPlainText(json.dumps(t, indent=2, ensure_ascii=False, default=str))
        att = self.store.attempts(tid)
        if tabs_only and self.attempts.rowCount() == len(att): return
        self.attempts.setRowCount(len(att))
        for r, a in enumerate(att):
            vals = [a['n'], a['worker'], a['model'], '✓' if a['ok'] else '✕', f'{a["seconds"] or 0:.0f}',
                    a['tok_in'] or '', a['tok_out'] or '', f'{a["cost"]:.3f}' if a['cost'] else '']
            for c, v in enumerate(vals):
                it = QTableWidgetItem(str(v))
                if c == 3: it.setForeground(QBrush(QColor('#7fd18b' if a['ok'] else '#ff5c6c')))
                self.attempts.setItem(r, c, it)
        self._att = att
        prompts = [a for a in att if a['prompt']]
        self.prompt.setPlainText(prompts[-1]['prompt'] if prompts else '(no prompt yet)')
        oracles = [a for a in att if a['oracle']]
        self.oracle.setPlainText(oracles[-1]['oracle'] if oracles else '(no oracle run yet)')

    def on_attempt(self):
        rows = self.attempts.selectionModel().selectedRows() or \
               [i for i in self.attempts.selectedIndexes()][:1]
        if not rows: return
        a = self._att[rows[0].row()]
        self.output.setPlainText((a['output'] or '') + ('\n\n──── oracle ────\n' + a['oracle'] if a['oracle'] else ''))
        if a['prompt']: self.prompt.setPlainText(a['prompt'])

    # ---- live stream --------------------------------------------------------------------------
    def wanted(self, e):
        if not self.wrap.isChecked() and e['source'] in ('qwen.out', 'claude.out'): return False
        if self.follow_all.isChecked() or not self.selected: return True
        if self.selected.startswith('phase:'):
            return e['task'] is None or (e['task'] or '').upper().startswith(self.selected[6:].upper())
        return e['task'] == self.selected[5:]

    def fmt(self, e):
        ts = time.strftime('%H:%M:%S', time.localtime(e['t']))
        col = '#ff5c6c' if e['level'] == 'error' else SOURCE.get(e['source'], TEXT)
        task = f'<span style="color:{DIM}">{html.escape(e["task"] or "—")}</span> ' if self.follow_all.isChecked() else ''
        body = html.escape(e['text']).replace('\n', '<br>')
        return (f'<span style="color:#3a3d46">{ts}</span> <span style="color:{col}">{e["source"]:<13}</span>'
                f' {task}<span style="color:{col}">{body}</span>').replace('  ', '&nbsp;&nbsp;')

    def reload_live(self, *_):
        self.live.clear()
        rows = self.store.q('select * from events order by id desc limit 4000')[::-1]
        self.live.append('<br>'.join(self.fmt(e) for e in rows if self.wanted(e)))
        self.last_event = rows[-1]['id'] if rows else 0
        self.router.setPlainText('\n'.join(
            time.strftime('%H:%M:%S ', time.localtime(e['t'])) + e['text']
            for e in self.store.q("select * from events where source='router' order by id desc limit 800")[::-1]))
        self.live.moveCursor(QTextCursor.End)

    def poll(self):
        rows = self.store.events(after=self.last_event, limit=2000)
        if not rows: return
        self.last_event = rows[-1]['id']
        bar = self.live.verticalScrollBar()
        at_end = bar.value() >= bar.maximum() - 20
        chunk = [self.fmt(e) for e in rows if self.wanted(e)]
        if chunk:
            self.live.append('<br>'.join(chunk))
            if at_end: bar.setValue(bar.maximum())
        for e in rows:
            if e['source'] == 'router':
                self.router.appendPlainText(time.strftime('%H:%M:%S ', time.localtime(e['t'])) + e['text'])

    # ---- dashboard ----------------------------------------------------------------------------
    def refresh_dash(self):
        eng = self.engine
        lanes = []
        for lane, size in (('python', 3), ('qwen', 1), ('claude', 1)):
            ids = [t for t, l in list(eng.inflight.items()) if l == lane]
            col = SOURCE[lane]
            lanes.append(f'<span style="color:{col}">■ {lane}</span> {len(ids)}/{size} '
                         f'<span style="color:{DIM}">{html.escape(", ".join(ids)) or "idle"}</span>')
        self.lanes.setText('<br>'.join(lanes))
        run = 'running' if eng.running else 'paused'
        ph = self.store.q("select id, gate from phases where gate in ('open','waiting') order by ord limit 1")
        self.state.setText(f'<span style="color:{"#7fd18b" if eng.running else DIM}">● {run}</span>'
                           + (f'  ·  phase {ph[0]["id"]} ({ph[0]["gate"]})' if ph else ''))
        rows = []
        for m in (C.QWEN_SMALL, C.QWEN_LARGE):
            r = eng.rates(m)
            stats = self.store.q("select count(*) n, sum(ok) ok, avg(seconds) s from attempts where model=?", m)[0]
            rows.append(f'<span style="color:#3fd4dc">{m}</span><br>&nbsp;&nbsp;in {r[0]:.1f} tok/s · out {r[1]:.1f} tok/s'
                        f'<br>&nbsp;&nbsp;{stats["n"]} calls · {stats["ok"] or 0} ok · avg {stats["s"] or 0:.0f}s')
        self.rates.setText('<br>'.join(rows))
        c = self.store.q("select count(*) n, sum(cost) c from attempts where worker='claude'")[0]
        self.spend.setText(f'<span style="color:#f5b041">${self.store.get("claude_spend", 0.0):.2f}</span> spent · '
                           f'{c["n"]} sessions<br><span style="color:{DIM}">budget/task ${C.CLAUDE_BUDGET_USD:.0f} · '
                           f'batch {C.CLAUDE_BATCH}</span>')
        fs = sorted(self.store.family_stats().items())
        self.families.setRowCount(len(fs))
        for r, ((fam, lang), s) in enumerate(fs):
            for col, v in enumerate([fam, lang, s['qwen_ok'], s['qwen_tried'], s['claude'], s['left']]):
                self.families.setItem(r, col, QTableWidgetItem(str(v)))


def run(store, engine):
    app = QApplication.instance() or QApplication([])
    app.setStyleSheet(QSS)
    w = Window(store, engine)
    w.show()
    return app.exec()
