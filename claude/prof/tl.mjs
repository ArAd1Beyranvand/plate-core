import { chromium } from '/home/aradbeyranvand/.npm/_npx/e41f203b7505f1fb/node_modules/playwright/index.mjs';
const b = await chromium.launch({ executablePath: '/opt/google/chrome/chrome', args: ['--enable-gpu', '--ignore-gpu-blocklist'] });
const p = await b.newPage({ viewport: { width: 1400, height: 900 } });
await p.goto(process.argv[2]); await p.waitForTimeout(6000);
await p.evaluate(() => { globalThis.__tl = []; globalThis.__tn = 0; });
for (let i = 0; i < 20; i++) { await p.mouse.move(700, 500); await p.mouse.wheel(0, 300); await p.waitForTimeout(100); }
await p.waitForTimeout(500);
const r = await p.evaluate(() => [globalThis.__tn, globalThis.__tl]);
console.log('layouts', r[0], 'slow(>0.5ms)', r[1].length, 'slow total ms', r[1].reduce((a, x) => a + x[0], 0).toFixed(0));
const agg = new Map(); for (const [d, t, f] of r[1]) { const k = f; const a = agg.get(k) ?? [0, 0, new Set()]; a[0] += d; a[1]++; if (a[2].size < 6) a[2].add(t); agg.set(k, a); }
[...agg.entries()].sort((a, b) => b[1][0] - a[1][0]).slice(0, 15).forEach(([k, [d, n, ts]]) => console.log(d.toFixed(0).padStart(6), String(n).padStart(4), k, JSON.stringify([...ts])));
r[1].sort((a, b) => b[0] - a[0]).slice(0, 10).forEach((x) => console.log(x[0].toFixed(1), JSON.stringify(x[1]), x[2]));
await b.close();
