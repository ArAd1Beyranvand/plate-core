import { type PlateAlphabet, type TextDirection, splitRunes } from '../alphabet/plate_alphabet';
import type { PlateAsset, PlateDrawing } from './plate_asset';
import { type PlateBox } from './plate_box';
import type { PlateCountry } from './plate_country';
import type { Color } from './plate_shape';

export type Axis = 'horizontal' | 'vertical';
export interface Insets {
  readonly left: number;
  readonly top: number;
  readonly right: number;
  readonly bottom: number;
}

/** What a PlateSpec needs of a restriction; the full type lives with the restriction port. */
export interface PlateRestrictionLike {
  readonly group: string;
  matches(value: string): boolean;
}

/** Key -> caption table or hand-ported function; null keeps the label's text. */
export type PlateLabelResolver = (group: (key: string) => string) => string | null;
/** Resolves a theme from the typed characters; T is the theme type of the render layer. */
export type PlateThemeResolver<T = unknown> = (base: T, group: (key: string) => string) => T;

/** One editable position on a plate. */
export class PlateSlot {
  readonly alphabet: PlateAlphabet;
  readonly box: PlateBox;
  readonly color?: Color;
  readonly length: number;
  readonly minLength: number;
  readonly spacing: number;

  constructor(o: { alphabet: PlateAlphabet; box: PlateBox; color?: Color; length?: number; minLength?: number; spacing?: number }) {
    this.alphabet = o.alphabet;
    this.box = o.box;
    this.color = o.color;
    this.length = o.length ?? 1;
    this.minLength = o.minLength ?? this.length;
    this.spacing = o.spacing ?? 0;
    if (this.length < 1) throw new Error('A slot holds at least one character.');
    if (this.minLength < 1 || this.minLength > this.length) throw new Error('minLength is 1..length.');
  }

  /** Legal, possibly partial, content; a chosen symbol is judged whole. */
  accepts(value: string): boolean {
    if (this.alphabet.input === 'chosen') return this.alphabet.accepts(value);
    const characters = splitRunes(value);
    return characters.length > 0 && characters.length <= this.length && characters.every((c) => this.alphabet.accepts(c));
  }

  canonical(value: string): string {
    return this.alphabet.canonicalAll(value);
  }

  render(value: string): string {
    return this.alphabet.renderAll(value);
  }

  isFull(value: string | null | undefined): boolean {
    return value != null && splitRunes(value).length >= this.length;
  }

  isComplete(value: string | null | undefined): boolean {
    return value != null && splitRunes(value).length >= this.minLength;
  }
}

/** An echo of a slot's value painted elsewhere; owns no position in slots. */
export interface PlateMirror {
  readonly source: number;
  readonly box: PlateBox;
  readonly glyphHeight: number;
  readonly alphabet?: PlateAlphabet;
  readonly editable?: boolean;
}

export interface PlateRule {
  readonly box: PlateBox;
}

export interface PlateFog {
  readonly center: { readonly x: number; readonly y: number };
  readonly radii: { readonly width: number; readonly height: number };
  readonly opacity?: number;
  readonly plateau?: number;
}

/**
 * What a section leaf is painted in. field/panel/divider resolve at render
 * time to the theme's background, the country's panelColor and the divider colour.
 */
export type PlateFill =
  | { readonly kind: 'color'; readonly color: Color }
  | { readonly kind: 'stripes'; readonly stripes: readonly PlateFill[]; readonly stops: readonly number[]; readonly angle?: number; readonly fog?: PlateFog }
  | { readonly kind: 'field' }
  | { readonly kind: 'panel' }
  | { readonly kind: 'divider' };

export const fillField: PlateFill = Object.freeze({ kind: 'field' });
export const fillPanel: PlateFill = Object.freeze({ kind: 'panel' });
export const fillDivider: PlateFill = Object.freeze({ kind: 'divider' });
export const fillColor = (color: Color): PlateFill => ({ kind: 'color', color });

export const fillPaintsPanel = (f: PlateFill): boolean =>
  f.kind === 'panel' || (f.kind === 'stripes' && f.stripes.some((s) => s.kind === 'panel'));

/** The paint colour; not meaningful for stripes, paint each stripe. */
export function resolveFill(f: PlateFill, c: { field: Color; panel: Color; divider: Color }): Color {
  switch (f.kind) {
    case 'color':
      return f.color;
    case 'stripes':
      throw new Error('paint each stripe');
    default:
      return c[f.kind];
  }
}

export interface PlatePart {
  readonly section: PlateSection;
  /** Far edge in plate coordinates along the parent's axis; absent on the last part. */
  readonly end?: number;
  /** Thickness of a rule centred on end. */
  readonly divider?: number;
}

/** A guillotine tree of columns and rows whose leaves are fills. layout lives in core/layout. */
export type PlateSection =
  | { readonly kind: 'leaf'; readonly fill: PlateFill; /** SVG path in leaf-local units. */ readonly shape?: string }
  | { readonly kind: 'split'; readonly axis: Axis; readonly parts: readonly PlatePart[] };

export const plainSection: PlateSection = Object.freeze({ kind: 'leaf', fill: fillField });

export const sectionPaintsPanel = (s: PlateSection): boolean =>
  s.kind === 'leaf' ? fillPaintsPanel(s.fill) : s.parts.some((p) => sectionPaintsPanel(p.section));

export interface PlateBand {
  readonly box: PlateBox;
  readonly color: Color;
  readonly topCornerRadius?: number;
  readonly bottomCornerRadius?: number;
}

