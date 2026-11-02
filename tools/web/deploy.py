#!/usr/bin/env python3
"""Assemble the static site in deploy/ (WEB_ARCH "Build and deploy").

  deploy.py [country...] [--changed] [--lang ts,kt,py,flutter] [--skip-gallery] [--force-gallery]

Components are built by each ports/<lang>/portctl.json `web_build` (or `web_build_all`, incremental)
and tools/web/build_flutter.py; all of them write straight into deploy/. The gallery is built only
when plate_number_holder lib/, web/, assets/ or pubspec.yaml change (stamp in build/gallery.stamp), so
updating one component never rebuilds it. Then components/index.json is regenerated and `_headers` is
written (Netlify / Cloudflare Pages format; any host with per-path headers can translate it).
"""
import argparse, hashlib, json, re, shutil, subprocess, sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
DEPLOY = ROOT / "deploy"
GALLERY = ROOT / "plate_number_holder"
STAMP = ROOT / "build/gallery.stamp"
sys.path.insert(0, str(ROOT / "ports/web"))
import seo  # noqa: E402
LANGS = {"ts": "typescript", "kt": "kotlin", "py": "python"}
NEEDS = {"ts": "node", "kt": "java", "py": "python3", "flutter": "flutter"}

# Hashed names never change content: immutable. Everything else must revalidate.
IMMUTABLE = ["/shared/*", "/components/*/typescript/assets/*", "/components/*/kotlin/js-*/*",
             "/components/*/kotlin/wasm-*/*", "/components/*/python/*.zip"]
REVALIDATE = ["/", "/index.html", "/flutter_bootstrap.js", "/flutter.js", "/flutter_service_worker.js",
              "/main.dart.js", "/version.json", "/components/index.json", "/components/*/*/index.html",
              "/components/*/flutter/*.js", "/components/*/flutter/version.json", "/plates/*", "/sitemap.xml"]


def sh(cmd, cwd=ROOT, check=True):
    print("+", " ".join(map(str, cmd)), flush=True)
    r = subprocess.run(cmd, cwd=cwd, capture_output=True, text=True)
    if r.returncode and check:
        sys.exit(f"failed ({r.returncode}): {' '.join(map(str, cmd))}\n{r.stdout[-2500:]}\n{r.stderr[-2500:]}")
    return r.stdout


def available(lang) -> bool:
    tool = NEEDS[lang]
    if lang == "kt" and not (ROOT / "ports/kt/gradlew").is_file():
        return False
    return shutil.which(tool) is not None


def changed_paths() -> list:
    return [l[3:].split(" -> ")[-1] for l in sh(["git", "status", "--porcelain", "-uall"]).splitlines()]


def plan_changed(langs) -> dict:
    """lang -> list of countries (underscored) to rebuild, or None for the language's incremental build_all."""
    out = {}
    for p in changed_paths():
        parts = p.split("/")
        if p.startswith("ports/data/countries/") and p.endswith(".json"):
            for l in langs:
                if out.get(l, []) is not None:
                    out.setdefault(l, []).append(Path(p).stem)
        elif parts[0] == "ports" and len(parts) > 3 and parts[1] in langs and parts[2] in ("src", "web", "codegen"):
            if "countries" in parts and parts[1] != "py" and len(parts) > 5:
                c = parts[parts.index("countries") + 1]
                if out.get(parts[1], []) is not None:
                    out.setdefault(parts[1], []).append(c)
            else:
                out[parts[1]] = None
    return out


def build_components(langs, countries, changed) -> None:
    plan = plan_changed(langs) if changed else {}
    for l in langs:
        if l == "flutter" or not available(l):
            continue
        cfg = json.loads((ROOT / f"ports/{l}/portctl.json").read_text())
        todo = countries if countries else plan.get(l, []) if changed else None
        if todo is None:
            sh(["bash", "-c", cfg["web_build_all"]], ROOT / f"ports/{l}")
        for c in sorted(set(todo or [])):
            sh(["bash", "-c", cfg["web_build"].format(country=c.replace("-", "_"))], ROOT / f"ports/{l}")
    if "flutter" in langs and available("flutter"):
        cmd = [sys.executable, "tools/web/build_flutter.py"]
        sh(cmd + ([c.replace("_", "-") for c in countries] if countries else ["--changed"] if changed else ["--all"]))


