import { expect, test } from 'vitest';
import { loadVectors } from './vectors';

test('alphabet vectors load', () => {
  const cases = loadVectors('core/alphabet.json');
  expect(cases.length).toBeGreaterThan(0);
  expect(cases[0]).toHaveProperty('expect');
});
