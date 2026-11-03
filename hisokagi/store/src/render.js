// アイコン・スプラッシュ・ストア素材を書き出す。
//
//   node store/src/render.js <出力先のルート（hisokagi/）> [アプリ画面のPNGがあるフォルダ]
//
// Chromium（Playwright）で SVG / HTML を描いて PNG にする。アプリ画面のフォルダを
// 渡したときだけ、ストアのスクリーンショットも作る（画面の撮り方は store/README.md）。
const fs = require('fs');
const path = require('path');
const { chromium } = require('playwright');

const root = path.resolve(process.argv[2] || '.');
const shotsDir = process.argv[3] ? path.resolve(process.argv[3]) : null;
const keyDefs = fs.readFileSync(path.join(__dirname, 'key.svg.part'), 'utf8');

// 星の位置は固定（毎回同じ絵になるように）。
const stars = [
  [150, 170, 5], [300, 110, 3], [820, 150, 4], [905, 300, 3], [120, 420, 3],
  [700, 90, 3], [880, 760, 4], [170, 830, 4], [560, 930, 3], [940, 520, 2.5],
  [70, 620, 2.5], [420, 60, 2.5], [760, 900, 3],
];

function starDots(scale = 1, opacity = 1) {
  return stars
    .map(([x, y, r]) => `<circle cx="${x * scale}" cy="${y * scale}" r="${r * scale}" fill="#EAF0FF" opacity="${0.55 * opacity}"/>`)
    .join('');
}

/// 割れた鍵。中心 (cx, cy)、大きさ s。
function key(cx, cy, s, gap = 13) {
  return `
  <g transform="translate(${cx},${cy}) rotate(-35) scale(${s}) translate(30,0)">
    <g transform="translate(0,${-gap})" clip-path="url(#top)"><use href="#keyshape" fill="url(#goldG)"/></g>
    <g transform="translate(0,${gap})" clip-path="url(#bottom)"><use href="#keyshape" fill="url(#blueG)"/></g>
    <use href="#sparkle" transform="translate(-230,0) scale(0.95)" fill="#FFF6DA"/>
  </g>`;
}

const sky = `
  <linearGradient id="sky" x1="0" y1="0" x2="0" y2="1">
    <stop offset="0" stop-color="#22357A"/><stop offset="0.55" stop-color="#121B3D"/><stop offset="1" stop-color="#0A0F22"/>
  </linearGradient>
  <radialGradient id="glow" cx="0.5" cy="0.5" r="0.5">
    <stop offset="0" stop-color="#9FBEFF" stop-opacity="0.20"/><stop offset="1" stop-color="#9FBEFF" stop-opacity="0"/>
  </radialGradient>`;

const iconSvg = (opaque) => `
<svg xmlns="http://www.w3.org/2000/svg" width="1024" height="1024" viewBox="0 0 1024 1024">
  ${keyDefs}
  <defs>${sky}</defs>
  ${opaque ? `<rect width="1024" height="1024" fill="url(#sky)"/>${starDots()}<circle cx="512" cy="512" r="420" fill="url(#glow)"/>` : ''}
  ${opaque ? key(512, 500, 0.86) : key(512, 500, 0.80, 11)}
</svg>`;

const page = (body, w, h, extraCss = '') => `<!doctype html><html><head><meta charset="utf-8">
<style>
  html,body{margin:0;width:${w}px;height:${h}px;overflow:hidden;background:transparent}
  body{font-family:"Noto Sans CJK JP","Hiragino Sans","WenQuanYi Zen Hei",sans-serif}
  ${extraCss}
</style></head><body>${body}</body></html>`;

async function shoot(browser, html, w, h, out, { transparent = false } = {}) {
  const p = await browser.newPage({ viewport: { width: w, height: h }, deviceScaleFactor: 1 });
  await p.setContent(html, { waitUntil: 'load' });
  await p.waitForTimeout(150);
  fs.mkdirSync(path.dirname(out), { recursive: true });
  await p.screenshot({ path: out, omitBackground: transparent });
  await p.close();
  console.log('wrote', path.relative(root, out));
}

// ストアのスクリーンショット：上に見出し、下にアプリの画面。
const captions = [
  ['01_title', 'スマホを持ち寄って、声で解く', 'ふたりの協力謎解き'],
  ['02_split', 'ふたりの画面は、ちがう手がかり', '見えたものを言葉で伝え合おう'],
  ['03_passphrase', '解いたら、合言葉を相棒へ', '合言葉を入れると、次の部屋へ進める'],
  ['04_puzzles', '時計、ケーブル、暗号の表', '5つの謎で、ドームの屋根を開けよう'],
  ['05_room', '通信なし。6けたの番号でつながる', '機内モードでも遊べます'],
];

/// 端末の画面の縦横比（440×956）。
const SCREEN_RATIO = 956 / 440;

