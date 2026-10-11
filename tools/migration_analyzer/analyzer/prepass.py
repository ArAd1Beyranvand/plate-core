"""Deterministic pre-analysis of out/specs/*.json -> out/prepass/*.json.

No model involved: these are the facts the LLM step may comment on but never
overrides.

  TYPE 1  per spec: segments split at hard boundaries (line, divider,
          painted item between, alphabet/ink change) and, inside them, soft
          boundaries (padding, pitch, width, group change) with a default
          merge/split for the model to confirm or overturn.
  TYPE 2  specs whose structure signature (everything except per-register
          cell counts) is identical, i.e. one plate with variable-length
          registers; plus near-miss pairs differing in one attribute.

Usage: python3 analyzer/prepass.py [country ...]
"""

import json
import re
import sys
from itertools import combinations
from pathlib import Path

TOOL = Path(__file__).resolve().parent.parent
SPECS = TOOL / 'out' / 'specs'
OUT = TOOL / 'out' / 'prepass'

PITCH_TOLERANCE = 0.5
# Gaps within this many plate units count as touching (not padding).
GAP_TOLERANCE = 0.5
MOTO_RE = re.compile(r'moto|motorcycle|bike|scooter|two.?wheel', re.I)


# ---------------------------------------------------------------- helpers

def overlaps(a0, a1, b0, b1):
    return min(a1, b1) - max(a0, b0) > 0.01


def right(box):
    return box[0] + box[2]


def bottom(box):
    return box[1] + box[3]


def rule_boxes(spec):
    rules = spec['rules']
    if isinstance(rules, list):
        return rules
    # A stipple summary: treat its whole extent as one painted strip; good
    # enough to tell whether it sits between two cells of a row.
    return []


def divider_xs(section, x0, x1, y0, y1, out):
    """Absolute x of every vertical PlatePart divider (columns split)."""
    if not section or 'parts' not in section:
        return out
    across = section['axis'] == 'columns'
    prev = x0 if across else y0
    for part in section['parts']:
        end = part['end'] if part['end'] is not None else (x1 if across else y1)
        if across and part['end'] is not None and part['divider'] > 0:
            out.append((part['end'], y0, y1))
        if across:
            divider_xs(part['section'], prev, end, y0, y1, out)
        else:
            divider_xs(part['section'], x0, x1, prev, end, out)
        prev = end
    return out


def vehicle_kind(spec):
    """From the id only; geometry says nothing reliable about the vehicle."""
    return 'moto' if MOTO_RE.search(spec['id']) else 'unspecified'


def aspect_class(a):
    return 'square' if a < 1.4 else 'medium' if a < 2.6 else 'wide' if a < 4 else 'long'


def sample_char(spec, slot, n):
    alpha = spec['alphabets'][slot['alphabet']]
    chars = alpha['glyphSample'] or alpha['sample'] or '?'
    return chars[(n + 1) % len(chars)] if alpha['numeric'] else chars[0]


# ---------------------------------------------------------------- TYPE 1

def blockers_between(spec, a, b):
    """Reasons two horizontally adjacent cells a, b must not merge."""
    reasons = []
    left, rgt = (a, b) if a['box'][0] <= b['box'][0] else (b, a)
    gx0, gx1 = right(left['box']), rgt['box'][0]
    y0, y1 = left['box'][1], bottom(left['box'])

    def between(box):
        cx = box[0] + box[2] / 2
        return gx0 - 0.01 <= cx <= gx1 + 0.01 and overlaps(box[1], bottom(box), y0, y1)

    for kind in ('labels', 'decals', 'bands'):
        for item in spec[kind]:
            if between(item['box']):
                what = item.get('text') or item.get('image') or 'band'
                reasons.append(f'{kind[:-1]} "{what}" between cells')
    for r in rule_boxes(spec):
        if between(r):
            reasons.append('rule between cells')
    for x, dy0, dy1 in divider_xs(spec['background'], 0, spec['canvas'][0], 0, spec['canvas'][1], []):
        if gx0 - 0.01 <= x <= gx1 + 0.01 and overlaps(dy0, dy1, y0, y1):
            reasons.append('background divider between cells')
    return reasons


