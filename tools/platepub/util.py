"""Subprocess runner, git helpers, and small shared helpers."""
import json
import os
import re
import subprocess
import threading
import time
from datetime import datetime
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
TOOLS = ROOT / "tools"
CONFIG_FILE = TOOLS / "platepub.json"
EXCLUDED = {"plate_number_holder", "core_plate"}
OWNER = "ArAd1Beyranvand"
NOISE = ("├", "└", "│")


def now():
    return datetime.now().strftime("%Y-%m-%d %H:%M")


def config():
    """Optional overrides from tools/platepub.json: {"limits": {...}, "gradle": "...", "proxy": "..."}."""
    return json.loads(CONFIG_FILE.read_text()) if CONFIG_FILE.exists() else {}


def packages():
    return sorted(p.parent.parent.name for p in ROOT.glob("*/flutter/pubspec.yaml")
                  if p.parent.parent.name not in EXCLUDED)


def clip(text, limit=3000):
    """Keep the tail of a long output; the verdict is at the end."""
    text = text.strip()
    return text if len(text) <= limit else f"[... {len(text) - limit} chars cut ...]\n" + text[-limit:]


def default_proxy():
    """The proxy git is configured with (what works for you), else the env one."""
    p = subprocess.run(["git", "config", "--global", "http.proxy"], capture_output=True, text=True)
    return p.stdout.strip() or os.environ.get("HTTPS_PROXY") or os.environ.get("https_proxy") or ""


class Sh:
    """Runs commands with one log sink, proxy and stop flag; streams output live."""

    def __init__(self, log=print, proxy="", stop=None):
        self.log, self.proxy, self.stop = log, proxy, stop or threading.Event()

    def env(self, extra=None):
        env = {**os.environ, "GIT_TERMINAL_PROMPT": "0", "GIT_ASKPASS": "true", "CI": "1", **(extra or {})}
        if self.proxy:
            for k in ("HTTP_PROXY", "HTTPS_PROXY", "ALL_PROXY", "http_proxy", "https_proxy", "all_proxy"):
                env[k] = self.proxy
            env.update(GIT_CONFIG_COUNT="1", GIT_CONFIG_KEY_0="http.proxy", GIT_CONFIG_VALUE_0=self.proxy)
        return env

    def run(self, cmd, cwd, quiet=False, timeout=1800, env=None, secret=()):
        """Returns (exit code, combined output). `secret` strings are masked in the log and the output."""
        mask = lambda s: re.sub("|".join(map(re.escape, secret)), "***", s) if secret else s
        self.log(mask(f"$ {' '.join(cmd)}"))
        start = time.time()
        try:
            p = subprocess.Popen(cmd, cwd=cwd, stdin=subprocess.DEVNULL, stdout=subprocess.PIPE,
                                 stderr=subprocess.STDOUT, text=True, env=self.env(env))
        except OSError as e:
            self.log(f"  error: {e}")
            return 127, str(e)
        lines = []

        def reader():
            for l in p.stdout:
                lines.append(l)
                if not quiet and not l.lstrip().startswith(NOISE) and "available)" not in l:
                    self.log(mask("  " + l.rstrip()))

        t = threading.Thread(target=reader, daemon=True)
        t.start()
        beat = start
        while t.is_alive():
            t.join(2)
            if not t.is_alive():
                break
            if self.stop.is_set() or time.time() - start > timeout:
                p.kill()
                self.log("  stopped" if self.stop.is_set() else f"  timeout after {timeout}s, killed")
            elif time.time() - beat > 60:
                beat = time.time()
                self.log(f"  ... still running ({int(beat - start)}s, {len(lines)} lines)")
        p.wait()
        self.log(f"  -> exit {p.returncode} in {time.time() - start:.1f}s")
        return p.returncode, mask("".join(lines).strip())  # tools like deno echo their command line, token included


def git(repo, *args):
    p = subprocess.run(["git", "-C", str(repo), *args], capture_output=True, text=True)
    return p.returncode, p.stdout.strip()


def git_info(repo):
    """(dirty, last_commit_time, unpushed) for a package repo; dirty is None without a repo."""
    if not (repo / ".git").exists():
        return None, "", None
    _, st = git(repo, "status", "--short")
    _, last = git(repo, "log", "-1", "--format=%cd", "--date=format:%Y-%m-%d %H:%M")
    rc, ahead = git(repo, "rev-list", "--count", "@{u}..HEAD")
    return bool(st), last, (int(ahead) if rc == 0 and ahead.isdigit() else None)


def bump_patch(manifest):
    """Raise the patch number of the first `version` key in a manifest; return (old, new) or None."""
    text = manifest.read_text()
    m = re.search(r'(\bversion"?\s*[:=]\s*"?)(\d+)\.(\d+)\.(\d+)', text)
    if not m:
        return None
    old, new = ".".join(m.groups()[1:]), f"{m[2]}.{m[3]}.{int(m[4]) + 1}"
    manifest.write_text(text[:m.start()] + m[1] + new + text[m.end():])
    return old, new
