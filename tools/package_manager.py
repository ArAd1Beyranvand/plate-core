#!/usr/bin/env python3
"""GUI to commit / push / check / publish the *_plate packages.

Each package directory is its own git repo. Per-package options (checkboxes)
choose which of the four steps run; "Run selected" iterates the packages and
records the time of the last commit, push, check and pub.dev publish in
tools/package_state.json.

Usage: python3 tools/package_manager.py
"""
import json
import os
import queue
import re
import subprocess
import shutil
import threading
import time
from concurrent.futures import ThreadPoolExecutor
import tkinter as tk
import unicodedata
from datetime import datetime
from pathlib import Path
from tkinter import messagebox, ttk

ROOT = Path(__file__).resolve().parent.parent
STATE_FILE = ROOT / "tools" / "package_state.json"
LOG_DIR = ROOT / "tools" / "manager_logs"
REPORT_DIR = ROOT / "reports"
OWNER = "ArAd1Beyranvand"
PROXY = ""  # set from the GUI; empty = inherit environment / git config
STEPS = ("commit", "push", "check", "publish")
CHECK_MODES = ("dry-run", "pana", "both")

# Countries / territories and their sub-areas, after
# https://en.wikipedia.org/wiki/Vehicle_registration_plate
# A name with no sub-areas maps to [].
AREAS = {
    "Afghanistan": [], "Albania": [], "Algeria": [], "Andorra": [], "Angola": [],
    "Antigua and Barbuda": [], "Argentina": [], "Armenia": [],
    "Australia": ["Australian Capital Territory", "New South Wales", "Northern Territory",
                  "Queensland", "South Australia", "Tasmania", "Victoria", "Western Australia"],
    "Austria": [], "Azerbaijan": ["Nakhchivan"], "Bahamas": [], "Bahrain": [],
    "Bangladesh": [], "Barbados": [], "Belarus": [], "Belgium": [], "Belize": [],
    "Benin": [], "Bhutan": [], "Bolivia": [], "Bosnia and Herzegovina": [],
    "Botswana": [], "Brazil": [], "Brunei": [], "Bulgaria": [], "Burkina Faso": [],
    "Burundi": [], "Cambodia": [], "Cameroon": [],
    "Canada": ["Alberta", "British Columbia", "Manitoba", "New Brunswick",
               "Newfoundland and Labrador", "Northwest Territories", "Nova Scotia",
               "Nunavut", "Ontario", "Prince Edward Island", "Quebec", "Saskatchewan", "Yukon"],
    "Cape Verde": [], "Central African Republic": [], "Chad": [], "Chile": [],
    "China": ["Hong Kong", "Macau"], "Colombia": [], "Comoros": [],
    "Congo": [], "Costa Rica": [], "Croatia": [], "Cuba": [], "Cyprus": ["Northern Cyprus"],
    "Czech Republic": [], "Democratic Republic of the Congo": [], "Denmark": ["Faroe Islands", "Greenland"],
    "Djibouti": [], "Dominica": [], "Dominican Republic": [], "Ecuador": [], "Egypt": [],
    "El Salvador": [], "Equatorial Guinea": [], "Eritrea": [], "Estonia": [],
    "Eswatini": [], "Ethiopia": [], "Fiji": [], "Finland": ["Aland"],
    "France": ["French Guiana", "French Polynesia", "Guadeloupe", "Martinique",
               "Mayotte", "New Caledonia", "Reunion", "Saint Pierre and Miquelon",
               "Wallis and Futuna"],
    "Gabon": [], "Gambia": [], "Georgia": ["Abkhazia", "South Ossetia"],
    "Germany": [], "Ghana": [], "Greece": [], "Grenada": [], "Guatemala": [],
    "Guinea": [], "Guinea-Bissau": [], "Guyana": [], "Haiti": [], "Honduras": [],
    "Hungary": [], "Iceland": [],
    "India": ["Andaman and Nicobar Islands", "Andhra Pradesh", "Arunachal Pradesh", "Assam",
              "Bihar", "Chandigarh", "Chhattisgarh", "Delhi", "Goa", "Gujarat", "Haryana",
              "Himachal Pradesh", "Jammu and Kashmir", "Jharkhand", "Karnataka", "Kerala",
              "Ladakh", "Lakshadweep", "Madhya Pradesh", "Maharashtra", "Manipur", "Meghalaya",
              "Mizoram", "Nagaland", "Odisha", "Puducherry", "Punjab", "Rajasthan", "Sikkim",
              "Tamil Nadu", "Telangana", "Tripura", "Uttar Pradesh", "Uttarakhand", "West Bengal"],
    "Indonesia": [], "Iran": [], "Iraq": [], "Ireland": [], "Israel": [], "Italy": [],
    "Ivory Coast": [], "Jamaica": [], "Japan": [], "Jordan": [], "Kazakhstan": [],
    "Kenya": [], "Kiribati": [], "Kosovo": [], "Kuwait": [], "Kyrgyzstan": [],
    "Laos": [], "Latvia": [], "Lebanon": [], "Lesotho": [], "Liberia": [], "Libya": [],
    "Liechtenstein": [], "Lithuania": [], "Luxembourg": [], "Madagascar": [],
    "Malawi": [], "Malaysia": [], "Maldives": [], "Mali": [], "Malta": [],
    "Marshall Islands": [], "Mauritania": [], "Mauritius": [], "Mexico": [],
    "Micronesia": [], "Moldova": ["Transnistria"], "Monaco": [], "Mongolia": [],
    "Montenegro": [], "Morocco": [], "Mozambique": [], "Myanmar": [], "Namibia": [],
    "Nauru": [], "Nepal": [],
    "Netherlands": ["Aruba", "Bonaire", "Curacao", "Saba", "Sint Eustatius", "Sint Maarten"],
    "New Zealand": ["Cook Islands", "Niue"], "Nicaragua": [], "Niger": [], "Nigeria": [],
    "North Korea": [], "North Macedonia": [], "Norway": ["Svalbard"], "Oman": [],
    "Pakistan": [], "Palau": [], "Palestine": [], "Panama": [], "Papua New Guinea": [],
    "Paraguay": [], "Peru": [], "Philippines": [], "Poland": [], "Portugal": [],
    "Qatar": [], "Romania": [], "Russia": [], "Rwanda": [], "Saint Kitts and Nevis": [],
    "Saint Lucia": [], "Saint Vincent and the Grenadines": [], "Samoa": [],
    "San Marino": [], "Sao Tome and Principe": [], "Saudi Arabia": [], "Senegal": [],
    "Serbia": [], "Seychelles": [], "Sierra Leone": [], "Singapore": [], "Slovakia": [],
    "Slovenia": [], "Solomon Islands": [], "Somalia": ["Somaliland"], "South Africa": [],
    "South Korea": [], "South Sudan": [], "Spain": [], "Sri Lanka": [], "Sudan": [],
    "Suriname": [], "Sweden": [], "Switzerland": [], "Syria": [], "Taiwan": [],
    "Tajikistan": [], "Tanzania": [], "Thailand": [], "Timor-Leste": [], "Togo": [],
    "Tonga": [], "Trinidad and Tobago": [], "Tunisia": [], "Turkey": [], "Turkmenistan": [],
    "Tuvalu": [], "Uganda": [], "Ukraine": [], "United Arab Emirates": [
        "Abu Dhabi", "Ajman", "Dubai", "Fujairah", "Ras Al Khaimah", "Sharjah", "Umm Al Quwain"],
    "United Kingdom": ["Anguilla", "Ascension Island", "Bermuda", "British Virgin Islands",
                       "Cayman Islands", "Falkland Islands", "Gibraltar", "Guernsey",
                       "Isle of Man", "Jersey", "Montserrat", "Saint Helena",
                       "Tristan da Cunha", "Turks and Caicos Islands"],
    "United States": ["American Samoa", "Guam", "Northern Mariana Islands", "Puerto Rico",
                      "US Virgin Islands"],
    "Uruguay": [], "Uzbekistan": [], "Vanuatu": [], "Vatican City": [], "Venezuela": [],
    "Vietnam": [], "Yemen": [], "Zambia": [], "Zimbabwe": [],
}


