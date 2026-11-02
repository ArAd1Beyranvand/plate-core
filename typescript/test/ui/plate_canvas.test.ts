import { describe, expect, it } from 'vitest';
import { PlateController } from '../../src/core/input/plate_controller';
import { PlateCanvas } from '../../src/ui/plate_canvas';
import { specOf } from '../core/specs';

const texts = (c: PlateCanvas) => c.displayList().flatMap((o) => (o.op === 'text' ? [o.text] : []));

describe('PlateCanvas headless', () => {
  const { spec } = specOf('germany_plate', 'de.car');

  it('constructs, takes values, reads them back, paints them', async () => {
    const seen: number[] = [];
    const c = new PlateCanvas({ spec, onRender: (ops) => seen.push(ops.length) });
    expect(c.values.every((v) => v === null)).toBe(true);
    expect(texts(c)).toEqual(['D']);

    c.setValues(['B', 'X', 'Y', '1', '2', null, null]);
    expect(c.values.slice(0, 5)).toEqual(['B', 'X', 'Y', '1', '2']);
    expect(texts(c)).toEqual(['D', 'B', 'X', 'Y', '1', '2']);
    await Promise.resolve();
    expect(seen.length).toBe(1);

    const svg = c.svg();
    expect(svg).toContain('viewBox="0 0 520 110"');
    expect(svg).toContain('>B</text>');
    c.dispose();
  });

  it('paints placeholders, hints and typed glyphs under native inputs in input mode', () => {
    const controller = new PlateController({ spec, values: ['B'] });
    const c = new PlateCanvas({ spec, controller, mode: 'input', inputSource: 'system' });
    expect(c.slotInputs().map((s) => s.index)).toEqual(spec.slots.map((_, i) => i));
    const placeholder = spec.slots[1].alphabet.placeholder;
    expect(texts(c).slice(0, 4)).toEqual(['D', placeholder, 'B', placeholder]);
    controller.hints.value = [null, 'X'];
    expect(texts(c)).toContain('X');
    c.dispose();
    controller.dispose();
  });

  it('adopts a host controller without disposing it', () => {
    const controller = new PlateController({ spec });
    const c = new PlateCanvas({ spec, controller });
    c.dispose();
    controller.setValues(['M']);
    expect(controller.values[0]).toBe('M');
  });
});
