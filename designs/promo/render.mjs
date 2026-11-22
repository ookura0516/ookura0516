// 宣伝動画を書き出す。
//   node render.mjs                       … 3案 × 縦横の6本
//   node render.mjs kozeni v              … 1本だけ
//   node render.mjs kozeni v --still 1.2,4.5 --out <フォルダ>   … 指定した時刻の静止画だけ
// 1コマずつ Canvas に描いて JPEG で受け取り、ffmpeg に渡す。音は audio.py で作って重ねる。
import { createRequire } from 'node:module';
import { spawn, spawnSync } from 'node:child_process';
import { mkdirSync, writeFileSync, rmSync, existsSync } from 'node:fs';
import { dirname, join, resolve } from 'node:path';
import { fileURLToPath, pathToFileURL } from 'node:url';

const here = dirname(fileURLToPath(import.meta.url));
// Playwright はこの環境に入っているものを使う（CommonJS の解決なら NODE_PATH も見る）
const { chromium } = createRequire(import.meta.url)('playwright');
const args = process.argv.slice(2);
const flag = (name) => {
  const i = args.indexOf(name);
  return i >= 0 ? args[i + 1] : null;
};
const positional = args.filter((a, i) => !a.startsWith('--') && !(i > 0 && args[i - 1].startsWith('--')));
const APPS = positional[0] ? [positional[0]] : ['kozeni', 'meirobin', 'monkiri'];
const FMTS = positional[1] ? [positional[1]] : ['v', 'h'];
const stills = flag('--still');
const outDir = resolve(flag('--out') || join(here, 'out'));
mkdirSync(outDir, { recursive: true });

function run(cmd, argv) {
  const r = spawnSync(cmd, argv, { stdio: 'inherit' });
  if (r.status !== 0) throw new Error(`${cmd} failed (${r.status})`);
}

const browser = await chromium.launch();
try {
  for (const app of APPS) {
    for (const fmt of FMTS) {
      const W = fmt === 'v' ? 1080 : 1920;
      const H = fmt === 'v' ? 1920 : 1080;
      const page = await browser.newPage({ viewport: { width: W, height: H }, deviceScaleFactor: 1 });
      page.on('pageerror', (e) => console.error('pageerror', e));
      const url = pathToFileURL(join(here, 'index.html')).href + `?app=${app}&fmt=${fmt}`;
      await page.goto(url);
      await page.waitForFunction(() => window.PROMO && window.PROMO.ready);
      await page.evaluate(() => window.PROMO.ready);
      const info = await page.evaluate(() => ({
        duration: PROMO.duration, fps: PROMO.fps, frames: PROMO.frames, cues: PROMO.cues, scenes: PROMO.scenes,
      }));
      const name = `${app}_${fmt === 'v' ? 'vertical' : 'horizontal'}`;

      if (stills) {
        for (const t of stills.split(',').map(Number)) {
          const data = await page.evaluate((t) => PROMO.framePng(t), t);
          const file = join(outDir, `${name}_${t.toFixed(2)}.png`);
          writeFileSync(file, Buffer.from(data.split(',')[1], 'base64'));
          console.log('still', file);
        }
        await page.close();
        continue;
      }

      console.log(`${name}: ${info.duration.toFixed(2)}s, ${info.frames} frames`);
      const cueFile = join(outDir, `${name}.cues.json`);
      writeFileSync(cueFile, JSON.stringify({ app, fmt, duration: info.duration, scenes: info.scenes, cues: info.cues }, null, 1));

      const silent = join(outDir, `${name}.silent.mp4`);
      const ff = spawn('ffmpeg', [
        '-y', '-loglevel', 'error',
        '-f', 'image2pipe', '-framerate', String(info.fps), '-c:v', 'mjpeg', '-i', '-',
        '-c:v', 'libx264', '-preset', 'medium', '-crf', '20', '-pix_fmt', 'yuv420p',
        '-r', String(info.fps), '-movflags', '+faststart', silent,
      ], { stdio: ['pipe', 'inherit', 'inherit'] });
      const done = new Promise((res, rej) => ff.on('close', (c) => (c === 0 ? res() : rej(new Error('ffmpeg ' + c)))));
      const t0 = Date.now();
      for (let i = 0; i < info.frames; i++) {
        const data = await page.evaluate((t) => PROMO.frameJpeg(t), i / info.fps);
        const buf = Buffer.from(data.split(',')[1], 'base64');
        if (!ff.stdin.write(buf)) await new Promise((r) => ff.stdin.once('drain', r));
        if (i % 150 === 0) console.log(`  frame ${i}/${info.frames}`);
      }
      ff.stdin.end();
      await done;
      console.log(`  video done in ${((Date.now() - t0) / 1000).toFixed(1)}s`);
      await page.close();

      const wav = join(outDir, `${name}.wav`);
      run('python3', [join(here, 'audio.py'), cueFile, wav]);
      const final = join(outDir, `${name}.mp4`);
      run('ffmpeg', [
        '-y', '-loglevel', 'error', '-i', silent, '-i', wav,
        '-c:v', 'copy', '-c:a', 'aac', '-b:a', '192k', '-shortest', '-movflags', '+faststart', final,
      ]);
      rmSync(silent);
      rmSync(wav);
      console.log('  wrote', final);
    }
  }
} finally {
  await browser.close();
}
