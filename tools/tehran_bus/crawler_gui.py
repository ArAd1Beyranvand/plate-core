#!/usr/bin/env python3
"""Tehran Bus timetable crawler (PySide6 GUI).

Run:  python3 crawler_gui.py

Crawls BusStationStaticTimeTable one (station, route, direction) pair at a time
with random delays. Line terminals (first and last station of every line) are
fetched first, then the rest in line order. Finished pairs live in
<data>/timetables.jsonl and are never requested again.

Data dir needs bus_routes.json, bus_stations.json, bus_routestations.json
(use "Fetch network" if missing).
"""
import csv
import json
import random
import sys
import time
import urllib.error
import urllib.request
from datetime import datetime, timedelta
from pathlib import Path

from PySide6.QtCore import QThread, Qt, Signal
from PySide6.QtGui import QFont
from PySide6.QtWidgets import (
    QApplication, QCheckBox, QDoubleSpinBox, QFileDialog, QFrame, QHBoxLayout,
    QLabel, QLineEdit, QMainWindow, QMessageBox, QProgressBar, QPushButton,
    QTextEdit, QVBoxLayout, QWidget,
)

BASE = "https://application2.irantracking.com/modsapi/api/PublicTransport/"
UA = "tehran-bus-crawler/1.0"
DEFAULT_DIR = Path(__file__).resolve().parent / "data"
Pair = tuple  # (station_code, route_code, direction)


def post(endpoint, body, timeout=30):
    """Return (status, parsed_json_or_None). status 0 = network error."""
    req = urllib.request.Request(
        BASE + endpoint, json.dumps(body).encode(),
        {"Content-Type": "application/json", "User-Agent": UA})
    try:
        with urllib.request.urlopen(req, timeout=timeout) as r:
            return r.status, json.load(r)
    except urllib.error.HTTPError as e:
        return e.code, None
    except (urllib.error.URLError, TimeoutError, OSError, ValueError):
        return 0, None


def load_json(path):
    return json.loads(path.read_text(encoding="utf-8"))


def read_done(data_dir):
    done = set()
    p = data_dir / "timetables.jsonl"
    if p.exists():
        for line in p.read_text(encoding="utf-8").splitlines():
            try:
                r = json.loads(line)
                done.add((r["StationCode"], r["RouteCode"], r["Direction"]))
            except (ValueError, KeyError):
                pass
    return done


def build_queue(data_dir):
    """All unique pairs: line terminals first, then the rest by line and order."""
    routes = {r["RouteID"]: r for r in load_json(data_dir / "bus_routes.json")}
    by_route = {}
    for rs in load_json(data_dir / "bus_routestations.json"):
        if rs.get("RouteID") in routes and rs.get("StationCode") is not None:
            by_route.setdefault(rs["RouteID"], []).append(rs)

    terminals, rest, seen = [], [], set()
    for rid in sorted(by_route, key=lambda i: (routes[i]["RouteCode"], routes[i]["Direction"])):
        stops = sorted(by_route[rid], key=lambda s: s.get("StationOrder") or 0)
        route = routes[rid]
        for i, s in enumerate(stops):
            pair = (s["StationCode"], route["RouteCode"], route["Direction"])
            if pair in seen:
                continue
            seen.add(pair)
            is_end = i == 0 or i == len(stops) - 1 or s.get("IsLastStation")
            (terminals if is_end else rest).append(pair)
    return terminals + rest, len(terminals)


