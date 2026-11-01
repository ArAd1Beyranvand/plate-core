import type { Rect } from '../core/values/plate_box';
import type { Color } from '../core/values/plate_shape';
import { layoutSection } from '../core/layout/section_layout';
import { lerpColor, type PlateTheme } from '../core/theme/plate_theme';
import { partId, type PlatePartId } from '../core/timing/plate_animation';
import { frameHidden, frameShown, frameSpan, plateRevealRect, type PlatePartFrame } from '../core/timing/plate_part_animator';
import { type PlateFill, type PlateSection, resolveFill } from '../core/values/plate_spec';
import { type DisplayList, type RRect, deflate, deflateRRect, withAlpha } from './display_list';
import { paintDivider } from './plate_divider';

export type Frames = (id: PlatePartId) => PlatePartFrame;

const clamp01 = (v: number) => Math.min(1, Math.max(0, v));

/** [D1] The outer rim, its inner edge, and the face the regions are clipped to. */
export interface FrameGeometry {
  readonly border: number;
  readonly outerRadius: number;
  readonly innerRadius: number;
  readonly outer: RRect;
  readonly inner: RRect;
  readonly face: RRect;
}

export function frameGeometry(theme: PlateTheme, width: number, height: number, frames: Frames): FrameGeometry {
  const border = theme.borderWidthRatio * height * clamp01(frameShown(frames(partId('borderWidth'))));
  const outerRadius = theme.plateRadiusRatio * height * clamp01(frameShown(frames(partId('corner'))));
  const innerRadius = Math.min(Math.max(outerRadius - border, 0), outerRadius);
  const outer: RRect = { rect: { left: 0, top: 0, right: width, bottom: height }, radius: outerRadius };
  // Halfway into the border: the border's inner edge lies over a region, and a
  // region's edge never reaches the outer anti-aliased rim.
  return { border, outerRadius, innerRadius, outer, inner: { rect: deflate(outer.rect, border), radius: innerRadius }, face: deflateRRect(outer, border / 2) };
}

/** Content bleeds this far under the border paint (PlateRimClip). */
export function rimClip(g: FrameGeometry): RRect {
  return { rect: deflate(g.outer.rect, Math.max(0, g.border - 0.75)), radius: g.innerRadius };
}

const fades = (f: PlatePartFrame) => f.motion.effect !== 'wipe' && f.motion.effect !== 'draw';

export interface FrameInput {
  readonly theme: PlateTheme;
  readonly width: number;
  readonly height: number;
  readonly background: PlateSection;
  readonly panelColor: Color;
  readonly isCompleted: boolean;
  readonly frames: Frames;
}

/** [D1] PlateFrame: face, regions, dividers, border, in that order, each clipped to the face. */
export function paintFrame(c: DisplayList, f: FrameInput): void {
  const g = frameGeometry(f.theme, f.width, f.height, f.frames);
  const bounds: Rect = { left: 0, top: 0, right: f.width, bottom: f.height };
  const { leaves, dividers } = layoutSection(f.background, bounds);
  const colors = { field: f.theme.plateBackground, panel: f.panelColor, divider: f.theme.dividerColor };

  const face = f.frames(partId('background'));
  if (!frameHidden(face)) {
    c.save();
    if (face.phase !== 'settled' && !fades(face)) c.clipRect(plateRevealRect(bounds, face.motion.origin, face));
    c.clipRRect(g.face);
    c.rrect(g.face, { color: fades(face) ? withAlpha(f.theme.plateBackground, frameShown(face)) : f.theme.plateBackground });
    c.restore();
  }

  leaves.forEach(([section, r], i) => {
    const frame = f.frames(partId('region', i));
    if (frameHidden(frame) || section.kind !== 'leaf' || section.fill.kind === 'field') return;
    c.save();
    c.clipRRect(g.face);
    if (frame.phase !== 'settled' && !fades(frame)) c.clipRect(plateRevealRect(r, frame.motion.origin, frame));
    const opacity = fades(frame) ? frameShown(frame) : 1;
    if (section.fill.kind === 'stripes') paintStripes(c, section.fill, r, section.shape, opacity, colors);
    else {
      const paint = { color: withAlpha(resolveFill(section.fill, colors), opacity) };
      if (section.shape === undefined) c.rect(r, paint);
      else {
        c.translate(r.left, r.top);
        c.path(section.shape, paint);
      }
    }
    c.restore();
  });

  dividers.forEach((r, i) => paintDivider(c, r, f.theme.dividerColor, f.frames(partId('divider', i)), g.face));

  paintBorder(c, f, g, bounds);
}

/** Each stripe a rect in a frame turned about [r]'s centre, clipped back to [r] (or its shape); then the fog. */
function paintStripes(
  c: DisplayList,
  fill: Extract<PlateFill, { kind: 'stripes' }>,
  r: Rect,
  shape: string | undefined,
  opacity: number,
  colors: { field: Color; panel: Color; divider: Color },
): void {
  const cx = (r.left + r.right) / 2, cy = (r.top + r.bottom) / 2;
  const reach = Math.max(r.right - r.left, r.bottom - r.top);
  const angle = fill.angle ?? 0;
  c.save();
  if (shape === undefined) c.clipRect(r);
  else c.clipPath(shiftPath(shape, r.left, r.top));
  c.translate(cx, cy);
  c.rotate(-angle);
  let top = -reach;
  // The Dart painter reuses one Paint: the fog keeps the last stripe's colour.
  let last: Color = 0xff000000;
  fill.stripes.forEach((stripe, i) => {
    // A stop is where the boundary meets the centreline: its perpendicular distance in the turned frame.
    const bottom = i < fill.stops.length ? (fill.stops[i] - cy) * Math.cos(angle) : reach;
    if (stripe.kind !== 'field') {
      last = withAlpha(resolveFill(stripe, colors), opacity);
      c.rect({ left: -reach, top, right: reach, bottom }, { color: last });
    }
    top = bottom;
  });
  c.restore();
  const fog = fill.fog;
  if (fog) {
    c.save();
    c.clipRect(r);
    c.translate(fog.center.x, fog.center.y);
    c.scale(fog.radii.width, fog.radii.height);
    c.circle(0, 0, 1, { color: last, shader: { kind: 'fog', color: withAlpha(colors.field, (fog.opacity ?? 1) * opacity), plateau: fog.plateau ?? 0 } });
    c.restore();
  }
}