HARD_NOTE = ('never merged: different line, divider, label/decal/band/rule between, '
             'alphabet or ink change, broken index order')


def boundary(spec, prev, cur, same_group, pitch):
    """(hard reasons, soft evidence) for the pair of cells prev -> cur.

    Hard reasons are certain splits. Soft evidence (padding, pitch, width,
    text-group change) is for the model to weigh: teams added padding between
    every cell even where the plate reads as one field (Iran 98 ه 886 40).
    """
    slots = spec['slots']
    a, b = slots[prev], slots[cur]
    hard, soft = [], []
    if a['box'][1] != b['box'][1] or a['box'][3] != b['box'][3]:
        hard.append('different line/row height')
    if a['alphabet'] != b['alphabet']:
        hard.append(f'alphabet {a["alphabet"]} -> {b["alphabet"]}')
    if a.get('color') != b.get('color'):
        hard.append('different slot ink')
    if abs(cur - prev) != 1:
        hard.append(f'indices {prev}->{cur} not consecutive')
    lo, hi = (a, b) if a['box'][0] <= b['box'][0] else (b, a)
    gap = round(hi['box'][0] - right(lo['box']), 2)
    if gap < -GAP_TOLERANCE:
        hard.append(f'cells overlap by {-gap}')
    if not hard:
        hard += blockers_between(spec, a, b)
    step = round(abs(b['box'][0] - a['box'][0]), 2)
    if not same_group:
        soft.append('text group changes')
    if gap > GAP_TOLERANCE:
        soft.append(f'padding {gap}')
    if a['box'][2] != b['box'][2]:
        soft.append(f'cell width {a["box"][2]} -> {b["box"][2]}')
    if pitch is not None and abs(step - pitch) > PITCH_TOLERANCE:
        soft.append(f'pitch {pitch} -> {step}')
    return hard, soft, gap, step


def type1(spec):
    """Segments split at hard boundaries; inside a segment every boundary is
    soft and gets a default (merge, except at a text-group change) that the
    model confirms or overturns."""
    slots = spec['slots']
    mirrored = {m['source'] for m in spec['mirrors']}
    order = [(gi, i) for gi, g in enumerate(spec['textGroups']) for i in g['indices'] if i < len(slots)]
    gkey = lambda gi: spec['textGroups'][gi]['key'] or f'#{gi}'
    segments, hard_splits, soft = [], [], []
    seg, pitch = [], None
    for k, (gi, i) in enumerate(order):
        if seg:
            pgi, prev = order[k - 1]
            h, s, gap, step = boundary(spec, prev, i, pgi == gi, pitch)
            if h:
                hard_splits.append({'between': [prev, i], 'reasons': h})
                segments.append(seg)
                seg, pitch = [], None
            else:
                soft.append({'between': [prev, i], 'groups': [gkey(pgi), gkey(gi)], 'gap': gap,
                             'step': step, 'evidence': s,
                             'default': 'split' if pgi != gi else 'merge'})
                pitch = step if pitch is None else pitch
        seg.append(i)
    if seg:
        segments.append(seg)

    def caveats(run):
        out = []
        if len(run) > 1 and mirrored & set(run):
            out.append(f'{len(mirrored & set(run))} cell(s) echoed by per-cell mirrors')
        if len(run) > 1 and any(slots[i]['input'] == 'chosen' for i in run):
            out.append('alphabet is chosen from a sheet, not typed')
        return out

    fields = fields_from(order, {tuple(b['between']): b['default'] for b in soft}, hard_splits)
    before = ' · '.join(' '.join(sample_char(spec, slots[i], n) for n, i in enumerate(g['indices']) if i < len(slots))
                        for g in spec['textGroups'])
    return {
        'id': spec['id'],
        'slotCount': len(slots),
        'segments': [{'indices': s, 'alphabet': slots[s[0]]['alphabet'], 'caveats': caveats(s)} for s in segments],
        'hardSplits': hard_splits,
        'softBoundaries': soft,
        'defaultFields': fields,
        'fieldCount': len(fields),
        'mergeableRuns': sum(1 for f in fields if len(f) > 1),
        'rendering': f'{before} → {render_fields(spec, fields)}',
        'chars': {str(i): sample_char(spec, slots[i], n) for g in spec['textGroups']
                  for n, i in enumerate(g['indices']) if i < len(slots)},
    }


