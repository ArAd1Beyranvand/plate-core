"""Stage 1: the article, its tables and its images — no model involved.

The skill's Phase 1 has an LLM read 120 KB of HTML and open every image to
find the size, the format, the categories and which picture goes with which
row. All of that is structure the page already carries: the infobox is a
<th>/<td> table, the vehicle-type table is a `wikitable`, and every image is a
`/wiki/File:` link inside the row it illustrates. This module turns the page
into `facts.json` (a few hundred tokens) and downloads the originals.
"""
from __future__ import annotations

import json
import re
import time
import urllib.error
import urllib.parse
import urllib.request
from pathlib import Path

from bs4 import BeautifulSoup

from platekit import progress

UA = {'User-Agent': 'platekit/0.1 (licence-plate research; offline tooling)'}
WIKI = 'https://en.wikipedia.org'


def _get(url: str, tries: int = 5, label: str = '') -> bytes:
    """upload.wikimedia.org answers 429 to bursts; back off and retry."""
    label = label or urllib.parse.unquote(url.rsplit('/', 1)[-1])[:60]
    for i in range(tries):
        try:
            with urllib.request.urlopen(urllib.request.Request(url, headers=UA), timeout=60) as r:
                total = int(r.headers.get('Content-Length') or 0) or None
                buf = bytearray()
                while chunk := r.read(64 * 1024):
                    buf += chunk
                    progress.task(label, len(buf), total, 'B')
                progress.task(label, len(buf), total or len(buf), 'B', force=True)
                return bytes(buf)
        except urllib.error.HTTPError as e:
            if e.code != 429 or i == tries - 1:
                raise
            wait = 2 ** (i + 1)
            progress.task(f'{label}: 429, retry in {wait:.0f}s', 0, None, force=True)
            time.sleep(wait)


def country_from_url(url: str) -> str:
    """`…/Vehicle_registration_plates_of_the_Gambia` -> `Gambia`."""
    m = re.search(r'/wiki/Vehicle_registration_plates_of_([^#?]+)', url)
    if not m:
        raise ValueError(f'not a Vehicle_registration_plates_of_… article: {url}')
    name = urllib.parse.unquote(m.group(1)).replace('_', ' ')
    return re.sub(r'^the ', '', name, flags=re.I)


def iso2(country: str) -> str | None:
    """The ISO 3166-1 alpha-2 code (Wikidata P297), lower case — the
    gallery's id prefix and the golden file prefix."""
    q = urllib.parse.urlencode({'action': 'wbgetentities', 'sites': 'enwiki', 'titles': f'{country}|The {country}',
                                'props': 'claims', 'format': 'json', 'redirects': 'yes'})
    try:
        data = json.loads(_get(f'https://www.wikidata.org/w/api.php?{q}'))
        for e in data.get('entities', {}).values():
            for c in e.get('claims', {}).get('P297', []):
                return c['mainsnak']['datavalue']['value'].lower()
    except Exception:
        pass
    return None


JUNK_SVG = re.compile(r'flag|coat_of_arms|logo|icon|map|seal|emblem|symbol|locator|wiki|question_book|'
                      r'edit-clear|ambox|crystal|nuvola', re.I)


# wiki chrome, never on a plate
NOT_ICON = re.compile(r'commons-logo|wiki|question_book|edit-clear|ambox|crystal|nuvola|locator|map', re.I)


def icon_files(body) -> list[str]:
    """The flags, coats of arms, emblems and seals the page shows: dropped
    as plate images, kept as candidates for what a plate carries."""
    return [n for n in _files(body) if n.lower().endswith('.svg')
            and JUNK_SVG.search(n) and not NOT_ICON.search(n)]


def article_url(country: str) -> str:
    return f'{WIKI}/wiki/Vehicle_registration_plates_of_{country.replace(" ", "_")}'


def fetch_article(country: str, out: Path) -> Path:
    """Downloads the article; falls back to the index's `Main article:` link."""
    out.mkdir(parents=True, exist_ok=True)
    dest = out / 'art.html'
    e: Exception | None = None
    for name in (country, f'the {country}'):  # country_from_url drops a leading "the"
        try:
            dest.write_bytes(_get(article_url(name)))
            return dest
        except urllib.error.HTTPError as err:
            e = err
    if e is not None:  # 404 or a redirect title that differs
        index = _get(f'{WIKI}/wiki/Vehicle_registration_plate').decode()
        soup = BeautifulSoup(index, 'lxml')
        for a in soup.select('div.hatnote a'):
            if country.lower() in a.get_text().lower():
                dest.write_bytes(_get(WIKI + a['href']))
                return dest
        raise RuntimeError(f'no article for {country}: {e}') from e


