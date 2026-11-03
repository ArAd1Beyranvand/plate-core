// Country data v2: the verbose `ports/data/countries/<package>.json` objects as trimmed tuples, so a generated module
// carries what differs from the defaults and nothing else. `expandCountry` (src/countries/expand.ts, Expand.kt,
// expand.py) is the exact inverse. Keep the three expanders and this schema in step: KINDS is the one table.

const REQ = null; // a field every tuple carries: nothing to default
const FIELD_BG = { kind: 'fill', fill: { kind: 'field' }, shape: null };

/** kind → [field, default, child]; child is `kind` or `kind[]`; a default of `@f` copies the earlier field f. */
export const KINDS = {
  spec: [['id'], ['country'], ['canvasWidth'], ['canvasHeight'], ['slots', [], 'slot[]'], ['labels', [], 'label[]'], ['panel', null, 'panel'], ['background', FIELD_BG], ['bands', [], 'band[]'], ['rules', [], 'rule[]'], ['decals', [], 'decal[]'], ['mirrors', [], 'mirror[]'], ['textGroups', null, 'group[]'], ['restrictions', [], 'restriction[]'], ['textDirection', 'ltr'], ['borderWidthRatioOverride', null], ['inkOverride', null], ['resolveTheme', null], ['resolveRegion', null]],
  slot: [['alphabet'], ['box'], ['length', 1], ['minLength', '@length'], ['spacing', 0], ['color', null], ['group', null]],
  label: [['text'], ['box'], ['glyphHeight'], ['color', null], ['rotated', false], ['lineHeight', null], ['fontFamily', null], ['fontPackage', null], ['resolve', null]],
  panel: [['box'], ['flagScale', 1], ['captionScale', 1], ['padding', null], ['direction', 'vertical'], ['shape', null]],
  band: [['box'], ['color'], ['topCornerRadius', 0], ['bottomCornerRadius', 0]],
  rule: [['box']],
  decal: [['box'], ['image', null], ['drawing', null]],
  mirror: [['source'], ['box'], ['glyphHeight'], ['alphabet', null], ['editable', false]],
  group: [['indices'], ['prefix', ''], ['key', null]],
  restriction: [['group'], ['values'], ['reason']],
  country: [['code'], ['panelColor'], ['panelTextColor'], ['flagAspectRatio'], ['captionLines', []], ['headingLines', []], ['flag', null], ['flagBorderColor', null]],
  gallery: [['id'], ['label'], ['spec'], ['sampleValues'], ['source'], ['section'], ['note', null], ['theme', null], ['country', null], ['validator', null], ['themeForValues', false], ['bands', []]],
  alphabet: [['id'], ['chars'], ['input', 'typed'], ['isNumeric', false], ['glyphs', []], ['direction', 'ltr'], ['placeholder', '?']],
};
export const INACTIVE = 4289769648; // 0xFFB0B0B0
export const ALERT = 4294472049; // 0xFFF87171

const same = (a, b) => JSON.stringify(a) === JSON.stringify(b);
/** Plate units are millimetres: four decimals is far below anything a plate can show. */
const round = (x) => (typeof x === 'number' && !Number.isInteger(x) ? Number(x.toFixed(4)) : Array.isArray(x) ? x.map(round) : x && typeof x === 'object' ? Object.fromEntries(Object.entries(x).map(([k, v]) => [k, round(v)])) : x);

function dflt(kind, i, o) {
  const d = KINDS[kind][i][1];
  return typeof d === 'string' && d[0] === '@' ? o[d.slice(1)] : structuredClone(d ?? null);
}

/** One verbose object → its tuple: children encoded, trailing defaults trimmed. */
function tuple(kind, src) {
  const o = { ...src };
  const fields = KINDS[kind];
  fields.forEach(([f], i) => {
    if (!(f in o)) o[f] = dflt(kind, i, o);
  });
  const out = fields.map(([f, , child]) => {
    const v = o[f];
    if (!child || v === null) return v;
    return child.endsWith('[]') ? v.map((x) => tuple(child.slice(0, -2), x)) : tuple(child, v);
  });
  while (out.length && same(o[fields[out.length - 1][0]], dflt(kind, out.length - 1, o))) out.pop();
  return out;
}

