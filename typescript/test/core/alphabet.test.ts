import { readFileSync } from 'node:fs';
import { resolve } from 'node:path';
import { describe, expect, test } from 'vitest';
import { PlateAlphabet } from '../../src/core/alphabet/plate_alphabet';
import { resolveSlotBehavior } from '../../src/core/input/slot_behavior';
import { PlateBox } from '../../src/core/values/plate_box';
import { PlateSlot } from '../../src/core/values/plate_spec';
import { layoutSection } from '../../src/core/layout/section_layout';
import { fillColor, fillField, type PlateSection } from '../../src/core/values/plate_spec';
import { loadVectors } from '../vectors';
import { alphabetOf } from './specs';

describe('alphabet vectors', () => {
  for (const c of loadVectors('core/alphabet.json')) {
    test(c.name, () => {
      if ('include' in c.input) {
        const a = PlateAlphabet.pattern({ id: 'p', include: c.input.include, exclude: c.input.exclude, input: 'typed', isNumeric: false });
        expect(a.characters).toEqual(c.expect.characters);
        return;
      }
      const a = alphabetOf(c.input.alphabet);
      const v: string = c.input.value;
      expect({
        accepts: a.accepts(v),
        canonical: a.canonical(v),
        render: a.render(v),
        renderAll: a.renderAll(v),
        canonicalAll: a.canonicalAll(v),
      }).toEqual(c.expect);
    });
  }
});

describe('slot vectors', () => {
  for (const c of loadVectors('core/values.json').filter((c) => c.name.startsWith('slot '))) {
    test(c.name, () => {
      const { alphabet, length, minLength } = c.input.slot;
      const s = new PlateSlot({ alphabet: alphabetOf(alphabet), box: new PlateBox(0, 0, 1, 1), length, minLength });
      const v: string | null = c.input.value;
      const e = c.expect;
      expect(s.isFull(v)).toBe(e.isFull);
      expect(s.isComplete(v)).toBe(e.isComplete);
      if (v !== null) {
        expect({ accepts: s.accepts(v), canonical: s.canonical(v), render: s.render(v) }).toEqual({
          accepts: e.accepts,
          canonical: e.canonical,
          render: e.render,
        });
      }
    });
  }
});

describe('slot behavior vectors', () => {
  for (const c of loadVectors('core/input.json').filter((c) => c.name.startsWith('behavior '))) {
    test(c.name, () => expect(resolveSlotBehavior(c.input)).toBe(c.expect));
  }
});

test('layoutSection', () => {
  const leaf = (n: number): PlateSection => ({ kind: 'leaf', fill: fillColor(n) });
  const root: PlateSection = {
    kind: 'split',
    axis: 'horizontal',
    parts: [{ section: leaf(1), end: 10, divider: 2 }, { section: { kind: 'leaf', fill: fillField } }],
  };
  const r = layoutSection(root, { left: 0, top: 0, right: 30, bottom: 5 });
  expect(r.leaves.map(([, rect]) => rect)).toEqual([
    { left: 0, top: 0, right: 10, bottom: 5 },
    { left: 10, top: 0, right: 30, bottom: 5 },
  ]);
  expect(r.dividers).toEqual([{ left: 9, top: 0, right: 11, bottom: 5 }]);
});
