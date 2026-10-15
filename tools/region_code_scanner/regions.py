"""Cut a Wikipedia plate page's raw HTML into one chunk per heading and let the
few-shot model `plate-regions` (see train.py) decide which chunks say which
plate code means which state/province/district/city.

The model only answers yes/no per chunk; the chunks written to out/regions/
are the page's own HTML, never model output.
"""
import json
import re
import urllib.request
from pathlib import Path

HERE = Path(__file__).resolve().parent
REGIONS = HERE / 'out' / 'regions'
ENDPOINT = 'http://localhost:11434'
MODEL = 'plate-regions'
# What the model sees per chunk. Long code lists are recognisable from
# their start, and a 0.8b model degrades on long input.
MODEL_CHARS = 2500

HEADING = re.compile(r'<div class="mw-heading mw-heading([2-4])"[^>]*>\s*<h[2-4][^>]*\bid="([^"]+)"[^>]*>(.*?)</h[2-4]>',
                     re.S)
STOP_IDS = re.compile(r'^(See_also|References|External_links|Notes|Further_reading|Sources|Bibliography)', re.I)

SCHEMA = {
    'type': 'object',
    'properties': {'region_codes': {'type': 'boolean'}},
    'required': ['region_codes'],
}


def _body(html):
    start = html.find('<div class="mw-content-ltr mw-parser-output"')
    start = html.find('>', start) + 1 if start >= 0 else 0
    end = html.find('<div class="printfooter"', start)
    return html[start:end if end > 0 else None]


def sections(html):
    """[{id, title, path, html}] for the intro and every h2-h4 section; path
    is the heading chain, e.g. 'Sarawak > Current format'."""
    body = _body(html)
    marks = list(HEADING.finditer(body))
    out = [{'id': '_intro', 'title': '(intro)', 'path': '(intro)', 'html': body[:marks[0].start() if marks else None]}]
    chain = {}
    for n, m in enumerate(marks):
        level, sid = int(m.group(1)), m.group(2)
        title = clean_text(m.group(3))
        chain = {k: v for k, v in chain.items() if k < level}
        chain[level] = title
        end = marks[n + 1].start() if n + 1 < len(marks) else len(body)
        out.append({'id': sid, 'title': title, 'path': ' > '.join(chain[k] for k in sorted(chain)),
                    'html': body[m.end():end]})
    return [s for s in out if not STOP_IDS.match(s['id']) and clean_text(compact(s['html']))]


def clean_text(html):
    return ' '.join(re.sub(r'<[^>]+>', ' ', html).split())


def compact(html):
    """Raw HTML minus noise: no scripts/styles/refs/images, no attributes
    except row/colspan, no inline wrapper tags. Structure (p, li, table) stays."""
    html = re.sub(r'<(style|script|math)\b.*?</\1>', '', html, flags=re.S)
    html = re.sub(r'<sup\b[^>]*class="[^"]*reference[^"]*".*?</sup>', '', html, flags=re.S)
    html = re.sub(r'<span class="mw-editsection.*?</span>\s*</span>', '', html, flags=re.S)
    html = re.sub(r'<(figure|figcaption)\b.*?</\1>', '', html, flags=re.S)
    html = re.sub(r'</?(a|span|img|abbr|small|div|link|meta|bdi|i|b|wbr|section|noscript)\b[^>]*>', '', html)
    html = re.sub(r'<(\w+)\s[^>]*?((?:rowspan|colspan)="\d+")?[^>]*>',
                  lambda m: f'<{m.group(1)} {m.group(2)}>' if m.group(2) else f'<{m.group(1)}>', html)
    html = re.sub(r'<!--.*?-->', '', html, flags=re.S)
    return re.sub(r'\s+', ' ', html).strip()


def model_input(country, section):
    return (f'Country: {country}\nSection: {section["path"]}\n'
            f'HTML:\n{compact(section["html"])[:MODEL_CHARS]}')


def classify(country, section, model=MODEL):
    body = {
        'model': model, 'stream': False, 'format': SCHEMA, 'think': False,
        'messages': [{'role': 'user', 'content': model_input(country, section)}],
        'options': {'temperature': 0},
    }
    req = urllib.request.Request(ENDPOINT + '/api/chat', data=json.dumps(body).encode(),
                                 headers={'Content-Type': 'application/json'})
    with urllib.request.urlopen(req, timeout=600) as r:
        return json.loads(json.load(r)['message']['content'])['region_codes']


def extract(country, slug, html, model=MODEL, log=lambda _: None):
    """Classify every section; write the kept ones to out/regions/<slug>.html.
    Returns the kept section paths."""
    kept = []
    for s in sections(html):
        yes = classify(country, s, model)
        log(f'  {"KEEP" if yes else "skip"}  {s["path"]}')
        if yes:
            kept.append(s)
    REGIONS.mkdir(parents=True, exist_ok=True)
    path = REGIONS / f'{slug}.html'
    if kept:
        parts = [f'<h2>{s["path"]}</h2>\n{s["html"]}' for s in kept]
        path.write_text(f'<!doctype html><meta charset="utf-8"><title>{country} region codes</title>\n'
                        + '\n<hr>\n'.join(parts), encoding='utf-8')
    elif path.exists():
        path.unlink()
    return [s['path'] for s in kept]
