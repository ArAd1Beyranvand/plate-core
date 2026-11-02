import { type Rect, rectFromLTWH } from '../values/plate_box';
import { layoutSection } from '../layout/section_layout';
import { type PlateFill, type PlateSection, type PlateSpec, fillPaintsPanel } from '../values/plate_spec';
import type { PlateBox } from '../values/plate_box';
import { Notifier, Store } from '../input/store';

export type PlatePartPhase = 'comingIn' | 'settled' | 'goingOut';

/** The kinds of visual part a plate is made of, in the Dart enum's order. */
export const platePartKinds = [
  'background', 'corner', 'region', 'divider', 'borderWidth', 'borderColor', 'border', 'panel', 'flag', 'caption',
  'band', 'bandCorner', 'rule', 'label', 'decal', 'slot', 'mirror',
] as const;
export type PlatePartKind = (typeof platePartKinds)[number];

/** [H11] Flutter's curves by name; `cubic` is the control points, absent for a function curve. */
export type CurveName = 'linear' | 'ease' | 'easeInOut' | 'easeInOutCubic' | 'easeOut' | 'easeOutBack' | 'easeInCubic' | 'easeOutCubic' | 'elasticOut';
export const cubics: Readonly<Record<string, readonly [number, number, number, number]>> = {
  ease: [0.25, 0.1, 0.25, 1],
  easeInOut: [0.42, 0, 0.58, 1],
  easeInOutCubic: [0.645, 0.045, 0.355, 1],
  easeOut: [0, 0, 0.58, 1],
  easeOutBack: [0.175, 0.885, 0.32, 1.275],
  easeInCubic: [0.55, 0.055, 0.675, 0.19],
  easeOutCubic: [0.215, 0.61, 0.355, 1],
};

const bezier = (a: number, b: number, m: number) => 3 * a * (1 - m) * (1 - m) * m + 3 * b * (1 - m) * m * m + m * m * m;

/** Flutter's `Curve.transform`, including the 0.001 bisection of `Cubic`. */
export function curveTransform(name: string, t: number): number {
  if (t === 0 || t === 1) return t;
  if (name === 'linear') return t;
  if (name === 'elasticOut') return 2 ** (-10 * t) * Math.sin(((t - 0.1) * (Math.PI * 2)) / 0.4) + 1;
  const [a, b, c, d] = cubics[name];
  let start = 0;
  let end = 1;
  for (;;) {
    const mid = (start + end) / 2;
    const est = bezier(a, c, mid);
    if (Math.abs(t - est) < 0.001) return bezier(b, d, mid);
    if (est < t) start = mid;
    else end = mid;
  }
}

/** [D9] A part's address: `${kind}:${index}`. */
export type PlatePartId = string;
export const partId = (kind: PlatePartKind, index = 0): PlatePartId => `${kind}:${index}`;
export const partKindOf = (id: PlatePartId): PlatePartKind => id.slice(0, id.indexOf(':')) as PlatePartKind;
export const partIndexOf = (id: PlatePartId): number => Number(id.slice(id.indexOf(':') + 1));
const singletons: ReadonlySet<PlatePartKind> = new Set(['background', 'corner', 'borderWidth', 'borderColor', 'border', 'panel', 'flag', 'caption']);
/** The Dart `toString`: a kind alone for single parts, else `kind index`. */
export const partIdLabel = (id: PlatePartId): string => (singletons.has(partKindOf(id)) ? partKindOf(id) : `${partKindOf(id)} ${partIndexOf(id)}`);

const noPanel = (s: PlateSpec) => s.panel === undefined;

const layoutOf = (s: PlateSpec) => layoutSection(s.background, rectFromLTWH(0, 0, s.canvasWidth, s.canvasHeight));

/** Leaves of [section]: derived from layout(), never a second walk. */
export const plateRegionCount = (section: PlateSection): number => layoutSection(section, rectFromLTWH(0, 0, 0, 0)).leaves.length;
export const plateDividerCount = (section: PlateSection): number => layoutSection(section, rectFromLTWH(0, 0, 0, 0)).dividers.length;

const range = (n: number) => Array.from({ length: n }, (_, i) => i);

