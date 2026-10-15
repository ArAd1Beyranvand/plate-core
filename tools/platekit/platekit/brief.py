"""Stage 4: the hand-off — what the LLM reads instead of the raw material.

Everything stages 1–3 found goes into one markdown file of a few
kilobytes: the infobox, the category table, per photo the fit, the
measured rows and the balanced colours, the local model's answers, and
which of those need a human (or LLM) look. The LLM then opens only the
contact sheet and the images flagged there.
"""
from __future__ import annotations

import json
from pathlib import Path

from . import icons as icon_stage
from .fetch import safe_name
from .scaffold import snake

PROMPTS = Path(__file__).resolve().parent.parent / 'prompts'
TEMPLATE = PROMPTS / 'llm_brief.md'


def _table(t: dict, limit: int = 40) -> str:
    rows = [r for r in t['rows'] if any(r['cells'])][:limit]
    if not rows:
        return ''
    out = []
    for r in rows:
        cells = ' | '.join(c[:80] for c in r['cells'])
        imgs = f"  ← {', '.join(r['images'])}" if r['images'] else ''
        out.append(f'| {cells} |{imgs}')
    return '\n'.join(out)


def facts_section(facts: dict) -> str:
    lines = [f"# {facts['country']}", '', f"Source: {facts['source']}", '']
    if facts.get('size_mm'):
        lines.append(f"Size: {facts['size_mm'][0]:g} × {facts['size_mm'][1]:g} mm")
    lines.append(f"Israel mentioned: {'YES — read those lines' if facts['mentions_israel'] else 'no'}")
    lines += ['', '## Infobox', '']
    lines += [f'- {k}: {v[:200]}' for k, v in facts['infobox'].items()]
    for i, t in enumerate(facts['tables']):
        body = _table(t)
        if body:
            lines += ['', f"## Table {i + 1} {t['caption']}".rstrip(), '', body]
    lines += ['', '## Prose', '']
    for s in facts['sections']:
        text = ' '.join(s['text'])
        lines.append(f"- **{s['heading']}**: {text[:600]}{'…' if len(text) > 600 else ''}")
    return '\n'.join(lines)


def _captions(facts: dict) -> dict[str, str]:
    """safe photo stem -> the caption (or table row) the article puts on it."""
    out = {}
    for n, c in facts.get('image_context', {}).items():
        bits = dict(line.split(': ', 1) for line in c.splitlines() if ': ' in line)
        out[safe_name(Path(n).stem)] = bits.get('caption') or bits.get('row') or ''
    return out


def categories_section(facts: dict, photos: dict) -> str:
    """Every captioned picture, with what happened to it. A caption is the
    article naming a category; one that ends up nowhere is a category
    silently lost, so it is listed whatever its fit."""
    caps = _captions(facts)
    if not caps:
        return ''
    lines = ['## Pictures and their captions', '',
             'Each caption naming a current plate is a category to implement; '
             'say explicitly why any is not.', '']
    for name, cap in caps.items():
        p = photos.get(name, {})
        if p.get('rejected'):
            state = f"SKIPPED ({p['rejected']})"
        elif not p.get('measure'):
            state = 'NOT MEASURED — open orig_' + name
        elif not p.get('found', {}).get('confident'):
            state = 'CHECK'
        else:
            state = 'measured'
        lines.append(f'- {name}: "{cap}" — {state}')
    return '\n'.join(lines)


def _fields(row: dict) -> str:
    """`2@40–75 | 1@90–110 | 3@125–200`: one entry per field, i.e. per PlateSlot."""
    fs = row.get('fields') or [{'x': row['x'], 'glyphs': len(row['runs'])}]
    return ' · '.join(f"{f['glyphs']}@{f['x'][0]:g}–{f['x'][1]:g}" for f in fs)


def photo_section(photos: dict) -> str:
    """photos: name -> {found, measure, colours, ask} as the CLI saves them."""
    lines = ['## Photos', '', '| photo | fit | aspect | field | ink | rows (y: x-span, fields as glyphs@x) | local model |',
             '|---|---|---|---|---|---|---|']
    flagged = []
    for name, p in photos.items():
        if p.get('rejected'):
            continue
        f = p.get('found', {})
        fit = 'ok' if f.get('confident') else 'CHECK'
        if not f.get('confident'):
            flagged.append(name)
        m, c = p.get('measure', {}), p.get('colours', {})
        rows = '; '.join(f"{r['y'][0]:g}–{r['y'][1]:g}: {r['x'][0]:g}–{r['x'][1]:g}, {_fields(r)}"
                         for r in m.get('rows', []))
        ask = dict(p.get('ask', {}))
        kinds, lens = ask.pop('fields', []), ask.pop('field_lengths', [])
        a = ', '.join(f'{k}={v}' for k, v in ask.items() if v != 'unknown')
        if kinds:
            a += ', fields=' + ' · '.join(f'{n} {k}' for k, n in zip(kinds, lens + ['?'] * len(kinds)))
        lines.append(f"| {name} | {fit} | {f.get('aspect', 0):.2f} | "
                     f"{c.get('field', '?')} | {c.get('ink', '?')} | {rows} | {a} |")
    lines += ['', '### Structure per photo (plate units)', '']
    for name, p in photos.items():
        z = '; '.join(f"{q.get('kind', 'zone')} {q['colour']} x {q['x'][0]:g}–{q['x'][1]:g} y {q['y'][0]:g}–{q['y'][1]:g}"
                      for q in p.get('zones', [])) or 'none'
        d = '; '.join(f"{q['axis']} at {q['at']:g}" for q in p.get('dividers', [])) or 'none'
        o = ' / '.join(f"{q['text']!r}" for q in p.get('ocr', []))
        lang = p['ocr'][0]['lang'] if p.get('ocr') else '-'
        lines.append(f'- {name}: zones {z}; dividers {d}; ocr ({lang}, unreliable for non-Latin) {o}')
    if flagged:
        lines += ['', 'Look at these yourself (corner sheets in `corners_<photo>.png`): '
                  + ', '.join(flagged)]
    return '\n'.join(lines)


def write(work: Path) -> Path:
    facts = json.loads((work / 'facts.json').read_text())
    photos = json.loads((work / 'photos.json').read_text()) if (work / 'photos.json').exists() else {}
    parts = [facts_section(facts)]
    cats = categories_section(facts, photos)
    if cats:
        parts.append(cats)
    if photos:
        parts.append(photo_section(photos))
    pkg = snake(facts['country']) + '_plate'
    icons = icon_stage.section(work)
    if icons:
        parts.append(icons + '\n\n' + (PROMPTS / 'icons.md').read_text().replace('{package}', pkg))
    parts.append(TEMPLATE.read_text().replace('{country}', snake(facts['country'])))
    out = work / 'brief.md'
    out.write_text('\n\n'.join(parts) + '\n')
    return out
