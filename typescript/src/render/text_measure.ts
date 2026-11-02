import type { TextStyle } from './display_list';

/** [H12] Measures a line in plate units; the UI swaps in canvas measureText with the bundled font. */
export type TextMeasurer = (text: string, style: TextStyle) => number;

/** A headless estimate: 0.6 em per grapheme plus letter spacing. Layout only, never compared. */
let measurer: TextMeasurer = (text, s) => Array.from(text).length * (s.fontSize * 0.6 + s.letterSpacing);

export const measureText: TextMeasurer = (text, style) => measurer(text, style);

export function setTextMeasurer(m: TextMeasurer): void {
  measurer = m;
}
