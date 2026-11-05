import { chromium } from '/home/aradbeyranvand/.npm/_npx/e41f203b7505f1fb/node_modules/playwright/index.mjs';
const b = await chromium.launch({ executablePath: '/opt/google/chrome/chrome', args: ['--enable-gpu', '--ignore-gpu-blocklist'] });
const p = await b.newPage({ viewport: { width: 1400, height: 900 } });
await p.goto(process.argv[2]); await p.waitForTimeout(+process.argv[4] || 6000);
await p.screenshot({ path: process.argv[3] }); await b.close();
