// web_check: both browser builds exist, and neither carries a node API or a country.
import { existsSync, readdirSync, readFileSync, statSync } from 'node:fs';
import { join } from 'node:path';

const dist = join(import.meta.dirname, '..', 'build', 'dist');
let failed = false;
for (const target of ['js', 'wasmJs']) {
  const dir = join(dist, target, 'productionExecutable');
  if (!existsSync(dir)) { console.error(`missing ${dir}`); process.exit(1); }
  const files = readdirSync(dir).filter((f) => f.endsWith('.js') || f.endsWith('.wasm'));
  const text = files.map((f) => readFileSync(join(dir, f), 'latin1')).join('\n');
  // The wasm loader glue feature-detects node itself, so only the countries are checked there.
  const banned = target === 'js' ? ['node:', 'readFileSync'] : [];
  const bad = [...banned, 'albania', 'germany'].filter((s) => text.includes(s));
  if (bad.length) { console.error(`${target} bundle contains: ${bad.join(', ')}`); failed = true; }
  const kib = files.reduce((n, f) => n + statSync(join(dir, f)).size, 0) / 1024;
  console.log(`${target} ok · ${kib.toFixed(1)} KiB`);
}
process.exit(failed ? 1 : 0);
