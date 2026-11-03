import { expect, it } from 'vitest';
import { expandCountry } from '../../src/countries/expand';
import { tableResolver } from '../../src/countries/load';

const country = (specs: unknown[], extra: Record<string, unknown> = {}) =>
  expandCountry({ package: 'x_plate', alphabets: { d: ['d', [['0', '9']], 'typed', true] }, countries: {}, themes: {}, resolvers: {}, assets: [], gallery: [], specs, ...extra });

it('a spec takes the defaults of everything its tuple leaves off', () => {
  const [s] = country([['x.a', 'C', 100, 50, [['d', [1, 2, 3, 4]], ['d', [5, 6, 7, 8], 3, 1]]]]).specs;
  expect(s.slots[0]).toMatchObject({ alphabet: 'd', box: [1, 2, 3, 4], length: 1, minLength: 1, spacing: 0, color: null });
  expect(s.slots[1]).toMatchObject({ length: 3, minLength: 1 });
  expect(s).toMatchObject({ labels: [], bands: [], textDirection: 'ltr', noPanel: true, panel: null, resolveRegion: null });
  expect(s.background).toEqual({ kind: 'fill', fill: { kind: 'field' }, shape: null });
});

it('slot keys are the text groups; a spec with none has none', () => {
  const [keyed, bare] = country([['k', 'C', 1, 1, [['d', [0, 0, 1, 1], 1, 1, 0, null, 'serial'], ['d', [1, 0, 1, 1], 1, 1, 0, null, 'tail']]], ['b', 'C', 1, 1, [['d', [0, 0, 1, 1]]]]]).specs;
  expect(keyed.textGroups).toEqual([{ indices: [0], prefix: '', key: 'serial' }, { indices: [1], prefix: '', key: 'tail' }]);
  expect(keyed.slots.every((x: any) => !('group' in x))).toBe(true);
  expect(bare.textGroups).toEqual([]);
});

it('alphabets expand their ranges and defaults', () => {
  const { alphabets } = country([], { alphabets: { l: ['l', [['A', 'C'], 'Ä', ['X', 'Z']]] } });
  expect(alphabets.l).toEqual({ id: 'l', characters: ['A', 'B', 'C', 'Ä', 'X', 'Y', 'Z'], input: 'typed', isNumeric: false, glyphs: [], direction: 'ltr', placeholder: '?' });
});

it('a theme tuple is one ink on one field', () => {
  const { themes } = country([], { themes: { t: [0xff112233, 0xff000000, 0.02, 0.05] } });
  expect(themes.t).toMatchObject({ plateBackground: 0xff112233, plateBorder: 0xff000000, ink: 0xff000000, dividerColor: 0xff000000, activeColor: 0xff000000, inactiveColor: 0xffb0b0b0, alertColor: 0xfff87171 });
});

it('a trie table answers as the rows it replaced, including its default', () => {
  const enc = { trie: { prefix: [['A', 'north'], ['B', 'south']], exact: [['AX', 'special'], ['', null]] } };
  const r = tableResolver<string | null>({ reads: ['k'], cut: {}, default: 'elsewhere', enc });
  const at = (k: string) => r(() => k);
  expect([at('AB'), at('AX'), at('BZ'), at('C'), at('')]).toEqual(['north', 'special', 'south', 'elsewhere', null]);
});

it('a grouped table lists each value once beside its keys', () => {
  const enc = { groups: [['one', [['a'], ['b']]], [null, [['c']]]] };
  const r = tableResolver<string | null>({ reads: ['k'], cut: {}, default: 'none', enc });
  expect(['a', 'b', 'c', 'd'].map((k) => r(() => k))).toEqual(['one', 'one', null, 'none']);
});