class Crawler(QThread):
    log = Signal(str, str)          # level, message
    progress = Signal(int, int, int)  # done, failed, total
    state = Signal(str)             # current request / status text
    finished_all = Signal()

    def __init__(self, data_dir, queue, done, dmin, dmax, long_pauses):
        super().__init__()
        self.data_dir, self.queue, self.done = data_dir, queue, set(done)
        self.dmin, self.dmax, self.long_pauses = dmin, dmax, long_pauses
        self._stop = False
        self._paused = False

    def stop(self):
        self._stop = True

    def set_paused(self, p):
        self._paused = p

    def _sleep(self, seconds):
        end = time.monotonic() + seconds
        while time.monotonic() < end and not self._stop:
            time.sleep(0.1)

    def run(self):
        todo = [p for p in self.queue if p not in self.done]
        total = len(self.queue)
        failed_pairs = []
        n_failed = 0
        since_long = 0
        long_after = random.randint(40, 90)
        consecutive_fail = 0
        out = open(self.data_dir / "timetables.jsonl", "a", encoding="utf-8")
        fail_log = open(self.data_dir / "failed.jsonl", "a", encoding="utf-8")

        def attempt(pair, label):
            nonlocal n_failed, consecutive_fail
            station, route, direction = pair
            self.state.emit(f"{label}: station {station} · line {route} {direction}")
            t0 = time.monotonic()
            status, resp = post("BusStationStaticTimeTable", {
                "StationCode": station,
                "Route": {"RouteCode": route, "Direction": direction}})
            ms = int((time.monotonic() - t0) * 1000)
            if status == 200 and isinstance(resp, dict):
                rec = {"StationCode": station, "RouteCode": route, "Direction": direction,
                       "ValidUntil": resp.get("ValidUntil"),
                       "CurrentDayType": resp.get("CurrentDayType"),
                       "Normal": [x.get("StaticTime") for x in resp.get("Normal") or []],
                       "HalfHoliday": [x.get("StaticTime") for x in resp.get("HalfHoliday") or []],
                       "Holiday": [x.get("StaticTime") for x in resp.get("Holiday") or []],
                       "FetchedAt": datetime.now().isoformat(timespec="seconds")}
                out.write(json.dumps(rec, ensure_ascii=False) + "\n")
                out.flush()
                self.done.add(pair)
                consecutive_fail = 0
                counts = f"{len(rec['Normal'])}/{len(rec['HalfHoliday'])}/{len(rec['Holiday'])}"
                self.log.emit("ok", f"200 {ms}ms  station {station}  line {route}{direction}  "
                                    f"times N/H/F = {counts}")
                return True
            n_failed += 1
            consecutive_fail += 1
            fail_log.write(json.dumps({"pair": list(pair), "status": status,
                                       "at": datetime.now().isoformat(timespec="seconds")}) + "\n")
            fail_log.flush()
            self.log.emit("err", f"{status or 'NET'} {ms}ms  station {station}  line {route}{direction}")
            return False

        def wait_if_paused():
            while self._paused and not self._stop:
                self.state.emit("Paused")
                time.sleep(0.2)

        passes = [("fetch", todo)]
        for pass_name, items in passes:
            for pair in items:
                wait_if_paused()
                if self._stop:
                    break
                ok = attempt(pair, "Requesting")
                if not ok and pass_name == "fetch":
                    failed_pairs.append(pair)
                self.progress.emit(len(self.done), n_failed, total)

                if consecutive_fail >= 5:
                    backoff = 120
                    self.log.emit("warn", f"5 failures in a row, backing off {backoff}s")
                    self._sleep(backoff)
                    consecutive_fail = 0
                delay = random.uniform(self.dmin, self.dmax)
                since_long += 1
                if self.long_pauses and since_long >= long_after:
                    delay += random.uniform(10, 30)
                    since_long, long_after = 0, random.randint(40, 90)
                    self.log.emit("info", f"short break, sleeping {delay:.0f}s")
                self.state.emit(f"Waiting {delay:.1f}s")
                self._sleep(delay)
            if pass_name == "fetch" and failed_pairs and not self._stop:
                passes.append(("retry", failed_pairs))
                self.log.emit("info", f"retrying {len(failed_pairs)} failed pairs once")

        out.close()
        fail_log.close()
        self.state.emit("Stopped" if self._stop else "Finished")
        self.finished_all.emit()