/** A fixed image on the plate face: a raster asset reference, or a drawing. */
export type PlateDecal = { readonly box: PlateBox } & (
  | { readonly image: PlateAsset; readonly drawing?: undefined }
  | { readonly drawing: PlateDrawing; readonly image?: undefined }
);

export interface PlateLabel {
  readonly text: string;
  readonly box: PlateBox;
  readonly glyphHeight: number;
  readonly resolve?: PlateLabelResolver;
  readonly color?: Color;
  readonly rotated?: boolean;
  readonly lineHeight?: number;
  readonly fontFamily?: string;
  readonly fontPackage?: string;
}

export interface PlatePanel {
  readonly box: PlateBox;
  readonly flagScale?: number;
  readonly captionScale?: number;
  /** Absent means 10% of the panel height on every side. */
  readonly padding?: Insets;
  readonly direction?: Axis;
  /** SVG path in panel-box units. */
  readonly shape?: string;
}

export interface PlateTextGroup {
  readonly indices: readonly number[];
  readonly prefix?: string;
  readonly key?: string;
}

export interface PlateSpecInit<T = unknown> {
  readonly id: string;
  readonly country: PlateCountry;
  readonly canvasWidth: number;
  readonly canvasHeight: number;
  readonly panel?: PlatePanel;
  readonly slots: readonly PlateSlot[];
  readonly background?: PlateSection;
  readonly bands?: readonly PlateBand[];
  readonly rules?: readonly PlateRule[];
  readonly labels?: readonly PlateLabel[];
  readonly decals?: readonly PlateDecal[];
  readonly mirrors?: readonly PlateMirror[];
  readonly textDirection?: TextDirection;
  readonly borderWidthRatioOverride?: number;
  readonly inkOverride?: Color;
  readonly textGroups?: readonly PlateTextGroup[];
  readonly restrictions?: readonly PlateRestrictionLike[];
  readonly resolveTheme?: PlateThemeResolver<T>;
  readonly resolveRegion?: PlateLabelResolver;
}

/** A complete plate design. Equal iff the ids match; key Maps by `id`. */
export class PlateSpec<T = unknown> {
  readonly id: string;
  readonly country: PlateCountry;
  readonly canvasWidth: number;
  readonly canvasHeight: number;
  readonly panel?: PlatePanel;
  readonly slots: readonly PlateSlot[];
  readonly background: PlateSection;
  readonly bands: readonly PlateBand[];
  readonly rules: readonly PlateRule[];
  readonly labels: readonly PlateLabel[];
  readonly decals: readonly PlateDecal[];
  readonly mirrors: readonly PlateMirror[];
  readonly textDirection: TextDirection;
  readonly borderWidthRatioOverride?: number;
  readonly inkOverride?: Color;
  readonly textGroups: readonly PlateTextGroup[];
  readonly restrictions: readonly PlateRestrictionLike[];
  readonly resolveTheme?: PlateThemeResolver<T>;
  readonly resolveRegion?: PlateLabelResolver;

  constructor(o: PlateSpecInit<T>) {
    this.id = o.id;
    this.country = o.country;
    this.canvasWidth = o.canvasWidth;
    this.canvasHeight = o.canvasHeight;
    this.panel = o.panel;
    this.slots = o.slots;
    this.background = o.background ?? plainSection;
    this.bands = o.bands ?? [];
    this.rules = o.rules ?? [];
    this.labels = o.labels ?? [];
    this.decals = o.decals ?? [];
    this.mirrors = o.mirrors ?? [];
    this.textDirection = o.textDirection ?? 'ltr';
    this.borderWidthRatioOverride = o.borderWidthRatioOverride;
    this.inkOverride = o.inkOverride;
    this.textGroups = o.textGroups ?? [];
    this.restrictions = o.restrictions ?? [];
    this.resolveTheme = o.resolveTheme;
    this.resolveRegion = o.resolveRegion;
  }

  get slotCount(): number {
    return this.slots.length;
  }

  slotAt(index: number): PlateSlot | null {
    return this.slots[index] ?? null;
  }

  /** textGroups, or one group per slot when none are declared. */
  get effectiveTextGroups(): readonly PlateTextGroup[] {
    return this.textGroups.length > 0 ? this.textGroups : this.slots.map((_, i) => ({ indices: [i] }));
  }

  groupAt(index: number): PlateTextGroup | null {
    return this.effectiveTextGroups.find((g) => g.indices.includes(index)) ?? null;
  }

  groupNamed(key: string): PlateTextGroup | null {
    return this.effectiveTextGroups.find((g) => g.key === key) ?? null;
  }

  renderGroup(group: PlateTextGroup, values: readonly (string | null)[]): string {
    let out = group.prefix ?? '';
    for (const i of group.indices) out += this.slotAt(i)?.render(i < values.length ? (values[i] ?? '') : '') ?? '';
    return out;
  }

  nextIndex(index: number): number | null {
    return index >= 0 && index + 1 < this.slots.length ? index + 1 : null;
  }

  previousIndex(index: number): number | null {
    return index > 0 && index < this.slots.length ? index - 1 : null;
  }

  valueOfGroup(key: string, values: readonly (string | null)[]): string {
    return this.indicesOfGroup(key)
      .filter((i) => i < values.length)
      .map((i) => values[i] ?? '')
      .join('');
  }

  restrictionViolatedBy(values: readonly (string | null)[]): PlateRestrictionLike | null {
    return this.restrictions.find((r) => r.matches(this.valueOfGroup(r.group, values))) ?? null;
  }

  indicesOfGroup(key: string): readonly number[] {
    return this.groupNamed(key)?.indices ?? [];
  }

  equals(other: PlateSpec<any>): boolean {
    return other.id === this.id;
  }
}
