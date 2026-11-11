import { chromium } from '/home/aradbeyranvand/.npm/_npx/e41f203b7505f1fb/node_modules/playwright/index.mjs';
const url = process.argv[2] ?? 'http://127.0.0.1:8765/plates/asia';
const b = await chromium.launch({ executablePath: '/opt/google/chrome/chrome', args: ['--enable-gpu', '--ignore-gpu-blocklist', '--use-angle=vulkan', '--enable-features=Vulkan'] });
const p = await b.newPage({ viewport: { width: 1400, height: 900 } });
p.on('console', (m) => { if (m.type() === 'error') console.log('console:', m.text()); });
const cdp = await p.context().newCDPSession(p);
await p.goto(url);
await p.waitForTimeout(+(process.env.W ?? 10000));
// frame stats while idle, then while scrolling
const frames = (ms) => p.evaluate((ms) => new Promise((res) => {
  const t = []; let last = performance.now(); const end = last + ms;
  const f = (n) => { t.push(n - last); last = n; n < end ? requestAnimationFrame(f) : res(t); };
  requestAnimationFrame(f);
}), ms);
const stats = (n, t) => { t.sort((a, b) => a - b); const q = (x) => t[Math.floor(t.length * x)]?.toFixed(1);
  console.log(n, 'frames', t.length, 'p50', q(.5), 'p90', q(.9), 'max', t.at(-1)?.toFixed(0), '>50ms', t.filter((x) => x > 50).length); };
stats('idle', await frames(2000));
await cdp.send('Profiler.enable'); await cdp.send('Profiler.setSamplingInterval', { interval: 200 }); await cdp.send('Profiler.start');
const f = frames(4000);
for (let i = 0; i < 20; i++) { await p.mouse.move(700, 500); await p.mouse.wheel(0, 300); await p.waitForTimeout(100); }
stats('scroll', await f);
const { profile } = await cdp.send('Profiler.stop');
const self = new Map(); const dt = profile.timeDeltas; const byId = new Map(profile.nodes.map((n) => [n.id, n]));
profile.samples.forEach((id, i) => { const n = byId.get(id); const k = `${n.callFrame.functionName || '(anon)'} ${n.callFrame.url.split('/').pop()}:${n.callFrame.lineNumber}`; self.set(k, (self.get(k) ?? 0) + (dt[i] ?? 0)); });
const tot = [...self.values()].reduce((a, b) => a + b, 0);
console.log('total sampled ms', (tot / 1000).toFixed(0));
[...self.entries()].sort((a, b) => b[1] - a[1]).slice(0, 25).forEach(([k, v]) => console.log((v / 1000).toFixed(0).padStart(6), k));
const parent = new Map(); profile.nodes.forEach((n) => (n.children ?? []).forEach((c) => parent.set(c, n.id)));
const incl = new Map();
profile.samples.forEach((id, i) => { const seen = new Set(); for (let x = id; x; x = parent.get(x)) { const n = byId.get(x); const k = `${n.callFrame.functionName || '(anon)'} ${n.callFrame.url.split('/').pop()}:${n.callFrame.lineNumber}`; if (seen.has(k)) continue; seen.add(k); incl.set(k, (incl.get(k) ?? 0) + (dt[i] ?? 0)); } });
console.log('--- inclusive');
[...incl.entries()].sort((a, b) => b[1] - a[1]).slice(0, process.env.N ? +process.env.N : 70).forEach(([k, v]) => console.log((v / 1000).toFixed(0).padStart(6), k));
await b.close();
