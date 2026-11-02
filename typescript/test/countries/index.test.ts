import { readdirSync, readFileSync } from 'node:fs';
import { resolve } from 'node:path';
import { expect, it } from 'vitest';
import { countries } from '../../src/countries/index';

const dir = resolve(import.meta.dirname, '../../src/countries');
const index = JSON.parse(readFileSync(resolve(dir, '../../../data/index.json'), 'utf8')).packages;

it('every country module loads all its specs', async () => {
  for (const [id, load] of Object.entries(countries)) {
    const c = await load();
    expect([...c.specs.keys()], id).toEqual(index[c.package].specs);
  }
}, 60_000);

it('no country module imports another country (W7)', () => {
  for (const c of readdirSync(dir, { withFileTypes: true }).filter((e) => e.isDirectory()))
    for (const f of readdirSync(resolve(dir, c.name))) {
      const imports = [...readFileSync(resolve(dir, c.name, f), 'utf8').matchAll(/from '([^']+)'/g)].map((m) => m[1]);
      expect(imports.filter((p) => !/^(\.\/|\.\.\/load$|\.\.\/\.\.\/core\/)/.test(p)), `${c.name}/${f}`).toEqual([]);
    }
});
