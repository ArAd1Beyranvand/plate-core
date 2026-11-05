"""The pipeline: per package git commit/push, then per registry check and publish, honouring quotas."""
import re
import threading
import time
from concurrent.futures import ThreadPoolExecutor
from dataclasses import dataclass, field
from datetime import datetime, timedelta

from .registries import REGISTRIES, REPORT_DIR, probe
from .state import Quota, State
from .util import OWNER, ROOT, Sh, bump_patch, git, git_info, now, packages

LOG_DIR = ROOT / "tools" / "manager_logs"
RATE_RE = re.compile(r"rate.?limit|too many (requests|packages)|exceed(ed)? .*limit|\b429\b", re.I)
STEPS = ("commit", "push", "check", "publish")


@dataclass
class Options:
    steps: set = field(default_factory=lambda: {"check", "publish"})
    regs: list = field(default_factory=lambda: ["pubdev"])
    check_mode: str = "dry-run"  # dry-run | pana | both (pub.dev only)
    need_full: bool = False  # pub.dev: publish only at full pub points
    republish: bool = False  # bump the patch version of already-published units and publish again
    workers: int = 4
    proxy: str = ""


class Engine:
    def __init__(self, log=print, state=None, stop=None):
        self.state = state or State()
        self.quota = Quota(self.state)
        self.stop = stop or threading.Event()
        self.log = log
        self.deferred = []  # (pkg, registry, wait seconds): quota said "not yet"
        LOG_DIR.mkdir(exist_ok=True)

    # ---- queries ---------------------------------------------------------
    def units(self, regs, pkgs=None):
        """[(pkg, registry key)] that have a manifest; plate_core first, since the others depend on it."""
        pkgs = sorted(pkgs or packages(), key=lambda p: (p != "plate_core", p))
        return [(p, r) for p in pkgs for r in regs if REGISTRIES[r].present(p)]

    def pending(self, reg, pkgs=None):
        return [p for p, r in self.units([reg], pkgs) if not self.state.published(p, r)]

    def refresh_git(self, pkgs=None):
        for p in pkgs or packages():
            dirty, last, ahead = git_info(ROOT / p)
            g = self.state.git(p)
            g["dirty"], g["unpushed"] = dirty, ahead
            if last:
                g["last_commit"] = last
        self.state.save()

    def sync(self, regs, pkgs=None, proxy=""):
        """Ask each registry whether the package is really there; fixes a stale local state."""
        us = self.units(regs, pkgs)

        def one(u):
            p, r = u
            return u, probe(REGISTRIES[r].probe_url(p), proxy)

        with ThreadPoolExecutor(8) as ex:
            res = list(ex.map(one, us))
        for (p, r), found in res:
            st = self.state.reg(p, r)
            if found and not st.get("published"):
                st["published"] = "remote " + now()
            elif found is False and st.get("published"):
                self.log(f"{p}: state says published on {r} but the registry has no such package; clearing")
                st.pop("published")
        self.state.save()
        return res

    # ---- running ---------------------------------------------------------
    def run(self, pkgs, o):
        """Process packages in parallel; returns the failed ones. plate_core goes alone and first."""
        pkgs = sorted(pkgs, key=lambda p: (p != "plate_core", p))
        failed = []
        logfile = (LOG_DIR / f"run_{datetime.now():%Y%m%d_%H%M%S}.log").open("a")
        lock = threading.Lock()

        def log(s):
            with lock:
                logfile.write(s + "\n")
                logfile.flush()
            self.log(s)

        log(f"Running {len(pkgs)} package(s) [{','.join(o.regs)}] steps={','.join(sorted(o.steps))}: {', '.join(pkgs)}")

        def one(p):
            if self.stop.is_set():
                return
            plog = lambda s: log("\n".join(f"[{p}] {l}" for l in s.splitlines() or [""]))
            try:
                ok = self.process(p, o, Sh(plog, o.proxy, self.stop), plog)
            except Exception as e:  # keep the other packages going
                plog(f"CRASH: {e!r}")
                ok = False
            if not ok:
                failed.append(p)
            self.refresh_git([p])
            plog("finished" + ("" if ok else " WITH FAILURES"))

        core = [p for p in pkgs if p == "plate_core"]
        for batch in ([core] if core else []) + [[p for p in pkgs if p != "plate_core"]]:
            with ThreadPoolExecutor(max_workers=max(1, o.workers)) as ex:
                list(ex.map(one, batch))
        self.state.save()
        logfile.close()
        return failed

    def process(self, p, o, sh, log):
        repo = ROOT / p
        if not (repo / ".git").exists():
            log("no git repo, skipping package")
            return True
        g = self.state.git(p)
        if "commit" in o.steps:
            _, out = git(repo, "status", "--short")
            if out:
                if sh.run(["git", "add", "-A"], repo)[0] or sh.run(["git", "commit", "-qm", f"Update {p}"], repo)[0]:
                    log("COMMIT FAILED")
                    return False
                g["last_commit"] = now()
            else:
                log("nothing to commit")
        if "push" in o.steps and not self.push(p, repo, sh, log):
            return False
        ok = True
        for r in o.regs:
            if REGISTRIES[r].present(p):
                ok = self.unit(p, REGISTRIES[r], o, sh, log) and ok
        return ok

    def push(self, p, repo, sh, log):
        """Make sure origin and the GitHub repo exist, then push the current branch."""
        rc, url = sh.run(["git", "remote", "get-url", "origin"], repo, quiet=True)
        slug = re.sub(r".*github\.com[:/]", "", re.sub(r"(\.git)?/?$", "", url)) if rc == 0 and url else f"{OWNER}/{p}"
        rc, out = sh.run(["gh", "repo", "view", slug], repo, quiet=True, timeout=60)
        if rc and not re.search(r"Could not resolve to a Repository|HTTP 404|not found", out, re.I):
            log(f"cannot check {slug} (network/proxy problem, not creating it): {out}")
            return False
        if rc:
            log(f"GitHub repo {slug} not found, creating it (public)")
            if sh.run(["gh", "repo", "create", slug, "--public"], repo)[0]:
                return False
        if not url and sh.run(["git", "remote", "add", "origin", f"https://github.com/{slug}.git"], repo)[0]:
            return False
        _, br = git(repo, "branch", "--show-current")
        rc, out = sh.run(["git", "push", "-u", "origin", br or "HEAD"], repo)
        if rc:
            if "imed out" in out:
                log("HINT: GitHub over IPv6 times out; prefer IPv4 system-wide (gai.conf)")
            log("PUSH FAILED")
            return False
        self.state.git(p)["last_push"] = now()
        return True

    def unit(self, p, reg, o, sh, log):
        st = self.state.reg(p, reg.key)
        log(f"-- {reg.label}: {reg.name(p)} {reg.version(p) or '?'}")
        if "check" in o.steps:
            ok, report, info = reg.check(p, sh, o)
            st.update(info, checked=f"{now()} {'ok' if ok else 'FAIL'}")
            REPORT_DIR.joinpath(reg.key).mkdir(parents=True, exist_ok=True)
            (REPORT_DIR / reg.key / f"{p}.txt").write_text(f"{p} - {reg.label} check {now()}\n{'=' * 60}\n{report}\n")
            self.state.save()
            if not ok:
                log(f"{reg.label} CHECK FAILED (publish skipped)")
                return False
        if "publish" not in o.steps:
            return True
        first = not st.get("published")
        if not first and not o.republish:
            log(f"already published on {reg.label}; skipped")
            return True
        if o.need_full and reg.key == "pubdev":
            if "points" not in st:
                st.update(reg.pana(p, sh)[2])
            g, _, t = st.get("points", "0/0").partition("/")
            if t in ("", "0") or g != t:
                log(f"PUBLISH SKIPPED: pub points {st.get('points')}, need full score")
                return False
        token = None
        if first:
            wait, token = self.quota.reserve(reg.key, p)
            if wait:
                self.deferred.append((p, reg.key, wait))
                log(f"QUOTA: {reg.label} allows the next new package at {datetime.now() + timedelta(seconds=wait):%H:%M}; deferred")
                return True
        elif o.republish:
            self.bump(p, reg, log)
        rc, out = reg.publish(p, sh, o)
        if rc and re.search(reg.exists_re, out, re.I):
            if self.bump(p, reg, log):
                if "push" in o.steps:
                    sh.run(["git", "push", "origin", "HEAD"], ROOT / p)
                rc, out = reg.publish(p, sh, o)
        if rc:
            if token:
                self.quota.release(token)
            if RATE_RE.search(out):
                self.quota.cooldown(reg.key, 3600)
                log(f"RATE LIMITED by {reg.label}; no more attempts for an hour")
            log(f"{reg.label} PUBLISH FAILED")
            return False
        st.update(published=now(), version=reg.version(p))
        self.state.save()
        return True

    def bump(self, p, reg, log):
        r = bump_patch(reg.dir(p) / reg.manifest)
        if not r:
            log(f"cannot bump {reg.manifest}: no plain x.y.z version")
            return None
        if reg.changelog:
            cl = reg.dir(p) / "CHANGELOG.md"
            cl.write_text(f"## {r[1]}\n\n- Version bump; {r[0]} was already published.\n\n" + (cl.read_text() if cl.exists() else ""))
        log(f"{reg.label}: version {r[0]} -> {r[1]}")
        git(ROOT / p, "add", "-A")
        git(ROOT / p, "commit", "-qm", f"Bump {reg.label} version to {r[1]}")
        return r[1]

    # ---- the daily pub.dev routine --------------------------------------
    def daily(self, o, reg="pubdev", batch=4, poll=lambda s: None):
        """Publish new packages in bursts, waiting out the short window, until the day limit is reached.

        Returns (published count, message). A package that fails is not retried in the same run.
        """
        tried, done = set(), 0
        o.regs, o.workers = [reg], batch
        while not self.stop.is_set():
            todo = [p for p in self.pending(reg) if p not in tried]
            if not todo:
                return done, f"No {REGISTRIES[reg].label} package left to publish."
            room = self.quota.room(reg)
            if room == 0:
                wait = self.quota.wait(reg)
                if self.quota.day_full(reg):
                    return done, f"Day limit reached; next slot at {datetime.now() + timedelta(seconds=wait):%Y-%m-%d %H:%M}."
                self.log(f"Burst limit: waiting {int(wait)}s (until {datetime.now() + timedelta(seconds=wait):%H:%M})")
                end = time.time() + wait + 1
                while time.time() < end and not self.stop.is_set():
                    time.sleep(1)
                    poll(end - time.time())
                continue
            chunk = todo[:min(batch, room)]
            tried.update(chunk)
            self.run(chunk, o)
            done += sum(self.state.published(p, reg) for p in chunk)
        return done, "Stopped."
