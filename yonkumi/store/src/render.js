// アイコン・スプラッシュ・ストア素材を書き出す。
//
//   node store/src/render.js <出力先のルート（yonkumi/）> [アプリ画面のPNGがあるフォルダ]
//
// Chromium（Playwright）で SVG / HTML を描いて PNG にする。アプリ画面のフォルダを
// 渡したときだけ、ストアのスクリーンショットも作る（画面の撮り方は store/README.md）。
const fs = require('fs');
const path = require('path');
const { chromium } = require('playwright');

const root = path.resolve(process.argv[2] || '.');
const shotsDir = process.argv[3] ? path.resolve(process.argv[3]) : null;

// アプリと同じ色（lib/ui/theme.dart）。帯は柿・紅・栗・墨。
const C = {
  paper: '#F6F1E7', tile: '#E8DFCF', ink: '#2B2622', inkDim: '#75695E',
  kaki: '#F0A65E', beni: '#C9483F', kuri: '#7B4B2C', sumi: '#2E2A2A', select: '#4A423B',
};

/// 4×4の盤。上の2段は当てた帯（柿・紅）、下の2段はタイル（2つ選んでいる）。
/// (x, y) が左上、size が一辺。
function board(x, y, size) {
  const gap = size * 0.045;
  const cell = (size - gap * 3) / 4;
  const r = cell * 0.2;
  const band = (row, color) =>
    `<rect x="${x}" y="${y + row * (cell + gap)}" width="${size}" height="${cell}" rx="${r}" fill="${color}"/>`;
  let s = band(0, C.kaki) + band(1, C.beni);
  const picked = new Set(['2,1', '3,2']);
  for (let row = 2; row < 4; row++) {
    for (let col = 0; col < 4; col++) {
      const fill = picked.has(`${row},${col}`) ? C.select : C.tile;
      s += `<rect x="${x + col * (cell + gap)}" y="${y + row * (cell + gap)}" width="${cell}" height="${cell}" rx="${r}" fill="${fill}"/>`;
    }
  }
  return s;
}

/// opaque：地の色を塗るか（iOS のアイコンは透過なし、Android の前景は透過）。
const iconSvg = (opaque, px = 1024, boardSize = 600) => `
<svg xmlns="http://www.w3.org/2000/svg" width="${px}" height="${px}" viewBox="0 0 1024 1024">
  ${opaque ? `<rect width="1024" height="1024" fill="${C.paper}"/>` : ''}
  ${board((1024 - boardSize) / 2, (1024 - boardSize) / 2, boardSize)}
</svg>`;

