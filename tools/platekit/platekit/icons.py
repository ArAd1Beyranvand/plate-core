"""Stage 3b: the icons a plate carries — flags, crests, emblems.

Two sources, both kept in `<work>/icons/` with a manifest `icons.json`:

* **on the plate** — every zone the local model named `emblem` or `flag`,
  cropped from the flattened photo, with its box in plate units;
* **on the page** — the flag, coat-of-arms and emblem SVGs the article
  shows, which fetch drops as plate images. Downloaded as the original SVG:
  they are often the very drawing the plate prints.

The brief lists them with a prompt (`prompts/icons.md`) that has Claude find
the vector for each on-plate icon, save it in the package and place it.
"""
from __future__ import annotations

import json
import shutil
import time
import urllib.parse
from pathlib import Path

from bs4 import BeautifulSoup

from platekit import fetch

ON_PLATE = ('emblem', 'flag')


def _page_icons(work: Path, facts: dict) -> list[str]:
    names = facts.get('icon_files')
    if names is None and (work / 'art.html').exists():  # facts from before icon_files
        soup = BeautifulSoup((work / 'art.html').read_text(), 'lxml')
        body = soup.select_one('#mw-content-text .mw-parser-output')
        for junk in body.select('.navbox, .metadata, .ambox, .asbox, .sistersitebox, .side-box'):
            junk.decompose()
        names = fetch.icon_files(body)
    return names or []


def commons_search(words: str) -> str:
    return 'https://commons.wikimedia.org/w/index.php?' + urllib.parse.urlencode(
        {'search': words + ' filetype:svg', 'ns6': 1})


def collect(work: Path) -> list[dict]:
    facts = json.loads((work / 'facts.json').read_text())
    photos = json.loads((work / 'photos.json').read_text()) if (work / 'photos.json').exists() else {}
    out_dir = work / 'icons'
    out_dir.mkdir(exist_ok=True)
    country = facts.get('country', '')
    icons: list[dict] = []

    for name, p in photos.items():
        if p.get('rejected'):
            continue
        for i, z in enumerate(p.get('zones', [])):
            if z.get('kind') not in ON_PLATE:
                continue
            crop = work / f'zone_{name}_{i}.png'
            entry = {'id': f'{name}_{i}', 'where': 'plate', 'photo': name, 'kind': z['kind'],
                     'box': {'x': z['x'], 'y': z['y']}, 'colour': z.get('colour'),
                     'search': commons_search(f'{country} {z["kind"]}')}
            if crop.exists():
                dest = out_dir / f'plate_{name}_{i}.png'
                shutil.copyfile(crop, dest)
                entry['crop'] = str(dest.relative_to(work.parent.parent))
            icons.append(entry)

    page = _page_icons(work, facts)
    meta = fetch.resolve_images(page) if page else {}
    for n in page:
        info = meta.get(n, {})
        dest = out_dir / ('page_' + fetch.safe_name(n))
        if info.get('url') and not dest.exists():
            try:
                dest.write_bytes(fetch._get(info['url'], label=n[:50]))
                time.sleep(1)
            except Exception as e:  # one missing icon must not stop the brief
                print(f'icon {n}: {e}', flush=True)
        icons.append({'id': Path(n).stem, 'where': 'page', 'file': n, 'url': info.get('url'),
                      'svg': str(dest.relative_to(work.parent.parent)) if dest.exists() else None,
                      'context': facts.get('image_context', {}).get(n, '')})

    (out_dir / 'icons.json').write_text(json.dumps(icons, ensure_ascii=False, indent=1))
    return icons


def section(work: Path) -> str:
    path = work / 'icons' / 'icons.json'
    if not path.exists():
        return ''
    icons = json.loads(path.read_text())
    if not icons:
        return ''
    lines = ['## Icons', '']
    plate = [i for i in icons if i['where'] == 'plate']
    page = [i for i in icons if i['where'] == 'page']
    if plate:
        lines += ['On the plates (crop, box in plate units):', '']
        for i in plate:
            b = i['box']
            lines.append(f"- `{i['id']}` {i['kind']} on {i['photo']}: x {b['x'][0]:g}–{b['x'][1]:g} "
                         f"y {b['y'][0]:g}–{b['y'][1]:g}, colour {i.get('colour')}; crop `{i.get('crop', '-')}`")
    if page:
        lines += ['', 'On the page (original SVGs, already downloaded):', '']
        for i in page:
            lines.append(f"- `{i['svg'] or i['file']}` ← {i['url']}")
    return '\n'.join(lines)