def _text(node) -> str:
    return re.sub(r'\s+', ' ', node.get_text(' ', strip=True)).strip()


def _files(node) -> list[str]:
    names = []
    # a flag icon is an <img resource=…File:…> with no link around it
    for el in node.select('a[href*="/wiki/File:"], img[resource*="/wiki/File:"]'):
        ref = el.get('href') or el['resource']
        n = urllib.parse.unquote(ref.split('File:', 1)[1])
        if n not in names:
            names.append(n)
    return names


def parse(html: str) -> dict:
    """Infobox, prose by section, every table row with its images."""
    soup = BeautifulSoup(html, 'lxml')
    body = soup.select_one('#mw-content-text .mw-parser-output')
    # Maintenance boxes, stub notices and navboxes carry icons and links to
    # every other country (an "Israel" link sits in the Asia navbox).
    for junk in body.select('style, script, sup.reference, .mw-editsection, .navbox, .reflist, '
                            '.metadata, .ambox, .asbox, .sistersitebox, .side-box, .hatnote'):
        junk.decompose()
    # plate drawings are often SVG (Ireland has no plate photo at all);
    # flags, logos, maps and coats of arms are SVG too and are dropped
    all_images = [n for n in _files(body) if not n.lower().endswith('.svg') or not JUNK_SVG.search(n)]
    icons = icon_files(body)
    context = image_context(body)
    all_images = [n for n in all_images if not _is_old(n, context.get(n, ''))]
    israel = bool(re.search(r'\bIsrael', body.get_text(' ')))

    infobox = {}
    box = body.select_one('table.infobox')
    if box:
        for tr in box.select('tr'):
            th, td = tr.find('th'), tr.find('td')
            if th and td:
                infobox[_text(th)] = _text(td)
        infobox_images = _files(box)
        box.decompose()
    else:
        infobox_images = []

    tables = []
    for t in body.select('table.wikitable'):
        caption = t.find('caption')
        rows = []
        for tr in t.select('tr'):
            cells = tr.find_all(['th', 'td'])
            rows.append({
                'cells': [_text(c) for c in cells],
                'images': _files(tr),
            })
        tables.append({'caption': _text(caption) if caption else '', 'rows': rows})
        t.decompose()

    sections, current = [], {'heading': '(lead)', 'text': []}
    for el in body.find_all(['h2', 'h3', 'p', 'li'], recursive=True):
        if el.name in ('h2', 'h3'):
            if current['text']:
                sections.append(current)
            current = {'heading': _text(el), 'text': []}
        else:
            s = _text(el)
            if s and el.find_parent(['table']) is None:
                current['text'].append(s)
    if current['text']:
        sections.append(current)
    sections = [s for s in sections if s['heading'] not in ('References', 'See also', 'External links')]

    return {
        'infobox': infobox,
        'infobox_images': infobox_images,
        'size_mm': _size(infobox),
        'sections': sections,
        'tables': tables,
        'all_images': all_images,
        'icon_files': icons,
        'image_context': {n: context[n] for n in all_images if n in context},
        'mentions_israel': israel,
    }


OLD = re.compile(r'\b(old|previous)\b', re.I)


def _is_old(name: str, ctx: str) -> bool:
    """Pictures filed under an "Old"/"Previous" section, caption or name are
    skipped. The row text is not checked: it may say "old" about a new plate."""
    if OLD.search(re.sub(r'[_.]', ' ', name)):
        return True
    return any(OLD.search(l) for l in ctx.split('\n')
               if l.startswith(('section:', 'caption:', 'table:', 'title:')))


def image_context(body) -> dict[str, str]:
    """The words around each image: its section heading, caption, and the
    table row and caption it sits in. Old designs are marked there, often
    only by a year range ("2000–2016"), which is why the model reads it."""
    out = {}
    for a in body.select('a[href*="/wiki/File:"]'):
        name = urllib.parse.unquote(a['href'].split('File:', 1)[1])
        if name in out:
            continue
        bits = []
        h = a.find_previous(lambda t: t.name in ('h2', 'h3') and not t.find_parent(id='toc')
                            and _text(t) != 'Contents')
        if h:
            bits.append('section: ' + _text(h))
        cap = (a.find_parent('figure') or a.find_parent(class_='gallerybox')
               or a.find_parent(class_='thumb'))
        if cap:
            c = cap.select_one('figcaption, .gallerytext, .thumbcaption')
            if c and _text(c):
                bits.append('caption: ' + _text(c))
        tr = a.find_parent('tr')
        if tr:
            t = tr.find_parent('table')
            tc = t.find('caption') if t else None
            if tc and _text(tc):
                bits.append('table: ' + _text(tc))
            head = t.find('tr') if t else None
            if head and head is not tr:
                bits.append('columns: ' + ' | '.join(_text(c) for c in head.find_all(['th', 'td'])))
            bits.append('row: ' + ' | '.join(_text(c) for c in tr.find_all(['th', 'td'])))
        if a.get('title') and a['title'] != 'File:' + name:
            bits.append('title: ' + a['title'])
        out[name] = '\n'.join(b[:400] for b in bits)
    return out