const page = (body, w, h, extraCss = '') => `<!doctype html><html><head><meta charset="utf-8">
<style>
  html,body{margin:0;width:${w}px;height:${h}px;overflow:hidden;background:transparent}
  body{font-family:"Hiragino Sans","Noto Sans CJK JP","IPAGothic",sans-serif;color:${C.ink}}
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
// [ファイル名, 見出し, 小見出し, 画面の上から見せる割合の上限]
const captions = [
  ['01_today', '16語を4組に分けろ', '毎日1問。日本時間の0時に替わる', 1],
  ['02_oneaway', '3語合っていたら「あと1つ！」', '間違えられるのは4回まで', 1],
  ['03_result', '4色の結果を、答えなしで共有', '画像でも、文字の四角でも', 1],
  ['04_notes', '読み・漢字・季語・数え方', '全部の組に、軸の解説とひっかけ', 1],
  ['05_archive', '過去の問題も遊べる', '連続日数は、失敗しても途切れない', 1],
];

/// 端末の画面の縦横比（440×956）。
const SCREEN_RATIO = 956 / 440;

function shotHtml(w, h, [, title, sub, crop], src) {
  const s = w / 1320; // 1320 幅を基準にした倍率
  const top = 430 * s;
  const maxH = h - top - 80 * s;
  // 枠の幅は決めておき、入りきらない分は画面の下を切る（下は余白が多いので）。
  const phoneW = 1180 * s;
  crop = Math.min(crop, maxH / (phoneW * SCREEN_RATIO));
  const phoneH = phoneW * SCREEN_RATIO * crop;
  const fade = crop < 1
    ? `<div style="position:absolute;left:0;right:0;bottom:0;height:${phoneH * 0.12}px;
         background:linear-gradient(180deg,rgba(246,241,231,0),${C.paper})"></div>`
    : '';
  return page(`
  <div style="width:${w}px;height:${h}px;position:relative;overflow:hidden;background:${C.paper}">
    <div style="position:absolute;left:0;right:0;top:0;height:${18 * s}px;display:flex">
      <div style="flex:1;background:${C.kaki}"></div><div style="flex:1;background:${C.beni}"></div>
      <div style="flex:1;background:${C.kuri}"></div><div style="flex:1;background:${C.sumi}"></div>
    </div>
    <div style="position:absolute;top:${140 * s}px;width:100%;text-align:center;
         font-size:${90 * s}px;font-weight:700;letter-spacing:${2 * s}px">${title}</div>
    <div style="position:absolute;top:${275 * s}px;width:100%;text-align:center;color:${C.inkDim};
         font-size:${50 * s}px">${sub}</div>
    <div style="position:absolute;top:${top}px;width:100%;display:flex;justify-content:center">
      <div style="position:relative;width:${phoneW}px;height:${phoneH}px;overflow:hidden;
           border-radius:${56 * s}px ${56 * s}px ${crop < 1 ? 0 : 56 * s}px ${crop < 1 ? 0 : 56 * s}px;
           border:${10 * s}px solid ${C.ink};${crop < 1 ? 'border-bottom:none;' : ''}
           box-shadow:0 ${24 * s}px ${70 * s}px rgba(43,38,34,.25);background:${C.paper}">
        <img src="${src}" style="display:block;width:100%">${fade}
      </div>
    </div>
  </div>`, w, h);
}

(async () => {
  const browser = await chromium.launch();
  const a = (...p) => path.join(root, ...p);

  // アプリのアイコン（iOS は透過なし）と、Android のアダプティブアイコンの前景
  // （前景は外側が切り取られるので、盤を小さめにする）
  await shoot(browser, page(iconSvg(true), 1024, 1024), 1024, 1024, a('assets/icon/icon.png'));
  await shoot(browser, page(iconSvg(false, 1024, 470), 1024, 1024), 1024, 1024,
    a('assets/icon/icon_foreground.png'), { transparent: true });

  // スプラッシュの中央の絵（盤だけ）
  await shoot(browser, page(iconSvg(false, 384, 900), 384, 384), 384, 384,
    a('assets/splash/splash_icon.png'), { transparent: true });

  // Play ストア：512 アイコンと 1024×500 のフィーチャーグラフィック
  await shoot(browser, page(iconSvg(true, 512), 512, 512), 512, 512, a('store/icon_512.png'));
  await shoot(browser, page(`
    <div style="width:1024px;height:500px;position:relative;overflow:hidden;background:${C.paper}">
      <svg width="1024" height="500" style="position:absolute;inset:0">${board(660, 90, 320)}</svg>
      <div style="position:absolute;left:70px;top:96px;font-size:104px;font-weight:700;letter-spacing:8px">ヨンクミ</div>
      <div style="position:absolute;left:74px;top:246px;font-size:38px;line-height:1.6">16語を4組に分けろ。<br>間違えは4回まで。</div>
      <div style="position:absolute;left:74px;top:396px;color:${C.inkDim};font-size:24px">毎日1問 ・ 日本語ならではの仕分け ・ 結果を色で共有</div>
    </div>`, 1024, 500), 1024, 500, a('store/feature_graphic.png'));

  if (shotsDir) {
    const img = (n) => 'data:image/png;base64,' + fs.readFileSync(path.join(shotsDir, `${n}.png`)).toString('base64');
    // App Store（6.9インチ：1320×2868）と Google Play（1080×1920、縦横比 2:1 以内）
    for (const [dir, w, h] of [['ios', 1320, 2868], ['android', 1080, 1920]]) {
      for (const c of captions) {
        await shoot(browser, shotHtml(w, h, c, img(c[0])), w, h, a(`store/screens/${dir}/${c[0]}.png`));
      }
    }
  }
  await browser.close();
})();
