import { chromium } from '/home/aradbeyranvand/.npm/_npx/e41f203b7505f1fb/node_modules/playwright/index.mjs';
const b = await chromium.launch({ executablePath: '/opt/google/chrome/chrome', args: ['--enable-gpu', '--ignore-gpu-blocklist'] });
const p = await b.newPage({ viewport: { width: 1400, height: 900 } });
await p.goto(process.argv[2].split("#")[0]); await p.waitForTimeout(5000); await p.evaluate(() => { location.hash = "#/plates/asia"; }); await p.waitForTimeout(2000);
const frames = (ms) => p.evaluate((ms) => new Promise((res) => { const t = []; let last = performance.now(); const end = last + ms;
  const f = (n) => { t.push(n - last); last = n; n < end ? requestAnimationFrame(f) : res(t); }; requestAnimationFrame(f); }), ms);
const stats = (n, t) => { t.sort((a, b) => a - b); const q = (x) => t[Math.floor(t.length * x)]?.toFixed(1);
  console.log(n, 'frames', t.length, 'p50', q(.5), 'p90', q(.9), 'max', t.at(-1)?.toFixed(0), '>50ms', t.filter((x) => x > 50).length); };
for (const pass of ['first', 'second']) {
  const f = frames(4000);
  for (let i = 0; i < 20; i++) { await p.mouse.move(700, 500); await p.mouse.wheel(0, 300); await p.waitForTimeout(100); }
  stats(pass, await f);
  await p.mouse.wheel(0, -100000); await p.waitForTimeout(3000);
}
await b.close();
