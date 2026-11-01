import type { PlateAlphabet } from '../alphabet/plate_alphabet';
import { PlateBox } from '../values/plate_box';
import type { Color } from '../values/plate_shape';
import { PlateSlot, type PlateMirror, type PlateRule } from '../values/plate_spec';

const checkCount = (count: number, caller: string): void => {
  if (count < 0) throw new RangeError(`${caller} needs count >= 0`);
};

const range = (n: number): number[] => Array.from({ length: n }, (_, i) => i);

/** `count` equal cells from `left`, stepping by `pitch` (default `width`: flush). */
export function plateRegister(o: {
  alphabet: PlateAlphabet;
  count: number;
  left: number;
  top: number;
  width: number;
  height: number;
  pitch?: number;
  color?: Color;
}): PlateSlot[] {
  checkCount(o.count, 'plateRegister');
  const step = o.pitch ?? o.width;
  return range(o.count).map(
    (i) => new PlateSlot({ alphabet: o.alphabet, box: new PlateBox(o.left + i * step, o.top, o.width, o.height), color: o.color }),
  );
}

/** `count` flush cells filling [left, right) exactly. */
export function plateRegisterAcross(o: {
  alphabet: PlateAlphabet;
  count: number;
  left: number;
  right: number;
  top: number;
  height: number;
  color?: Color;
}): PlateSlot[] {
  checkCount(o.count, 'plateRegisterAcross');
  return plateRegister({ ...o, width: o.count === 0 ? 0 : (o.right - o.left) / o.count });
}

/** One mirror per entry of `sources`, laid out as a register. */
export function plateEcho(o: {
  sources: Iterable<number>;
  left: number;
  top: number;
  width: number;
  height: number;
  pitch?: number;
  glyphHeight?: number;
  alphabet?: PlateAlphabet;
  editable?: boolean;
}): PlateMirror[] {
  const step = o.pitch ?? o.width;
  return Array.from(o.sources, (source, i) => ({
    source,
    box: new PlateBox(o.left + i * step, o.top, o.width, o.height),
    glyphHeight: o.glyphHeight ?? o.height,
    alphabet: o.alphabet,
    editable: o.editable ?? false,
  }));
}

/** `count` identical rules stepping by `stepX` across and `stepY` down. */
export function plateStipple(o: {
  count: number;
  left: number;
  top: number;
  width: number;
  height: number;
  stepX?: number;
  stepY?: number;
}): PlateRule[] {
  checkCount(o.count, 'plateStipple');
  return range(o.count).map((i) => ({
    box: new PlateBox(o.left + i * (o.stepX ?? 0), o.top + i * (o.stepY ?? 0), o.width, o.height),
  }));
}
