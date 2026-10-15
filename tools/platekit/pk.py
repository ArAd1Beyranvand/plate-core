#!/usr/bin/env python3
"""platekit — the offline half of the plate_creator skill.

    pk.py fetch    Laos la              article → .plateref/la/facts.json + originals
    pk.py photos   .plateref/la         find, flatten, measure, colour every photo
    pk.py ask      .plateref/la         local-model layout questions per photo
    pk.py sheet    out.png  a.png b.png contact sheet (one Read for many images)
    pk.py archive  .plateref/la         copy the before data to $PLATEKIT_ARCHIVE (default ~/platekit-archive)
    pk.py icons    .plateref/la         flags/crests on the plates and the page → icons/
    pk.py brief    .plateref/la         facts + photos + icons → brief.md for the LLM
    pk.py scaffold Laos la              package boilerplate + registrations
    pk.py goldens  laos_plate targets.json   render-free check of goldens vs targets
    pk.py calibrate GLYPH MEASURED TARGET
    pk.py test     laos_plate           flutter test, reduced to failures
    pk.py analyze  laos_plate           flutter analyze, one line per issue
    pk.py commits                       dirty repos, innermost first
    pk.py all      Laos la              fetch → photos → ask → brief

    pk.py before   <wikipedia url>      everything before Claude Code (see README)
    pk.py after    <wikipedia url>      everything after it

Run from the workspace root. Nothing here edits Dart beyond the scaffold.
"""
from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path

import cv2

sys.path.insert(0, str(Path(__file__).resolve().parent))
from platekit import archive, brief, fetch, github, gitplan, icons, logfilter, progress, scaffold, vision  # noqa: E402

_imwrite = cv2.imwrite


def _imwrite_shown(path, img, *args):
    """Every picture pk writes goes to the GUI the moment it exists."""
    ok = _imwrite(path, img, *args)
    if ok and not str(path).startswith('/tmp/'):
        progress.image(path)
    return ok


cv2.imwrite = _imwrite_shown

ROOT = Path.cwd()


def _dump(obj) -> None:
    print(json.dumps(obj, ensure_ascii=False, indent=1))


def cmd_fetch(a):
    work = ROOT / '.plateref' / a.code
    f = fetch.run(a.country, work)
    print(f"{work}/facts.json: {len(f['tables'])} tables, {len(f['images'])} images, "
          f"size {f['size_mm']}, israel={f['mentions_israel']}")


def _plate_size(work: Path, override=None) -> tuple[float, float]:
    if override:
        return tuple(override)
    f = json.loads((work / 'facts.json').read_text())
    return tuple(f['size_mm']) if f.get('size_mm') else (520.0, 110.0)


def _used_size(work: Path) -> tuple[float, float]:
    """The plate size the flats were made with (after any infobox fix)."""
    c = work / 'size_conflict.json'
    return tuple(json.loads(c.read_text())['used']) if c.exists() else _plate_size(work)


MIN_ASPECT = 0.8