def _size(infobox: dict) -> list[float] | None:
    for k, v in infobox.items():
        if k.lower().startswith('size'):
            m = re.search(r'(\d+(?:\.\d+)?)\s*mm\s*[×x]\s*(\d+(?:\.\d+)?)\s*mm', v)
            if m:
                return [float(m.group(1)), float(m.group(2))]
    return None


def resolve_images(names: list[str]) -> dict[str, dict]:
    """One batched imageinfo call (50 titles per request, the API's limit)."""
    out = {}
    for i in range(0, len(names), 50):
        titles = '|'.join('File:' + n for n in names[i:i + 50])
        q = urllib.parse.urlencode({
            'action': 'query', 'format': 'json', 'prop': 'imageinfo',
            'iiprop': 'url|size|mime', 'iiurlwidth': 1600, 'titles': titles,
        })
        data = json.loads(_get(f'{WIKI}/w/api.php?{q}'))
        norm = {n['to']: n['from'] for n in data['query'].get('normalized', [])}
        for page in data['query']['pages'].values():
            info = (page.get('imageinfo') or [{}])[0]
            title = norm.get(page['title'], page['title'])
            out[title.split(':', 1)[1]] = {
                'url': info.get('url'), 'width': info.get('width'),
                'height': info.get('height'), 'mime': info.get('mime'),
                'thumb': info.get('thumburl'),
            }
    return out


def safe_name(name: str) -> str:
    return re.sub(r'[^A-Za-z0-9._-]+', '_', name)


def page_images(html: str) -> dict[str, dict]:
    """The pictures exactly as the article shows them: each <img>'s own URL
    (the largest of its srcset), no per-file lookup or original download."""
    out = {}
    for img in BeautifulSoup(html, 'lxml').select('img'):
        a = img.find_parent('a', href=re.compile(r'/wiki/File:'))
        ref = a['href'] if a else img.get('resource', '')
        if 'File:' not in ref:
            continue
        name = urllib.parse.unquote(ref.split('File:', 1)[1])
        if name in out:
            continue
        url, best = img.get('src'), 1.0
        for part in (img.get('srcset') or '').split(','):
            bits = part.split()
            if len(bits) == 2 and bits[1].endswith('x') and float(bits[1][:-1]) > best:
                url, best = bits[0], float(bits[1][:-1])
        if url and url.startswith('//'):
            url = 'https:' + url
        out[name] = {'url': url, 'width': img.get('data-file-width'), 'height': img.get('data-file-height')}
    return out


def download(names: list[str], out: Path, html: str) -> dict[str, dict]:
    shown = page_images(html)
    meta = {n: shown[n] for n in names if n in shown}
    for n, (name, info) in enumerate(meta.items(), 1):
        progress.step_items(n, len(meta))
        if not info['url']:
            continue
        dest = out / ('orig_' + safe_name(name))
        url = info['url']
        if name.lower().endswith('.svg'):  # the page already shows a PNG render of the drawing
            dest, info['drawing'] = dest.with_suffix('.png'), True
        if name.lower().endswith('.gif'):  # OpenCV cannot read GIF; keep the first frame as PNG
            dest, info['drawing'] = dest.with_suffix('.png'), True
        if not dest.exists():
            try:
                data = _get(url, label=f'[{n}/{len(meta)}] {name[:50]}')
            except urllib.error.HTTPError as e:
                if e.code != 429 or not progress.paste(dest, f'{WIKI}/wiki/File:{urllib.parse.quote(name)}',
                                                       f'429 on {name}: paste the picture'):
                    raise
                progress.image(dest)
                info['file'] = dest.name
                continue
            if name.lower().endswith('.gif'):
                import io
                from PIL import Image
                Image.open(io.BytesIO(data)).convert('RGB').save(dest)
            else:
                dest.write_bytes(data)
            time.sleep(1)
        progress.image(dest)
        info['file'] = dest.name
    return meta


def run(country: str, out: Path) -> dict:
    html = fetch_article(country, out).read_text()
    facts = parse(html)
    facts['country'] = country
    facts['source'] = article_url(country)
    facts['images'] = download(facts['all_images'], out, html)
    (out / 'facts.json').write_text(json.dumps(facts, ensure_ascii=False, indent=1))
    return facts
