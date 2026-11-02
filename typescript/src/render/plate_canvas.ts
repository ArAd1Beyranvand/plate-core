import { lerpColor, PlateTheme } from '../core/theme/plate_theme';
import { type PlateMode, resolveSlotBehavior } from '../core/input/slot_behavior';
import type { PlateInputSource } from '../core/input/plate_input_source';
import { type PlateBox, rectFromLTWH } from '../core/values/plate_box';
import type { PlateCountry } from '../core/values/plate_country';
import { type PlateSpec, sectionPaintsPanel } from '../core/values/plate_spec';
import type { PlateRestriction } from '../core/values/plate_restriction';
import { PlateAnimationStyle, type PlatePartId, partId } from '../core/timing/plate_animation';
import { frameHidden } from '../core/timing/plate_part_animator';
import { type DisplayOp, DisplayList } from './display_list';
import { paintPanel } from './country_panel';
import { paintDivider } from './plate_divider';
import { paintDrawing } from './plate_drawing_view';
import { type Frames, frameGeometry, paintFrame, rimClip } from './plate_frame';
import { paintGlyphRun } from './plate_glyph_run';
import { paintTextLine } from './plate_text_row';

type Values = readonly (string | null)[];

/** [H15] _ThemeTween: the six colours the livery cross-fades; ratios and alert come from [b]. */
export function lerpTheme(a: PlateTheme, b: PlateTheme, t: number): PlateTheme {
  return b.copyWith({
    plateBackground: lerpColor(a.plateBackground, b.plateBackground, t),
    plateBorder: lerpColor(a.plateBorder, b.plateBorder, t),
    ink: lerpColor(a.ink, b.ink, t),
    dividerColor: lerpColor(a.dividerColor, b.dividerColor, t),
    activeColor: lerpColor(a.activeColor, b.activeColor, t),
    inactiveColor: lerpColor(a.inactiveColor, b.inactiveColor, t),
  });
}

/** [H4] The theme a plate paints with: the spec's overrides on [theme], then its resolver over [values]. */
export function plateTheme(spec: PlateSpec, theme: PlateTheme | undefined, values: Values): PlateTheme {
  let base = theme ?? PlateTheme.standard();
  if (spec.borderWidthRatioOverride !== undefined) base = base.copyWith({ borderWidthRatio: spec.borderWidthRatioOverride });
  const ink = spec.inkOverride;
  if (ink !== undefined) base = base.copyWith({ ink, plateBorder: ink, dividerColor: ink, activeColor: ink });
  const resolve = spec.resolveTheme as ((b: PlateTheme, g: (k: string) => string) => PlateTheme) | undefined;
  return resolve ? resolve(base, (k) => spec.valueOfGroup(k, values)) : base;
}

/** Every part settled, as the vectors render. */
export const settledFrames =
  (style = new PlateAnimationStyle()): Frames =>
  (id: PlatePartId) => ({ phase: 'settled', progress: 1, motion: style.motionFor(id) });

export interface RenderInput {
  readonly spec: PlateSpec;
  readonly values: Values;
  readonly theme?: PlateTheme;
  /** The theme already resolved (a tween in flight); skips plateTheme. */
  readonly resolvedTheme?: PlateTheme;
  /** Replaces the spec's country chrome. */
  readonly country?: PlateCountry;
  readonly frames?: Frames;
  readonly mode?: PlateMode;
  readonly inputSource?: PlateInputSource;
  readonly isCompleted?: boolean;
  readonly rejection?: PlateRestriction | null;
  /** Input mode: a faint sample per slot (PlateController.hintAt), else the alphabet's placeholder. */
  readonly hintAt?: (index: number) => string | null;
  /** Input mode: the focused slot, whose underline takes the active colour. */
  readonly activeIndex?: number | null;
  /** Resolved labels: the wording on show and its per-character alphas while it staggers out and in. */
  readonly labelText?: (index: number, value: string) => { text: string; alphas?: number[] };
  /** The view's size; the frame stretches to it, the content contain-fits. Defaults to the canvas. */
  readonly size?: readonly [number, number];
}

/** Flutter's Stack clips its children to itself only when one of them overflows it. */
function clipOverflow(c: DisplayList, W: number, H: number, boxes: readonly PlateBox[]): void {
  if (boxes.some((b) => b.left < 0 || b.top < 0 || b.right > W || b.bottom > H)) c.clipRect(rectFromLTWH(0, 0, W, H));
}

/**
 * [D1] PlateCanvas as a display list in spec units: the frame, the content
 * (panel, bands, rules, labels, decals) and the display-mode inputs (mirrors,
 * slots, the restriction banner), each under the rim clip.
 */
