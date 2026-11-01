import { type Rect } from '../values/plate_box';
import { type Alignment, type PlateMotion, type PlatePartPhase, curveTransform } from './plate_animation';

/** [D1] Where one part is right now: progress runs 0→1 across the transition, delay and curve applied. */
export interface PlatePartFrame {
  readonly phase: PlatePartPhase;
  readonly progress: number;
  readonly motion: PlateMotion;
}

/** How much of the part shows, 0 (gone) to 1 (as settled). */
export function frameShown({ phase, progress }: PlatePartFrame): number {
  return phase === 'settled' ? 1 : phase === 'comingIn' ? progress : 1 - progress;
}

export const frameHidden = (f: PlatePartFrame): boolean => frameShown(f) <= 0;

/** The span of a directional effect as fractions along the run from its origin end. */
export function frameSpan({ phase, progress: t }: PlatePartFrame): readonly [number, number] {
  return phase === 'settled' ? [0, 1] : phase === 'comingIn' ? [0, t] : [t, 1];
}

/** [H11] Delay is the head of the curve interval: t<start -> 0, then curve((t-start)/(1-start)). */
export function partProgress(motion: PlateMotion, cueDelayMs: number, atMs: number): number {
  const wait = motion.delayMs + cueDelayMs;
  const total = wait + motion.durationMs;
  if (total <= 0) return 1;
  const start = wait / total;
  const t = atMs / total;
  if (t <= start) return 0;
  return curveTransform(motion.curve, Math.min(1, (t - start) / (1 - start)));
}

/** The part of [bounds] a wipe from [origin] leaves visible. An axis on which [origin] is centred grows from the middle. */
export function plateRevealRect(bounds: Rect, origin: Alignment, frame: PlatePartFrame): Rect {
  const [a, b] = frameSpan(frame);
  if (a <= 0 && b >= 1) return bounds;
  const centred = origin.x === 0 && origin.y === 0;
  const axis = (o: number, lo: number, hi: number, start: boolean): number => {
    const len = hi - lo;
    if (o === 0) {
      if (!centred) return start ? lo : hi;
      return lo + (len * (start ? 1 - (b - a) : 1 + (b - a))) / 2;
    }
    const f0 = o < 0 ? a : 1 - b;
    const f1 = o < 0 ? b : 1 - a;
    return lo + len * (start ? f0 : f1);
  };
  return {
    left: axis(origin.x, bounds.left, bounds.right, true),
    top: axis(origin.y, bounds.top, bounds.bottom, true),
    right: axis(origin.x, bounds.left, bounds.right, false),
    bottom: axis(origin.y, bounds.top, bounds.bottom, false),
  };
}

/** What render() applies to a part's paint for one frame. */
export interface PartChain {
  readonly opacity: number;
  /** Clip to plateRevealRect(bounds, motion.origin, frame). */
  readonly clip: boolean;
  /** Translation as a fraction of the part's size. */
  readonly slide: { readonly x: number; readonly y: number };
  readonly scale: number;
  readonly scaleOrigin: Alignment;
}

const centre: Alignment = { x: 0, y: 0 };

/** [D1] fade=opacity, wipe/draw=clip+gate, fadeScale=scale 0.4→1, fadeSlide=translate 0.6 size. */
export function partChain(frame: PlatePartFrame): PartChain {
  const identity: PartChain = { opacity: 1, clip: false, slide: { x: 0, y: 0 }, scale: 1, scaleOrigin: centre };
  if (frame.phase === 'settled') return identity;
  const shown = frameShown(frame);
  const { effect, origin } = frame.motion;
  switch (effect) {
    case 'fade':
      return { ...identity, opacity: shown };
    case 'wipe':
    case 'draw':
      return { ...identity, opacity: shown <= 0 ? 0 : 1, clip: true };
    case 'fadeScale':
      return { ...identity, opacity: shown, scale: 0.4 + 0.6 * shown, scaleOrigin: origin };
    case 'fadeSlide':
      return { ...identity, opacity: shown, slide: { x: origin.x * 0.6 * (1 - shown), y: origin.y * 0.6 * (1 - shown) } };
  }
}
