"""One class per package registry: where its manifest lives, how to check, publish and probe it."""
import json
import os
import re
import shutil
import threading
import urllib.error
import urllib.request
from pathlib import Path

from .util import NOISE, ROOT, clip, config, now

REPORT_DIR = ROOT / "reports"
NOT_FULL_FILE = REPORT_DIR / "not_160.txt"
MAVEN_GROUP = "io.github.arad1beyranvand"
NPM_SCOPE = JSR_SCOPE = "plate"  # JSR only: its names cannot hold underscores, so it keeps @plate/<dash>
_points_lock = threading.Lock()


def dash(pkg):
    """algeria_plate -> algeria, new_south_wales_plate -> new-south-wales, plate_core -> core."""
    if pkg == "plate_core":
        return "core"
    return (pkg[:-6] if pkg.endswith("_plate") else pkg).replace("_", "-")


def probe(url, proxy=""):
    """True if the URL exists, False on 404, None when the registry could not be reached."""
    opener = urllib.request.build_opener(
        *([urllib.request.ProxyHandler({"http": proxy, "https": proxy})] if proxy else []))
    try:
        with opener.open(urllib.request.Request(url, headers={"User-Agent": "platepub"}), timeout=20):
            return True
    except urllib.error.HTTPError as e:
        return False if e.code in (404, 410) else None
    except (urllib.error.URLError, OSError):
        return None


class Registry:
    key = label = subdir = manifest = ""
    exists_re = r"already exists"
    changelog = False

    def dir(self, pkg):
        return ROOT / pkg / self.subdir

    def present(self, pkg):
        return (self.dir(pkg) / self.manifest).exists()

    def version(self, pkg):
        m = re.search(r'\bversion"?\s*[:=]\s*"?(\d+\.\d+\.\d+)', (self.dir(pkg) / self.manifest).read_text())
        return m[1] if m else None

    def name(self, pkg):
        return pkg

    def probe_url(self, pkg):
        raise NotImplementedError

    def check(self, pkg, sh, o):
        """Dry-run. Returns (ok, report text, info dict stored in the state)."""
        raise NotImplementedError

    def publish(self, pkg, sh, o):
        raise NotImplementedError

    def doctor(self, sh):
        """[(what, ok, detail)] for tools and credentials; never prints a secret."""
        raise NotImplementedError

    @staticmethod
    def need(*tools):
        return [(f"{t} on PATH", bool(shutil.which(t)), shutil.which(t) or "missing") for t in tools]


