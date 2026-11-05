import { PlateAlphabet } from '../core/alphabet/plate_alphabet';
import { curveTransform } from '../core/timing/plate_animation';

/** Backspace's key label; not a character any alphabet accepts. */
export const kPlateBackspaceKey = 'BACKSPACE';

/** [H11] Duration of a digits/letters switch in integer ms; the phase fractions below are fractions of it. */
export const kPlateKeypadSlide = 560;

/** Letters alphabet of a numeric-only keypad; never shown. */
export const noLetters = PlateAlphabet.listed({ id: 'keypad.noLetters', characters: [], input: 'chosen', isNumeric: false });

const outEnd = 0.4;
const resizeStart = 0.3;
const resizeEnd = 0.7;
const inStart = 0.6;
export const swapAt = 0.5;

export const digitRows: readonly (readonly string[])[] = [['1', '2', '3'], ['4', '5', '6'], ['7', '8', '9'], ['', '0', '⌫']];
export const digitLabels: readonly string[] = digitRows.flat();
export const keyGap = 6;
export const keyHeight = (compact: boolean): number => (compact ? 44 : 56);

const clamp01 = (x: number) => Math.min(1, Math.max(0, x));

/** [D1] How present key [index] of [count] is at [t]: 1 at rest, 0 while the grids swap. */
export function reveal(t: number, index: number, count: number): number {
  if (t >= 1) return 1;
  const leaving = t < swapAt;
  const a = leaving ? 0 : inStart;
  const b = leaving ? outEnd : 1;
  const start = count <= 1 ? 0 : (index / (count - 1)) * 0.5;
  const p = clamp01(((t - a) / (b - a) - start) / 0.5);
  return leaving ? 1 - curveTransform('easeInCubic', p) : curveTransform('easeOutCubic', p);
}

/** How present key [index] of [count] is [elapsed] ms into the pad coming in or going out: keys
 * stagger over the first half of [kPlateKeypadSlide], in reading order coming in and reversed going out. */
export function entrance(elapsed: number, index: number, count: number, coming: boolean): number {
  const at = count <= 1 ? 0 : ((coming ? index : count - 1 - index) / (count - 1)) * 0.5;
  const p = clamp01((elapsed / kPlateKeypadSlide - at) / 0.5);
  return coming ? curveTransform('easeOutCubic', p) : 1 - curveTransform('easeInCubic', p);
}

/** Pad height at [t] while resizing from [from] to [to]. */
export function heightAt(t: number, from: number, to: number): number {
  return from + (to - from) * curveTransform('easeInOutCubic', clamp01((t - resizeStart) / (resizeEnd - resizeStart)));
}

export interface KeyGrid {
  readonly id: string;
  readonly cells: readonly string[];
  readonly columns: number;
  readonly rows: number;
}

const grids = new Map<string, KeyGrid>();

/** [H17] A roughly square grid ending in backspace; cached by alphabet id (H3). */
export function gridFor(alphabet: PlateAlphabet): KeyGrid {
  const hit = grids.get(alphabet.id);
  if (hit) return hit;
  const letters = alphabet.characters;
  const columns = Math.max(1, Math.ceil(Math.sqrt(letters.length)));
  const rows = Math.ceil((letters.length + 1) / columns);
  const cells = [...letters];
  for (let i = letters.length + 1; i < rows * columns; i++) cells.push('');
  cells.push('⌫');
  const grid = { id: alphabet.id, cells, columns, rows };
  grids.set(alphabet.id, grid);
  return grid;
}

/** The pad height of a grid with [rows] rows. */
export const gridHeight = (rows: number, compact: boolean): number => rows * keyHeight(compact) + (rows - 1) * keyGap;

/** What a key reports: backspace is its own key; a digit key reports the script it shows. */
export function reportedKey(label: string, digitAlphabet?: PlateAlphabet): string {
  return label === '⌫' ? kPlateBackspaceKey : digitAlphabet ? digitAlphabet.render(label) : label;
}