/** Every part [spec] renders, in painting order. */
export function allOf(spec: PlateSpec): PlatePartId[] {
  const each = (kind: PlatePartKind, n: number) => range(n).map((i) => partId(kind, i));
  return [
    partId('background'),
    partId('corner'),
    ...each('region', plateRegionCount(spec.background)),
    ...each('divider', plateDividerCount(spec.background)),
    partId('borderWidth'),
    partId('borderColor'),
    partId('border'),
    ...(noPanel(spec) ? [] : [partId('panel'), partId('flag'), partId('caption')]),
    ...each('band', spec.bands.length),
    ...each('bandCorner', spec.bands.length),
    ...each('rule', spec.rules.length),
    ...each('label', spec.labels.length),
    ...each('decal', spec.decals.length),
    ...each('mirror', spec.mirrors.length),
    ...each('slot', spec.slots.length),
  ];
}

export type PlatePartEffect = 'fade' | 'wipe' | 'fadeScale' | 'fadeSlide' | 'draw';

/** [H10] x, y in [-1, 1]; the centre is (0, 0). */
export interface Alignment {
  readonly x: number;
  readonly y: number;
}
export const centerLeft: Alignment = { x: -1, y: 0 };
const center: Alignment = { x: 0, y: 0 };
const topCenter: Alignment = { x: 0, y: -1 };
const bottomCenter: Alignment = { x: 0, y: 1 };

/** [H11] The timing and look of one part's transitions; times in integer ms. */
export interface PlateMotion {
  readonly effect: PlatePartEffect;
  readonly durationMs: number;
  readonly curve: CurveName;
  /** Added before every transition of the part; a cue's own delay adds to it. */
  readonly delayMs: number;
  readonly origin: Alignment;
  /** For the border: where the stroke starts, as a fraction of the perimeter clockwise from the top-left. */
  readonly startPoint: number;
  readonly clockwise: boolean;
  /** For a divider or rule: a short alpha ramp at the moving edge. */
  readonly softEdge: boolean;
}

export const plateMotion = (o: Partial<PlateMotion> = {}): PlateMotion => ({
  effect: 'fade',
  durationMs: 420,
  curve: 'easeInOutCubic',
  delayMs: 0,
  origin: centerLeft,
  startPoint: 0,
  clockwise: true,
  softEdge: false,
  ...o,
});

/** [D9] The default motion per kind. */
export const defaultMotions: Readonly<Record<PlatePartKind, PlateMotion>> = {
  background: plateMotion({ effect: 'wipe', origin: center }),
  region: plateMotion({ effect: 'wipe' }),
  divider: plateMotion({ effect: 'draw', origin: topCenter, softEdge: true }),
  corner: plateMotion({ durationMs: 600 }),
  borderWidth: plateMotion({ durationMs: 600 }),
  borderColor: plateMotion({ durationMs: 600 }),
  border: plateMotion({ effect: 'draw', durationMs: 900 }),
  panel: plateMotion({ effect: 'wipe' }),
  flag: plateMotion({ effect: 'wipe' }),
  caption: plateMotion({ effect: 'wipe', origin: topCenter }),
  band: plateMotion({ effect: 'wipe' }),
  bandCorner: plateMotion(),
  rule: plateMotion({ effect: 'draw', origin: topCenter, softEdge: true }),
  label: plateMotion({ effect: 'wipe' }),
  decal: plateMotion({ effect: 'fadeScale', origin: center }),
  slot: plateMotion({ effect: 'fadeSlide', origin: bottomCenter }),
  mirror: plateMotion({ effect: 'fadeSlide', origin: bottomCenter }),
};

/** The motion each part uses: one per kind, with optional overrides for single parts. */
export class PlateAnimationStyle {
  constructor(
    readonly byKind: Readonly<Partial<Record<PlatePartKind, PlateMotion>>> = defaultMotions,
    readonly overrides: ReadonlyMap<PlatePartId, PlateMotion> = new Map(),
  ) {}

  motionFor(id: PlatePartId): PlateMotion {
    return this.overrides.get(id) ?? this.byKind[partKindOf(id)] ?? plateMotion();
  }
}

/** One instruction to a part: go to [phase] after [delayMs]. [serial] tells a repeat from a stale cue. */
export interface PlatePartCue {
  readonly phase: PlatePartPhase;
  readonly delayMs: number;
  readonly serial: number;
  /** Jump to the end of [phase] with no transition. */
  readonly instant: boolean;
}

export const settledCue: PlatePartCue = Object.freeze({ phase: 'settled', delayMs: 0, serial: 0, instant: false });