/** Runs of consecutive BMP code points become [lo, hi]; anything else stays a literal entry. */
function alphabetTokens(chars) {
  const cp = chars.map((c) => (Array.from(c).length === 1 && c.codePointAt(0) < 0xd800 ? c.codePointAt(0) : null));
  const out = [];
  for (let i = 0; i < chars.length; ) {
    let j = i;
    while (j + 1 < chars.length && cp[j] !== null && cp[j + 1] === cp[j] + 1) j++;
    if (j - i >= 2) out.push([chars[i], chars[j]]);
    else out.push(...chars.slice(i, j + 1));
    i = j + 1;
  }
  return out;
}

const alphabet = (a) => tuple('alphabet', { ...a, chars: alphabetTokens(a.characters) });

const mono = (t) => t.plateBorder === t.ink && t.dividerColor === t.ink && t.activeColor === t.ink;
function theme({ names, ...t }) {
  if (!mono(t)) return t;
  const out = [t.plateBackground, t.ink, t.borderWidthRatio, t.plateRadiusRatio, t.inactiveColor, t.alertColor];
  if (out[5] === ALERT) out.pop();
  if (out.length === 5 && out[4] === INACTIVE) out.pop();
  return out;
}

/** A table keyed by one string, as the prefixes whose every key shares a value plus the exact keys that break the
 * pattern; exact over every string of the keys' own characters up to their length. Null when that domain is too big. */
function trie(rows, dflt) {
  const keys = new Map(rows.map(([k, v]) => [k[0], v]));
  const chars = [...new Set([...keys.keys()].flatMap((k) => Array.from(k)))].sort();
  const depth = Math.max(...[...keys.keys()].map((k) => Array.from(k).length));
  if (Array.from({ length: depth + 1 }, (_, l) => chars.length ** l).reduce((a, b) => a + b) > 200000) return null;
  const f = (s) => (keys.has(s) ? keys.get(s) : dflt);
  const prefix = [], exact = [];
  /** The JSON of the one value f takes on p and everything beneath it, else null. */
  const uniform = (p) => {
    const v = JSON.stringify(f(p));
    return Array.from(p).length === depth || chars.every((c) => uniform(p + c) === v) ? v : null;
  };
  const walk = (p) => {
    const v = uniform(p);
    if (v !== null) {
      if (v !== JSON.stringify(dflt)) prefix.push([p, JSON.parse(v)]);
      return;
    }
    if (!same(f(p), dflt)) exact.push([p, f(p)]);
    chars.forEach((c) => walk(p + c));
  };
  walk('');
  return { trie: { prefix, exact } };
}

function resolver(r) {
  if (r.kind === 'code') return ['code', r.signature];
  const single = r.reads.length === 1 && !Object.keys(r.cut).length && r.table.every(([k]) => k.length === 1 && typeof k[0] === 'string');
  const groups = new Map();
  for (const [k, v] of r.table) groups.set(JSON.stringify(v), [...(groups.get(JSON.stringify(v)) ?? []), k]);
  const byValue = { groups: [...groups].map(([v, ks]) => [JSON.parse(v), ks]) };
  const tried = single ? trie(r.table, r.default) : null;
  const body = tried && JSON.stringify(tried).length <= JSON.stringify(byValue).length ? tried : byValue;
  return ['table', r.signature, r.reads, r.cut, r.default, body];
}

/** The tuples `expandCountry` reads back; `d` is the verbose country with its alphabets inlined (ref → alphabet). */
export function compactCountry(d) {
  d = round(d);
  return {
    package: d.package,
    alphabets: Object.fromEntries(Object.entries(d.alphabets).map(([ref, a]) => [ref, alphabet(a)])),
    countries: Object.fromEntries(Object.entries(d.countries).map(([ref, c]) => [ref, tuple('country', c)])),
    themes: Object.fromEntries(Object.entries(d.themes).map(([ref, t]) => [ref, theme(t)])),
    specs: d.specs.map((s) => {
      const g = s.textGroups;
      const keyed = g.length === s.slots.length && g.length && g.every((x, i) => same(x.indices, [i]) && x.prefix === '' && x.key !== null);
      return tuple('spec', {
        ...s,
        panel: s.noPanel ? null : s.panel,
        slots: keyed ? s.slots.map((x, i) => ({ ...x, group: g[i].key })) : s.slots,
        textGroups: keyed || !g.length ? null : g,
      });
    }),
    resolvers: Object.fromEntries(Object.entries(d.resolvers).map(([k, r]) => [k, resolver(r)])),
    assets: d.assets,
    gallery: d.gallery.map((g) => tuple('gallery', g)),
  };
}