class NetworkFetcher(QThread):
    log = Signal(str, str)
    done = Signal(bool)

    def __init__(self, data_dir):
        super().__init__()
        self.data_dir = data_dir

    def run(self):
        lo, hi = 1_740_000_000_000, 1_750_000_000_000  # lo is rejected, hi works
        self.log.emit("info", "Looking for the oldest serverTime the server accepts...")
        data = None
        while hi - lo > 1000:
            mid = (lo + hi) // 2
            status, resp = post("LastRoutesStationsUpdate", {"serverTime": mid}, 120)
            self.log.emit("info", f"serverTime={mid} -> {status}")
            if status == 200:
                hi, data = mid, resp
            else:
                lo = mid
            time.sleep(random.uniform(1.5, 3.0))
        if data is None:
            status, data = post("LastRoutesStationsUpdate", {"serverTime": hi}, 120)
        if not data:
            self.log.emit("err", "Could not fetch the network")
            self.done.emit(False)
            return
        self.data_dir.mkdir(parents=True, exist_ok=True)
        for part, name in (("Routes", "bus_routes"), ("Stations", "bus_stations"),
                           ("RouteStations", "bus_routestations")):
            rows = data.get(part, [])
            (self.data_dir / f"{name}.json").write_text(json.dumps(rows, ensure_ascii=False))
            self.log.emit("ok", f"{part}: {len(rows)}")
        self.done.emit(True)


STYLE = """
* { font-family: 'Inter','Segoe UI','Noto Sans',sans-serif; font-size: 13px; color: #e6e9ef; }
QMainWindow, QWidget#root { background: #14161b; }
QFrame#card { background: #1d2027; border: 1px solid #2a2e38; border-radius: 12px; }
QLabel#statValue { font-size: 26px; font-weight: 600; }
QLabel#statName { color: #8b93a5; font-size: 12px; }
QLabel#status { color: #8b93a5; }
QPushButton { background: #2a2e38; border: none; border-radius: 8px; padding: 9px 18px; }
QPushButton:hover { background: #343947; }
QPushButton:disabled { color: #5b6275; background: #20232b; }
QPushButton#primary { background: #4f7cff; font-weight: 600; }
QPushButton#primary:hover { background: #6b91ff; }
QPushButton#primary:disabled { background: #2a3a66; color: #7f8bb0; }
QPushButton#danger { background: #c9485b; }
QPushButton#danger:hover { background: #dc5b6e; }
QPushButton#danger:disabled { background: #3a2a2e; color: #7a5a60; }
QLineEdit, QDoubleSpinBox { background: #1d2027; border: 1px solid #2a2e38; border-radius: 8px; padding: 6px 8px; }
QProgressBar { background: #1d2027; border: 1px solid #2a2e38; border-radius: 8px; height: 16px; text-align: center; }
QProgressBar::chunk { background: #4f7cff; border-radius: 7px; }
QTextEdit { background: #0f1115; border: 1px solid #2a2e38; border-radius: 10px; padding: 8px;
            font-family: 'JetBrains Mono','Fira Code','DejaVu Sans Mono',monospace; font-size: 12px; }
QCheckBox::indicator { width: 16px; height: 16px; }
"""
COLORS = {"ok": "#6fd49a", "err": "#ff7b8a", "warn": "#f0c060", "info": "#8b93a5"}


def card():
    f = QFrame()
    f.setObjectName("card")
    return f


class Stat(QFrame):
    def __init__(self, name):
        super().__init__()
        self.setObjectName("card")
        lay = QVBoxLayout(self)
        self.value = QLabel("0")
        self.value.setObjectName("statValue")
        n = QLabel(name)
        n.setObjectName("statName")
        lay.addWidget(self.value)
        lay.addWidget(n)

    def set(self, v):
        self.value.setText(f"{v:,}")