/** Shifts every coordinate pair of a `<rule>:<M/L/Z d>` path. */
export function shiftPath(path: string, dx: number, dy: number): string {
  const [rule, d] = path.split(':');
  let x = true;
  return `${rule}:${d.replace(/-?\d+(\.\d+)?(e-?\d+)?/g, (v) => {
    const out = String(Math.round((Number(v) + (x ? dx : dy)) * 1e4) / 1e4);
    x = !x;
    return out;
  })}`;
}

/** The ring's centreline, clockwise from the top-left corner, as sampled points with running lengths. */
function centreline(width: number, height: number, g: FrameGeometry): { pts: [number, number][]; at: number[] } {
  const h = g.border / 2;
  const L = h, T = h, R = width - h, B = height - h;
  const r = Math.max(0, g.outerRadius - h);
  const pts: [number, number][] = [];
  const corner = (cx: number, cy: number, from: number) => {
    const steps = Math.max(1, Math.ceil((r * Math.PI) / 2 / 0.25));
    for (let i = 0; i <= steps; i++) {
      const a = from + ((Math.PI / 2) * i) / steps;
      pts.push([cx + r * Math.cos(a), cy + r * Math.sin(a)]);
    }
  };
  pts.push([L + r, T]);
  corner(R - r, T + r, -Math.PI / 2);
  corner(R - r, B - r, 0);
  corner(L + r, B - r, Math.PI / 2);
  corner(L + r, T + r, Math.PI);
  const at = [0];
  for (let i = 1; i < pts.length; i++) at.push(at[i - 1] + Math.hypot(pts[i][0] - pts[i - 1][0], pts[i][1] - pts[i - 1][1]));
  return { pts, at };
}

/** [H13] The run of the centreline between lengths [from] and [to], 0 <= from <= to <= length. */
function extract({ pts, at }: { pts: [number, number][]; at: number[] }, from: number, to: number): string {
  const point = (s: number): [number, number] => {
    let i = 1;
    while (i < at.length - 1 && at[i] < s) i++;
    const t = at[i] === at[i - 1] ? 0 : (s - at[i - 1]) / (at[i] - at[i - 1]);
    return [pts[i - 1][0] + (pts[i][0] - pts[i - 1][0]) * t, pts[i - 1][1] + (pts[i][1] - pts[i - 1][1]) * t];
  };
  const run = [point(from), ...pts.filter((_, i) => at[i] > from && at[i] < to), point(to)];
  return run.map(([x, y], i) => `${i === 0 ? 'M' : 'L'}${Math.round(x * 1e4) / 1e4} ${Math.round(y * 1e4) / 1e4}`).join(' ');
}

/** [H15] The completed border's tint: Color.lerp on 0..1 channels, so a half rounds as the doubles fall. */
function lerpUnit(a: Color, b: Color, t: number): Color {
  let out = 0;
  for (const shift of [24, 16, 8, 0]) {
    const x = ((a >>> shift) & 0xff) / 255, y = ((b >>> shift) & 0xff) / 255;
    out += Math.round((x + (y - x) * t) * 255) * 2 ** shift;
  }
  return out;
}

/** Settled: a filled ring. Drawing: a stroke along the centreline, grown from startPoint. */
function paintBorder(c: DisplayList, f: FrameInput, g: FrameGeometry, bounds: Rect): void {
  const frame = f.frames(partId('border'));
  if (frameHidden(frame)) return;
  const { theme } = f;
  const settled = f.isCompleted ? lerpUnit(theme.plateBorder, theme.plateBackground, 0.02) : theme.plateBorder;
  const shownColor = clamp01(frameShown(f.frames(partId('borderColor'))));
  const color = shownColor >= 1 ? settled : lerpColor(theme.plateBackground, settled, shownColor);
  const [a, b] = frameSpan(frame);
  const whole = a <= 0 && b >= 1;
  c.save();
  if (whole || frame.motion.effect !== 'draw') {
    if (whole || fades(frame)) c.drrect(g.outer, g.inner, { color: whole || !fades(frame) ? color : withAlpha(color, frameShown(frame)) });
    else {
      c.save();
      c.clipRect(plateRevealRect(bounds, frame.motion.origin, frame));
      c.drrect(g.outer, g.inner, { color });
      c.restore();
    }
    c.restore();
    return;
  }
  const line = centreline(f.width, f.height, g);
  const length = line.at[line.at.length - 1];
  const s = (((frame.motion.startPoint % 1) + 1) % 1) * length;
  const [from, to] = frame.motion.clockwise ? [s + a * length, s + b * length] : [s - b * length, s - a * length];
  const lo = ((from % length) + length) % length;
  const span = to - from;
  const d = lo + span <= length ? extract(line, lo, lo + span) : `${extract(line, lo, length)} ${extract(line, 0, lo + span - length)}`;
  c.path(`nonzero:${d}`, { color, stroke: g.border, cap: 'butt', join: 'miter' });
  c.restore();
}