def slug(name):
    s = unicodedata.normalize("NFKD", name).encode("ascii", "ignore").decode()
    return re.sub(r"[^a-z0-9]+", "_", s.lower()).strip("_")


# package slug -> (country, area or "")
LOOKUP = {}
for _c, _areas in AREAS.items():
    LOOKUP[slug(_c)] = (_c, "")
    for _a in _areas:
        LOOKUP.setdefault(slug(_a), (_c, _a))


def describe(pkg):
    base = pkg[:-6] if pkg.endswith("_plate") else pkg
    if base in LOOKUP:
        return LOOKUP[base]
    return (base.replace("_", " ").title(), "")


def now():
    return datetime.now().strftime("%Y-%m-%d %H:%M")


def default_proxy():
    """The proxy git is configured with (what works for you), else the env one."""
    p = subprocess.run(["git", "config", "--global", "http.proxy"], capture_output=True, text=True)
    return p.stdout.strip() or os.environ.get("HTTPS_PROXY") or os.environ.get("https_proxy") or ""


MAX_REPORT_CHARS = 3000


def clip(text, limit=MAX_REPORT_CHARS):
    """Keep the tail of a long output; the verdict is at the end."""
    text = text.strip()
    if len(text) <= limit:
        return text
    return f"[... {len(text) - limit} chars cut ...]\n" + text[-limit:]