/// [crop]：画面の上から何割を見せるか。1 なら全部。
function shotHtml(w, h, [name, title, sub], images, crop) {
  const s = w / 1320; // 1320 幅を基準にした倍率
  const two = images.length === 2;
  const top = 450 * s;
  const maxH = h - top - 70 * s;
  let phoneW = two ? 620 * s : 1120 * s;
  if (phoneW * SCREEN_RATIO * crop > maxH) phoneW = maxH / (SCREEN_RATIO * crop);
  const phoneH = phoneW * SCREEN_RATIO * crop;
  const tilt = two ? [-3, 3] : [0];
  const fade = crop < 1
    ? `<div style="position:absolute;left:0;right:0;bottom:0;height:${phoneH * 0.18}px;
         background:linear-gradient(180deg,rgba(13,20,38,0),rgba(13,20,38,1))"></div>`
    : '';
  const imgs = images
    .map((src, i) => `<div style="position:relative;width:${phoneW}px;height:${phoneH}px;overflow:hidden;
        border-radius:${48 * s}px;border:${9 * s}px solid #2A3866;box-shadow:0 ${30 * s}px ${80 * s}px rgba(0,0,0,.55);
        transform:rotate(${tilt[i]}deg);margin:0 ${two ? -30 * s : 0}px;background:#0D1426">
        <img src="${src}" style="display:block;width:100%">${fade}</div>`)
    .join('');
  return page(`
  <div style="width:${w}px;height:${h}px;position:relative;overflow:hidden;
       background:linear-gradient(180deg,#22357A 0%,#121B3D 50%,#0A0F22 100%)">
    <svg width="${w}" height="${h}" style="position:absolute;inset:0">${starDots(w / 1024, 0.8)}</svg>
    <div style="position:absolute;top:${150 * s}px;width:100%;text-align:center;color:#F2C96B;
         font-size:${88 * s}px;font-weight:700;letter-spacing:${2 * s}px">${title}</div>
    <div style="position:absolute;top:${280 * s}px;width:100%;text-align:center;color:#C9D3EE;
         font-size:${50 * s}px">${sub}</div>
    <div style="position:absolute;top:${top}px;width:100%;display:flex;justify-content:center;align-items:flex-start">
      ${imgs}
    </div>
  </div>`, w, h);
}

(async () => {
  const browser = await chromium.launch();
  const a = (...p) => path.join(root, ...p);

  // アプリのアイコン（iOS は透過なし）と、Android のアダプティブアイコンの前景
  await shoot(browser, page(iconSvg(true), 1024, 1024), 1024, 1024, a('assets/icon/icon.png'));
  await shoot(browser, page(iconSvg(false), 1024, 1024), 1024, 1024, a('assets/icon/icon_foreground.png'), { transparent: true });

  // スプラッシュの中央の絵（鍵だけ）
  await shoot(browser, page(`<div style="width:384px;height:384px">${iconSvg(false).replace('width="1024" height="1024"', 'width="384" height="384"')}</div>`, 384, 384),
    384, 384, a('assets/splash/splash_icon.png'), { transparent: true });

  // Play ストア：512 アイコンと 1024×500 のフィーチャーグラフィック
  await shoot(browser, page(iconSvg(true).replace('width="1024" height="1024"', 'width="512" height="512"'), 512, 512), 512, 512, a('store/icon_512.png'));
  await shoot(browser, page(`
    <div style="width:1024px;height:500px;position:relative;overflow:hidden;
         background:linear-gradient(180deg,#22357A 0%,#121B3D 60%,#0A0F22 100%)">
      <svg width="1024" height="500" style="position:absolute;inset:0">${starDots(0.6)}</svg>
      <svg width="1024" height="500" viewBox="0 0 1024 500" style="position:absolute;inset:0">
        ${keyDefs}<defs>${sky}</defs>
        <circle cx="790" cy="250" r="230" fill="url(#glow)"/>
        ${key(790, 255, 0.5, 8)}
      </svg>
      <div style="position:absolute;left:70px;top:92px;color:#F2C96B;font-size:96px;font-weight:700;letter-spacing:10px">ひそかぎ</div>
      <div style="position:absolute;left:74px;top:232px;color:#EAF0FF;font-size:34px;line-height:1.6">
        スマホを持ち寄って、声で解く。<br>ふたりの協力謎解き
      </div>
      <div style="position:absolute;left:74px;top:378px;color:#B8C4E6;font-size:24px">通信なし ・ 1台でも遊べる ・ 最初のシナリオは無料</div>
    </div>`, 1024, 500), 1024, 500, a('store/feature_graphic.png'));

  if (shotsDir) {
    const img = (n) => 'data:image/png;base64,' + fs.readFileSync(path.join(shotsDir, n)).toString('base64');
    // [画面, 上から見せる割合]
    const sources = {
      '01_title': [[img('title.png')], 1],
      '02_split': [[img('door_a.png'), img('door_b.png')], 0.8],
      '03_passphrase': [[img('passphrase.png')], 0.74],
      '04_puzzles': [[img('clock_a.png'), img('grid_b.png')], 0.72],
      '05_room': [[img('room.png')], 0.62],
    };
    // App Store（6.9インチ：1320×2868）と Google Play（1080×1920、縦横比 2:1 以内）
    for (const [dir, w, h] of [['ios', 1320, 2868], ['android', 1080, 1920]]) {
      for (const c of captions) {
        await shoot(browser, shotHtml(w, h, c, ...sources[c[0]]), w, h, a(`store/screens/${dir}/${c[0]}.png`));
      }
    }
  }
  await browser.close();
})();
