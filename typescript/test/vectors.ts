import { readFileSync } from 'node:fs';
import { resolve } from 'node:path';

export interface VectorCase<I = any, E = any> {
  name: string;
  input: I;
  expect: E;
}

const root = resolve(import.meta.dirname, '../../vectors');

/** Loads `ports/vectors/<rel>` (e.g. `core/alphabet.json`) and returns its cases. */
export function loadVectors<I = any, E = any>(rel: string): VectorCase<I, E>[] {
  return JSON.parse(readFileSync(resolve(root, rel), 'utf8')).cases;
}
