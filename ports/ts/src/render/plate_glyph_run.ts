import type { TextDirection } from '../core/alphabet/plate_alphabet';
import type { Rect } from '../core/values/plate_box';
import type { DisplayList, TextStyle } from './display_list';
import { measureText } from './text_measure';

/** GlyphRun timing: a glyph grows in over enterMs and shrinks out over leaveMs. */
export const glyphEnterMs = 260;
export const glyphLeaveMs = 180;

const segmenter = new Intl.Segmenter(undefined, { granularity: 'grapheme' });

/** [H7] The units a run animates: graphemes left to right; a right-to-left run stays whole so it keeps its shaping. */
export function glyphUnits(text: string, direction: TextDirection): string[] {
  if (text === '') return [];
  return direction === 'rtl' ? [text] : Array.from(segmenter.segment(text), (s) => s.segment);
}

/**
 * [H12] PlateGlyphRun settled: one text op per unit, laid out along [box] from its start edge,
 * scaled down to fit and centred vertically at line height 1.
 */
export function paintGlyphRun(c: DisplayList, text: string, box: Rect, style: TextStyle, direction: TextDirection): void {
  const units = glyphUnits(text, direction);
  if (units.length === 0) return;
  const widths = units.map((u) => measureText(u, style));
  const total = widths.reduce((a, b) => a + b, 0);
  const bw = box.right - box.left, bh = box.bottom - box.top;
  const k = Math.min(1, bw / total, bh / style.fontSize);
  const ltr = direction === 'ltr';
  c.save();
  c.translate(box.left + (bw - total * k) / 2, box.top + (bh - style.fontSize * k) / 2);
  c.scale(k);
  let x = ltr ? 0 : total;
  units.forEach((text, i) => {
    if (!ltr) x -= widths[i];
    c.text({ text, box: [x, 0, widths[i], style.fontSize], align: 'start', direction, ...style });
    if (ltr) x += widths[i];
  });
  c.restore();
}