def gallery_stamp() -> str:
    h = hashlib.sha256()
    files = [GALLERY / "pubspec.yaml", *(f for d in ("lib", "web", "assets") for f in (GALLERY / d).rglob("*") if f.is_file())]
    for f in sorted(files):
        h.update(f.relative_to(GALLERY).as_posix().encode() + b"\0" + f.read_bytes())
    return h.hexdigest()


def engine() -> str:
    return json.loads(sh(["flutter", "--version", "--machine"]))["engineRevision"][:10]


def build_gallery(force: bool) -> None:
    if not available("flutter"):
        print("flutter not installed: gallery skipped")
        return
    stamp = gallery_stamp()
    if not force and (DEPLOY / "index.html").is_file() and STAMP.is_file() and STAMP.read_text() == stamp:
        print("gallery: up to date")
        return
    sh(["flutter", "pub", "get"], GALLERY)
    sh(["flutter", "build", "web", "--release"], GALLERY)
    built = GALLERY / "build/web"
    kit = DEPLOY / "shared/flutter" / engine() / "canvaskit"
    if not kit.is_dir():
        kit.parent.mkdir(parents=True, exist_ok=True)
        shutil.copytree(built / "canvaskit", kit)
    for e in DEPLOY.iterdir():
        if e.name not in ("components", "shared", "_headers"):
            shutil.rmtree(e) if e.is_dir() else e.unlink()
    for e in built.iterdir():
        if e.name == "canvaskit":
            continue
        shutil.copytree(e, DEPLOY / e.name) if e.is_dir() else shutil.copy(e, DEPLOY / e.name)
    boot = DEPLOY / "flutter_bootstrap.js"
    text = boot.read_text()
    assert "_flutter.loader.load({" in text, "unexpected flutter_bootstrap.js"
    boot.write_text(text.replace("_flutter.loader.load({", f'_flutter.loader.load({{\n  config: {{ canvasKitBaseUrl: "/shared/flutter/{engine()}/canvaskit/" }},', 1))
    STAMP.parent.mkdir(exist_ok=True)
    STAMP.write_text(stamp)
    print("gallery: built")


def route_page(shell: str, s: dict, links: list, crumbs: list) -> str:
    """The gallery shell with one route's title, meta, canonical and readable pre-boot text (W13)."""
    e, url = seo.esc(s), s["canonical"]
    ld = json.dumps({"@context": "https://schema.org", "@type": "WebPage", "name": s["title"], "url": url,
                     "description": s["description"], "isPartOf": {"@type": "WebSite", "name": "platexample", "url": seo.ORIGIN + "/"}},
                    ensure_ascii=False).replace("</", "<\\/")
    nav = " · ".join(f'<a href="{h}" style="color:#2dd4c4">{seo.html.escape(n)}</a>' for h, n in crumbs + links)
    body = (f'<main id="preboot" style="max-width:560px;width:86vw;color:#c9ccd3;font-size:14px;line-height:1.5;text-align:center">'
            f'<h1 style="margin:0 0 6px;font-size:18px;color:#e8eaee">{e["h1"]}</h1><p style="margin:0 0 8px">{e["text"]}</p><nav>{nav}</nav></main>')
    for pat, rep in [
        (r"<title>.*?</title>", f"<title>{e['title']}</title>"),
        (r'(<meta name="description" content=")[^"]*', r"\g<1>" + e["description"]),
        (r'(<link rel="canonical" href=")[^"]*', r"\g<1>" + e["canonical"]),
        (r'(<meta property="og:title" content=")[^"]*', r"\g<1>" + e["title"]),
        (r'(<meta property="og:description" content=")[^"]*', r"\g<1>" + e["description"]),
        (r'(<meta property="og:url" content=")[^"]*', r"\g<1>" + e["canonical"]),
        (r'(<meta name="twitter:title" content=")[^"]*', r"\g<1>" + e["title"]),
        (r'(<meta name="twitter:description" content=")[^"]*', r"\g<1>" + e["description"]),
        (r'<script type="application/ld\+json">.*?</script>', '<script type="application/ld+json">' + ld + "</script>"),
        (r'<main id="preboot".*?</main>', body)]:
        shell, n = re.subn(pat, lambda m, rep=rep: m.expand(rep), shell, count=1, flags=re.S)
        assert n, f"gallery shell lacks {pat}"
    return shell