def fields_from(order, decisions, hard_splits):
    """Fields (index lists) from per-boundary merge/split decisions."""
    hard = {tuple(h['between']) for h in hard_splits}
    fields = []
    for k, (_, i) in enumerate(order):
        pair = (order[k - 1][1], i) if k else None
        if fields and pair not in hard and decisions.get(pair) == 'merge':
            fields[-1].append(i)
        else:
            fields.append([i])
    return fields


def render_fields(spec, fields):
    return ''.join('[' + ''.join(sample_char(spec, spec['slots'][i], k) for k, i in enumerate(f)) + ']'
                   for f in fields)


# ---------------------------------------------------------------- TYPE 2

def register_shape(spec):
    """Per text group: (key, alphabet ids with repeats collapsed, rows), plus counts."""
    shape, counts = [], []
    slots = spec['slots']
    for gi, g in enumerate(spec['textGroups']):
        alphas, rows = [], set()
        for i in g['indices']:
            if i >= len(slots):
                continue
            if not alphas or alphas[-1] != slots[i]['alphabet']:
                alphas.append(slots[i]['alphabet'])
            rows.add(slots[i]['box'][1])
        shape.append((g['key'] or f'#{gi}', tuple(alphas), len(rows), g['prefix'], g['reversed']))
        counts.append(len(g['indices']))
    return shape, counts


def background_shape(section):
    if not section:
        return None
    if 'parts' in section:
        return (section['axis'], tuple(background_shape(p['section']) for p in section['parts']),
                tuple(p['divider'] > 0 for p in section['parts']))
    return json.dumps(section['fill'], sort_keys=True)


def signature(spec):
    """Everything that must match for two specs to be one plate; counts excluded."""
    shape, _ = register_shape(spec)
    groups_by_slot = {i: gi for gi, g in enumerate(spec['textGroups']) for i in g['indices']}
    rules = spec['rules']
    return {
        'registers': json.dumps(shape),
        'direction': spec['direction'],
        'vehicle': vehicle_kind(spec),
        'aspectClass': aspect_class(spec['aspect']),
        'countryPanel': json.dumps([spec['country']['code'], spec['country']['panelColor'], spec['panel']['hidden'],
                                    spec['panel']['axis'], spec['panel']['shape'], spec['panel']['flagScale'],
                                    spec['panel']['captionScale']]),
        'background': json.dumps(background_shape(spec['background'])),
        'labels': json.dumps(sorted(l['text'] for l in spec['labels'])),
        'rules': 'stipple' if isinstance(rules, dict) else f'{len(rules)} rules',
        'mirrors': json.dumps(sorted({(groups_by_slot.get(m['source']), m['alphabet'], m['editable'])
                                      for m in spec['mirrors']}, key=str)),
        'bands': json.dumps(sorted(b['color'] for b in spec['bands'])),
        'decals': json.dumps(sorted(d['image'] for d in spec['decals'])),
        'ink': json.dumps([spec['ink'], spec['borderRatio'], sorted({s.get('color', '') for s in spec['slots']})]),
        'restrictions': json.dumps(spec['restrictions'], sort_keys=True),
    }