class Window(QMainWindow):
    def __init__(self):
        super().__init__()
        self.setWindowTitle("Tehran Bus timetable crawler")
        self.resize(980, 760)
        self.worker = None
        self.fetcher = None
        self.queue, self.n_terminals = [], 0
        self.started_at = None
        self.start_done = 0

        root = QWidget()
        root.setObjectName("root")
        self.setCentralWidget(root)
        v = QVBoxLayout(root)
        v.setContentsMargins(20, 18, 20, 18)
        v.setSpacing(14)

        title = QLabel("Tehran Bus · timetable crawler")
        title.setFont(QFont(title.font().family(), 17, QFont.DemiBold))
        v.addWidget(title)

        dir_row = QHBoxLayout()
        self.dir_edit = QLineEdit(str(DEFAULT_DIR))
        self.dir_edit.editingFinished.connect(self.reload)
        browse = QPushButton("Browse")
        browse.clicked.connect(self.browse)
        self.fetch_btn = QPushButton("Fetch network")
        self.fetch_btn.clicked.connect(self.fetch_network)
        dir_row.addWidget(QLabel("Data folder"))
        dir_row.addWidget(self.dir_edit, 1)
        dir_row.addWidget(browse)
        dir_row.addWidget(self.fetch_btn)
        v.addLayout(dir_row)

        stats = QHBoxLayout()
        self.s_total, self.s_done = Stat("Total pairs"), Stat("Done")
        self.s_fail, self.s_left = Stat("Failed this session"), Stat("Remaining")
        for s in (self.s_total, self.s_done, self.s_fail, self.s_left):
            stats.addWidget(s)
        v.addLayout(stats)

        self.bar = QProgressBar()
        self.bar.setFormat("%p%")
        v.addWidget(self.bar)
        self.status = QLabel("Idle")
        self.status.setObjectName("status")
        v.addWidget(self.status)

        ctl = card()
        c = QHBoxLayout(ctl)
        c.setContentsMargins(14, 12, 14, 12)
        self.dmin = QDoubleSpinBox()
        self.dmax = QDoubleSpinBox()
        for sp, val in ((self.dmin, 1.5), (self.dmax, 4.0)):
            sp.setRange(0.5, 120)
            sp.setSingleStep(0.5)
            sp.setSuffix(" s")
            sp.setValue(val)
        self.long_pauses = QCheckBox("Occasional longer breaks")
        self.long_pauses.setChecked(True)
        c.addWidget(QLabel("Delay between requests"))
        c.addWidget(self.dmin)
        c.addWidget(QLabel("to"))
        c.addWidget(self.dmax)
        c.addWidget(self.long_pauses)
        c.addStretch(1)
        self.start_btn = QPushButton("Start")
        self.start_btn.setObjectName("primary")
        self.start_btn.clicked.connect(self.start)
        self.pause_btn = QPushButton("Pause")
        self.pause_btn.setEnabled(False)
        self.pause_btn.clicked.connect(self.toggle_pause)
        self.stop_btn = QPushButton("Stop")
        self.stop_btn.setObjectName("danger")
        self.stop_btn.setEnabled(False)
        self.stop_btn.clicked.connect(self.stop)
        self.export_btn = QPushButton("Export CSV")
        self.export_btn.clicked.connect(self.export_csv)
        for b in (self.start_btn, self.pause_btn, self.stop_btn, self.export_btn):
            c.addWidget(b)
        v.addWidget(ctl)

        self.logview = QTextEdit()
        self.logview.setReadOnly(True)
        self.logview.document().setMaximumBlockCount(5000)
        v.addWidget(self.logview, 1)

        self.setStyleSheet(STYLE)
        self.reload()

    # ---- helpers
    def data_dir(self):
        return Path(self.dir_edit.text()).expanduser()

    def add_log(self, level, msg):
        ts = datetime.now().strftime("%H:%M:%S")
        self.logview.append(
            f'<span style="color:#5b6275">{ts}</span> '
            f'<span style="color:{COLORS.get(level, "#e6e9ef")}">{msg}</span>')

    def browse(self):
        d = QFileDialog.getExistingDirectory(self, "Data folder", str(self.data_dir()))
        if d:
            self.dir_edit.setText(d)
            self.reload()

    def reload(self):
        d = self.data_dir()
        self.queue = []
        try:
            self.queue, self.n_terminals = build_queue(d)
        except (OSError, ValueError, KeyError):
            self.add_log("warn", f"No network files in {d}. Use 'Fetch network'.")
        done = read_done(d) if d.exists() else set()
        self.update_stats(len(done & set(self.queue)), 0)
        if self.queue:
            self.add_log("info", f"{len(self.queue):,} pairs queued "
                                 f"({self.n_terminals:,} line start/end first), "
                                 f"{len(done & set(self.queue)):,} already done.")
        self.start_btn.setEnabled(bool(self.queue))

    def update_stats(self, done, failed):
        total = len(self.queue)
        self.s_total.set(total)
        self.s_done.set(done)
        self.s_fail.set(failed)
        self.s_left.set(max(total - done, 0))
        self.bar.setMaximum(max(total, 1))
        self.bar.setValue(done)

    # ---- actions
    def fetch_network(self):
        if self.fetcher and self.fetcher.isRunning():
            return
        self.fetch_btn.setEnabled(False)
        self.fetcher = NetworkFetcher(self.data_dir())
        self.fetcher.log.connect(self.add_log)
        self.fetcher.done.connect(self.fetch_done)
        self.fetcher.start()

    def fetch_done(self, ok):
        self.fetch_btn.setEnabled(True)
        if ok:
            self.reload()

    def start(self):
        if self.worker and self.worker.isRunning():
            return
        if self.dmin.value() > self.dmax.value():
            QMessageBox.warning(self, "Delay", "Min delay must be <= max delay.")
            return
        done = read_done(self.data_dir()) & set(self.queue)
        if len(done) >= len(self.queue):
            self.add_log("ok", "Everything is already done.")
            return
        self.start_done = len(done)
        self.started_at = time.monotonic()
        self.worker = Crawler(self.data_dir(), self.queue, done, self.dmin.value(),
                              self.dmax.value(), self.long_pauses.isChecked())
        self.worker.log.connect(self.add_log)
        self.worker.progress.connect(self.on_progress)
        self.worker.state.connect(self.status.setText)
        self.worker.finished_all.connect(self.on_finished)
        self.worker.start()
        self.start_btn.setEnabled(False)
        self.pause_btn.setEnabled(True)
        self.stop_btn.setEnabled(True)
        self.add_log("info", "Started.")

    def on_progress(self, done, failed, total):
        self.update_stats(done, failed)
        got = done - self.start_done
        if got > 0 and self.started_at:
            per = (time.monotonic() - self.started_at) / got
            eta = timedelta(seconds=int(per * max(total - done, 0)))
            self.bar.setFormat(f"%p%   ETA {eta}")

    def toggle_pause(self):
        paused = self.pause_btn.text() == "Pause"
        self.worker.set_paused(paused)
        self.pause_btn.setText("Resume" if paused else "Pause")
        self.add_log("info", "Paused." if paused else "Resumed.")

    def stop(self):
        if self.worker:
            self.worker.set_paused(False)
            self.worker.stop()
            self.stop_btn.setEnabled(False)
            self.add_log("info", "Stopping after the current request...")

    def on_finished(self):
        self.start_btn.setEnabled(True)
        self.pause_btn.setEnabled(False)
        self.pause_btn.setText("Pause")
        self.stop_btn.setEnabled(False)
        self.add_log("info", "Crawler stopped.")

    def export_csv(self):
        src = self.data_dir() / "timetables.jsonl"
        if not src.exists():
            QMessageBox.information(self, "Export", "No timetables yet.")
            return
        path, _ = QFileDialog.getSaveFileName(
            self, "Export CSV", str(self.data_dir() / "timetables.csv"), "CSV (*.csv)")
        if not path:
            return
        n = 0
        with open(path, "w", newline="", encoding="utf-8-sig") as f:
            w = csv.writer(f)
            w.writerow(["StationCode", "RouteCode", "Direction", "DayType", "Order", "Time"])
            for line in src.read_text(encoding="utf-8").splitlines():
                r = json.loads(line)
                for day in ("Normal", "HalfHoliday", "Holiday"):
                    for i, t in enumerate(r.get(day) or []):
                        w.writerow([r["StationCode"], r["RouteCode"], r["Direction"], day, i, t])
                        n += 1
        self.add_log("ok", f"Exported {n:,} rows to {path}")

    def closeEvent(self, e):
        if self.worker and self.worker.isRunning():
            self.worker.set_paused(False)
            self.worker.stop()
            self.worker.wait(5000)
        e.accept()


if __name__ == "__main__":
    app = QApplication(sys.argv)
    w = Window()
    w.show()
    sys.exit(app.exec())
