import { readdirSync, readFileSync } from 'node:fs';
import { resolve } from 'node:path';
import { expect, test } from 'vitest';
import { EuropeanStars } from '../../src/core/values/european_stars';
import type { PlateGraphic } from '../../src/core/values/plate_asset';
import { PlateBox } from '../../src/core/values/plate_box';

test('PlateBox', () => {
  const box = new PlateBox(1, 2, 3, 4);
  expect([box.right, box.bottom]).toEqual([4, 6]);
  expect(box.rect).toEqual({ left: 1, top: 2, right: 4, bottom: 6 });
});

const dir = resolve(import.meta.dirname, '../../../data/countries');

function graphics(node: any, out: PlateGraphic[] = []): PlateGraphic[] {
  if (Array.isArray(node)) node.forEach((n) => graphics(n, out));
  else if (node && typeof node === 'object') {
    if (['drawing', 'svg', 'raster'].includes(node.kind) && (node.shapes || node.path)) out.push(node);
    Object.values(node).forEach((n) => graphics(n, out));
  }
  return out;
}

test('exported graphics fit the value types', () => {
  const kinds = new Set(['rect', 'polygon', 'circle', 'ring', 'crescent', 'star', 'starRing']);
  let seen = 0;
  for (const f of readdirSync(dir)) {
    for (const g of graphics(JSON.parse(readFileSync(resolve(dir, f), 'utf8')))) {
      seen++;
      if (g.kind === 'drawing') g.shapes.forEach((s) => expect(kinds.has(s.kind)).toBe(true));
      else expect(typeof g.package).toBe('string');
    }
  }
  expect(seen).toBeGreaterThan(0);
});

test('EuropeanStars matches the exported EU flag', () => {
  const flags = readdirSync(dir).flatMap((f) =>
    graphics(JSON.parse(readFileSync(resolve(dir, f), 'utf8'))).filter((g) => g.kind === 'drawing'),
  );
  expect(flags).toContainEqual(EuropeanStars.flag);
});