def flat_geometry(spec):
    """Attributes compared between cluster members to list what differs."""
    shape, counts = register_shape(spec)
    out = {'canvas': spec['canvas'], 'panel.box': spec['panel']['box']}
    for (key, *_), n, g in zip(shape, counts, spec['textGroups']):
        boxes = [spec['slots'][i]['box'] for i in g['indices'] if i < len(spec['slots'])]
        out[f'count[{key}]'] = n
        if boxes:
            out[f'cell[{key}]'] = [boxes[0][2], boxes[0][3]]
            out[f'pitch[{key}]'] = round(boxes[1][0] - boxes[0][0], 2) if len(boxes) > 1 else None
            out[f'start[{key}]'] = boxes[0][:2]
    for n, l in enumerate(spec['labels']):
        out[f'label[{l["text"]}].box'] = l['box']
    rules = spec['rules']
    out['rules'] = rules.get('summary') if isinstance(rules, dict) else len(rules)
    out['mirrors.count'] = len(spec['mirrors'])
    out['background'] = json.dumps(spec['background'])
    out['catalogues'] = spec['catalogues']
    return out


CELL_KEYS = ('count[', 'cell[', 'pitch[', 'start[')


def compare(members):
    flats = {s['id']: flat_geometry(s) for s in members}
    keys = sorted({k for f in flats.values() for k in f})
    differs = {}
    for k in keys:
        vals = {s['id']: flats[s['id']].get(k) for s in members}
        if len({json.dumps(v) for v in vals.values()}) > 1:
            differs[k] = vals
    return differs


def cluster_report(members):
    _, counts0 = register_shape(members[0])
    keys = [k for k, *_ in register_shape(members[0])[0]]
    registers = []
    for gi, key in enumerate(keys):
        obs = sorted({register_shape(s)[1][gi] for s in members})
        registers.append({'group': key, 'min': obs[0], 'max': obs[-1], 'observed': obs, 'varies': len(obs) > 1})
    differs = compare(members)
    varying = [r['group'] for r in registers if r['varies']]
    non_cell = [k for k in differs if not k.startswith(CELL_KEYS) and k not in ('catalogues',)]
    if not varying:
        confidence = 'unclear'
        note = 'no register count differs: members differ only in geometry/ids'
    elif not non_cell and len(varying) == 1:
        confidence, note = 'certain', 'only one register count (and its cell geometry) differs'
    elif set(non_cell) <= {'canvas', 'panel.box', 'rules', 'mirrors.count', 'background'} or len(varying) > 1:
        confidence = 'probable'
        note = (f'{len(varying)} registers vary together' if len(varying) > 1 else '') + \
               (f'; also differs in {", ".join(non_cell)}' if non_cell else '')
    else:
        confidence, note = 'unclear', f'differs in {", ".join(non_cell)}'
    # combinations actually present: a merged spec with independent ranges
    # would also admit the ones that are not
    combos = sorted({tuple(register_shape(s)[1][gi] for gi, r in enumerate(registers) if r['varies'])
                     for s in members})
    return {
        'members': [s['id'] for s in members],
        'registers': registers,
        'observedCombinations': [list(c) for c in combos] if len(varying) > 1 else None,
        'differs': {k: v for k, v in differs.items() if k != 'catalogues'},
        'catalogues': {s['id']: s['catalogues'] for s in members},
        'confidence': confidence,
        'confidenceNote': note.strip('; '),
    }


def type2(specs):
    live = [s for s in specs if 'cloneOf' not in s]
    sigs = {s['id']: signature(s) for s in live}
    buckets = {}
    for s in live:
        buckets.setdefault(json.dumps(sigs[s['id']], sort_keys=True), []).append(s)
    clusters = []
    for members in buckets.values():
        if len(members) > 1:
            c = cluster_report(members)
            c['id'] = f'C{len(clusters) + 1}'
            clusters.append(c)
    reps = list(buckets.values())
    near = []
    for a, b in combinations(reps, 2):
        sa, sb = sigs[a[0]['id']], sigs[b[0]['id']]
        diff = [k for k in sa if sa[k] != sb[k]]
        if len(diff) == 1:
            near.append({
                'id': f'N{len(near) + 1}',
                'a': [s['id'] for s in a], 'b': [s['id'] for s in b],
                'attribute': diff[0], 'aValue': sa[diff[0]], 'bValue': sb[diff[0]],
            })
    singletons = [m[0]['id'] for m in buckets.values() if len(m) == 1]
    return clusters, near, singletons, sigs


