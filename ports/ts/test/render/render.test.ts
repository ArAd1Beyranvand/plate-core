import { readdirSync, readFileSync } from 'node:fs';
import { resolve } from 'node:path';
import { describe, it } from 'vitest';
import { PlateController } from '../../src/core/input/plate_controller';
import { PlateTheme } from '../../src/core/theme/plate_theme';
import { PlateRestriction } from '../../src/core/values/plate_restriction';
import type { DisplayOp } from '../../src/render/display_list';
import { renderPlate } from '../../src/render/plate_canvas';
import { countryOf, specOf } from '../core/specs';

const dir = resolve(import.meta.dirname, '../../../vectors/render');
const data = (pkg: string) => JSON.parse(readFileSync(resolve(import.meta.dirname, `../../../data/countries/${pkg}.json`), 'utf8'));
const tol = 0.01;

/** The code is shared by a package's variants: the gallery entry names the one shown. */
function galleryCountry(i: any) {
  const d = data(i.package);
  const ref = d.gallery.find((g: any) => g.id === i.gallery)?.country;
  return ref ? countryOf(d.countries[ref]) : specOf(i.package, i.spec).countries.get(i.country);
}

type Op = Record<string, any>;

/**
 * The bounding box of a `<rule>:<d>` path in its own units. Vectors sample a path every
 * 0.25 along its length, so a sharp corner may be cut by up to half a step.
 */
function pathBox(path: string): number[] {
  const n = path.slice(path.indexOf(':') + 1).match(/-?\d+(\.\d+)?(e-?\d+)?/g)?.map(Number) ?? [];
  const xs = n.filter((_, i) => i % 2 === 0), ys = n.filter((_, i) => i % 2 === 1);
  return xs.length ? [Math.min(...xs), Math.min(...ys), Math.max(...xs), Math.max(...ys)] : [];
}

const near = (a: unknown, b: unknown, t: number): boolean => {
  if (typeof a === 'number' && typeof b === 'number') return Math.abs(a - b) <= t;
  if (Array.isArray(a) && Array.isArray(b)) return a.length === b.length && a.every((x, i) => near(x, b[i], t));
  if (a && b && typeof a === 'object' && typeof b === 'object') {
    const keys = new Set([...Object.keys(a), ...Object.keys(b)]);
    return [...keys].every((k) => near((a as any)[k], (b as any)[k], t));
  }
  return a === b;
};

const channelsNear = (x: number, y: number) => [24, 16, 8, 0].every((s) => Math.abs(((x >>> s) & 255) - ((y >>> s) & 255)) <= 1);

const textKeys = ['text', 'align', 'direction', 'fontSize', 'height', 'color', 'fontFamily', 'fontWeight', 'letterSpacing'];
const identity = [1, 0, 0, 1, 0, 0];

/** The first difference between two display lists, save/restore aside; null when they match. */
function diff(got: Op[], want: Op[]): string | null {
  const g = got.filter((o) => o.op !== 'save' && o.op !== 'restore');
  const w = want.filter((o) => o.op !== 'save' && o.op !== 'restore');
  for (let i = 0; i < Math.max(g.length, w.length); i++) {
    const a = g[i], b = w[i];
    const at = `op ${i}: got ${JSON.stringify(a)?.slice(0, 300)}\n want ${JSON.stringify(b)?.slice(0, 300)}`;
    if (!a || !b || a.op !== b.op) return at;
    if (a.op === 'text') {
      if (!textKeys.every((k) => near(a[k], b[k], tol))) return at;
      continue;
    }
    if (a.op === 'path' || a.op === 'clipPath') {
      if (a.path.split(':')[0] !== b.path.split(':')[0] || !near(a.m ?? identity, b.m ?? identity, tol) || !near(pathBox(a.path), pathBox(b.path), 0.15) || !near(a.paint, b.paint, 0)) return at;
      continue;
    }
    // The fog's gradient is recorded as a flag only.
    const { m: am = identity, ...ra } = a.paint?.shader ? { ...a, paint: { ...a.paint, shader: true } } : a;
    const { m: bm = identity, ...rb } = b;
    // The completed border's tint rounds per channel through doubles: allow one step.
    if (a.op === 'drrect' && channelsNear(ra.paint.color, rb.paint.color)) ra.paint = rb.paint;
    if (!near(am, bm, tol) || !near(ra, rb, tol)) return at;
  }
  return null;
}

for (const file of readdirSync(dir).filter((f) => f.endsWith('.json'))) {
  const { cases } = JSON.parse(readFileSync(resolve(dir, file), 'utf8'));
  describe(`render ${file}`, () => {
    for (const c of cases) {
      const i = c.input;
      const loaded = specOf(i.package, i.spec);
      it.skipIf(loaded.codeRender)(c.name, () => {
        const { spec } = loaded;
        // Values reach the plate through a controller, which drops what a slot refuses.
        const controller = new PlateController({ spec, values: i.values });
        const values = controller.values;
        const restriction = spec.restrictionViolatedBy(values);
        const ops = renderPlate({
          spec,
          values,
          isCompleted: controller.isCompleted,
          theme: i.theme ? new PlateTheme(i.theme) : undefined,
          country: i.country ? galleryCountry(i) : undefined,
          // The Flutter test surface is 800x600; a wider plate is laid out squeezed into it.
          size: [Math.min(i.size[0], 800), Math.min(i.size[1], 600)],
          rejection: restriction ? new PlateRestriction(restriction.group, [], (restriction as PlateRestriction).reason) : null,
        });
        const d = diff(ops as DisplayOp[] as Op[], c.expect);
        if (d) throw new Error(d);
      });
    }
  });
}
