#!/usr/bin/env python3
"""Page text for search engines and the loading pages (WEB_ARCH W13), written from ports/data.

  seo.py <country> <lang> [--key title|description|h1|text|canonical]    JSON, or one raw value

Every component splash and every static route page takes its words from here, so the text never
drifts from the data and nothing is written per country by hand. Values are HTML-escaped.
"""
import html, json, os, sys
from pathlib import Path

DATA = Path(__file__).resolve().parents[1] / "data/countries"
ORIGIN = os.environ.get("VITE_GALLERY_ORIGIN") or "https://platexample.ir"
LANGS = {"flutter": "Flutter", "typescript": "TypeScript", "kotlin": "Kotlin", "python": "Python"}
RUNS = {"flutter": "the Flutter widgets", "typescript": "the TypeScript port", "kotlin": "the Kotlin port",
        "python": "the Python port on Pyodide"}


def name_of(country: str) -> str:
    return " ".join(w.capitalize() for w in country.replace("-", "_").split("_"))


def _list(items: list) -> str:
    return items[0] if len(items) == 1 else ", ".join(items[:-1]) + " and " + items[-1]


def describe(country: str) -> str:
    """Two or three sentences on the country's plate formats: kinds, regions, one example."""
    name, f = name_of(country), DATA / f"{country.replace('-', '_')}_plate.json"
    if not f.is_file():
        return f"{name} license plates, drawn and checked as you type."
    d = json.loads(f.read_text())
    entries = d["gallery"]
    kinds = list(dict.fromkeys(e["label"].split(" · ")[0] for e in entries))[:4]
    first = entries[0] if entries else None
    out = [f"The library draws {len(d['specs'])} plate format{'s' * (len(d['specs']) != 1)} for {name}"
           + (f", among them {_list(kinds)}." if kinds else ".")]
    if d["resolvers"]:
        out.append("The region or district on a plate is looked up from its code and shown beside the number.")
    if first:
        out.append(f"A typical registration reads {''.join(first['sampleValues'])}.")
    return " ".join(out)


def slots(country: str, lang: str) -> dict:
    name, language = name_of(country), LANGS[lang]
    text = (f"{describe(country)} This page runs {RUNS[lang]}: type a registration and watch the plate "
            f"take shape and get checked as you go.")
    first = text.split(". ")[0] + "."
    return {"title": f"{name} license plates · {language}",
            "description": f"{name} license plates in {language}. {first} Type a registration and see it drawn live.",
            "h1": f"{name} license plates in {language}", "text": text,
            "canonical": f"{ORIGIN}/plates/{country.replace('_', '-')}/{lang}"}


def country_slots(country: str) -> dict:
    name = name_of(country)
    text = f"{describe(country)} Pick a language below the plate to try the same formats in Flutter, TypeScript, Kotlin or Python."
    return {"title": f"{name} license plates · platexample",
            "description": f"{name} license plates: formats, regions and a live example you can type into. {text.split('. ')[0]}.",
            "h1": f"{name} license plates", "text": text, "canonical": f"{ORIGIN}/plates/{country.replace('_', '-')}"}


def esc(d: dict) -> dict:
    return {k: html.escape(v, quote=True) for k, v in d.items()}


if __name__ == "__main__":
    a = sys.argv
    out = esc(slots(a[1], a[2]))
    print(out[a[a.index("--key") + 1]] if "--key" in a else json.dumps(out, ensure_ascii=False))
