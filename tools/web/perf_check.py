#!/usr/bin/env python3
"""Performance gate for deploy/ (WEB_ARCH W4, W14).

  perf_check.py [country...] [--static]

Serves deploy/ locally and, with headless Chrome (net-log), records every URL a page requests:
  * homepage: no /components/ URL, no deferred *.part.js, gzip transfer <= HOME_BUDGET;
  * <country> + <lang>: only /components/index.json, /components/<country>/<lang>/ and that language's
    /shared/ folder (Kotlin ships its runtime inside the component, Flutter's CanvasKit is shared).
Without Chrome (or with --static) the same rules run over the asset graph referenced by each
index.html. Also checks that `_headers` gives every file the intended cache policy.
Exits non-zero on a breach.
"""
import argparse, functools, gzip, http.server, json, re, shutil, subprocess, sys, tempfile, threading
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
DEPLOY = ROOT / "deploy"
# Measured 2026-11-02 (single main.dart.js gallery, before W14 deferral): gzip of everything the
# homepage fetches. Lower it when W14 lands; a breach means the gallery grew.
HOME_BUDGET = 6 * 2**20
SHARED = {"typescript": "typescript", "python": "python", "kotlin": None, "flutter": "flutter"}
CHROME = next(filter(None, map(shutil.which, ("google-chrome", "chromium", "chromium-browser"))), None)
sys.path.insert(0, str(ROOT / "tools/web"))
import deploy as D  # noqa: E402  (cache policy lists)


def gz(path: Path) -> int:
    return len(gzip.compress(path.read_bytes(), 6))


def browse(url: str, port: int) -> list:
    """Paths (same origin) and external URLs requested while loading url, via Chrome's net log."""
    with tempfile.TemporaryDirectory() as tmp:
        log = Path(tmp) / "net.json"
        subprocess.run([CHROME, "--headless=new", "--no-sandbox", "--disable-gpu", "--use-angle=swiftshader",
                        "--enable-unsafe-swiftshader", f"--user-data-dir={tmp}/p", f"--log-net-log={log}",
                        "--virtual-time-budget=25000", "--dump-dom", url],
                       capture_output=True, timeout=120)
        data = json.loads(log.read_text() + ("]}" if not log.read_text().rstrip().endswith("}") else ""))
    start = data["constants"]["logEventTypes"]["URL_REQUEST_START_JOB"]
    urls = {e["params"]["url"] for e in data["events"] if e["type"] == start and "url" in e.get("params", {})}
    return sorted(u for u in urls if u.startswith("http"))


def graph(country: str, lang: str) -> list:
    """Static fallback: same-origin paths an index.html references (src/href/import)."""
    base = f"/components/{country}/{lang}/"
    html = (DEPLOY / base.strip("/") / "index.html").read_text()
    out = [base]
    for ref in re.findall(r'(?:src|href)="([^"#?]+)"|import\(["\']([^"\']+)', html):
        r = next(x for x in ref if x)
        if not r.startswith(("http", "//", "data:")):
            out.append("/" + str(Path(base.lstrip("/")) / r).replace("\\", "/") if not r.startswith("/") else r)
    return [re.sub(r"/[^/]+/\.\./", "/", p) for p in out]


def norm(p: str) -> str:
    parts = []
    for s in p.split("/"):
        parts = parts[:-1] if s == ".." and parts else parts + [s]
    return "/".join(parts)


def violations(paths: list, country=None, lang=None) -> list:
    bad = []
    paths = [norm(p) for p in paths]
    for p in paths:
        if p.endswith(".part.js") and country is None:
            bad.append(f"deferred country chunk on homepage: {p}")
        if country is None and p.startswith("/components/"):
            bad.append(f"homepage fetched {p}")
        if country is not None:
            ok = p == "/components/index.json" or p.startswith(f"/components/{country}/{lang}/")
            shared = SHARED[lang]
            ok = ok or (shared and p.startswith(f"/shared/{shared}/")) or p.startswith("/shared/flutter/")
            # The Flutter host's own CanvasKit is always shared/flutter; other runtimes must match lang.
            if p.startswith(("/components/", "/shared/")) and not ok:
                bad.append(f"{country}/{lang} fetched {p}")
    return bad


