import { readFileSync } from 'node:fs';
import { resolve } from 'node:path';
import { type PlateAlphabet } from '../../src/core/alphabet/plate_alphabet';
import { type PlateCountry } from '../../src/core/values/plate_country';
import { type PlateSpec } from '../../src/core/values/plate_spec';
import { alphabetOf as alphabetFrom, type CountryData, type LoadedCountry, loadCountry } from '../../src/countries/load';

export { countryOf } from '../../src/countries/load';

const data = resolve(import.meta.dirname, '../../../data');
const alphabets = JSON.parse(readFileSync(resolve(data, 'alphabets.json'), 'utf8')).alphabets;

export const alphabetOf = (ref: string): PlateAlphabet => alphabetFrom(alphabets[ref]);

/** `ports/data/countries/<pkg>.json` with its alphabets inlined, as the generated `data.ts` holds it. */
export function countryData(pkg: string): CountryData {
  const d = JSON.parse(readFileSync(resolve(data, 'countries', `${pkg}.json`), 'utf8'));
  return { ...d, alphabets: Object.fromEntries(d.alphabets.map((ref: string) => [ref, alphabets[ref]])) };
}

export interface LoadedSpec {
  spec: PlateSpec<any>;
  /** The spec's region resolver is code the core port cannot run. */
  codeRegion: boolean;
  /** A label or theme resolver is code: the render port cannot paint the spec as Dart does. */
  codeRender: boolean;
  /** The package's countries by code. */
  countries: ReadonlyMap<string, PlateCountry>;
}

const cache = new Map<string, LoadedCountry>();

/** A spec from ports/data with table resolvers only. */
export function specOf(pkg: string, id: string): LoadedSpec {
  let c = cache.get(pkg);
  if (!c) cache.set(pkg, (c = loadCountry(countryData(pkg))));
  const s = c.data.specs.find((x) => x.id === id);
  const isCode = (r: string | null) => r !== null && c.data.resolvers[r].kind !== 'table';
  return {
    spec: c.specs.get(id)!,
    codeRegion: isCode(s.resolveRegion),
    codeRender: [s.resolveTheme, ...s.labels.map((l: any) => l.resolve)].some(isCode),
    countries: new Map([...c.countries.values()].map((x) => [x.code, x])),
  };
}
