#!/usr/bin/env python3
"""Check the static SEO of deploy/ (WEB_ARCH W13): germany and india, every built language.

  seo_check.py [country...]

Per page: unique title, description and canonical, one <h1>, at least 40 words of visible text. Across pages:
no duplicate descriptions, every sitemap URL resolves to a file in deploy/, and the homepage fetches no
/components/ URL. Exit 1 on any failure.
"""
import re, sys
from pathlib import Path
from urllib.parse import urlparse

DEPLOY = Path(__file__).resolve().parents[2] / "deploy"
LANGS = ("flutter", "typescript", "kotlin", "python")
errors = []


def fail(msg: str) -> None:
    errors.append(msg)


def first(pat: str, html: str) -> str:
    m = re.search(pat, html, re.S)
    return m[1].strip() if m else ""


def words(html: str) -> int:
    body = first(r"<body[^>]*>(.*)</body>", html)
    body = re.sub(r"<(script|style|noscript)\b.*?</\1>", " ", body, flags=re.S)
    return len(re.sub(r"<[^>]+>", " ", body).split())


def check_page(rel: str, seen: dict) -> None:
    f = DEPLOY / rel / "index.html"
    if not f.is_file():
        return fail(f"{rel}: no index.html")
    html = f.read_text()
    got = {"title": first(r"<title>(.*?)</title>", html),
           "description": first(r'<meta name="description" content="([^"]*)"', html),
           "canonical": first(r'<link rel="canonical" href="([^"]*)"', html)}
    for k, v in got.items():
        if not v:
            fail(f"{rel}: empty {k}")
        elif v in seen[k]:
            fail(f"{rel}: {k} duplicates {seen[k][v]}")
        else:
            seen[k][v] = rel
    if len(re.findall(r"<h1[ >]", html)) != 1:
        fail(f"{rel}: needs exactly one <h1>")
    if (n := words(html)) < 40:
        fail(f"{rel}: only {n} visible words")


def main() -> int:
    countries = sys.argv[1:] or ["germany", "india"]
    seen = {"title": {}, "description": {}, "canonical": {}}
    for c in countries:
        check_page(f"plates/{c}", seen)
        for l in LANGS:
            if (DEPLOY / "components" / c / l / "index.html").is_file():
                check_page(f"components/{c}/{l}", {"title": {}, "description": {}, "canonical": {}})
                check_page(f"plates/{c}/{l}", seen)
    # The component splash and the route page of one language describe the same URL; their canonicals must agree.
    for c in countries:
        for l in LANGS:
            a, b = DEPLOY / "components" / c / l / "index.html", DEPLOY / "plates" / c / l / "index.html"
            if a.is_file() and b.is_file():
                url = first(r'<link rel="canonical" href="([^"]*)"', a.read_text())
                if url != first(r'<link rel="canonical" href="([^"]*)"', b.read_text()):
                    fail(f"{c}/{l}: splash and route canonical differ")
    sm = DEPLOY / "sitemap.xml"
    if not sm.is_file():
        fail("sitemap.xml missing")
    else:
        for u in re.findall(r"<loc>([^<]+)</loc>", sm.read_text()):
            p = urlparse(u).path.lstrip("/")
            if not ((DEPLOY / p / "index.html").is_file() or (p and (DEPLOY / p).is_file())):
                fail(f"sitemap URL has no file: {u}")
    robots = DEPLOY / "robots.txt"
    if not robots.is_file() or "Sitemap:" not in robots.read_text():
        fail("robots.txt missing or without Sitemap")
    home = (DEPLOY / "index.html").read_text()
    if "/components/" in home:
        fail("homepage mentions a /components/ URL")
    for e in errors:
        print("FAIL", e)
    print(f"seo_check: {'FAILED' if errors else 'ok'} ({len(errors)} problems)")
    return 1 if errors else 0


if __name__ == "__main__":
    sys.exit(main())