def write_seo() -> None:
    """Per-route static pages, sitemap.xml and robots.txt (W12, W13); a crawler needs no Flutter."""
    shell = (DEPLOY / "index.html").read_text()
    reg = json.loads((DEPLOY / "components/index.json").read_text())["components"]
    shutil.rmtree(DEPLOY / "plates", ignore_errors=True)
    urls = [seo.ORIGIN + "/"]

    def put(rel: str, html: str, url: str) -> None:
        (DEPLOY / rel).mkdir(parents=True, exist_ok=True)
        (DEPLOY / rel / "index.html").write_text(html)
        urls.append(url)

    for slug, langs in sorted(reg.items()):
        country = seo.country_slots(slug)
        name = seo.name_of(slug)
        links = [(f"/plates/{slug}/{l}", seo.LANGS[l]) for l in seo.LANGS if l in langs]
        put(f"plates/{slug}", route_page(shell, country, links, [("/", "All countries")]), country["canonical"])
        for l in langs:
            s = seo.slots(slug, l)
            put(f"plates/{slug}/{l}", route_page(shell, s, [x for x in links if not x[0].endswith("/" + l)],
                                                 [(f"/plates/{slug}", f"{name} overview")]), s["canonical"])
    sm = "".join(f"  <url><loc>{u}</loc></url>\n" for u in urls)
    (DEPLOY / "sitemap.xml").write_text('<?xml version="1.0" encoding="UTF-8"?>\n<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">\n' + sm + "</urlset>\n")
    (DEPLOY / "robots.txt").write_text(f"User-agent: *\nAllow: /\nSitemap: {seo.ORIGIN}/sitemap.xml\n")
    print(f"seo: {len(urls)} pages in sitemap.xml")


def write_headers() -> None:
    lines = ["# Generated by tools/web/deploy.py. Hashed assets never change; entry points revalidate.\n"]
    for pat in REVALIDATE:
        lines.append(f"{pat}\n  Cache-Control: no-cache\n")
    for pat in IMMUTABLE:
        lines.append(f"{pat}\n  Cache-Control: public, max-age=31536000, immutable\n")
    (DEPLOY / "_headers").write_text("\n".join(lines))


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("countries", nargs="*", help="build only these (all languages) instead of everything")
    ap.add_argument("--changed", action="store_true", help="build what git status says changed")
    ap.add_argument("--lang", default="ts,kt,py,flutter")
    ap.add_argument("--skip-gallery", action="store_true")
    ap.add_argument("--force-gallery", action="store_true")
    a = ap.parse_args()
    langs = [l for l in a.lang.split(",") if l]
    missing = [l for l in langs if not available(l)]
    if missing:
        print(f"unavailable toolchains, skipped: {', '.join(missing)}")
    DEPLOY.mkdir(exist_ok=True)
    build_components(langs, a.countries, a.changed)
    if not a.skip_gallery:
        build_gallery(a.force_gallery)
    sh([sys.executable, "ports/web/registry.py", "--deploy", str(DEPLOY)])
    sh([sys.executable, "ports/web/registry.py", "--deploy", str(DEPLOY), "--check"])
    write_headers()
    if (DEPLOY / "index.html").is_file():
        write_seo()
    print(f"deploy/ ready: {sum(f.stat().st_size for f in DEPLOY.rglob('*') if f.is_file()) // 2**20} MB")
    return 0


if __name__ == "__main__":
    sys.exit(main())