export function renderPlate(o: RenderInput): DisplayOp[] {
  const { spec, values } = o;
  const frames = o.frames ?? settledFrames();
  const theme = o.resolvedTheme ?? plateTheme(spec, o.theme, values);
  const country = o.country ?? spec.country;
  const W = spec.canvasWidth, H = spec.canvasHeight;
  const shown = (id: PlatePartId) => !frameHidden(frames(id));
  const group = (k: string) => spec.valueOfGroup(k, values);
  const isCompleted = o.isCompleted ?? spec.slots.every((s, i) => s.isComplete(values[i]));
  const c = new DisplayList();
  const [vw, vh] = o.size ?? [W, H];
  const k = Math.min(vw / W, vh / H);
  const fit = () => {
    c.translate((vw - W * k) / 2, (vh - H * k) / 2);
    c.scale(k);
  };

  c.save();
  c.scale(vw / W, vh / H);
  paintFrame(c, { theme, width: W, height: H, background: spec.background, panelColor: country.panelColor, isCompleted, frames });
  c.restore();
  const rim = rimClip(frameGeometry(theme, W, H, frames));

  c.save();
  fit();
  c.clipRRect(rim);
  clipOverflow(c, W, H, [...(spec.panel ? [spec.panel.box] : []), ...spec.bands.map((b) => b.box), ...spec.rules.map((r) => r.box), ...spec.labels.map((l) => l.box), ...spec.decals.map((d) => d.box)]);
  if (spec.panel && shown(partId('panel'))) {
    paintPanel(c, spec.panel, country, theme.ink, !sectionPaintsPanel(spec.background), {
      flag: shown(partId('flag')),
      caption: shown(partId('caption')),
    });
  }
  spec.bands.forEach((b, i) => {
    if (!shown(partId('band', i))) return;
    const t = b.topCornerRadius ?? 0, bt = b.bottomCornerRadius ?? 0;
    if (t === 0 && bt === 0) c.rect(b.box.rect, { color: b.color });
    else c.rrectRaw([b.box.left, b.box.top, b.box.width, b.box.height, t, t, t, t, bt, bt, bt, bt], { color: b.color });
  });
  spec.rules.forEach((r, i) => {
    c.save();
    c.translate(r.box.left, r.box.top);
    paintDivider(c, rectFromLTWH(0, 0, r.box.width, r.box.height), theme.dividerColor, frames(partId('rule', i)));
    c.restore();
  });
  spec.labels.forEach((l, i) => {
    if (!shown(partId('label', i))) return;
    const value = l.resolve ? (l.resolve(group) ?? l.text) : l.text;
    const { text, alphas } = l.resolve && o.labelText ? o.labelText(i, value) : { text: value, alphas: undefined };
    const fontFamily = l.fontPackage ? `packages/${l.fontPackage}/${l.fontFamily}` : (l.fontFamily ?? 'Roboto');
    const g = theme.glyphStyle(l.glyphHeight, l.color ?? theme.ink);
    const style = { fontSize: g.fontSize, height: l.lineHeight ?? 1, color: g.color, fontFamily, fontWeight: g.fontWeight, letterSpacing: 0 };
    paintTextLine(c, text, l.box.rect, style, spec.textDirection, l.rotated, 'center', alphas);
  });
  spec.decals.forEach((d, i) => {
    if (!shown(partId('decal', i))) return;
    if (d.drawing) {
      c.save();
      c.translate(d.box.left, d.box.top);
      paintDrawing(c, d.drawing, d.box.width, d.box.height, 'contain');
      c.restore();
    } else c.asset({ kind: d.image.kind, package: d.image.package, path: d.image.path, box: [d.box.left, d.box.top, d.box.width, d.box.height] });
  });
  c.restore();

  c.save();
  fit();
  c.clipRRect(rim);
  clipOverflow(c, W, H, [...spec.mirrors.map((m) => m.box), ...spec.slots.map((s) => s.box)]);
  spec.mirrors.forEach((m, i) => {
    const v = values[m.source];
    if (!shown(partId('mirror', i)) || !v) return;
    const alphabet = m.alphabet ?? spec.slots[m.source].alphabet;
    const g = theme.glyphStyle(m.glyphHeight, theme.ink);
    paintGlyphRun(c, alphabet.renderAll(v), m.box.rect, { fontSize: g.fontSize, height: 1, color: g.color, fontFamily: 'Roboto', fontWeight: 700, letterSpacing: 0 }, alphabet.direction);
  });
  spec.slots.forEach((s, i) => {
    if (!shown(partId('slot', i))) return;
    const v = values[i];
    const g = theme.glyphStyle(s.box.height, s.color ?? theme.ink, s.spacing);
    const style = { fontSize: g.fontSize, height: 1, color: g.color, fontFamily: 'Roboto', fontWeight: 700, letterSpacing: g.letterSpacing };
    // [D2] Anything but a glyph is a native input the UI layer places at the slot box; its glyphs,
    // placeholder and underline are still painted here, under the transparent field.
    const field = o.mode === 'input' && resolveSlotBehavior({ mode: 'input', input: s.alphabet.input, source: o.inputSource ?? 'system' }) !== 'glyph';
    if (!field) return paintGlyphRun(c, v ? s.render(v) : '', s.box.rect, style, s.alphabet.direction);
    // glyphStyle's 0.72 of the box, centred, as the field's content padding leaves it.
    const r = s.box.rect, inset = s.box.height * 0.14;
    const hint = o.hintAt?.(i) ?? s.alphabet.placeholder;
    paintGlyphRun(c, v ? s.render(v) : '', { ...r, top: r.top + inset, bottom: r.bottom - inset }, style, s.alphabet.direction, { text: hint, color: theme.inactiveColor });
    const lit = !!v || o.activeIndex === i;
    c.rect({ left: r.left, top: r.bottom - 1, right: r.right, bottom: r.bottom }, { color: lit ? theme.activeColor : theme.inactiveColor });
  });
  if (o.rejection) {
    const bh = H * 0.42, top = (H - bh) / 2;
    c.rect(rectFromLTWH(0, top, W, bh), { color: theme.alertColor });
    const style = { fontSize: H * 0.26, height: 1, color: 0xffffffff, fontFamily: 'Roboto', fontWeight: 800, letterSpacing: 0.25 };
    paintTextLine(c, o.rejection.reason, rectFromLTWH(H * 0.1, top, W - H * 0.2, bh), style, 'ltr', false, 'start');
  }
  c.restore();
  return c.ops;
}
