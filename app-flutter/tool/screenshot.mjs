// 用 Edge 的 DevTools 协议按手机尺寸截图（Node 22+ 自带 WebSocket，无需依赖）
// 用法：node tool/screenshot.mjs <url> <out.png> [width] [height]
import { spawn } from 'node:child_process';
import { writeFileSync } from 'node:fs';

const [, , url, outPath, widthArg, heightArg, clickXArg, clickYArg] = process.argv;
if (!url || !outPath) {
  console.error('usage: node tool/screenshot.mjs <url> <out.png> [width] [height]');
  process.exit(2);
}
const width = Number(widthArg ?? 390);
const height = Number(heightArg ?? 844);
const edge = 'C:\\Program Files (x86)\\Microsoft\\Edge\\Application\\msedge.exe';
const port = 9333;
const profile = `${process.env.TEMP}\\edge-cdp-profile`;
const sleep = (ms) => new Promise((resolve) => setTimeout(resolve, ms));

const child = spawn(
  edge,
  [
    '--headless=new',
    '--disable-gpu',
    '--no-first-run',
    '--hide-scrollbars',
    `--remote-debugging-port=${port}`,
    `--user-data-dir=${profile}`,
    'about:blank',
  ],
  { stdio: 'ignore' },
);

async function findTarget() {
  for (let i = 0; i < 60; i += 1) {
    try {
      const list = await (await fetch(`http://127.0.0.1:${port}/json/list`)).json();
      const page = list.find((t) => t.type === 'page');
      if (page?.webSocketDebuggerUrl) return page;
    } catch {
      // devtools 端口还没起来，继续等
    }
    await sleep(300);
  }
  throw new Error('Edge DevTools 端口没有就绪');
}

const target = await findTarget();
const ws = new WebSocket(target.webSocketDebuggerUrl);
await new Promise((resolve, reject) => {
  ws.onopen = resolve;
  ws.onerror = (event) => reject(new Error(`WebSocket 连接失败: ${event?.message ?? ''}`));
});

let seq = 0;
const pending = new Map();
ws.onmessage = (event) => {
  const msg = JSON.parse(event.data);
  if (msg.id && pending.has(msg.id)) {
    pending.get(msg.id)(msg);
    pending.delete(msg.id);
  }
};
const send = (method, params = {}) =>
  new Promise((resolve) => {
    const id = ++seq;
    pending.set(id, resolve);
    ws.send(JSON.stringify({ id, method, params }));
  });

await send('Page.enable');
await send('Emulation.setDeviceMetricsOverride', {
  width,
  height,
  deviceScaleFactor: 2,
  mobile: true,
});
await send('Page.navigate', { url });
await sleep(9000);

// 可选：先点一下页面（逻辑坐标），用于截取切换后的页面
if (clickXArg && clickYArg) {
  const x = Number(clickXArg);
  const y = Number(clickYArg);
  for (const type of ['mousePressed', 'mouseReleased']) {
    await send('Input.dispatchMouseEvent', {
      type,
      x,
      y,
      button: 'left',
      clickCount: 1,
    });
    await sleep(120);
  }
  await sleep(1500);
}

const shot = await send('Page.captureScreenshot', { format: 'png' });
writeFileSync(outPath, Buffer.from(shot.result.data, 'base64'));
console.log(`saved ${outPath} (${width}x${height} @2x)`);

ws.close();
child.kill();
process.exit(0);
