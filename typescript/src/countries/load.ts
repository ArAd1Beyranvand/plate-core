// Turns a generated country module's data (ports/data, D3) into specs. Shared runtime: no country here (W6, W7).
import { PlateAlphabet } from '../core/alphabet/plate_alphabet';
import { PlateTheme, type PlateThemeFields } from '../core/theme/plate_theme';
import type { PlateValidator } from '../core/validators/plate_validator';
import { PlateBox } from '../core/values/plate_box';
import { PlateCountry } from '../core/values/plate_country';
import { PlateRestriction } from '../core/values/plate_restriction';
import { type PlateFill, type PlateLabelResolver, type PlateSection, PlateSlot, PlateSpec, type PlateThemeResolver } from '../core/values/plate_spec';

/** One `ports/data/countries/<package>.json`, with `alphabets` inlined as ref → alphabet. */
export interface CountryData {
  readonly package: string;
  readonly alphabets: Record<string, any>;
  readonly countries: Record<string, any>;
  readonly themes: Record<string, any>;
  readonly specs: readonly any[];
  readonly resolvers: Record<string, any>;
  readonly assets: readonly any[];
  readonly gallery: readonly any[];
}

/** The hand-ported `[D4-code]` names a country wires into its specs. */
export interface CountryCode {
  readonly resolvers?: Record<string, PlateLabelResolver | PlateThemeResolver<PlateTheme>>;
  readonly validators?: Record<string, new () => PlateValidator>;
}

export interface LoadedCountry {
  readonly package: string;
  /** By spec id; ids are unique within a package only. */
  readonly specs: ReadonlyMap<string, PlateSpec<any>>;
  readonly countries: ReadonlyMap<string, PlateCountry>;
  readonly themes: ReadonlyMap<string, PlateTheme>;
  readonly validators: Record<string, new () => PlateValidator>;
  readonly data: CountryData;
}

export const themeOf = (t: PlateThemeFields): PlateTheme => new PlateTheme(t);

export const alphabetOf = (a: any): PlateAlphabet =>
  PlateAlphabet.listed({ id: a.id, characters: a.characters, input: a.input, isNumeric: a.isNumeric, glyphs: new Map<string, string>(a.glyphs), direction: a.direction, placeholder: a.placeholder });

export const countryOf = (c: any): PlateCountry => new PlateCountry({ ...c, flag: c.flag ?? undefined, flagBorderColor: c.flagBorderColor ?? undefined });

/** A `[D4-table]` resolver: the row keyed by the groups it reads (cut to n code points), else the default. */
export function tableResolver<T>(r: any): (group: (key: string) => string) => T {
  const rows = new Map<string, T>(r.table.map(([k, v]: [string[], T]) => [JSON.stringify(k), v]));
  return (group) => {
    const key = JSON.stringify(r.reads.map((g: string) => (g in r.cut ? Array.from(group(g)).slice(0, r.cut[g]).join('') : group(g))));
    return rows.has(key) ? rows.get(key)! : r.default;
  };
}

const box = (b: number[]) => new PlateBox(b[0], b[1], b[2], b[3]);
const shapeOf = (s: any): string | undefined => (s ? `${s.fillRule}:${s.svg}` : undefined);

function fillOf(f: any): PlateFill {
  if (f.kind !== 'stripes') return f;
  const fog = f.fog && { ...f.fog, center: { x: f.fog.center[0], y: f.fog.center[1] }, radii: { width: f.fog.radii[0], height: f.fog.radii[1] } };
  return { ...f, stripes: f.stripes.map(fillOf), angle: f.angle ?? undefined, fog: fog ?? undefined };
}

/** Columns lay out horizontally, rows vertically. */
function sectionOf(s: any): PlateSection {
  if (s.kind === 'fill') return { kind: 'leaf', fill: fillOf(s.fill), shape: shapeOf(s.shape) };
  return { kind: 'split', axis: s.kind === 'columns' ? 'horizontal' : 'vertical', parts: s.parts.map((p: any) => ({ section: sectionOf(p.section), end: p.end ?? undefined, divider: p.divider })) };
}

/** Builds every spec of `d`. A code resolver missing from `code` is left out (the core port cannot run it). */
export function loadCountry(d: CountryData, code: CountryCode = {}): LoadedCountry {
  const alphabets = new Map(Object.entries(d.alphabets).map(([ref, a]) => [ref, alphabetOf(a)]));
  const countries = new Map(Object.entries(d.countries).map(([ref, c]) => [ref, countryOf(c)]));
  const resolver = (name: string | null): any => {
    if (!name) return undefined;
    const r = d.resolvers[name];
    return r.kind === 'table' ? tableResolver(r) : code.resolvers?.[name];
  };
  const theme = (name: string | null): PlateThemeResolver<PlateTheme> | undefined => {
    const r = d.resolvers[name ?? ''];
    if (r?.kind !== 'table') return resolver(name);
    const patch = tableResolver<Partial<PlateThemeFields> | null>(r);
    return (base, group) => base.copyWith(patch(group) ?? {});
  };
  const specs = new Map<string, PlateSpec<PlateTheme>>();
  for (const s of d.specs) {
    const p = s.panel;
    specs.set(
      s.id,
      new PlateSpec<PlateTheme>({
        id: s.id,
        country: countries.get(s.country)!,
        panel: s.noPanel ? undefined : { ...p, box: box(p.box), shape: shapeOf(p.shape), padding: p.padding ? { left: p.padding[0], top: p.padding[1], right: p.padding[2], bottom: p.padding[3] } : undefined },
        background: sectionOf(s.background),
        bands: s.bands.map((b: any) => ({ ...b, box: box(b.box) })),
        rules: s.rules.map((r: any) => ({ box: box(r.box) })),
        labels: s.labels.map((l: any) => ({ ...l, box: box(l.box), color: l.color ?? undefined, lineHeight: l.lineHeight ?? undefined, fontFamily: l.fontFamily ?? undefined, fontPackage: l.fontPackage ?? undefined, resolve: resolver(l.resolve) })),
        decals: s.decals.map((x: any) => ({ box: box(x.box), drawing: x.drawing ?? undefined, image: x.image ?? undefined })),
        inkOverride: s.inkOverride ?? undefined,
        borderWidthRatioOverride: s.borderWidthRatioOverride ?? undefined,
        resolveTheme: theme(s.resolveTheme),
        canvasWidth: s.canvasWidth,
        canvasHeight: s.canvasHeight,
        slots: s.slots.map((x: any) => new PlateSlot({ alphabet: alphabets.get(x.alphabet)!, box: box(x.box), color: x.color ?? undefined, length: x.length, minLength: x.minLength, spacing: x.spacing })),
        mirrors: s.mirrors.map((m: any) => ({ ...m, box: box(m.box), alphabet: m.alphabet ? alphabets.get(m.alphabet) : undefined })),
        textDirection: s.textDirection,
        textGroups: s.textGroups.map((g: any) => ({ indices: g.indices, prefix: g.prefix, key: g.key ?? undefined })),
        restrictions: s.restrictions.map((r: any) => new PlateRestriction(r.group, r.values, r.reason)),
        resolveRegion: resolver(s.resolveRegion),
      }),
    );
  }
  const themes = new Map(Object.entries(d.themes).map(([ref, t]) => [ref, themeOf(t)]));
  return { package: d.package, specs, countries, themes, validators: code.validators ?? {}, data: d };
}
