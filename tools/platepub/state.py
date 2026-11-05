"""Persistent state (tools/package_state.json) and registry publish quotas.

Schema v2:  {"_v": 2, "_publishes": [{reg, pkg, at}], "_cooldown": {reg: epoch},
             "<pkg>": {"git": {dirty, unpushed, last_commit, last_push},
                       "reg": {"<registry>": {published, version, checked, points}}}}
"""
import json
import shutil
import threading
import time
from datetime import datetime

from .util import TOOLS, config

STATE_FILE = TOOLS / "package_state.json"
DAY = 86400

# Per registry: (max NEW packages, per seconds). Only first publishes of a package count.
# pub.dev: 12 new packages a day and 4 within a short burst; the burst window is a guess, so it is
# configurable in tools/platepub.json ({"limits": {"pubdev": [[12, 86400], [4, 600]]}}).
DEFAULT_LIMITS = {"pubdev": [(12, DAY), (4, 600)]}


class State:
    def __init__(self, path=STATE_FILE):
        self.path, self.lock = path, threading.RLock()
        self.data = json.loads(path.read_text()) if path.exists() else {}
        if self.data.get("_v") != 2:
            self.migrate()

    def migrate(self):
        backup = self.path.with_name("package_state.v1.json.bak")
        if self.path.exists() and not backup.exists():
            shutil.copy(self.path, backup)
        new = {"_v": 2, "_publishes": [], "_cooldown": {}}
        for pkg, o in self.data.items():
            git = {k: o[k] for k in ("dirty", "unpushed", "last_commit", "last_push") if k in o}
            reg = {}
            if o.get("last_publish"):
                reg["pubdev"] = {"published": o["last_publish"]}
                at = datetime.strptime(o["last_publish"], "%Y-%m-%d %H:%M").timestamp()
                if time.time() - at < DAY:
                    new["_publishes"].append({"reg": "pubdev", "pkg": pkg, "at": at})
            for k, dst in (("last_check", "checked"), ("points", "points")):
                if o.get(k):
                    reg.setdefault("pubdev", {})[dst] = o[k]
            new[pkg] = {"git": git, "reg": reg}
        self.data = new
        self.save()

    def git(self, p):
        with self.lock:
            return self.data.setdefault(p, {}).setdefault("git", {})

    def reg(self, p, r):
        with self.lock:
            return self.data.setdefault(p, {}).setdefault("reg", {}).setdefault(r, {})

    def published(self, p, r):
        return bool(self.data.get(p, {}).get("reg", {}).get(r, {}).get("published"))

    def save(self):
        with self.lock:
            cut = time.time() - 2 * DAY
            self.data["_publishes"] = [e for e in self.data.get("_publishes", []) if e["at"] > cut]
            self.path.write_text(json.dumps(self.data, indent=1, sort_keys=True))


class Quota:
    """Rolling-window limits on new-package publishes, shared by all worker threads."""

    def __init__(self, state):
        self.state, self.lock = state, threading.Lock()
        lim = {**DEFAULT_LIMITS, **{k: [tuple(x) for x in v] for k, v in config().get("limits", {}).items()}}
        self.limits = lim

    def _recent(self, reg, window, t):
        return sorted(e["at"] for e in self.state.data.get("_publishes", [])
                      if e["reg"] == reg and e["at"] > t - window)

    def wait(self, reg, t=None):
        """Seconds until one more new package may be published on `reg` (0 = now)."""
        t = t or time.time()
        w = max(0, self.state.data.get("_cooldown", {}).get(reg, 0) - t)
        for n, window in self.limits.get(reg, []):
            r = self._recent(reg, window, t)
            if len(r) >= n:
                w = max(w, r[len(r) - n] + window - t)
        return w

    def room(self, reg, t=None):
        """How many new packages may be published right now."""
        t = t or time.time()
        if self.wait(reg, t) > 0:
            return 0
        return min((n - len(self._recent(reg, w, t)) for n, w in self.limits.get(reg, [])), default=10**6)

    def day_full(self, reg):
        """True when the longest window is used up (waiting a few minutes will not help)."""
        lim = self.limits.get(reg)
        if not lim:
            return False
        n, window = max(lim, key=lambda x: x[1])
        return len(self._recent(reg, window, time.time())) >= n

    def used(self, reg):
        t = time.time()
        return [(len(self._recent(reg, w, t)), n, w) for n, w in self.limits.get(reg, [])]

    def reserve(self, reg, pkg):
        """Take a slot (returns (0, token)) or return (seconds to wait, None)."""
        with self.lock:
            w = self.wait(reg)
            if w > 0:
                return w, None
            e = {"reg": reg, "pkg": pkg, "at": time.time()}
            self.state.data.setdefault("_publishes", []).append(e)
            self.state.save()
            return 0, e

    def release(self, token):
        with self.lock:
            if token in self.state.data.get("_publishes", []):
                self.state.data["_publishes"].remove(token)
                self.state.save()

    def cooldown(self, reg, seconds):
        with self.lock:
            self.state.data.setdefault("_cooldown", {})[reg] = time.time() + seconds
            self.state.save()