def glob(pat: str) -> re.Pattern:
    return re.compile("^" + re.escape(pat).replace(r"\*", ".*") + "$")


def header_problems() -> list:
    """Every file must match exactly one policy class (immutable xor revalidate, or neither for plain assets)."""
    headers = (DEPLOY / "_headers").read_text()
    rules = dict(re.findall(r"^(/\S*)\n\s+Cache-Control: (.+)$", headers, re.M))
    imm = [glob(p) for p, v in rules.items() if "immutable" in v]
    rev = [glob(p) for p, v in rules.items() if v == "no-cache"]
    bad = []
    if set(rules) != set(D.IMMUTABLE) | set(D.REVALIDATE):
        bad.append("_headers is out of date: rerun deploy.py")
    for f in DEPLOY.rglob("*"):
        if not f.is_file():
            continue
        p = "/" + f.relative_to(DEPLOY).as_posix()
        i, r = any(g.match(p) for g in imm), any(g.match(p) for g in rev)
        if i and r:
            bad.append(f"{p}: both immutable and revalidate")
    for p in ("/components/index.json", "/index.html"):
        if not any(g.match(p) for g in rev):
            bad.append(f"{p}: not revalidated")
    for f in list(DEPLOY.glob("components/*/*/index.html"))[:50]:
        if any(g.match("/" + f.relative_to(DEPLOY).as_posix()) for g in imm):
            bad.append(f"{f.name} immutable")
    return bad


class Quiet(http.server.SimpleHTTPRequestHandler):
    def log_message(self, *a):
        pass


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("countries", nargs="*", default=["germany", "india"])
    ap.add_argument("--static", action="store_true")
    a = ap.parse_args()
    countries = a.countries or ["germany", "india"]
    registry = json.loads((DEPLOY / "components/index.json").read_text())["components"]
    fails = header_problems()
    live = CHROME and not a.static
    print("mode:", "chrome net-log" if live else "static asset graph")
    srv = http.server.ThreadingHTTPServer(("127.0.0.1", 0), functools.partial(Quiet, directory=str(DEPLOY)))
    threading.Thread(target=srv.serve_forever, daemon=True).start()
    port, origin = srv.server_port, f"http://127.0.0.1:{srv.server_port}"

    def paths(pageurl, static):
        if not live:
            return static, 0
        got = browse(pageurl, port)
        local = [u[len(origin):].split("?")[0].split("#")[0] or "/" for u in got if u.startswith(origin)]
        return local, sum(gz(DEPLOY / p.lstrip("/")) for p in set(local) if (DEPLOY / p.lstrip("/")).is_file())

    home_static = ["/index.html", "/flutter_bootstrap.js", "/main.dart.js"]
    got, size = paths(origin + "/", home_static)
    if not live:
        size = sum(gz(DEPLOY / p.lstrip("/")) for p in home_static)
    bad = violations(got)
    if live and "/main.dart.js" not in got:
        bad.append("homepage never loaded main.dart.js (browser run failed)")
    if size > HOME_BUDGET:
        bad.append(f"homepage transfer {size} > budget {HOME_BUDGET}")
    print(f"home: {len(got)} requests, {size / 2**20:.2f} MB gzip (budget {HOME_BUDGET / 2**20:.0f} MB)")
    fails += bad
    for c in countries:
        for lang in registry.get(c, {}):
            got, _ = paths(f"{origin}/#/plates/{c}/{lang}", graph(c, lang))
            if live and lang != "flutter" and not any(p.startswith(f"/components/{c}/{lang}/") for p in got):
                print(f"  note: {c}/{lang} iframe not requested (gallery host not wired); falling back to its asset graph")
                got += graph(c, lang)
            bad = violations(got, c, lang)
            print(f"{c}/{lang}: {len([p for p in got if p.startswith(('/components/', '/shared/'))])} component requests",
                  "ok" if not bad else "BREACH")
            fails += bad
    for c in countries:
        if c not in registry:
            fails.append(f"{c}: not in registry")
    srv.shutdown()
    print("\n".join(f"FAIL {f}" for f in fails) or "perf_check ok")
    return 1 if fails else 0


if __name__ == "__main__":
    sys.exit(main())
