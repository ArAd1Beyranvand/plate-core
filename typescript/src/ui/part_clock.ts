import { type PlateAnimationController, type PlatePartCue, type PlatePartId } from '../core/timing/plate_animation';
import { partProgress } from '../core/timing/plate_part_animator';
import type { Frames } from '../render/plate_frame';

/**
 * The current frame's time: every canvas painting this frame reads the same instant, so a ghost
 * and the plate under it never sit a frame apart. Off the page, the wall clock.
 */
export const frameNow = (): number => (typeof document === 'undefined' ? null : (document.timeline?.currentTime as number | null)) ?? performance.now();

/**
 * [H11] The animation driver: remembers when each part's cue arrived and turns
 * (cue, elapsed) into frames through the core timing model. The UI ticks it per animation frame.
 */
export class PartClock {
  private readonly started = new Map<PlatePartId, { cue: PlatePartCue; at: number }>();

  constructor(private readonly animation: PlateAnimationController, private readonly now: () => number = frameNow) {}

  frames(): Frames {
    const t = this.now();
    return (id) => {
      const cue = this.animation.cueOf(id).value;
      let s = this.started.get(id);
      if (!s || s.cue !== cue) this.started.set(id, (s = { cue, at: t }));
      const motion = this.animation.style.motionFor(id);
      const progress = cue.instant || cue.phase === 'settled' ? 1 : partProgress(motion, cue.delayMs, t - s.at);
      return { phase: cue.phase, progress, motion };
    };
  }

  /** True while some part seen so far is still moving. */
  get running(): boolean {
    const t = this.now();
    for (const [id, { cue, at }] of this.started) {
      if (cue.instant || cue.phase === 'settled') continue;
      if (partProgress(this.animation.style.motionFor(id), cue.delayMs, t - at) < 1) return true;
    }
    return false;
  }
}