class PubDev(Registry):
    key, label, subdir, manifest = "pubdev", "pub.dev", "flutter", "pubspec.yaml"
    exists_re = r"version \S+ of package \S+ already exists"
    changelog = True

    def probe_url(self, pkg):
        return f"https://pub.dev/api/packages/{pkg}"

    def check(self, pkg, sh, o):
        d, ok, parts, info = self.dir(pkg), True, [], {}
        if o.check_mode in ("dry-run", "both"):
            rc, out = sh.run(["flutter", "pub", "publish", "--dry-run"], d)
            ok = ok and rc == 0
            keep = [l for l in out.splitlines() if not l.lstrip().startswith(NOISE) and "available)" not in l]
            parts.append(f"## flutter pub publish --dry-run (exit {rc})\n{clip(chr(10).join(keep))}")
        if o.check_mode in ("pana", "both"):
            rc, text, info = self.pana(pkg, sh)
            ok = ok and rc == 0
            parts.append(f"## pana (exit {rc})\n{text}")
        return ok, "\n\n".join(parts), info

    def pana(self, pkg, sh):
        cmd = ["pana"] if shutil.which("pana") else ["dart", "pub", "global", "run", "pana"]
        rc, out = sh.run(cmd + ["--no-warning", "--json", "."], self.dir(pkg), quiet=True)
        try:  # stderr log lines are JSON too; the report is the pretty-printed object on its own line
            data = json.loads(out[out.index("\n{\n") + 1:] if "\n{\n" in out else out[out.index("{"):])
        except ValueError:
            return rc, "pana output (could not parse JSON):\n" + clip(out), {}
        secs = (data.get("report") or {}).get("sections") or []
        granted = sum(s.get("grantedPoints") or 0 for s in secs)
        total = sum(s.get("maxPoints") or 0 for s in secs)
        lines = [f"PUB POINTS: {granted} / {total}"]
        for s in secs:
            lines += [f"\n[{s.get('grantedPoints')}/{s.get('maxPoints')}] {s.get('title')} ({s.get('status')})",
                      clip(s.get("summary", ""), 600)]
        sh.log(lines[0])
        self.log_points(pkg, granted, total)
        return rc, "\n".join(lines), {"points": f"{granted}/{total}"}

    @staticmethod
    def log_points(pkg, granted, total):
        """Keep reports/not_160.txt = one line per package that is below full points."""
        with _points_lock:
            rows = dict(l.split(": ", 1) for l in NOT_FULL_FILE.read_text().splitlines() if ": " in l) \
                if NOT_FULL_FILE.exists() else {}
            if granted == total and total:
                rows.pop(pkg, None)
            else:
                rows[pkg] = f"{granted}/{total}  ({now()})"
            REPORT_DIR.mkdir(exist_ok=True)
            NOT_FULL_FILE.write_text("".join(f"{k}: {v}\n" for k, v in sorted(rows.items())))

    def publish(self, pkg, sh, o):
        return sh.run(["flutter", "pub", "publish", "--force"], self.dir(pkg))

    def doctor(self, sh):
        cred = Path.home() / ".config/dart/pub-credentials.json"
        return self.need("flutter", "dart") + [("pub.dev login", cred.exists(), "run `dart pub login`" if not cred.exists() else str(cred))]


class Npm(Registry):
    key, label, subdir, manifest = "npm", "npm", "typescript", "package.json"
    exists_re = r"cannot publish over the previously published"

    def name(self, pkg):
        return pkg

    def probe_url(self, pkg):
        return f"https://registry.npmjs.org/{pkg}"

    def check(self, pkg, sh, o):
        rc, out = sh.run(["npm", "publish", "--dry-run", "--access", "public"], self.dir(pkg))
        return rc == 0, f"## npm publish --dry-run (exit {rc})\n{clip(out)}", {}

    def publish(self, pkg, sh, o):
        return sh.run(["npm", "publish", "--access", "public"], self.dir(pkg))

    def doctor(self, sh):
        rc, out = sh.run(["npm", "whoami"], ROOT, quiet=True, timeout=60) if shutil.which("npm") else (1, "")
        return self.need("npm") + [("npm login", rc == 0, out if rc == 0 else "run `npm login`")]


class Jsr(Registry):
    key, label, subdir, manifest = "jsr", "JSR", "typescript", "jsr.json"
    exists_re = r"already exists|version .* is already published"

    def name(self, pkg):
        return f"@{JSR_SCOPE}/{dash(pkg)}"

    def probe_url(self, pkg):
        return f"https://jsr.io/@{JSR_SCOPE}/{dash(pkg)}/meta.json"

    def _cmd(self, *extra):
        tok = os.environ.get("JSR_TOKEN")
        return ["npx", "--yes", "jsr", "publish", "--allow-dirty", *extra] + (["--token", tok] if tok else []), \
            (tok,) if tok else ()

    def check(self, pkg, sh, o):
        cmd, secret = self._cmd("--dry-run")
        rc, out = sh.run(cmd, self.dir(pkg), secret=secret)
        return rc == 0, f"## jsr publish --dry-run (exit {rc})\n{clip(out)}", {}

    def publish(self, pkg, sh, o):
        cmd, secret = self._cmd()
        return sh.run(cmd, self.dir(pkg), secret=secret)

    def doctor(self, sh):
        has = bool(os.environ.get("JSR_TOKEN"))
        return self.need("npx") + [("JSR_TOKEN", has, "set" if has else "create one at jsr.io, export JSR_TOKEN (else the browser prompt blocks)")]


