import { readFileSync } from 'node:fs';
import { resolve } from 'node:path';
import { expect, test } from 'vitest';
import { latinDigits } from '../../src/core/alphabet/plate_alphabet';
import { layoutSection } from '../../src/core/layout/section_layout';
import { plateEcho, plateRegister, plateRegisterAcross, plateStipple } from '../../src/core/layout/plate_layout';
import { PlateTheme } from '../../src/core/theme/plate_theme';
import { PlateRestriction, PlateRestrictionException } from '../../src/core/values/plate_restriction';
import { PlateBox } from '../../src/core/values/plate_box';
import { PlateSlot, PlateSpec, fillField } from '../../src/core/values/plate_spec';
import { specProblems } from '../../src/core/validators/debug_validate_spec';
import { isDigits, isDigitsOfLength } from '../../src/core/validators/plate_validator';

const cases: any[] = JSON.parse(readFileSync(resolve(import.meta.dirname, '../../../vectors/core/layout.json'), 'utf8')).cases;
const box = (b: PlateBox) => [b.left, b.top, b.width, b.height, b.right, b.bottom];

function build(i: any): any {
  const args = { ...i, pitch: i.pitch ?? undefined, alphabet: latinDigits };
  switch (i.builder) {
    case 'plateRegister':
    case 'plateRegisterAcross':
      return (i.builder === 'plateRegister' ? plateRegister : plateRegisterAcross)(args).map((s) => box(s.box));
    case 'plateEcho':
      return plateEcho({ ...args, alphabet: undefined }).map((m) => ({ source: m.source, box: box(m.box), glyphHeight: m.glyphHeight }));
    default:
      return plateStipple(args).map((r) => box(r.box));
  }
}

test('builder vectors', () => {
  for (const c of cases.filter((c) => c.input.builder)) {
    if (c.expect.throws) expect(() => build(c.input), c.name).toThrow(RangeError);
    else expect(build(c.input), c.name).toEqual(c.expect);
  }
});

test('section layout', () => {
  const leaf = { kind: 'leaf', fill: fillField } as const;
  const { leaves, dividers } = layoutSection(
    { kind: 'split', axis: 'horizontal', parts: [{ section: leaf, end: 40, divider: 2 }, { section: leaf }] },
    { left: 0, top: 0, right: 100, bottom: 10 },
  );
  expect(leaves.map(([, r]) => r)).toEqual([
    { left: 0, top: 0, right: 40, bottom: 10 },
    { left: 40, top: 0, right: 100, bottom: 10 },
  ]);
  expect(dividers).toEqual([{ left: 39, top: 0, right: 41, bottom: 10 }]);
});

test('digits are ASCII only', () => {
  expect(isDigits('0129')).toBe(true);
  expect(isDigits('٣')).toBe(false);
  expect(isDigits('')).toBe(false);
  expect(isDigitsOfLength('12', 2)).toBe(true);
  expect(isDigitsOfLength('12', 3)).toBe(false);
});

test('restriction error', () => {
  const e = new PlateRestrictionException(new PlateRestriction('g', ['09'], 'no 09'));
  expect([e.name, e.message, e instanceof Error]).toEqual(['PlateRestrictionError', 'no 09', true]);
});

test('theme equality and lerp', () => {
  const a = PlateTheme.standard();
  expect(a.equals(a.copyWith({}))).toBe(true);
  expect(a.equals(a.copyWith({ ink: 1 }))).toBe(false);
  const b = a.copyWith({ plateBackground: 0xff000000, borderWidthRatio: 0.08 });
  expect(PlateTheme.lerp(a, b, 0).equals(a)).toBe(true);
  expect(PlateTheme.lerp(a, b, 1).equals(b)).toBe(true);
  expect(PlateTheme.lerp(a, b, 0.5).plateBackground).toBe(0xff808080);
  expect(a.glyphStyle(100, 0).fontSize).toBeCloseTo(72);
});

test('specProblems', () => {
  const slots = plateRegister({ alphabet: latinDigits, count: 3, left: 0, top: 0, width: 10, height: 10 });
  const mk = (s: PlateSlot[]) => new PlateSpec({ id: 't', country: undefined as any, canvasWidth: 30, canvasHeight: 10, slots: s });
  expect(specProblems(mk(slots))).toEqual([]);
  expect(specProblems(mk([...slots, new PlateSlot({ alphabet: latinDigits, box: new PlateBox(25, 0, 10, 10) })]))).toEqual([
    'PlateSlot 3 in spec "t" has a rect outside the canvas (30.0x10.0).',
  ]);
});
