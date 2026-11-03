#!/usr/bin/env python3
"""Build a country's Flutter component (WEB_ARCH W9): deploy/components/<slug>/flutter/.

  build_flutter.py <country>... | --all | --changed [--force]

One generic shell (tools/web/flutter_shell) plus the gallery's own source for the country and the
files it needs are copied into build/flutter_embed/<slug>/, so the app imports only that country's
package. CanvasKit is built once per engine revision into deploy/shared/flutter/<engine>/canvaskit.
"""
import argparse, hashlib, json, re, shutil, subprocess, sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "ports/web"))
import seo  # noqa: E402
SHELL = Path(__file__).parent / "flutter_shell"
GALLERY = ROOT / "plate_number_holder"
SOURCES = GALLERY / "lib/screens/gallery/sources"
DEPLOY = ROOT / "deploy"
WORK = ROOT / "build/flutter_embed"
SHARED_PKGS = {"plate_core", "plate_keypad", "plate_alphabet"}
# Gallery files the shell reuses, copied to the path the shell's imports expect under lib/.
REUSED = {
    "lib/screens/gallery/catalogue.dart": "lib/catalogue.dart",
    "lib/newdesign/plate/live_plate.dart": "lib/newdesign/plate/live_plate.dart",
    "lib/newdesign/plate/letter_sheet.dart": "lib/newdesign/plate/letter_sheet.dart",
    "lib/newdesign/design/tokens.dart": "lib/newdesign/design/tokens.dart",
    "lib/newdesign/widgets/controls.dart": "lib/newdesign/widgets/controls.dart",
}


def run(cmd, cwd):
    p = subprocess.run(cmd, cwd=cwd, capture_output=True, text=True)
    if p.returncode:
        sys.exit(f"{' '.join(cmd)} failed in {cwd}:\n{p.stdout[-3000:]}\n{p.stderr[-3000:]}")
    return p.stdout


def engine() -> str:
    return json.loads(run(["flutter", "--version", "--machine"], ROOT))["engineRevision"][:10]


def info(slug: str) -> dict:
    src = SOURCES / f"{slug.replace('-', '_')}.dart"
    if not src.is_file():
        sys.exit(f"{slug}: no gallery source {src.relative_to(ROOT)}")
    text = src.read_text()
    cls = re.search(r"class (\w+) extends GallerySource\b", text)
    name = re.search(r"String get countryName\s*=>\s*'([^']*)'", text)
    pkgs = sorted(set(re.findall(r"import 'package:(\w+)/", text)) - SHARED_PKGS)
    if not cls or not name or not pkgs:
        sys.exit(f"{slug}: {src.name} is not a single-country GallerySource")
    return {"src": src, "cls": cls[1], "name": name[1], "pkgs": pkgs}


def stamp(i: dict, eng: str) -> str:
    h = hashlib.sha256(eng.encode())
    files = [*SHELL.iterdir(), i["src"], *(GALLERY / r for r in REUSED)]
    for p in i["pkgs"]:
        files += [f for f in (ROOT / p / "flutter").rglob("*")
                  if f.is_file() and not {"build", ".dart_tool"} & set(f.relative_to(ROOT / p / "flutter").parts)]
    for f in sorted(files):
        h.update(f.name.encode() + f.read_bytes())
    return h.hexdigest()[:16]


