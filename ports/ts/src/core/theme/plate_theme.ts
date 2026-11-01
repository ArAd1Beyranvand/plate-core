import type { Color } from '../values/plate_shape';

const lerpNum = (a: number, b: number, t: number): number => a + (b - a) * t;

/** Per-channel ARGB32 interpolation, rounded like Flutter's Color.lerp. */
export function lerpColor(a: Color, b: Color, t: number): Color {
  let out = 0;
  for (const shift of [24, 16, 8, 0]) {
    const x = (a >>> shift) & 0xff;
    const y = (b >>> shift) & 0xff;
    out += Math.round(lerpNum(x, y, t)) * 2 ** shift;
  }
  return out;
}

export interface PlateThemeFields {
  readonly plateBackground: Color;
  readonly plateBorder: Color;
  readonly ink: Color;
  readonly dividerColor: Color;
  readonly borderWidthRatio: number;
  readonly plateRadiusRatio: number;
  /** Outline of a completed input field. */
  readonly activeColor: Color;
  /** Outline of an empty or in-progress input field. */
  readonly inactiveColor: Color;
  /** Outline painted when validating an invalid plate. */
  readonly alertColor: Color;
}

export interface GlyphStyle {
  readonly color: Color;
  readonly fontWeight: number;
  readonly fontSize: number;
  readonly lineHeight: number;
  readonly letterSpacing: number;
  readonly fontFamily: string;
}

const colorKeys = ['plateBackground', 'plateBorder', 'ink', 'dividerColor', 'activeColor', 'inactiveColor', 'alertColor'] as const;
const ratioKeys = ['borderWidthRatio', 'plateRadiusRatio'] as const;

/**
 * Chrome colours and ratios, sampled from real plates; never tint them with a
 * host accent. The `*Ratio` fields are fractions of the plate height.
 */
export class PlateTheme implements PlateThemeFields {
  readonly plateBackground: Color;
  readonly plateBorder: Color;
  readonly ink: Color;
  readonly dividerColor: Color;
  readonly borderWidthRatio: number;
  readonly plateRadiusRatio: number;
  readonly activeColor: Color;
  readonly inactiveColor: Color;
  readonly alertColor: Color;

  constructor(f: Omit<PlateThemeFields, 'alertColor'> & { alertColor?: Color }) {
    this.plateBackground = f.plateBackground;
    this.plateBorder = f.plateBorder;
    this.ink = f.ink;
    this.dividerColor = f.dividerColor;
    this.borderWidthRatio = f.borderWidthRatio;
    this.plateRadiusRatio = f.plateRadiusRatio;
    this.activeColor = f.activeColor;
    this.inactiveColor = f.inactiveColor;
    this.alertColor = f.alertColor ?? 0xfff87171;
  }

  /** White face, black frame. */
  static standard(): PlateTheme {
    return new PlateTheme({
      plateBackground: 0xffffffff,
      plateBorder: 0xff000000,
      ink: 0xff0a0a0a,
      dividerColor: 0xff000000,
      borderWidthRatio: 0.04,
      plateRadiusRatio: 0.12,
      activeColor: 0xff0a0a0a,
      inactiveColor: 0x66666666,
    });
  }

  /** A plate printed in one ink on one field; `inactive` is input chrome only. */
  static monochrome(o: { field: Color; ink: Color; inactive: Color; borderWidthRatio: number; plateRadiusRatio: number; alertColor?: Color }): PlateTheme {
    return new PlateTheme({
      plateBackground: o.field,
      plateBorder: o.ink,
      ink: o.ink,
      dividerColor: o.ink,
      borderWidthRatio: o.borderWidthRatio,
      plateRadiusRatio: o.plateRadiusRatio,
      activeColor: o.ink,
      inactiveColor: o.inactive,
      alertColor: o.alertColor,
    });
  }

  copyWith(o: Partial<PlateThemeFields>): PlateTheme {
    return new PlateTheme({ ...this, ...o });
  }

  glyphStyle(slotHeight: number, color: Color, letterSpacing = 0, fontFamily = 'sans-serif'): GlyphStyle {
    return { color, fontWeight: 700, fontSize: slotHeight * 0.72, lineHeight: 1, letterSpacing, fontFamily };
  }

  equals(other: PlateTheme): boolean {
    return this === other || [...colorKeys, ...ratioKeys].every((k) => this[k] === other[k]);
  }

  /** Every field interpolated, for the cross-fade. */
  static lerp(a: PlateTheme, b: PlateTheme, t: number): PlateTheme {
    const out: Record<string, number> = {};
    for (const k of colorKeys) out[k] = lerpColor(a[k], b[k], t);
    for (const k of ratioKeys) out[k] = lerpNum(a[k], b[k], t);
    return new PlateTheme(out as unknown as PlateThemeFields);
  }
}