/**
 * [D7] Drives the phases of a plate's parts, all at once or one at a time.
 * A part subscribes to its own cue only; every part starts settled.
 */
export class PlateAnimationController extends Notifier {
  private readonly cues = new Map<PlatePartId, Store<PlatePartCue>>();
  private fallback = settledCue;
  private serial = 0;
  private current: PlateAnimationStyle;

  constructor(style = new PlateAnimationStyle()) {
    super();
    this.current = style;
  }

  get style(): PlateAnimationStyle {
    return this.current;
  }

  set style(value: PlateAnimationStyle) {
    if (value === this.current) return;
    this.current = value;
    this.notify();
  }

  /** The live cue store for [id]; a part subscribes to this. */
  cueOf(id: PlatePartId): Store<PlatePartCue> {
    let s = this.cues.get(id);
    if (!s) this.cues.set(id, (s = new Store(this.fallback)));
    return s;
  }

  phaseOf(id: PlatePartId): PlatePartPhase {
    return (this.cues.get(id)?.value ?? this.fallback).phase;
  }

  cue(id: PlatePartId, phase: PlatePartPhase, delayMs = 0): void {
    this.cueOf(id).value = { phase, delayMs, serial: ++this.serial, instant: false };
  }

  comeIn = (id: PlatePartId, delayMs = 0) => this.cue(id, 'comingIn', delayMs);
  goOut = (id: PlatePartId, delayMs = 0) => this.cue(id, 'goingOut', delayMs);
  settle = (id: PlatePartId) => this.cue(id, 'settled');

  /** Takes [id] straight to gone, with no transition. */
  hide(id: PlatePartId): void {
    this.cueOf(id).value = { phase: 'goingOut', delayMs: 0, serial: ++this.serial, instant: true };
  }

  /** Cues every part, mounted or not, to [phase]; a part named in [delays] waits that long first. */
  cueAll(phase: PlatePartPhase, delays: ReadonlyMap<PlatePartId, number> = new Map()): void {
    const serial = ++this.serial;
    this.fallback = { phase, delayMs: 0, serial, instant: false };
    for (const id of new Set([...this.cues.keys(), ...delays.keys()])) {
      this.cueOf(id).value = { phase, delayMs: delays.get(id) ?? 0, serial, instant: false };
    }
  }

  comeInAll = (delays?: ReadonlyMap<PlatePartId, number>) => this.cueAll('comingIn', delays);
  goOutAll = (delays?: ReadonlyMap<PlatePartId, number>) => this.cueAll('goingOut', delays);
  settleAll = () => this.cueAll('settled');

  override dispose(): void {
    for (const s of this.cues.values()) s.dispose();
    super.dispose();
  }
}

/** [H19] Each of [spec]'s parts [stepMs] after the one before, in painting order; [reverse] to take it apart. */
export function staggerSequence(spec: PlateSpec, { stepMs = 60, reverse = false } = {}): Map<PlatePartId, number> {
  const ids = allOf(spec);
  if (reverse) ids.reverse();
  return new Map(ids.map((id, i) => [id, stepMs * i]));
}

/** How long a cueAll with [delays] runs under [style], for the parts in [ids]. */
export function plateCueLength(style: PlateAnimationStyle, ids: Iterable<PlatePartId>, delays: ReadonlyMap<PlatePartId, number>): number {
  let longest = 0;
  for (const id of ids) {
    const m = style.motionFor(id);
    longest = Math.max(longest, (delays.get(id) ?? 0) + m.delayMs + m.durationMs);
  }
  return longest;
}

/** [H4] Decides per part from the outgoing and incoming plates; undefined defers to the other rules. */
export type PlateKeep = (id: PlatePartId, from: PlateSpec, to: PlateSpec) => boolean | undefined;

export interface PlateSpecTransition {
  readonly keepKinds?: ReadonlySet<PlatePartKind>;
  readonly keep?: PlateKeep;
  /** Also keep every part both plates draw the same way, see samePart. */
  readonly keepIdentical?: boolean;
  /** The face's base colour blends into the next plate's instead of going out and coming back in. */
  readonly morphBackground?: boolean;
  readonly stepMs?: number;
}

export interface SamePartValues {
  readonly fromValues?: readonly (string | null)[];
  readonly toValues?: readonly (string | null)[];
}