def build(slug: str, eng: str, force: bool) -> None:
    i = info(slug)
    out = DEPLOY / "components" / slug / "flutter"
    stamp_file = WORK / "stamps" / slug
    s = stamp(i, eng)
    if not force and (out / "index.html").is_file() and stamp_file.is_file() and stamp_file.read_text() == s:
        print(f"{slug}: up to date")
        return
    app = WORK / slug
    shutil.rmtree(app, ignore_errors=True)
    lib = app / "lib"
    (app / "web").mkdir(parents=True)
    lib.mkdir(parents=True)
    for n in ("embed_shell.dart", "bridge_web.dart", "bridge_stub.dart"):
        shutil.copy(SHELL / n, lib / n)
    for a, b in REUSED.items():
        (app / b).parent.mkdir(parents=True, exist_ok=True)
        shutil.copy(GALLERY / a, app / b)
    (lib / "sources").mkdir()
    shutil.copy(i["src"], lib / "sources" / i["src"].name)
    shutil.copytree(GALLERY / "assets/fonts", app / "assets/fonts",
                    ignore=shutil.ignore_patterns("MaterialIcons*"))
    fill = {"slug": slug, "root": str(ROOT), "engine": eng, **seo.esc(seo.slots(slug, "flutter")),
            "deps": "\n".join(f"  {p}:\n    path: {ROOT / p / 'flutter'}" for p in i["pkgs"])}

    def render(t: str) -> str:
        return re.sub(r"\{\{(\w+)\}\}", lambda m: fill.get(m[1], m[0]), t)

    (app / "pubspec.yaml").write_text(render((SHELL / "pubspec.yaml.tmpl").read_text()))
    for n in ("index.html", "flutter_bootstrap.js"):
        (app / "web" / n).write_text(render((SHELL / n).read_text()))
    (lib / "main.dart").write_text(
        f"import 'embed_shell.dart';\nimport 'sources/{i['src'].stem}.dart';\n\n"
        f"void main() => runEmbed({i['cls']}(), '{slug}');\n")
    run(["flutter", "pub", "get"], app)
    run(["flutter", "build", "web", "--release", "--no-web-resources-cdn", "--pwa-strategy=none",
         "--base-href", f"/components/{slug}/flutter/"], app)

    built = app / "build/web"
    kit = DEPLOY / "shared/flutter" / eng / "canvaskit"
    if not kit.is_dir():
        kit.parent.mkdir(parents=True, exist_ok=True)
        shutil.copytree(built / "canvaskit", kit)
    shutil.rmtree(built / "canvaskit")
    shutil.rmtree(out, ignore_errors=True)
    shutil.copytree(built, out)
    stamp_file.parent.mkdir(parents=True, exist_ok=True)
    stamp_file.write_text(s)
    size = sum(f.stat().st_size for f in out.rglob("*") if f.is_file())
    print(f"{slug}: built, {size // 1024} KB")


def all_slugs() -> list:
    return sorted(p.stem.replace("_", "-") for p in SOURCES.glob("*.dart") if p.stem != "sources")


def changed_slugs() -> list:
    paths = [l[3:].split(" -> ")[-1] for l in run(["git", "status", "--porcelain", "-uall"], ROOT).splitlines()]
    if any(p.startswith(("tools/web/flutter_shell/", "plate_number_holder/lib/newdesign/")) for p in paths):
        return sorted(d.parent.name for d in (DEPLOY / "components").glob("*/flutter"))
    dirs = {p.split("/")[0] for p in paths}
    out = []
    for slug in all_slugs():
        try:
            src = f"plate_number_holder/lib/screens/gallery/sources/{slug.replace('-', '_')}.dart"
            if set(info(slug)["pkgs"]) & dirs or src in paths:
                out.append(slug)
        except SystemExit:
            pass
    return out


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("countries", nargs="*")
    ap.add_argument("--all", action="store_true")
    ap.add_argument("--changed", action="store_true")
    ap.add_argument("--force", action="store_true")
    a = ap.parse_args()
    slugs = all_slugs() if a.all else changed_slugs() if a.changed else [c.replace("_", "-") for c in a.countries]
    if not slugs:
        print("nothing to build")
        return 0
    eng = engine()
    failed = []
    for slug in slugs:
        try:
            build(slug, eng, a.force)
        except SystemExit as e:
            print(e, file=sys.stderr)
            failed.append(slug)
            if not (a.all or a.changed):
                break
    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main())
