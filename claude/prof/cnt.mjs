import { chromium } from '/home/aradbeyranvand/.npm/_npx/e41f203b7505f1fb/node_modules/playwright/index.mjs';
const b = await chromium.launch({ executablePath: '/opt/google/chrome/chrome', args: ['--enable-gpu', '--ignore-gpu-blocklist'] });
const p = await b.newPage({ viewport: { width: 1400, height: 900 } });
await p.goto(process.argv[2]); await p.waitForTimeout(8000);
const before = await p.evaluate(() => [globalThis.__hdr, globalThis.__tn]);
await p.evaluate(() => { globalThis.__hdr = 0; globalThis.__tn = 0; });
for (let i = 0; i < 30; i++) { await p.mouse.move(700, 500); await p.mouse.wheel(0, 300); await p.waitForTimeout(100); }
await p.waitForTimeout(1500);
console.log('load: header relayouts', before[0], '| scroll: header relayouts', await p.evaluate(() => globalThis.__hdr), 'text layouts', await p.evaluate(() => globalThis.__tn));
await b.close();
