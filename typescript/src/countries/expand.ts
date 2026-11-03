// Country data v2 (codegen/compact.mjs) → the verbose shape `loadCountry` reads. Every object is a tuple of its kind's
// fields with the trailing defaults left off; KINDS is the one table, and must match the one in compact.mjs.
import type { CountryData } from './load';

/** [field, default, child]: a child is a kind, or `kind[]` for a list; a default of `@f` copies the earlier field f. */
type Field = readonly [name: string, dflt?: unknown, child?: string];

const KINDS: Record<string, readonly Field[]> = {
  spec: [['id'], ['country'], ['canvasWidth'], ['canvasHeight'], ['slots', [], 'slot[]'], ['labels', [], 'label[]'], ['panel', null, 'panel'], ['background', { kind: 'fill', fill: { kind: 'field' }, shape: null }], ['bands', [], 'band[]'], ['rules', [], 'rule[]'], ['decals', [], 'decal[]'], ['mirrors', [], 'mirror[]'], ['textGroups', null, 'group[]'], ['restrictions', [], 'restriction[]'], ['textDirection', 'ltr'], ['borderWidthRatioOverride', null], ['inkOverride', null], ['resolveTheme', null], ['resolveRegion', null]],
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

/** A tuple → the object of its kind, defaults filled in and children built. */
function build(kind: string, t: readonly any[]): Record<string, any> {
  const out: Record<string, any> = {};
  KINDS[kind]!.forEach(([name, dflt, child], i) => {
    if (i >= t.length) out[name] = typeof dflt === 'string' && dflt[0] === '@' ? out[dflt.slice(1)] : structuredClone(dflt ?? null);
    else out[name] = !child || t[i] === null ? t[i] : child.endsWith('[]') ? t[i].map((x: any[]) => build(child.slice(0, -2), x)) : build(child, t[i]);
  });
  return out;
}

const codePoints = (lo: string, hi: string) => Array.from({ length: hi.codePointAt(0)! - lo.codePointAt(0)! + 1 }, (_, i) => String.fromCodePoint(lo.codePointAt(0)! + i));

/** A theme is a plain object, or `[field, ink, border, radius, inactive?, alert?]` for one ink on one field. */
const theme = (t: any) =>
  Array.isArray(t)
    ? { plateBackground: t[0], plateBorder: t[1], ink: t[1], dividerColor: t[1], borderWidthRatio: t[2], plateRadiusRatio: t[3], activeColor: t[1], inactiveColor: t[4] ?? 0xffb0b0b0, alertColor: t[5] ?? 0xfff87171 }
    : t;

export function expandCountry(c: any): CountryData {
  const entries = (o: Record<string, any>, f: (v: any) => any) => Object.fromEntries(Object.entries(o).map(([k, v]) => [k, f(v)]));
  return {
    package: c.package,
    alphabets: entries(c.alphabets, (t) => {
      const { chars, ...a } = build('alphabet', t);
      return { ...a, characters: chars.flatMap((x: string | string[]) => (typeof x === 'string' ? [x] : codePoints(x[0]!, x[1]!))) };
    }),
    countries: entries(c.countries, (t) => build('country', t)),
    themes: entries(c.themes, theme),
    specs: c.specs.map((t: any[]) => {
      const s = build('spec', t);
      const keyed = s.slots.length > 0 && s.slots.every((x: any) => x.group !== null);
      s.textGroups ??= keyed ? s.slots.map((x: any, i: number) => ({ indices: [i], prefix: '', key: x.group })) : [];
      for (const x of s.slots) delete x.group;
      s.noPanel = s.panel === null;
      return s;
    }),
    resolvers: entries(c.resolvers, (r) => (r[0] === 'code' ? { kind: 'code', signature: r[1] } : { kind: 'table', signature: r[1], reads: r[2], cut: r[3], default: r[4], enc: r[5] })),
    assets: c.assets,
    gallery: c.gallery.map((t: any[]) => build('gallery', t)),
  };
}