def cmd_photos(a):
    """Two passes: fit every photo, then flatten all of them to one aspect.

    The infobox size is not trusted on its own — Laos's says 520 × 110 while
    the photographed plates are 340 × 150. When the median fitted aspect
    disagrees with it by more than 25 %, the fitted aspect wins (width kept,
    so units stay roughly millimetres) and the conflict is recorded for the
    brief. A fit whose aspect strays more than 8 % from the median is marked
    for checking: a cut edge or a mount caught in the quad shows up that way.
    """
    work = Path(a.work)
    cw, ch = _plate_size(work, getattr(a, 'size', None))
    photos_path = work / 'photos.json'
    photos = json.loads(photos_path.read_text()) if photos_path.exists() else {}
    facts = json.loads((work / 'facts.json').read_text()) if (work / 'facts.json').exists() else {}
    drawings = {fetch.safe_name(Path(n).stem) for n, i in facts.get('images', {}).items() if i.get('drawing')}
    origs = [p for p in sorted(work.glob('orig_*'))
             if p.suffix.lower() in ('.jpg', '.jpeg', '.png', '.webp')]
    # the user ticks which pictures go on (cars, maps and old designs are
    # left out here) and drags same-layout plates into groups
    was_dropped = {n for n, e in photos.items() if e.get('rejected') == 'unticked'}
    old_groups: dict[int, list[str]] = {}
    for p in origs:
        g = photos.get(p.stem[5:], {}).get('group')
        if g is not None:
            old_groups.setdefault(g, []).append(str(p))
    keep, groups = progress.pick([str(p) for p in origs],
                                 [str(p) for p in origs if p.stem[5:] not in was_dropped],
                                 'Which pictures should continue? Drag plates onto each other to group them',
                                 list(old_groups.values()))
    keep = set(keep)
    group_of = {Path(p).stem[5:]: i for i, g in enumerate(g for g in groups if len(g) > 1) for p in g}
    images = {}
    for p in progress.items(origs, 'fit'):
        name = p.stem[5:]
        entry = photos.setdefault(name, {})
        entry.pop('rejected', None)
        entry.pop('group', None)
        if name in group_of:
            entry['group'] = group_of[name]
        if str(p) not in keep:
            entry['rejected'] = 'unticked'
            (work / f'flat_{name}.png').unlink(missing_ok=True)
            (work / f'corners_{name}.png').unlink(missing_ok=True)
            print(f'{name}: unticked, skipped', flush=True)
            continue
        im = cv2.imread(str(p), cv2.IMREAD_UNCHANGED)
        if im is None:
            continue
        im = vision.on_white(im)
        if name in drawings:
            # already flat: the whole render is the plate
            h, w = im.shape[:2]
            entry['found'] = {'corners': [[0, 0], [w - 1, 0], [w - 1, h - 1], [0, h - 1]],
                              'aspect': w / h, 'confident': True, 'drawing': True}
            images[name] = im
            continue
        try:
            entry['found'] = vision.found_dict(vision.find(im))
        except RuntimeError as e:
            entry['found'] = {'confident': False, 'error': str(e)}
        if 'error' in entry['found']:
            print(f"{name}: {entry['found']['error']}")
        else:
            images[name] = im

    # no plate is taller than wide by much: narrower fits are crops such as
    # Italy's EU band strip (0.45), which once overrode the infobox size
    aspects = sorted(photos[n]['found']['aspect'] for n in images
                     if photos[n]['found']['confident'] and photos[n]['found']['aspect'] >= MIN_ASPECT)
    drawn = sorted(photos[n]['found']['aspect'] for n in drawings & set(images)
                   if photos[n]['found']['aspect'] >= MIN_ASPECT)
    if drawn:  # a drawing's aspect is the designed one
        aspects = drawn
    if aspects:
        median = aspects[len(aspects) // 2]
        if not getattr(a, 'size', None) and abs(median - cw / ch) / median > 0.25:
            print(f'infobox size {cw:g} x {ch:g} (aspect {cw / ch:.2f}) disagrees with the photos '
                  f'(median aspect {median:.2f}); flattening to {cw:g} x {cw / median:.0f}')
            (work / 'size_conflict.json').write_text(json.dumps(
                {'infobox': [cw, ch], 'photo_aspect': median, 'used': [cw, round(cw / median)]}))
            ch = round(cw / median)
        for n in images:
            f = photos[n]['found']
            if f['confident'] and abs(f['aspect'] - median) / median > 0.08:
                f['confident'] = False
                f['why'] = f'aspect {f["aspect"]:.2f} vs median {median:.2f}'

    for n, (name, im) in enumerate(progress.items(images.items(), 'flatten'), 1):
        print(f'[{n}/{len(images)}] {name}', flush=True)
        entry = photos[name]
        found = entry['found']
        flat = vision.flatten(im, found['corners'], cw, cw / ch)
        cv2.imwrite(str(work / f'flat_{name}.png'), flat)
        entry['measure'] = vision.measure(flat, cw, ch)
        entry['colours'] = vision.colours(flat)
        entry['zones'] = vision.zones(flat, cw, ch)
        entry['dividers'] = vision.dividers(flat, cw, ch, entry['measure']['rows'])
        entry['ocr'] = vision.ocr_rows(flat, entry['measure']['rows'], cw, ch)
        if not found['confident']:
            vision.corner_sheet(im, found['corners'], work / f'corners_{name}.png')
        print(f"{name}: {'ok' if found['confident'] else 'CHECK ' + found.get('why', '')} "
              f"aspect {found['aspect']:.2f} field {entry['colours']['field']} "
              f"ink {entry['colours']['ink']} rows {len(entry['measure']['rows'])} "
              f"zones {len(entry['zones'])} dividers {len(entry['dividers'])} "
              f"ocr {[o['text'] for o in entry['ocr']]}")
    photos_path.write_text(json.dumps(photos, ensure_ascii=False, indent=1))
    flats = sorted(work.glob('flat_*.png'))
    if flats:
        vision.contact_sheet(flats, work / 'sheet_flat.png', cell=(540, int(540 * ch / cw)))
        print(f'{work}/sheet_flat.png')


def _small_zone(z: dict, pw: float, ph: float) -> bool:
    """Sticker-sized: under a third of the plate height and 2% of its area."""
    w, h = z['x'][1] - z['x'][0], z['y'][1] - z['y'][0]
    return h < ph / 3 and w * h < 0.02 * pw * ph


def cmd_ask(a):
    from platekit import local_llm
    if not local_llm.available():
        print('ollama is not running; skipped')
        return
    work = Path(a.work)
    photos_path = work / 'photos.json'
    photos = json.loads(photos_path.read_text())
    # photos of one design in different colours get the whole-plate
    # questions once; the rest copy the answers from the first of their group
    asked: list[tuple] = []   # (signature, name)
    for n, (name, entry) in enumerate(progress.items(photos.items(), 'ask'), 1):
        img = work / f'flat_{name}.png'
        if not img.exists():
            continue
        flat = cv2.imread(str(img))
        sig = vision.layout_signature(flat)
        # a group the user made is asked once: its first answered member is the
        # twin of the rest; otherwise a twin is a photo with the same layout
        grouped = entry.get('group') is not None
        twin = next((t for t, e in photos.items() if t != name and grouped and e.get('group') == entry['group']
                     and 'ask' in e), None) if grouped else None
        twin = twin or next((t for s, t in asked if float(s @ sig) >= vision.SAME_LAYOUT), None)
        user_twin = bool(twin) and grouped and photos[twin].get('group') == entry['group']
        if 'ask' in entry and not a.again:
            asked.append((sig, name))
            continue
        if twin and 'ask' in photos[twin]:
            why = 'in a group with' if user_twin else 'same layout as'
            print(f'[{n}/{len(photos)}] {name}: {why} {twin}, reusing its answers', flush=True)
            entry['ask'] = {**photos[twin]['ask'], 'from': twin}
        else:
            print(f'[{n}/{len(photos)}] asking about {name}', flush=True)
            entry['ask'] = local_llm.ask_named('layout', [img])
            entry['ask'].update(local_llm.ask_named('structure', [img]))
            asked.append((sig, name))
        print(name, entry['ask'], flush=True)
        # each pixel-found zone, cropped with a margin, labelled by the model;
        # a zone at the same place on the twin plate keeps the twin's label
        H, W = flat.shape[:2]
        pw, ph = _used_size(work)
        sx, sy = W / pw, H / ph
        for i, z in enumerate(entry.get('zones', [])):
            same = twin and next((t for t in photos[twin].get('zones', []) if 'kind' in t
                                  and abs(t['x'][0] - z['x'][0]) < 4 and abs(t['y'][0] - z['y'][0]) < 4
                                  and abs(t['x'][1] - z['x'][1]) < 4 and abs(t['y'][1] - z['y'][1]) < 4), None)
            if not same and user_twin:
                # same structure, other photo: the twin's zone nearest this one
                labelled = [t for t in photos[twin].get('zones', []) if 'kind' in t]
                same = min(labelled, default=None, key=lambda t: abs(sum(t['x']) - sum(z['x']))
                           + abs(sum(t['y']) - sum(z['y'])))
            if same:
                z.update(kind=same['kind'], has_text=same.get('has_text'))
                print(f'  zone {i} {z["colour"]}: {z["kind"]} (from {twin})', flush=True)
                continue
            x0, x1 = int(z['x'][0] * sx), int(z['x'][1] * sx)
            y0, y1 = int(z['y'][0] * sy), int(z['y'][1] * sy)
            m = max(6, (x1 - x0) // 2, (y1 - y0) // 2)  # small zones need context
            crop = flat[max(0, y0 - m):y1 + m, max(0, x0 - m):x1 + m]
            if crop.size == 0:
                continue
            if max(crop.shape[:2]) < 256:  # tiny crops are unreadable to the model
                k = 256 / max(crop.shape[:2])
                crop = cv2.resize(crop, None, fx=k, fy=k, interpolation=cv2.INTER_CUBIC)
            path = work / f'zone_{name}_{i}.png'
            cv2.imwrite(str(path), crop)
            z.update(local_llm.ask_named('zone', [path]))
            if z.get('kind') == 'sticker' and not _small_zone(z, pw, ph):
                # a full-height badge is never a sticker: the small model
                # guessed, so the big one decides
                z.update(local_llm.ask_named('zone', [path], model=local_llm.model_for('layout')))
            print(f'  zone {i} {z["colour"]}: {z.get("kind")}', flush=True)
        # the whole-plate view is too coarse for a sticker; a zone found by
        # pixels and named a sticker is the stronger evidence
        if any(z.get('kind') == 'sticker' and _small_zone(z, pw, ph) for z in entry.get('zones', [])):
            entry['ask']['sticker'] = True
        # saved per photo: a killed run keeps what it already paid for
        photos_path.write_text(json.dumps(photos, ensure_ascii=False, indent=1))


def cmd_sheet(a):
    vision.contact_sheet([Path(p) for p in a.images], Path(a.out), crop_content=a.crop)
    print(a.out)


def cmd_archive(a):
    print(archive.save(Path(a.work)))


def cmd_icons(a):
    found = icons.collect(Path(a.work))
    print(f"{len(found)} icons in {Path(a.work) / 'icons'}")


def cmd_brief(a):
    if (Path(a.work) / 'facts.json').exists():
        cmd_icons(a)
    out = brief.write(Path(a.work))
    print(f'{out} ({out.stat().st_size} bytes)')


def cmd_scaffold(a):
    cats = scaffold.load_categories(Path(a.categories)) if a.categories else None
    written = scaffold.package(ROOT, a.country, a.code, epithet=a.epithet, summary=a.summary,
                               categories=cats, fonts=a.font or None, force=a.force)
    written += scaffold.register(ROOT, a.country, a.code) if a.register else []
    print('\n'.join(written) or 'nothing new')


def cmd_goldens(a):
    """targets.json: {"<golden stem>": [{"name", "y": [..], "x": [..], "tol"}]}
    in plate units; the plate size comes from --size."""
    cw, ch = a.size
    targets = json.loads(Path(a.targets).read_text())
    gold = ROOT / a.package / 'test' / 'goldens'
    bad = 0
    for stem, rows in targets.items():
        im = cv2.imread(str(gold / f'{stem}.png'))
        if im is None:
            print(f'{stem}: no golden')
            bad += 1
            continue
        plate = vision.crop_to_content(im)
        got = vision.measure(plate, cw, ch)
        for r in vision.compare(rows, got['rows']):
            if r['verdict'] != 'OK' or a.verbose:
                bad += r['verdict'] != 'OK'
                print(f"{stem} {r['name']}: {r['verdict']} " + json.dumps(
                    {k: v for k, v in r.items() if k not in ('name', 'verdict')}))
    print(f'{bad} off' if bad else 'all rows within tolerance')
    sys.exit(1 if bad else 0)


def cmd_calibrate(a):
    print(vision.calibrate(a.glyph, a.measured, a.target))


def cmd_test(a):
    log = logfilter.run(['flutter', 'test', *a.args], ROOT / a.package)
    print(logfilter.render(logfilter.tests(log)))


def cmd_analyze(a):
    log = logfilter.run(['flutter', 'analyze'], ROOT / a.package)
    issues = logfilter.analyze(log)
    print('\n'.join(issues) or 'No issues found')


def cmd_commits(a):
    print(gitplan.render(gitplan.plan(ROOT)))


def cmd_all(a):
    a.work = str(ROOT / '.plateref' / a.code)
    cmd_fetch(a)
    cmd_photos(a)
    if not a.no_ask:
        a.again = False
        cmd_ask(a)
    cmd_brief(a)


def _resolve(a) -> tuple[str, str, str]:
    """country, code, package for a `before`/`after` url."""
    country = fetch.country_from_url(a.url)
    code = a.code or _saved_code(country) or fetch.iso2(country) or scaffold.snake(country)[:2]
    return country, code, f'{scaffold.snake(country)}_plate'


def _saved_code(country: str) -> str | None:
    for f in (ROOT / '.plateref').glob('*/facts.json'):
        if json.loads(f.read_text()).get('country') == country:
            return f.parent.name
    return None


def _step(title: str) -> None:
    print(f'\n== {title}', flush=True)
    progress.done()
    m = re.match(r'(\d+)/(\d+)\s*(.*)', title)
    if m:
        progress.step(int(m.group(1)), int(m.group(2)), m.group(3))


def cmd_before(a):
    """fetch → photos → ask → brief → package skeleton → workspace member
    → the prompt to paste into Claude Code."""
    from platekit import local_llm
    country, code, pkg = _resolve(a)
    work = ROOT / '.plateref' / code
    a.country, a.code, a.work, a.again = country, code, str(work), False
    print(f'{country} · code {code} · package {pkg} · work {work.relative_to(ROOT)}')

    _step('1/6 fetch the article and photos')
    cmd_fetch(a)
    _step('2/6 fit, flatten, measure the photos')
    cmd_photos(a)
    _step('3/6 local model')
    if a.no_ask:
        print('skipped (--no-ask)')
    elif not local_llm.available():
        print('ollama is not running; skipped (start it and run: pk.py ask ' + str(work.relative_to(ROOT)) + ')')
    else:
        cmd_ask(a)
    _step('4/6 brief')
    cmd_brief(a)
    _step(f'5/6 package skeleton {pkg}/')
    written = scaffold.package(ROOT, country, code, epithet=a.epithet,
                               summary=a.summary, fonts=a.font or None)
    print('\n'.join(written) or 'already there, nothing overwritten')
    _step('6/6 workspace member + pub get')
    if scaffold._register(ROOT / 'pubspec.yaml', r'  - \w+_plate$', f'  - {pkg}'):
        print(f'pubspec.yaml: added {pkg}')
    print(logfilter.run(['flutter', 'pub', 'get'], ROOT).strip().splitlines()[-1])
    if a.github:
        _step('github repo')
        why = github.ready()
        print(why or github.create(ROOT / pkg, public=a.public))

    prompt = (f'/plate_creator {a.url}\n\n'
              f'The offline stage already ran (tools/platekit). Read '
              f'.plateref/{code}/brief.md and .plateref/{code}/sheet_flat.png first, '
              f'instead of the article and the photos; open other images only where '
              f'the brief says CHECK. The package skeleton {pkg}/ exists. Model every '
              f'field (a run printed and typed as a unit) as one PlateSlot with '
              f'length/minLength, as the /numbmig rules and "Fields, not cells" in '
              f'the brief say — not one cell per character. Follow '
              f'"What is left for you" at the end of the brief and stop there; '
              f'registration, goldens, tests and the commit plan are done afterwards '
              f'by `pk.py after`.')
    (work / 'claude_prompt.txt').write_text(prompt + '\n')
    if not a.no_archive:
        print(f'archived to {archive.save(work)}')
    print(f'\nDone. Now start Claude Code in {ROOT} and paste '
          f'.plateref/{code}/claude_prompt.txt:\n\n{prompt}\n')


def _per_character_samples(pkg: Path, gallery: Path) -> list[str]:
    """Sample values typed one character per slot (`'A B 1 2 3 4'`,
    `['1', '2', '3']`): the sign of a field split into cells. Each field is
    one PlateSlot, so its sample is one token."""
    found = []
    for f in (pkg / 'test' / 'golden_test.dart', gallery):
        if not f.exists():
            continue
        for n, line in enumerate(f.read_text().splitlines(), 1):
            if (re.search(r"'(?:\S ){3,}\S'", line)
                    or re.search(r"(?:'[^'\s]',\s*){4,}", line)):
                found.append(f'{f.relative_to(ROOT)}:{n}: one character per slot — '
                             f'make each field one PlateSlot (length/minLength) and its sample one token')
    return found


def cmd_after(a):
    """gallery registration → pub get → format → goldens → analyze + test
    (package, gallery) → commit plan. Exit 1 with a short report if
    anything fails; the report is written for pasting back into Claude."""
    country, code, pkg = _resolve(a)
    work = ROOT / '.plateref' / code
    s = scaffold.snake(country)
    holder = ROOT / 'plate_number_holder'
    report: list[str] = []
    print(f'{country} · code {code} · package {pkg}')
    if not (ROOT / pkg / 'lib').exists():
        sys.exit(f'{pkg}/ does not exist — run `pk.py before {a.url}` first')

    _step('1/6 gallery registration')
    if (holder / 'lib/screens/gallery/sources' / f'{s}.dart').exists():
        print('\n'.join(scaffold.register(ROOT, country, code)) or 'already registered')
    else:
        report.append(f'gallery source plate_number_holder/lib/screens/gallery/sources/{s}.dart is missing')
        print(report[-1])
    _step('2/6 pub get + format')
    print(logfilter.run(['flutter', 'pub', 'get'], ROOT).strip().splitlines()[-1])
    logfilter.run(['dart', 'format', 'lib', 'test'], ROOT / pkg)

    report += _per_character_samples(ROOT / pkg, holder / 'lib/screens/gallery/sources' / f'{s}.dart')
    _step('3/6 analyze')
    for d in (pkg, 'plate_number_holder'):
        issues = [i for i in logfilter.analyze(logfilter.run(['flutter', 'analyze'], ROOT / d))
                  if not i.startswith('info') or d == pkg]
        print(f'{d}: ' + (f'{len(issues)} issues' if issues else 'clean'))
        report += [f'{d}: {i}' for i in issues]

    _step('4/6 goldens')
    gold = ROOT / pkg / 'test' / 'goldens'
    if (ROOT / pkg / 'test' / 'golden_test.dart').exists():
        log = logfilter.run(['flutter', 'test', '--update-goldens', 'test/golden_test.dart'], ROOT / pkg)
        t = logfilter.tests(log)
        pngs = sorted(gold.glob('*.png'))
        print(f'{len(pngs)} goldens written')
        if t['failures']:
            report.append(f'{pkg} goldens: ' + logfilter.render(t))
        if pngs:
            vision.contact_sheet(pngs, work / 'goldens_sheet.png', crop_content=True)
            print(f'compare {work.relative_to(ROOT)}/goldens_sheet.png with sheet_flat.png')

    _step('5/6 tests')
    t = logfilter.tests(logfilter.run(['flutter', 'test'], ROOT / pkg))
    print(f'{pkg}: ' + logfilter.render(t).splitlines()[0])
    if t['failures']:
        report.append(f'{pkg}: ' + logfilter.render(t))
    gtest = holder / 'test' / f'{s}_gallery_render_test.dart'
    if gtest.exists():
        args = [str(gtest.relative_to(holder))]
        if a.full:
            args = []
        t = logfilter.tests(logfilter.run(['flutter', 'test', *args], holder))
        print('plate_number_holder: ' + logfilter.render(t).splitlines()[0])
        if t['failures']:
            report.append('plate_number_holder: ' + logfilter.render(t))

    if a.push and not report:
        _step('push to github')
        why = github.ready()
        try:
            print(why or github.push(ROOT / pkg, a.message or f'{country} licence plates'))
        except RuntimeError as e:
            report.append(f'push failed: {e}')
    elif a.push:
        print('\nnot pushed: checks failed')

    _step('6/6 commit plan')
    print(gitplan.render(gitplan.plan(ROOT)))

    out = work / 'after_report.md'
    if report:
        out.write_text('`pk.py after` found these; fix them and stop:\n\n' + '\n'.join(report) + '\n')
        print(f'\nFAILED — {len(report)} problem(s). Paste {out.relative_to(ROOT)} into Claude Code, '
              f'then run `pk.py after` again.')
        sys.exit(1)
    out.unlink(missing_ok=True)
    print('\nAll checks pass. Look at the goldens sheet, then commit in the order above.')


def main():
    p = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    sub = p.add_subparsers(dest='cmd', required=True)

    s = sub.add_parser('fetch'); s.add_argument('country'); s.add_argument('code'); s.set_defaults(f=cmd_fetch)
    s = sub.add_parser('photos'); s.add_argument('work')
    s.add_argument('--size', nargs=2, type=float, help='plate width height, overrides the infobox')
    s.set_defaults(f=cmd_photos)
    s = sub.add_parser('ask'); s.add_argument('work')
    s.add_argument('--again', action='store_true', help='re-ask photos already answered')
    s.set_defaults(f=cmd_ask)
    s = sub.add_parser('sheet'); s.add_argument('out'); s.add_argument('images', nargs='+')
    s.add_argument('--crop', action='store_true'); s.set_defaults(f=cmd_sheet)
    s = sub.add_parser('archive'); s.add_argument('work'); s.set_defaults(f=cmd_archive)
    s = sub.add_parser('icons'); s.add_argument('work'); s.set_defaults(f=cmd_icons)
    s = sub.add_parser('brief'); s.add_argument('work'); s.set_defaults(f=cmd_brief)
    s = sub.add_parser('scaffold'); s.add_argument('country'); s.add_argument('code')
    s.add_argument('--epithet', default=''); s.add_argument('--summary', default='')
    s.add_argument('--categories', help='json list of {id, getter, theme, value}')
    s.add_argument('--font', action='append', help='font file for the golden test (repeatable)')
    s.add_argument('--register', action='store_true', help='also edit workspace + gallery')
    s.add_argument('--force', action='store_true'); s.set_defaults(f=cmd_scaffold)
    s = sub.add_parser('goldens'); s.add_argument('package'); s.add_argument('targets')
    s.add_argument('--size', nargs=2, type=float, default=(520, 110))
    s.add_argument('-v', '--verbose', action='store_true'); s.set_defaults(f=cmd_goldens)
    s = sub.add_parser('calibrate'); s.add_argument('glyph', type=float)
    s.add_argument('measured', type=float); s.add_argument('target', type=float); s.set_defaults(f=cmd_calibrate)
    s = sub.add_parser('test'); s.add_argument('package'); s.add_argument('args', nargs='*'); s.set_defaults(f=cmd_test)
    s = sub.add_parser('analyze'); s.add_argument('package'); s.set_defaults(f=cmd_analyze)
    s = sub.add_parser('commits'); s.set_defaults(f=cmd_commits)
    s = sub.add_parser('before', help='everything before Claude Code')
    s.add_argument('url'); s.add_argument('--code', help='two-letter code (default: Wikidata ISO code)')
    s.add_argument('--size', nargs=2, type=float, help='plate width height, overrides the infobox')
    s.add_argument('--no-ask', action='store_true', help='skip the local model')
    s.add_argument('--no-archive', action='store_true', help='do not copy the before data to the archive')
    s.add_argument('--epithet', default='', help='README: "the <epithet> people of …"')
    s.add_argument('--summary', default='', help='one sentence for README, pubspec, library doc')
    s.add_argument('--font', action='append', help='extra font for the goldens (repeatable)')
    s.add_argument('--github', action='store_true', help='create a GitHub repo named after the package')
    s.add_argument('--public', action='store_true', help='with --github: public instead of private')
    s.set_defaults(f=cmd_before)
    s = sub.add_parser('after', help='everything after Claude Code')
    s.add_argument('url'); s.add_argument('--code')
    s.add_argument('--full', action='store_true', help='run the whole gallery test suite')
    s.add_argument('--push', action='store_true', help='commit the package and push it when all checks pass')
    s.add_argument('--message', help='commit message for --push')
    s.set_defaults(f=cmd_after)
    s = sub.add_parser('all'); s.add_argument('country'); s.add_argument('code')
    s.add_argument('--no-ask', action='store_true'); s.set_defaults(f=cmd_all)

    a = p.parse_args()
    a.f(a)


if __name__ == '__main__':
    main()