/** Whether a spec change keeps [id]: swaps it in place with no transition. */
export function transitionKeeps(t: PlateSpecTransition, id: PlatePartId, from: PlateSpec, to: PlateSpec, values: SamePartValues = {}): boolean {
  if (partKindOf(id) === 'bandCorner') return transitionKeeps(t, partId('band', partIndexOf(id)), from, to, values);
  const decided = t.keep?.(id, from, to);
  if (decided !== undefined) return decided;
  if (t.keepIdentical && samePart(id, from, to, values)) return true;
  return !!t.keepKinds?.has(partKindOf(id)) && allOf(from).includes(id) && allOf(to).includes(id);
}

const sameBox = (a: PlateBox, b: PlateBox) => a.left === b.left && a.top === b.top && a.width === b.width && a.height === b.height;
const sameRect = (a: Rect, b: Rect) => a.left === b.left && a.top === b.top && a.right === b.right && a.bottom === b.bottom;
const sameInsets = (a?: Rect, b?: Rect) => (a && b ? sameRect(a, b) : a === b);

function sameFill(a: PlateFill, b: PlateFill): boolean {
  if (a === b) return true;
  if (a.kind === 'stripes' || b.kind === 'stripes') return false;
  return a.kind === b.kind && (a.kind !== 'color' || a.color === (b as typeof a).color);
}

/**
 * [H1] True when [from] and [to] would paint [id] identically, as far as the specs say.
 * Clip shapes are path strings, compared by equality. The border and the face always redraw.
 */
export function samePart(id: PlatePartId, from: PlateSpec, to: PlateSpec, { fromValues, toValues }: SamePartValues = {}): boolean {
  if (from.canvasWidth !== to.canvasWidth || from.canvasHeight !== to.canvasHeight) return false;
  const i = partIndexOf(id);
  switch (partKindOf(id)) {
    case 'panel':
    case 'flag':
    case 'caption': {
      const a = from.panel;
      const b = to.panel;
      return (
        !!a &&
        !!b &&
        from.country.code === to.country.code &&
        from.country.panelColor === to.country.panelColor &&
        sameBox(a.box, b.box) &&
        (a.flagScale ?? 1) === (b.flagScale ?? 1) &&
        (a.captionScale ?? 1) === (b.captionScale ?? 1) &&
        sameInsets(a.padding, b.padding) &&
        a.direction === b.direction &&
        a.shape === b.shape
      );
    }
    case 'region': {
      const a = layoutOf(from).leaves[i];
      const b = layoutOf(to).leaves[i];
      if (!a || !b || a[0].kind !== 'leaf' || b[0].kind !== 'leaf') return false;
      return (
        sameRect(a[1], b[1]) &&
        a[0].shape === b[0].shape &&
        sameFill(a[0].fill, b[0].fill) &&
        (!fillPaintsPanel(a[0].fill) || from.country.panelColor === to.country.panelColor)
      );
    }
    case 'divider': {
      const a = layoutOf(from).dividers[i];
      const b = layoutOf(to).dividers[i];
      return !!a && !!b && sameRect(a, b) && from.inkOverride === to.inkOverride;
    }
    case 'slot': {
      if (!fromValues || !toValues) return false;
      if (i >= from.slots.length || i >= to.slots.length || i >= fromValues.length || i >= toValues.length) return false;
      const a = from.slots[i];
      const b = to.slots[i];
      return (fromValues[i] ?? '') === (toValues[i] ?? '') && sameBox(a.box, b.box) && a.color === b.color && from.inkOverride === to.inkOverride;
    }
    case 'band': {
      const a = from.bands[i];
      const b = to.bands[i];
      return !!a && !!b && sameBox(a.box, b.box) && a.color === b.color && a.topCornerRadius === b.topCornerRadius && a.bottomCornerRadius === b.bottomCornerRadius;
    }
    case 'rule': {
      const a = from.rules[i];
      const b = to.rules[i];
      return !!a && !!b && sameBox(a.box, b.box) && from.inkOverride === to.inkOverride;
    }
    case 'label': {
      const a = from.labels[i];
      const b = to.labels[i];
      return (
        !!a &&
        !!b &&
        sameBox(a.box, b.box) &&
        a.text === b.text &&
        a.glyphHeight === b.glyphHeight &&
        a.color === b.color &&
        !!a.rotated === !!b.rotated &&
        a.lineHeight === b.lineHeight &&
        a.fontFamily === b.fontFamily &&
        a.fontPackage === b.fontPackage
      );
    }
    default:
      return false;
  }
}