def squeeze_dry_run(out):
    """Drop the file tree and 'newer version available' noise from pub's dry-run."""
    keep = [l for l in out.splitlines()
            if not l.lstrip().startswith(("├", "└", "│")) and "available)" not in l]
    return clip("\n".join(keep))


def pana_cmd():
    if shutil.which("pana"):
        return ["pana"]
    return ["dart", "pub", "global", "run", "pana"]


def run(cmd, cwd, log, quiet=False, timeout=1800):
    """Run cmd, streaming its output to log live; heartbeat while it is silent."""
    log(f"$ {' '.join(cmd)}")
    env = {**os.environ, "GIT_TERMINAL_PROMPT": "0", "GIT_ASKPASS": "true", "CI": "1"}
    if PROXY:
        for k in ("HTTP_PROXY", "HTTPS_PROXY", "ALL_PROXY", "http_proxy", "https_proxy", "all_proxy"):
            env[k] = PROXY
        env.update(GIT_CONFIG_COUNT="1", GIT_CONFIG_KEY_0="http.proxy", GIT_CONFIG_VALUE_0=PROXY)
    start = time.time()
    try:
        p = subprocess.Popen(cmd, cwd=cwd, stdin=subprocess.DEVNULL, stdout=subprocess.PIPE,
                             stderr=subprocess.STDOUT, text=True, env=env)
    except OSError as e:
        log(f"  error: {e}")
        return 1, ""
    lines = []

    def reader():
        for l in p.stdout:
            lines.append(l)
            if not quiet and not l.lstrip().startswith(("├", "└", "│")) and "available)" not in l:
                log("  " + l.rstrip())

    t = threading.Thread(target=reader, daemon=True)
    t.start()
    while t.is_alive():
        t.join(60)
        if t.is_alive():
            log(f"  ... still running ({int(time.time() - start)}s, {len(lines)} lines so far)")
            if time.time() - start > timeout:
                p.kill()
                log(f"  timeout after {timeout}s, killed")
    p.wait()
    log(f"  -> exit {p.returncode} in {time.time() - start:.1f}s")
    return p.returncode, "".join(lines).strip()


