import { describe, expect, it } from 'vitest';
import { PlateAlphabet, latinDigits, latinUppercase } from '../../src/core/alphabet/plate_alphabet';
import { KeypadModel } from '../../src/keypad/keypad_model';
import {
  ColorTween, cssColor, faceTargets, gridFor, defaultKeypadTheme, isHighlight, kPlateBackspaceKey, kPlateKeypadSlide, lerpColor, reveal, turnDelayMs,
} from '../../src/keypad/keypad_motion';
import { pickerItems } from '../../src/keypad/plate_character_picker';

const persian = PlateAlphabet.listed({
  id: 'fa.digits', characters: [...'0123456789'], input: 'typed', isNumeric: true,
  glyphs: new Map([...'0123456789'].map((c, i) => [c, '۰۱۲۳۴۵۶۷۸۹'[i]])),
});

describe('keypad motion', () => {
  it('reveal is 1 at rest, 0 at the swap, ordered by index', () => {
    expect(reveal(1, 3, 12)).toBe(1);
    expect(reveal(0.5, 0, 12)).toBe(0);
    expect(reveal(0.2, 0, 12)).toBeLessThan(1);
    expect(reveal(0.2, 11, 12)).toBeGreaterThan(reveal(0.2, 0, 12));
    expect(reveal(0.8, 0, 12)).toBeGreaterThan(reveal(0.8, 11, 12));
  });

  it('grid is square-ish, ends in backspace, cached by id', () => {
    const g = gridFor(latinUppercase);
    expect([g.columns, g.rows]).toEqual([6, 5]);
    expect(g.cells.at(-1)).toBe('⌫');
    expect(g.cells.length).toBe(30);
    expect(gridFor(latinUppercase)).toBe(g);
  });

  it('colours: rgba alpha and per-channel lerp', () => {
    expect(cssColor(0x3dffffff)).toBe('rgba(255,255,255,0.239)');
    expect(lerpColor(0xff000000, 0x00ffffff, 0.5)).toBe(0x80808080);
    const t = new ColorTween(0);
    t.set(0xff000000, 0, 100);
    expect(t.value(0)).toBe(0);
    expect(t.value(100)).toBe(0xff000000);
    expect(faceTargets(defaultKeypadTheme, true, true).ms).toBe(90);
  });

  it('highlight matches across scripts', () => {
    expect(isHighlight('5', '۵', persian)).toBe(true);
    expect(isHighlight('4', '۵', persian)).toBe(false);
    expect(isHighlight(null, '5')).toBe(false);
    expect(turnDelayMs(false, 0, 12)).toBe(18 * 11);
  });
});

describe('keypad model', () => {
  it('digits pad reports the shown script and disables outside the active alphabet', () => {
    const m = new KeypadModel({ digitAlphabet: persian, activeAlphabet: PlateAlphabet.listed({ id: 'one', characters: ['5'], input: 'typed', isNumeric: true, glyphs: persian.glyphs }) });
    const cells = m.cells(false);
    expect(cells.find((c) => c.label === '5')).toMatchObject({ key: '۵', text: '۵', enabled: true });
    expect(cells.find((c) => c.label === '4')!.enabled).toBe(false);
    expect(cells.find((c) => c.label === '⌫')).toMatchObject({ key: kPlateBackspaceKey, enabled: true });
    expect(cells.find((c) => c.label === '')!.enabled).toBe(false);
  });

  it('switch swaps grids at the midpoint and resizes', () => {
    const o = { digitAlphabet: latinDigits, letterAlphabet: latinUppercase };
    const m = new KeypadModel(o);
    expect(m.animating(0)).toBe(false);
    m.update({ ...o, showLetters: true }, 1000);
    expect(m.animating(1000)).toBe(true);
    expect(m.showingLetters(1000 + kPlateKeypadSlide * 0.4)).toBe(false);
    expect(m.showingLetters(1000 + kPlateKeypadSlide * 0.6)).toBe(true);
    const from = m.heightAt(1000);
    expect(m.heightAt(1000 + kPlateKeypadSlide)).toBeGreaterThan(from);
    expect(m.animating(1000 + kPlateKeypadSlide)).toBe(false);
  });

  it('a reversal before the swap brings the old grid back', () => {
    const o = { digitAlphabet: latinDigits, letterAlphabet: latinUppercase };
    const m = new KeypadModel(o);
    m.update({ ...o, showLetters: true }, 0);
    m.update({ ...o, showLetters: false }, kPlateKeypadSlide * 0.2);
    expect(m.t(kPlateKeypadSlide * 0.2)).toBeCloseTo(0.8);
    expect(m.showingLetters(kPlateKeypadSlide * 0.2)).toBe(false);
  });
});

describe('character picker', () => {
  it('lists canonical values with their glyphs', () => {
    expect(pickerItems(persian)[5]).toEqual({ value: '5', glyph: '۵' });
  });
});