/** The text on a key face. */
export const faceText = (label: string, displayAlphabet?: PlateAlphabet): string =>
  label === '⌫' || !displayAlphabet ? label : displayAlphabet.render(label);

/** [H3] Whether [candidate] names [key] in either script. */
export function isHighlight(candidate: string | null, key: string, digitAlphabet?: PlateAlphabet): boolean {
  if (candidate === null) return false;
  if (candidate === key) return true;
  return !!digitAlphabet && digitAlphabet.canonical(candidate) === digitAlphabet.canonical(key);
}

/** Backspace always; otherwise only keys of the active (else the pad's own) alphabet. */
export function keyEnabled(key: string, own: PlateAlphabet, active?: PlateAlphabet | null): boolean {
  if (key === '') return false;
  return key === kPlateBackspaceKey || (active ?? own).accepts(key);
}

/** [H14] Delay before key [index] of [count] turns grey (last to first) or returns (first to last). */
export const turnDelayMs = (enabled: boolean, index: number, count: number): number => 18 * (enabled ? count + index : count - 1 - index);

/** [H10] Theme colours are ARGB ints. */
export interface PlateKeypadTheme {
  readonly surface: number;
  readonly keyBorder: number;
  readonly ink: number;
  readonly disabledInk: number;
  readonly highlight: number;
  readonly highlightInk: number;
}
export const defaultKeypadTheme: PlateKeypadTheme = {
  surface: 0xff1c1f26,
  keyBorder: 0x3dffffff,
  ink: 0xffffffff,
  disabledInk: 0x4dffffff,
  highlight: 0xffe8a33d,
  highlightInk: 0xff05080b,
};

export const cssColor = (c: number): string =>
  `rgba(${(c >>> 16) & 255},${(c >>> 8) & 255},${c & 255},${(((c >>> 24) & 255) / 255).toFixed(3)})`;

/** [H15] Each ARGB channel lerped on its own, rounded. */
export function lerpColor(a: number, b: number, t: number): number {
  let out = 0;
  for (const shift of [24, 16, 8, 0]) {
    const x = (a >>> shift) & 255;
    const y = (b >>> shift) & 255;
    out |= Math.round(x + (y - x) * t) << shift;
  }
  return out >>> 0;
}

export const flashInMs = 90;
export const flashOutMs = 160;
export const greyOutMs = 180;

/** [H15] A colour/scale tween on the shared clock, easeOut, retargeted from where it is. */
export class ColorTween {
  private from: number;
  private to: number;
  private at = 0;
  private ms = 0;

  constructor(value: number) {
    this.from = this.to = value;
  }

  set(target: number, now: number, ms: number): void {
    if (target === this.to) return;
    this.from = this.at_(now);
    this.to = target;
    this.at = now;
    this.ms = ms;
  }

  private at_(now: number): number {
    const t = this.ms <= 0 ? 1 : clamp01((now - this.at) / this.ms);
    return t >= 1 ? this.to : lerpColor(this.from, this.to, curveTransform('easeOut', t));
  }

  value(now: number): number {
    return this.at_(now);
  }

  running(now: number): boolean {
    return now - this.at < this.ms && this.from !== this.to;
  }
}

/** The fill/border/ink targets and duration of a key face. */
export function faceTargets(theme: PlateKeypadTheme, highlighted: boolean, enabled: boolean) {
  const dim = (theme.keyBorder & 0xffffff) | (Math.round(((theme.keyBorder >>> 24) & 255) * 0.5) << 24);
  return {
    fill: highlighted ? theme.highlight : 0,
    border: highlighted ? theme.highlight : enabled ? theme.keyBorder : dim >>> 0,
    ink: highlighted ? theme.highlightInk : enabled ? theme.ink : theme.disabledInk,
    ms: highlighted ? flashInMs : enabled ? flashOutMs : greyOutMs,
    scale: highlighted ? 0.94 : 1,
  };
}
