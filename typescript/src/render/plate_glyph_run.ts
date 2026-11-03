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
 * scaled down to fit and centred vertically at line height 1. A [placeholder] is painted faintly
 * under the run, which then starts where the placeholder starts, each character on its twin.
 * A [caret] colour paints the insertion point at the end of the typed text, where the run is.
 */
export function paintGlyphRun(
  c: DisplayList, text: string, box: Rect, style: TextStyle, direction: TextDirection,
  placeholder?: { text: string; color: TextStyle['color'] },
  caret?: TextStyle['color'],
): void {
  // The characters already typed hide their twins; a whole right-to-left run is split at that point.
  const rtl = direction === 'rtl';
  const n = rtl ? text.length : glyphUnits(text, direction).length;
  const runs = [...(placeholder?.text ? [{ text: placeholder.text, style: { ...style, color: placeholder.color }, ghost: true }] : []), { text, style, ghost: false }]
    .map((r) => {
      const units = r.ghost && rtl ? [r.text.slice(0, n), r.text.slice(n)].filter(Boolean) : glyphUnits(r.text, direction);
      const widths = units.map((u) => measureText(u, r.style));
      return { ...r, units, widths, skip: r.ghost ? (rtl ? (n ? 1 : 0) : n) : 0, total: widths.reduce((a, b) => a + b, 0) };
    })
    .filter((r) => r.units.length);
  if (runs.length === 0 && caret === undefined) return;
  const total = Math.max(0, ...runs.map((r) => r.total));
  const bw = box.right - box.left, bh = box.bottom - box.top;
  const k = Math.min(1, total ? bw / total : 1, bh / style.fontSize);
  const ltr = direction === 'ltr';
  c.save();
  c.translate(box.left + (bw - total * k) / 2, box.top + (bh - style.fontSize * k) / 2);
  c.scale(k);
  for (const r of runs) {
    let x = ltr ? 0 : total;
    r.units.forEach((text, i) => {
      if (!ltr) x -= r.widths[i];
      if (i >= r.skip) c.text({ text, box: [x, 0, r.widths[i], style.fontSize], align: 'start', direction, ...r.style });
      if (ltr) x += r.widths[i];
    });
  }
  if (caret !== undefined) {
    const typed = runs.find((r) => !r.ghost)?.total ?? 0, x = ltr ? typed : total - typed, f = style.fontSize;
    c.rect({ left: x, top: f * 0.1, right: x + f * 0.05, bottom: f * 0.9 }, { color: caret });
  }
  c.restore();
}
