import { describe, expect, it } from 'vitest';
import { PlateController } from '../../src/core/input/plate_controller';
import { PlateAnimationController, partId } from '../../src/core/timing/plate_animation';
import { PartClock } from '../../src/ui/part_clock';
import { plateSelector } from '../../src/ui/plate_selector';
import { plateText, plateViewSvg } from '../../src/ui/plate_view';
import { specOf } from '../core/specs';

const { spec } = specOf('germany_plate', 'de.car');

describe('ui helpers', () => {
  it('selector fires only on flips', () => {
    const c = new PlateController({ spec });
    const seen: boolean[] = [];
    const off = plateSelector(c, (x) => x.isEmpty, (v) => seen.push(v));
    c.setValues(['B']);
    c.setValues(['B', 'X']);
    c.setValues([]);
    expect(seen).toEqual([false, true]);
    off();
  });

  it('view renders read-only and formats text', () => {
    expect(plateText(['B', null, 'X', '1'])).toBe('BX1');
    expect(plateViewSvg({ spec, values: ['B', 'X'] })).toContain('>X</text>');
    expect(plateViewSvg({ spec, values: [], emptySvg: '' })).toBe('');
  });

  it('clock turns cues into frames over time', () => {
    let now = 0;
    const a = new PlateAnimationController();
    const clock = new PartClock(a, () => now);
    const id = partId('slot', 0);
    a.comeIn(id);
    expect(clock.frames()(id).progress).toBe(0);
    expect(clock.running).toBe(true);
    now = 10_000;
    expect(clock.frames()(id).progress).toBe(1);
    expect(clock.running).toBe(false);
  });
});
