import type { Rect } from '../core/values/plate_box';
import type { Color } from '../core/values/plate_shape';
import { frameHidden, frameShown, frameSpan, type PlatePartFrame } from '../core/timing/plate_part_animator';
import { type DisplayList, type RRect, withAlpha } from './display_list';

/** Which end of a divider its effect starts at: start is the left or top end. */
export type DividerOrigin = 'start' | 'end';

const rampSteps = 3;

/**
 * [D1] The rects a divider paints in [r] this frame, with the alpha fraction of each:
 * the shown span along its long axis, softened at the moving edge when the motion asks.
 */
export function dividerSpans(r: Rect, frame: PlatePartFrame, origin?: DividerOrigin): [Rect, number][] {
  if (frameHidden(frame)) return [];
  const { motion } = frame;
  if (frame.phase === 'settled' || (motion.effect !== 'wipe' && motion.effect !== 'draw')) return [[r, frameShown(frame)]];
  const vertical = r.bottom - r.top > r.right - r.left;
  const fromEnd = (origin ?? ((vertical ? motion.origin.y : motion.origin.x) > 0 ? 'end' : 'start')) === 'end';
  let [a, b] = frameSpan(frame);
  if (fromEnd) [a, b] = [1 - b, 1 - a];
  const whole = a <= 0 && b >= 1;
  const lo = vertical ? r.top : r.left;
  const len = vertical ? r.bottom - r.top : r.right - r.left;
  const along = (f0: number, f1: number): Rect =>
    vertical ? { left: r.left, top: lo + len * f0, right: r.right, bottom: lo + len * f1 } : { left: lo + len * f0, top: r.top, right: lo + len * f1, bottom: r.bottom };
  // The moving edge: the head on the way in, the tail on the way out.
  const moving = (frame.phase === 'comingIn') !== fromEnd ? b : a;
  const ramp = motion.softEdge && !whole ? Math.min(Math.max(((vertical ? r.right - r.left : r.bottom - r.top) * 3) / len, 0), b - a) : 0;
  if (ramp <= 0) return [[along(a, b), 1]];
  const towardLo = moving === a;
  const out: [Rect, number][] = [[towardLo ? along(a + ramp, b) : along(a, b - ramp), 1]];
  const step = ramp / rampSteps;
  for (let i = 0; i < rampSteps; i++) {
    const f = i * step;
    out.push([towardLo ? along(a + ramp - f - step, a + ramp - f) : along(b - ramp + f, b - ramp + f + step), (rampSteps - i) / (rampSteps + 1)]);
  }
  return out;
}

/** PlateDividerPainter: one divider line in [r], clipped to [clip] when given. */
export function paintDivider(c: DisplayList, r: Rect | undefined, color: Color, frame: PlatePartFrame, clip?: RRect, origin?: DividerOrigin): void {
  if (frameHidden(frame) || !r) return;
  if (clip) {
    c.save();
    c.clipRRect(clip);
  }
  for (const [rect, alpha] of dividerSpans(r, frame, origin)) c.rect(rect, { color: withAlpha(color, alpha) });
  if (clip) c.restore();
}