def git_info(path):
    """(dirty, last_commit_time, unpushed) for a package repo."""
    def g(*a):
        p = subprocess.run(["git", "-C", str(path), *a], capture_output=True, text=True)
        return p.returncode, p.stdout.strip()
    if not (path / ".git").exists():
        return None, "", None
    _, st = g("status", "--short")
    _, last = g("log", "-1", "--format=%cd", "--date=format:%Y-%m-%d %H:%M")
    rc, ahead = g("rev-list", "--count", "@{u}..HEAD")
    return bool(st), last, (int(ahead) if rc == 0 and ahead.isdigit() else None)


class App(tk.Tk):
    COLS = ("pkg", "country", "area", "dirty", "commit", "push", "check", "publish",
            "last_commit", "last_push", "last_check", "last_publish")
    HEAD = ("Package", "Country", "Area", "Git", "Commit", "Push", "Check", "Publish",
            "Last commit", "Last push", "Last check", "Last pub.dev")

    def __init__(self):
        super().__init__()
        self.title("Plate package manager")
        self.geometry("1500x800")
        self.state_data = json.loads(STATE_FILE.read_text()) if STATE_FILE.exists() else {}
        self.opts = {}
        self.q = queue.Queue()
        self.stop_flag = threading.Event()
        self.worker = None
        self.pkgs = sorted(p.parent.name for p in ROOT.glob("*/pubspec.yaml"))
        for p in self.pkgs:
            self.opts[p] = {s: s != "publish" for s in STEPS}
        self.check_mode = tk.StringVar(value="both")
        self.filter_var = tk.StringVar()
        self.filter_var.trace_add("write", lambda *_: self.fill())
        self.build()
        self.fill()
        self.refresh_git()
        self.after(100, self.pump)

    def build(self):
        top = ttk.Frame(self)
        top.pack(fill="x", padx=6, pady=4)
        ttk.Label(top, text="Filter:").pack(side="left")
        ttk.Entry(top, textvariable=self.filter_var, width=22).pack(side="left", padx=4)
        for s in STEPS:
            ttk.Button(top, text=f"Toggle all {s}", command=lambda s=s: self.toggle_col(s)).pack(side="left", padx=2)
        ttk.Label(top, text="Check mode:").pack(side="left", padx=(12, 2))
        ttk.Combobox(top, textvariable=self.check_mode, values=CHECK_MODES, width=8,
                     state="readonly").pack(side="left")
        ttk.Button(top, text="Refresh git status", command=self.refresh_git).pack(side="left", padx=12)
        ttk.Label(top, text="Proxy:").pack(side="left", padx=(12, 2))
        self.proxy = tk.StringVar(value=default_proxy())
        ttk.Entry(top, textvariable=self.proxy, width=24).pack(side="left")
        ttk.Label(top, text="Parallel:").pack(side="left", padx=(12, 2))
        self.workers = tk.IntVar(value=4)
        ttk.Spinbox(top, from_=1, to=16, textvariable=self.workers, width=3).pack(side="left")
        self.run_btn = ttk.Button(top, text="▶ Run all selected", command=lambda: self.start(None))
        self.run_btn.pack(side="right", padx=2)
        self.batch_btn = ttk.Button(top, text="▶ Run next batch", command=lambda: self.start(self.batch.get()))
        self.batch_btn.pack(side="right", padx=2)
        self.batch = tk.IntVar(value=7)
        ttk.Spinbox(top, from_=1, to=300, textvariable=self.batch, width=4).pack(side="right")
        ttk.Label(top, text="Batch size:").pack(side="right", padx=(12, 2))
        ttk.Button(top, text="Reset batches", command=self.reset_batches).pack(side="right", padx=8)
        self.stop_btn = ttk.Button(top, text="■ Stop", command=self.stop_flag.set, state="disabled")
        self.stop_btn.pack(side="right", padx=2)

        paned = ttk.PanedWindow(self, orient="vertical")
        paned.pack(fill="both", expand=True, padx=6, pady=4)
        frame = ttk.Frame(paned)
        self.tree = ttk.Treeview(frame, columns=self.COLS, show="headings", selectmode="extended")
        for c, h in zip(self.COLS, self.HEAD):
            self.tree.heading(c, text=h)
            narrow = c in ("dirty", "commit", "push", "check", "publish")
            self.tree.column(c, width=60 if narrow else 130, anchor="center" if narrow else "w")
        self.tree.column("pkg", width=190)
        sb = ttk.Scrollbar(frame, command=self.tree.yview)
        self.tree.configure(yscrollcommand=sb.set)
        self.tree.pack(side="left", fill="both", expand=True)
        sb.pack(side="right", fill="y")
        self.tree.bind("<Button-1>", self.on_click)
        paned.add(frame, weight=3)

        self.logbox = tk.Text(paned, height=12, state="disabled", wrap="none")
        paned.add(self.logbox, weight=1)
        self.status = ttk.Label(self, text="Click a Commit/Push/Check/Publish cell to toggle it.")
        self.status.pack(fill="x", padx=6)

    # ---- table -----------------------------------------------------------
    def row_values(self, p):
        st = self.state_data.get(p, {})
        country, area = describe(p)
        dirty = st.get("dirty")
        git = "?" if dirty is None else ("dirty" if dirty else "clean")
        if st.get("unpushed"):
            git += f" ↑{st['unpushed']}"
        box = lambda s: "☑" if self.opts[p][s] else "☐"
        return (p, country, area, git, *(box(s) for s in STEPS),
                st.get("last_commit", ""), st.get("last_push", ""),
                st.get("last_check", ""), st.get("last_publish", ""))

    def fill(self):
        f = self.filter_var.get().lower()
        self.tree.delete(*self.tree.get_children())
        for p in self.pkgs:
            vals = self.row_values(p)
            if f and f not in " ".join(vals[:3]).lower():
                continue
            self.tree.insert("", "end", iid=p, values=vals)

    def update_row(self, p):
        if self.tree.exists(p):
            self.tree.item(p, values=self.row_values(p))

    def on_click(self, ev):
        if self.tree.identify_region(ev.x, ev.y) != "cell":
            return
        col = self.COLS[int(self.tree.identify_column(ev.x)[1:]) - 1]
        row = self.tree.identify_row(ev.y)
        if col in STEPS and row:
            self.opts[row][col] = not self.opts[row][col]
            self.update_row(row)

    def toggle_col(self, s):
        shown = self.tree.get_children()
        new = not all(self.opts[p][s] for p in shown)
        for p in shown:
            self.opts[p][s] = new
            self.update_row(p)

    # ---- state -----------------------------------------------------------
    def save_state(self):
        STATE_FILE.write_text(json.dumps(self.state_data, indent=2, sort_keys=True))

    def refresh_git(self):
        def job():
            for p in self.pkgs:
                dirty, last, ahead = git_info(ROOT / p)
                self.q.put(("git", p, dirty, last, ahead))
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
                elif m[0] == "git":
                    _, p, dirty, last, ahead = m
                    st = self.state_data.setdefault(p, {})
                    st["dirty"], st["unpushed"] = dirty, ahead
                    if last:
                        st["last_commit"] = last
                    self.update_row(p)
                elif m[0] == "row":
                    self.update_row(m[1])
                elif m[0] == "done":
                    self.run_btn.configure(state="normal")
                    self.batch_btn.configure(state="normal")
                    self.stop_btn.configure(state="disabled")
                    self.status.configure(text=m[1])
        except queue.Empty:
            pass
        self.after(100, self.pump)

    # ---- run -------------------------------------------------------------
    def reset_batches(self):
        for st in self.state_data.values():
            st.pop("batch_done", None)
        self.save_state()
        self.status.configure(text="Batch marks cleared.")

    def start(self, limit):
        todo = [p for p in self.pkgs if any(self.opts[p].values())]
        nogit = [p for p in todo if not (ROOT / p / ".git").exists()]
        todo = [p for p in todo if p not in nogit]
        if nogit:
            self.q.put(("log", f"Skipping {len(nogit)} package(s) without git: {', '.join(nogit)}"))
        if limit:
            todo = [p for p in todo if not self.state_data.get(p, {}).get("batch_done")][:limit]
        if not todo:
            return messagebox.showinfo("Nothing to do", "No package left with a step checked.")
        pubs = [p for p in todo if self.opts[p]["publish"]]
        if pubs and not messagebox.askyesno(
                "Publish to pub.dev",
                f"{len(pubs)} package(s) will be REALLY published to pub.dev "
                "(irreversible). Continue?"):
            return
        self.proxy_value = self.proxy.get().strip()
        self.stop_flag.clear()
        self.run_btn.configure(state="disabled")
        self.batch_btn.configure(state="disabled")
        self.stop_btn.configure(state="normal")
        opts = {p: dict(self.opts[p]) for p in todo}
        self.worker = threading.Thread(
            target=self.work, args=(todo, opts, self.check_mode.get(), max(1, self.workers.get())),
            daemon=True)
        self.worker.start()

    def work(self, todo, opts, mode, workers):
        LOG_DIR.mkdir(exist_ok=True)
        REPORT_DIR.mkdir(exist_ok=True)
        logfile = LOG_DIR / f"run_{datetime.now():%Y%m%d_%H%M%S}.log"
        fh = logfile.open("w")
        lock = threading.Lock()

        def log(s):
            with lock:
                fh.write(s + "\n")
                fh.flush()
            self.q.put(("log", s))

        self.q.put(("log", f"Running {len(todo)} package(s), {workers} in parallel: {', '.join(todo)}"))
        global PROXY
        PROXY = self.proxy_value
        log(f"Proxy: {PROXY or '(inherited from environment/git config)'}")
        if any(opts[p]["push"] for p in todo):
            rc, out = run(["gh", "api", "user", "-q", ".login"], ROOT, log, quiet=True, timeout=30)
            if rc:
                log("ABORT: cannot reach GitHub (gh api user failed). Nothing was pushed or created.\n"
                    f"  {out}\n  Fix the Proxy field (or your network) and run again.")
                fh.close()
                self.q.put(("done", "Aborted: GitHub unreachable"))
                return
        failed = []

        def one(p):
            if self.stop_flag.is_set():
                return
            plog = lambda s: log("\n".join(f"[{p}] {l}" for l in s.splitlines() or [""]))
            path = ROOT / p
            st = self.state_data.setdefault(p, {})
            try:
                ok = self.step_all(p, path, opts[p], mode, st, plog)
            except Exception as e:  # keep the other packages going
                plog(f"CRASH: {e}")
                ok = False
            if not ok:
                failed.append(p)
            dirty, last, ahead = git_info(path)
            with lock:
                st["dirty"], st["unpushed"] = dirty, ahead
                if last:
                    st["last_commit"] = last
                st["batch_done"] = now()
                self.save_state()
            self.q.put(("row", p))
            plog("finished" + ("" if ok else " WITH FAILURES"))

        with ThreadPoolExecutor(max_workers=workers) as ex:
            list(ex.map(one, todo))
        fh.close()
        msg = (f"Done. {len(failed)} failed: {', '.join(sorted(failed))}" if failed
               else "Done, no failures.") + f"  Reports in {REPORT_DIR}"
        self.q.put(("log", f"\n{msg}  (log: {logfile})"))
        self.q.put(("done", msg))

    def write_report(self, p, mode, parts):
        header = f"{p} - check report {now()} (mode: {mode})\n{'=' * 60}\n"
        REPORT_DIR.mkdir(exist_ok=True)
        (REPORT_DIR / f"{p}.txt").write_text(header + "\n\n".join(parts) + "\n")

    def run_pana(self, path, log):
        rc, out = run(pana_cmd() + ["--no-warning", "--json", "."], path, log, quiet=True)
        try:
            # stderr log lines are JSON too; the report is the pretty-printed object on its own line
            data = json.loads(out[out.index("\n{\n") + 1:] if "\n{\n" in out else out[out.index("{"):])
        except ValueError:
            return rc, "pana output (could not parse JSON):\n" + clip(out)
        lines = []
        rep = data.get("report") or {}
        secs = rep.get("sections") or []
        granted = sum(s.get("grantedPoints") or 0 for s in secs)
        total = sum(s.get("maxPoints") or 0 for s in secs)
        lines.append(f"PUB POINTS: {granted} / {total}")
        for sec in (rep.get("sections") or []):
            lines.append(f"\n[{sec.get('grantedPoints')}/{sec.get('maxPoints')}] {sec.get('title')} ({sec.get('status')})")
            lines.append(clip(sec.get("summary", ""), 600))
        log(lines[0])
        return rc, "\n".join(lines)

    def ensure_remote(self, p, path, log):
        """Make sure origin exists and the GitHub repo behind it exists (public)."""
        rc, url = run(["git", "remote", "get-url", "origin"], path, log)
        if rc != 0:
            url = ""
        if url:
            repo = re.sub(r"(\.git)?/?$", "", url)
            repo = re.sub(r".*github\.com[:/]", "", repo)
        else:
            repo = f"{OWNER}/{p}"
        rc, out = run(["gh", "repo", "view", repo], path, log, quiet=True, timeout=60)
        if rc != 0 and not re.search(r"Could not resolve to a Repository|HTTP 404|not found", out, re.I):
            log(f"cannot check {repo} (network/proxy problem, not creating it): {out}")
            return False
        if rc != 0:
            log(f"GitHub repo {repo} not found, creating it (public)")
            rc, _ = run(["gh", "repo", "create", repo, "--public"], path, log)
            if rc:
                return False
        if not url:
            rc, _ = run(["git", "remote", "add", "origin", f"https://github.com/{repo}.git"], path, log)
        return rc == 0 or bool(url)

    def step_all(self, p, path, o, mode, st, log):
        if not (path / ".git").exists():
            log("no git repo, skipping package")
            return True
        if o["commit"]:
            rc, out = run(["git", "status", "--short"], path, log)
            if out:
                rc, _ = run(["git", "add", "-A"], path, log)
                if rc == 0:
                    rc, _ = run(["git", "commit", "-qm", f"Update {p}"], path, log)
                if rc:
                    log("COMMIT FAILED")
                    return False
                st["last_commit"] = now()
            else:
                log("nothing to commit")
        if o["push"]:
            if not self.ensure_remote(p, path, log):
                log("NO GITHUB REMOTE")
                return False
            # -u sets the upstream on a first push and is harmless afterwards.
            _, br = run(["git", "branch", "--show-current"], path, log)
            rc, out = run(["git", "push", "-u", "origin", br or "HEAD"], path, log)
            if rc:
                if "imeout" in out or "imed out" in out:
                    log("HINT: GitHub over IPv6 times out; prefer IPv4 system-wide (gai.conf)")
                log("PUSH FAILED")
                return False
            st["last_push"] = now()
        if o["check"]:
            ok, parts = True, []
            if mode in ("dry-run", "both"):
                rc, out = run(["flutter", "pub", "publish", "--dry-run"], path, log)
                ok = ok and rc == 0
                parts.append(f"## flutter pub publish --dry-run (exit {rc})\n{squeeze_dry_run(out)}")
            if mode in ("pana", "both"):
                rc, out = self.run_pana(path, log)
                ok = ok and rc == 0
                parts.append(f"## pana (exit {rc})\n{out}")
            self.write_report(p, mode, parts)
            st["last_check"] = f"{now()} {'ok' if ok else 'FAIL'}"
            if not ok:
                log("CHECK FAILED (publish skipped)")
                return False
        if o["publish"]:
            rc, _ = run(["flutter", "pub", "publish", "--force"], path, log)
            if rc:
                log("PUBLISH FAILED")
                return False
            st["last_publish"] = now()
        return True


if __name__ == "__main__":
    App().mainloop()
