// Usage: node shot.mjs <url> <out.png> [waitMs] [js-to-eval-before-shot]  — real-time headless Chrome screenshot via CDP.
import { spawn } from 'node:child_process';
import { writeFileSync } from 'node:fs';
import { createRequire } from 'node:module';
const require = createRequire(new URL('../../ports/ts/package.json', import.meta.url));
const WebSocket = require('ws');
const [url, out, wait = '15000', script = ''] = process.argv.slice(2);
const port = 9333 + Math.floor(Math.random() * 500);
const chrome = spawn('google-chrome', ['--headless=new', '--no-sandbox', '--disable-gpu', `--remote-debugging-port=${port}`, '--window-size=900,600', '--user-data-dir=/tmp/shot-' + port, 'about:blank'], { stdio: 'ignore' });
const sleep = (ms) => new Promise((r) => setTimeout(r, ms));
let targets;
for (let i = 0; i < 50; i++) { try { targets = await (await fetch(`http://127.0.0.1:${port}/json`)).json(); break; } catch { await sleep(200); } }
const ws = new WebSocket(targets.find((t) => t.type === 'page').webSocketDebuggerUrl);
await new Promise((r) => ws.on('open', r));
let id = 0; const pending = new Map();
ws.on('message', (m) => { const d = JSON.parse(m); pending.get(d.id)?.(d.result); });
const send = (method, params = {}) => new Promise((r) => { pending.set(++id, r); ws.send(JSON.stringify({ id, method, params })); });
await send('Page.navigate', { url });
await sleep(Number(wait));
if (script) console.log(JSON.stringify((await send('Runtime.evaluate', { expression: script, awaitPromise: true, returnByValue: true })).result?.value));
await sleep(1500);
writeFileSync(out, Buffer.from((await send('Page.captureScreenshot', { format: 'png' })).data, 'base64'));
ws.close(); chrome.kill();
