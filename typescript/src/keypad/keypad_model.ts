import type { PlateAlphabet } from '../core/alphabet/plate_alphabet';
import {
  type KeyGrid, type PlateKeypadTheme, defaultKeypadTheme, digitLabels, digitRows, faceText, gridFor, gridHeight, heightAt,
  entrance, kPlateKeypadSlide, keyEnabled as keyAccepts, noLetters, reportedKey, reveal, swapAt,
} from './keypad_motion';

export interface PlateKeypadOptions {
  readonly digitAlphabet: PlateAlphabet;
  readonly letterAlphabet?: PlateAlphabet;
  readonly activeAlphabet?: PlateAlphabet | null;
  readonly showLetters?: boolean;
  readonly compact?: boolean;
  readonly theme?: PlateKeypadTheme;
}

export interface KeyCell {
  readonly label: string;
  readonly index: number;
  readonly key: string;
  readonly text: string;
  readonly enabled: boolean;
}

/** [D1] The switch state machine of the pad, headless: grids, heights and per-key presence at a time. */
export class KeypadModel {
  private o: PlateKeypadOptions;
  private fromLetters: boolean;
  private toLetters: boolean;
  private fromHeight: number | null = null;
  private startedAt = -Infinity;
  private enteredAt = -Infinity;
  private coming = true;

  constructor(o: PlateKeypadOptions) {
    this.o = o;
    this.fromLetters = this.toLetters = !!o.showLetters;
  }

  get options(): PlateKeypadOptions {
    return this.o;
  }
  get theme(): PlateKeypadTheme {
    return this.o.theme ?? defaultKeypadTheme;
  }
  get compact(): boolean {
    return !!this.o.compact;
  }
  get letterAlphabet(): PlateAlphabet {
    return this.o.letterAlphabet ?? noLetters;
  }

  /** Animation position 0..1 at [now]. */
  t(now: number): number {
    return Math.min(1, Math.max(0, (now - this.startedAt) / kPlateKeypadSlide));
  }
  animating(now: number): boolean {
    return this.t(now) < 1 || now - this.enteredAt < kPlateKeypadSlide;
  }

  /** Starts the whole pad staggering in ([coming]) or out from [now]. */
  enter(now: number, coming: boolean): void {
    this.enteredAt = now;
    this.coming = coming;
  }

  /** Applies new options; a showLetters flip starts or reverses a switch. */
  update(o: PlateKeypadOptions, now: number): void {
    this.o = o;
    const want = !!o.showLetters;
    if (want === this.toLetters) return;
    const t = this.t(now);
    if (t < 1 && t < swapAt) {
      [this.fromLetters, this.toLetters] = [this.toLetters, this.fromLetters];
      this.fromHeight = null;
      this.startedAt = now - (1 - t) * kPlateKeypadSlide;
      return;
    }
    this.fromHeight = t < 1 ? this.heightAt(now) : null;
    this.fromLetters = this.toLetters;
    this.toLetters = want;
    this.startedAt = now;
  }

  private naturalHeight(letters: boolean): number {
    return gridHeight(letters ? gridFor(this.letterAlphabet).rows : digitRows.length, this.compact);
  }

  heightAt(now: number): number {
    return heightAt(this.t(now), this.fromHeight ?? this.naturalHeight(this.fromLetters), this.naturalHeight(this.toLetters));
  }

  /** The grid on screen at [now]: before the swap the leaving one, after it the arriving one. */
  showingLetters(now: number): boolean {
    return this.t(now) < swapAt ? this.fromLetters : this.toLetters;
  }

  grid(letters: boolean): KeyGrid {
    return letters ? gridFor(this.letterAlphabet) : { id: 'digits', cells: digitLabels, columns: digitRows[0].length, rows: digitRows.length };
  }

  /** How present the pad itself is: it fades with its keys when it comes in or goes out. */
  padPresence(now: number): number {
    const p = Math.min(1, Math.max(0, (now - this.enteredAt) / kPlateKeypadSlide));
    return this.coming ? p : 1 - p;
  }

  presence(now: number, index: number, count: number): number {
    return reveal(this.t(now), index, count) * entrance(now - this.enteredAt, index, count, this.coming);
  }

  /** Alphabet that renders and reports keys of a grid: digits report in their script, letters verbatim. */
  digitsOf(letters: boolean): PlateAlphabet | undefined {
    return letters ? undefined : this.o.digitAlphabet;
  }

  cells(letters: boolean): KeyCell[] {
    const own = letters ? this.letterAlphabet : this.o.digitAlphabet;
    const digits = this.digitsOf(letters);
    return this.grid(letters).cells.map((label, index) => {
      const key = reportedKey(label, digits);
      return { label, index, key, text: faceText(label, own), enabled: label !== '' && keyAccepts(key, own, this.o.activeAlphabet) };
    });
  }
}

