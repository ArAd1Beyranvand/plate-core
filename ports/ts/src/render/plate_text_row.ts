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
export function paintTextLine(c: DisplayList, text: string, box: Rect, style: TextStyle, direction: TextDirection, rotated = false, align: 'start' | 'center' = 'center'): void {
  if (text === '') return;
  const w = measureText(text, style), h = style.fontSize * style.height;
  const bw = box.right - box.left, bh = box.bottom - box.top;
  const [fw, fh] = rotated ? [h, w] : [w, h];
  const k = Math.min(1, bw / fw, bh / fh);
  c.save();
  c.translate((box.left + box.right) / 2, (box.top + box.bottom) / 2);
  c.scale(k);
  if (rotated) c.rotate(-Math.PI / 2);
  c.text({ text, box: [-w / 2, -h / 2, w, h], align, direction, ...style });
  c.restore();
}
