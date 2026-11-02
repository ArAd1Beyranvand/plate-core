import type { TextDirection } from '../core/alphabet/plate_alphabet';
import type { Rect } from '../core/values/plate_box';
import type { DisplayList, TextStyle } from './display_list';
import { measureText } from './text_measure';

/** StaggeredText timing: each character fades over charMs, the next starting stepMs later. */
export const staggerCharMs = 220;
export const staggerStepMs = 55;

/**
 * [H24] The alpha of each UTF-16 unit of the incoming wording [ms] into its stagger,
 * indexed like Dart's String so a surrogate pair takes two steps.
 */
export function staggerAlphas(text: string, ms: number): number[] {
  return Array.from({ length: text.length }, (_, i) => Math.min(1, Math.max(0, (ms - i * staggerStepMs) / staggerCharMs)));
}

/**
 * [D1] A label or other centred line of fixed text in [box]: scaled down to fit, never up;
 * `rotated` reads bottom to top.
 */
export function paintTextLine(c: DisplayList, text: string, box: Rect, style: TextStyle, direction: TextDirection, rotated = false, align: 'start' | 'center' = 'center', alphas?: readonly number[]): void {
  if (text === '') return;
  const w = measureText(text, style), h = style.fontSize * style.height;
  const bw = box.right - box.left, bh = box.bottom - box.top;
  const [fw, fh] = rotated ? [h, w] : [w, h];
  const k = Math.min(1, bw / fw, bh / fh);
  c.save();
  c.translate((box.left + box.right) / 2, (box.top + box.bottom) / 2);
  c.scale(k);
  if (rotated) c.rotate(-Math.PI / 2);
  c.text({ text, box: [-w / 2, -h / 2, w, h], align, direction, ...style, ...(alphas && { alphas }) });
  c.restore();
}

/** [H24] A caption whose characters leave one after another, then the next wording's arrive; one per resolved label. */
export class StaggeredText {
  private shown: string;
  private leaving = false;
  private settled = true;
  private at = 0;

  constructor(value: string) {
    this.shown = value;
  }

  private run = (text: string) => staggerCharMs + staggerStepMs * Math.min(99, Math.max(0, text.length - 1));

  get running(): boolean {
    return !this.settled;
  }

  /** What to paint for [value] at [now] (ms): the wording on show and, mid-stagger, each unit's alpha. */
  frame(value: string, now: number): { text: string; alphas?: number[] } {
    if (!this.leaving && value !== this.shown) [this.leaving, this.settled, this.at] = [true, false, now];
    if (this.leaving && now - this.at >= this.run(this.shown)) [this.shown, this.leaving, this.at] = [value, false, now];
    if (!this.leaving && !this.settled && now - this.at >= this.run(this.shown)) this.settled = true;
    if (this.settled) return { text: this.shown };
    const a = staggerAlphas(this.shown, now - this.at);
    return { text: this.shown, alphas: this.leaving ? a.map((x) => 1 - x) : a };
  }
}
