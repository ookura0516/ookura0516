// 1本の動画（声なし）を書き出す
//   node render.mjs <案> <V|H> [--cps 6.2] [--frames 0,30,60]  （--frames は確認用の静止画だけ）
// 出力: out/<案>_<V|H>.timeline.json と out/<案>_<V|H>_video.mp4（音なし）
import { createRequire } from 'node:module';
import { spawn } from 'node:child_process';
import { mkdirSync, writeFileSync } from 'node:fs';
import { fileURLToPath, pathToFileURL } from 'node:url';
import path from 'node:path';

const here = path.dirname(fileURLToPath(import.meta.url));
// Playwright は全体に入っているものを使う（ESM の import では見つからないため require で読む）。
// playwright が無ければ playwright-core（npm i playwright-core）でもよい
const req = createRequire(import.meta.url);
let pw = null;
for (const m of ['playwright', 'playwright-core']) { try { pw = req(m); break; } catch { /* 次を試す */ } }
if (!pw) { console.error('Playwright が見つかりません。promo_videos で npm i playwright-core を実行してください'); process.exit(1); }
const { chromium } = pw;
const [app, fmt] = process.argv.slice(2);
const opt = (k, d) => { const i = process.argv.indexOf(k); return i > 0 ? process.argv[i + 1] : d; };
const cps = Number(opt('--cps', '6.2'));
const frames = opt('--frames', null);
const outDir = path.join(here, 'out');
mkdirSync(outDir, { recursive: true });

const size = fmt === 'V' ? { width: 1080, height: 1920 } : { width: 1920, height: 1080 };
// Playwright の Chromium が無い Mac では、入っている Google Chrome を使う
let browser;
try { browser = await chromium.launch(); } catch { browser = await chromium.launch({ channel: 'chrome' }); }
const page = await browser.newPage({ viewport: size, deviceScaleFactor: 1 });
page.on('pageerror', e => { console.error('page error:', e.message); process.exitCode = 1; });
await page.goto(pathToFileURL(path.join(here, 'page.html')).href);
const tl = await page.evaluate(([a, f, c]) => window.setup(a, f, c), [app, fmt, cps]);
await page.evaluate(() => window.warmup());
const base = `${app}_${fmt}`;
writeFileSync(path.join(outDir, `${base}.timeline.json`), JSON.stringify(tl, null, 1));

const fps = tl.fps;
const total = Math.ceil(tl.duration * fps);

if (frames) {
  for (const f of frames.split(',').map(Number)) {
    await page.evaluate(async t => { window.renderAt(t); await document.fonts.ready; }, f / fps);
    await page.screenshot({ path: path.join(outDir, `${base}_f${String(f).padStart(5, '0')}.png`) });
  }
  console.log(`${base}: ${tl.duration}s, 静止画 ${frames}`);
  await browser.close();
  process.exit(process.exitCode || 0);
}

const ff = spawn('ffmpeg', ['-y', '-loglevel', 'error', '-f', 'image2pipe', '-framerate', String(fps), '-c:v', 'mjpeg', '-i', '-',
  '-c:v', 'libx264', '-preset', 'medium', '-crf', '19', '-pix_fmt', 'yuv420p', '-r', String(fps),
  path.join(outDir, `${base}_video.mp4`)], { stdio: ['pipe', 'inherit', 'inherit'] });
const t0 = Date.now();
for (let i = 0; i < total; i++) {
  await page.evaluate(async t => { window.renderAt(t); await document.fonts.ready; }, i / fps);
  const buf = await page.screenshot({ type: 'jpeg', quality: 92 });
  if (!ff.stdin.write(buf)) await new Promise(r => ff.stdin.once('drain', r));
  if (i % 150 === 0) console.log(`${base}: ${i}/${total} コマ (${((Date.now() - t0) / 1000).toFixed(0)}秒)`);
}
ff.stdin.end();
await new Promise(r => ff.on('close', r));
await browser.close();
console.log(`${base}: 完了 ${tl.duration}s / ${total} コマ`);
