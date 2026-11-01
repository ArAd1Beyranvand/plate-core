// web_check: the web entry builds, and the bundle carries no node API and no country.
import { readdirSync, readFileSync } from 'node:fs';
import { join } from 'node:path';

const dist = join(import.meta.dirname, 'dist', 'assets');
const js = readdirSync(dist).filter((f) => f.endsWith('.js')).map((f) => readFileSync(join(dist, f), 'utf8')).join('\n');
const bad = ['node:', 'readFileSync', 'albania', 'germany'].filter((s) => js.includes(s));
if (bad.length) { console.error(`web bundle contains: ${bad.join(', ')}`); process.exit(1); }
console.log(`web ok · ${(js.length / 1024).toFixed(1)} KiB js`);
