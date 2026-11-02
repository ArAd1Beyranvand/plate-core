// Runs ports/vectors against a hand-ported [D4-code] unit; the generated unit tests call these.
import { expect, it } from 'vitest';
import { PlateTheme } from '../../src/core/theme/plate_theme';
import { PlateEntry } from '../../src/core/validators/plate_validator';
import { type LoadedCountry, loadCountry } from '../../src/countries/load';
import { countryData } from '../core/specs';
import { loadVectors } from '../vectors';

const loaded = new Map<string, LoadedCountry>();
const specOf = (pkg: string, id: string) => {
  if (!loaded.has(pkg)) loaded.set(pkg, loadCountry(countryData(pkg)));
  return loaded.get(pkg)!.specs.get(id)!;
};

/** Every case that fails, as `name: got … want …`; the first few are reported. */
function check(cases: { name: string; expect: unknown }[], run: (c: any) => unknown) {
  const bad: string[] = [];
  for (const c of cases) {
    let got: unknown;
    try {
      got = run(c);
    } catch (e) {
      got = { throws: (e as Error).message };
    }
    if (JSON.stringify(got) !== JSON.stringify(c.expect)) bad.push(`${c.name}: got ${JSON.stringify(got)} want ${JSON.stringify(c.expect)}`);
  }
  expect(bad.slice(0, 5), `${bad.length} of ${cases.length} cases fail`).toEqual([]);
}

export function validatorVectors(unit: Record<string, any>, classes: string[]) {
  for (const cls of classes)
    it(cls, () => {
      const cases = loadVectors(`validators/${cls}.json`).filter((c) => c.input.validator.class === cls);
      check(cases, ({ input: i }) => {
        const v = i.validator.args ? new unit[cls](i.validator.args) : new unit[cls]();
        const reason = v.validate(new PlateEntry(specOf(i.package, i.spec), i.values)).reason;
        return { valid: reason === null, reason };
      });
    });
}

export function resolverVectors(unit: Record<string, any>, names: string[]) {
  for (const name of names)
    it(name, () => {
      const [owner, member] = name.split('.');
      check(loadVectors(`resolvers/${name}.json`), ({ input: i }) => {
        const group = (k: string) => i.groups[k] ?? '';
        if (!i.base) return unit[owner][member](group);
        const t = unit[owner][member](new PlateTheme(i.base), group);
        return Object.fromEntries(Object.keys(i.base).map((k) => [k, t[k]]));
      });
    });
}