# ---------------------------------------------------------------- gallery

def gallery_facts(spec_ids):
    """Gallery entries on this country's specs. Entries that agree on spec,
    theme, panel country and validator draw the same plate - only the sample
    value differs - so they are duplicates."""
    path = TOOL / 'out' / 'gallery.json'
    if not path.exists():
        return {'entries': [], 'duplicates': [], 'note': 'out/gallery.json missing; rerun the Dart dump'}
    entries = [e for e in json.loads(path.read_text()) if e['specId'] in spec_ids]
    groups = {}
    for e in entries:
        key = (e['specId'], e['theme'], e['country'], e['validator'], e['valueDrivenTheme'])
        groups.setdefault(key, []).append(e)
    duplicates = [{
        'specId': k[0], 'theme': k[1], 'themeColors': g[0]['themeColors'],
        'entries': [{'id': e['id'], 'label': e['label'], 'section': e['section'], 'sample': e['sample']}
                    for e in g],
        'reason': 'same spec, theme, panel country and validator; only the sample value differs',
    } for k, g in groups.items() if len(g) > 1]
    return {
        'entries': [{k: e[k] for k in ('id', 'label', 'section', 'specId', 'theme', 'themeColors', 'validator')}
                    for e in entries],
        'duplicates': duplicates,
    }


# ---------------------------------------------------------------- driver

def analyse(path):
    data = json.loads(path.read_text())
    specs = data['specs']
    clusters, near, singletons, sigs = type2(specs)
    return {
        'country': data['country'],
        'package': data['package'],
        'warnings': data['warnings'],
        'validatorFiles': data['validatorFiles'],
        'specs': [{
            'id': s['id'], 'slots': len(s['slots']),
            'groups': [f'{g["key"] or "#"}:{len(g["indices"])}' for g in s['textGroups']],
            'canvas': s['canvas'], 'vehicle': vehicle_kind(s), 'cloneOf': s.get('cloneOf'),
            'catalogues': s['catalogues'],
        } for s in specs],
        'clones': [{'id': s['id'], 'cloneOf': s['cloneOf']} for s in specs if 'cloneOf' in s],
        'type1': [type1(s) for s in specs if 'cloneOf' not in s],
        'type2': {'clusters': clusters, 'nearMisses': near, 'singletons': singletons},
        'gallery': gallery_facts({s['id'] for s in specs}),
        'signatures': sigs,
    }


def main(argv):
    OUT.mkdir(parents=True, exist_ok=True)
    wanted = set(argv)
    files = sorted(SPECS.glob('*.json'))
    if not files:
        print('no dumps in out/specs; run the Dart dump first', file=sys.stderr)
        return 1
    for path in files:
        if wanted and path.stem not in wanted:
            continue
        result = analyse(path)
        (OUT / path.name).write_text(json.dumps(result, indent=1, ensure_ascii=False))
        t1 = sum(r['mergeableRuns'] for r in result['type1'])
        print(f'{result["country"]:<40} specs {len(result["specs"]):>3}  type1 runs {t1:>4}  '
              f'type2 clusters {len(result["type2"]["clusters"]):>2}  near-miss {len(result["type2"]["nearMisses"]):>3}  '
              f'gallery dups {len(result["gallery"]["duplicates"]):>2}')
    return 0


if __name__ == '__main__':
    sys.exit(main(sys.argv[1:]))