class Maven(Registry):
    key, label, subdir, manifest = "maven", "Maven Central", "kotlin", "build.gradle.kts"
    exists_re = r"already exists|already been published|409"

    def name(self, pkg):
        return f"{MAVEN_GROUP}:{pkg}"

    def probe_url(self, pkg):
        return f"https://repo1.maven.org/maven2/{MAVEN_GROUP.replace('.', '/')}/{pkg}/maven-metadata.xml"

    @staticmethod
    def gradle():
        return config().get("gradle") or str(ROOT / "plate_core/kotlin/gradlew")

    def _run(self, pkg, sh, task):
        return sh.run([self.gradle(), "-p", str(self.dir(pkg)), task, "--no-daemon", "--console=plain"], ROOT)

    def check(self, pkg, sh, o):
        rc, out = self._run(pkg, sh, "publishToMavenLocal")
        return rc == 0, f"## gradle publishToMavenLocal (exit {rc})\n{clip(out)}", {}

    def publish(self, pkg, sh, o):
        return self._run(pkg, sh, "publishToMavenCentral")

    def doctor(self, sh):
        props = Path.home() / ".gradle/gradle.properties"
        text = props.read_text() if props.exists() else ""
        env = " ".join(os.environ)
        rows = [("gradle wrapper", Path(self.gradle()).exists(), self.gradle())]
        for k in ("mavenCentralUsername", "mavenCentralPassword"):
            rows.append((k, k in text or f"ORG_GRADLE_PROJECT_{k}" in env, "in ~/.gradle/gradle.properties or ORG_GRADLE_PROJECT_*"))
        rows.append(("signing key", bool(re.search(r"signing\.keyId|signingInMemoryKey", text)) or "ORG_GRADLE_PROJECT_signingInMemoryKey" in env,
                     "signing.keyId/password/secretKeyRingFile or signingInMemoryKey"))
        return self.need("gpg") + rows


class PyPI(Registry):
    key, label, subdir, manifest = "pypi", "PyPI", "python", "pyproject.toml"
    exists_re = r"File already exists|already exist"

    def name(self, pkg):
        return pkg

    def probe_url(self, pkg):
        return f"https://pypi.org/pypi/{self.name(pkg)}/json"

    def _build(self, pkg, sh):
        d = self.dir(pkg)
        shutil.rmtree(d / "dist", ignore_errors=True)
        return sh.run(["python3", "-m", "build", "--outdir", "dist"], d)

    def check(self, pkg, sh, o):
        rc, out = self._build(pkg, sh)
        if rc == 0:
            rc, out2 = sh.run(["python3", "-m", "twine", "check", "dist/*"], self.dir(pkg))
            out += "\n" + out2
        return rc == 0, f"## python -m build + twine check (exit {rc})\n{clip(out)}", {}

    def publish(self, pkg, sh, o):
        rc, out = self._build(pkg, sh)
        if rc:
            return rc, out
        files = [str(p) for p in (self.dir(pkg) / "dist").iterdir()]
        return sh.run(["python3", "-m", "twine", "upload", "--non-interactive", *files], self.dir(pkg))

    def doctor(self, sh):
        mods = [(f"python module {m}", sh.run(["python3", "-c", f"import {m}"], ROOT, quiet=True)[0] == 0, f"pip install {m}")
                for m in ("build", "twine")]
        ok = (Path.home() / ".pypirc").exists() or bool(os.environ.get("TWINE_PASSWORD"))
        return mods + [("PyPI token", ok, "~/.pypirc or TWINE_USERNAME=__token__ / TWINE_PASSWORD")]


REGISTRIES = {r.key: r for r in (PubDev(), Npm(), Jsr(), Maven(), PyPI())}
EARLY = ("npm", "jsr", "maven", "pypi")  # no known per-day quota: push these as soon as the package exists
