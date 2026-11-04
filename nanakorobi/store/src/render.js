// アイコン・フィーチャーグラフィック・ストア素材を書き出す。
//
//   node store/src/render.js <出力先のルート（nanakorobi/）> [アプリ画面のPNGがあるフォルダ]
//
// Chromium（Playwright）で SVG / HTML を描いて PNG にする。アプリ画面のフォルダを渡した
// ときだけ、ストアのスクリーンショットも作る（画面の撮り方は store/README.md）。
// だるまはアプリと同じ線（lib/paint/daruma_painter.dart の座標）を SVG に写したもの。
const fs = require('fs');
const os = require('os');
const path = require('path');
const { chromium } = require('playwright');

const root = path.resolve(process.argv[2] || '.');
const shotsDir = process.argv[3] ? path.resolve(process.argv[3]) : null;
const fontPath = path.join(root, 'assets/fonts/YujiSyuku-Regular.ttf');

const PAPER = '#F3ECDF';
const INK = '#2A221C';
const INK_DIM = '#6B5A4A';
const RED = '#C3262A';
const GOLD = '#E2B94E';

/// だるま（600×760 の箱、台座つき）。eyes: 入っている目の数、brows: 眉を描くか。
function daruma({ eyes = 1, brows = true, beard = false, stripes = 2, text = '合格', base = true } = {}) {
  const baseSvg = base ? `
    <rect x="104" y="664" width="392" height="58" rx="16" fill="#3A2A22"/>
    <rect x="124" y="712" width="352" height="24" rx="9" fill="#2A1D17"/>
    ${Array.from({ length: stripes }, (_, i) => {
      const x = stripes === 1 ? 300 : 150 + (300 / (stripes - 1)) * i;
      return `<rect x="${x - 5}" y="673" width="10" height="40" rx="4" fill="${GOLD}"/>`;
    }).join('')}` : '';
  const browsSvg = brows ? `
    <path d="M132 256 Q 206 148 300 204 Q 232 186 174 240 Q 152 262 132 256 Z" fill="#1C1C1C"/>
    <path d="M468 256 Q 394 148 300 204 Q 368 186 426 240 Q 448 262 468 256 Z" fill="#1C1C1C"/>` : '';
  const beardSvg = beard ? `
    <g fill="none" stroke="#1C1C1C" stroke-linecap="round">
      <path d="M296 350 C 268 338 238 342 216 360" stroke-width="11"/>
      <path d="M304 350 C 332 338 362 342 384 360" stroke-width="11"/>
      <path d="M150 340 C 156 400 196 444 262 462" stroke-width="16"/>
      <path d="M450 340 C 444 400 404 444 338 462" stroke-width="16"/>
      <path d="M166 384 C 188 420 222 446 270 468" stroke-width="11"/>
      <path d="M434 384 C 412 420 378 446 330 468" stroke-width="11"/>
      <path d="M232 470 C 256 486 344 486 368 470" stroke-width="10"/>
    </g>` : '';
  const eye = (cx, painted) => `
    <circle cx="${cx}" cy="276" r="54" fill="none" stroke="${GOLD}" stroke-width="4"/>
    <circle cx="${cx}" cy="276" r="46" fill="#fff" stroke="#1C1C1C" stroke-width="7"/>
    ${painted ? `<circle cx="${cx}" cy="276" r="33" fill="#1C1C1C"/><circle cx="${cx + 12}" cy="262" r="9" fill="#fff"/>` : ''}`;
  return `
  <g>
    ${baseSvg}
    <path d="M300 30 C 402 30 468 112 490 232 C 510 342 584 442 574 562 C 566 650 470 678 300 678 C 130 678 34 650 26 562 C 16 442 90 342 110 232 C 132 112 198 30 300 30 Z"
          fill="${RED}" stroke="#7A1414" stroke-width="7" stroke-linejoin="round"/>
    <path d="M156 118 C 196 70 244 50 290 46" fill="none" stroke="#E25C53" stroke-width="12" stroke-linecap="round" opacity="0.75"/>
    <path d="M74 430 c 16 -30 40 -46 70 -54" fill="none" stroke="${GOLD}" stroke-width="7" stroke-linecap="round"/>
    <path d="M526 430 c -16 -30 -40 -46 -70 -54" fill="none" stroke="${GOLD}" stroke-width="7" stroke-linecap="round"/>
    <ellipse cx="300" cy="296" rx="198" ry="206" fill="none" stroke="${GOLD}" stroke-width="11"/>
    <ellipse cx="300" cy="296" rx="184" ry="192" fill="#F5E8D2"/>
    ${browsSvg}
    ${eye(226, eyes >= 2)}
    ${eye(374, eyes >= 1)}
    <path d="M300 318 c -10 12 -14 22 -4 28 c 10 -6 6 -16 -4 -28" fill="none" stroke="#9A5B3C" stroke-width="5" stroke-linecap="round" stroke-linejoin="round"/>
    ${beardSvg}
    <text x="300" y="582" font-family="YujiSyuku" font-size="74" fill="#1C1C1C" text-anchor="middle" style="writing-mode:vertical-rl;text-orientation:upright;dominant-baseline:central">${text}</text>
  </g>`;
}

const fontFace = `@font-face{font-family:'YujiSyuku';src:url('file://${fontPath}') format('truetype');}`;

const page = (body, w, h, extraCss = '') => `<!doctype html><html><head><meta charset="utf-8">
<style>
  ${fontFace}
  html,body{margin:0;width:${w}px;height:${h}px;overflow:hidden;background:transparent}
  body{font-family:"IPAPGothic","Noto Sans CJK JP","Hiragino Sans","Noto Sans JP",sans-serif}
  ${extraCss}
</style></head><body>${body}</body></html>`;

/// アイコン：生成りの地に、片目を入れた赤いだるま（台座なし）。
const iconSvg = (opaque) => `
<svg xmlns="http://www.w3.org/2000/svg" width="1024" height="1024" viewBox="0 0 1024 1024">
  ${opaque ? `<rect width="1024" height="1024" fill="${PAPER}"/>
  <circle cx="512" cy="540" r="470" fill="#EADFC9"/>` : ''}
  <g transform="translate(${opaque ? 172 : 212},${opaque ? 128 : 190}) scale(${opaque ? 1.13 : 1.0})">
    ${daruma({ eyes: 1, brows: true, beard: false, base: false, text: '合格' })}
  </g>
</svg>`;

/// フィーチャーグラフィック（1024×500）。
const featureHtml = () => page(`
  <div style="position:relative;width:1024px;height:500px;background:radial-gradient(ellipse at 30% 50%,#F8F1E4 0%,#EFE4CF 70%,#E6D8BF 100%)">
    <svg width="440" height="500" viewBox="0 0 600 760" style="position:absolute;left:40px;top:10px">${daruma({ eyes: 1, brows: true, beard: true, stripes: 3 })}</svg>
    <div style="position:absolute;left:480px;top:120px;width:520px;color:${INK}">
      <div style="font-size:64px;font-weight:700;letter-spacing:4px">ナナコロビ</div>
      <div style="font-size:30px;font-weight:700;margin-top:14px;line-height:1.5">だるまに目を入れて、<br>目標を始める。</div>
      <div style="font-size:21px;color:${INK_DIM};margin-top:18px;line-height:1.7">毎日1タップで模様が増える。転んでも減らない。<br>試験日までの残り日数はウィジェットに。広告なし。</div>
    </div>
  </div>`, 1024, 500);

async function shoot(browser, html, w, h, out, { transparent = false } = {}) {
  const tmp = path.join(os.tmpdir(), `nanakorobi-render-${Date.now()}-${Math.random().toString(16).slice(2)}.html`);
  fs.writeFileSync(tmp, html);
  const p = await browser.newPage({ viewport: { width: w, height: h }, deviceScaleFactor: 1 });
  await p.goto('file://' + tmp, { waitUntil: 'load' });
  await p.evaluate(() => document.fonts.ready);
  await p.waitForTimeout(200);
  fs.mkdirSync(path.dirname(out), { recursive: true });
  await p.screenshot({ path: out, omitBackground: transparent });
  await p.close();
  fs.unlinkSync(tmp);
  console.log('wrote', path.relative(root, out));
}

// ストアのスクリーンショット：上に見出し、下にアプリの画面。
const captions = [
  ['01_eye', '目を入れて、目標を始める', '指でなぞって、片目を入れる'],
  ['02_home', '毎日1タップで、模様が増える', '眉、ひげ、金の模様が1筆ずつ'],
  ['03_fallen', '転んでも、減らない', '起き上がると、台座に金の筋が1本'],
  ['04_widget', '試験日まで、あと何日', 'ホーム画面のウィジェットは毎日0時に進む'],
  ['05_shelf', '広告なし。記録は端末の中だけ', '満願のだるまは棚に並ぶ'],
];

/// 端末の画面の縦横比（440×956）。
const SCREEN_RATIO = 956 / 440;

function shotHtml(w, h, [name, title, sub], images) {
  const s = w / 1320;
  const top = 430 * s;
  const maxH = h - top - 60 * s;
  let phoneW = 1080 * s;
  if (phoneW * SCREEN_RATIO > maxH) phoneW = maxH / SCREEN_RATIO;
  const phoneH = phoneW * SCREEN_RATIO;
  const imgs = images
    .map((src) => `<div style="position:relative;width:${phoneW}px;height:${phoneH}px;overflow:hidden;
        border-radius:${54 * s}px;border:${10 * s}px solid #2A221C;box-shadow:0 ${30 * s}px ${80 * s}px rgba(60,40,20,.35);background:${PAPER}">
        <img src="file://${src}" style="display:block;width:100%"></div>`)
    .join('');
  return page(`
  <div style="width:${w}px;height:${h}px;position:relative;overflow:hidden;
       background:radial-gradient(ellipse at 50% 30%,#F8F1E4 0%,#EFE4CF 70%,#E6D8BF 100%)">
    <div style="position:absolute;top:${140 * s}px;width:100%;text-align:center;color:${INK};
         font-size:${84 * s}px;font-weight:700;letter-spacing:${2 * s}px">${title}</div>
    <div style="position:absolute;top:${270 * s}px;width:100%;text-align:center;color:${INK_DIM};
         font-size:${46 * s}px">${sub}</div>
    <div style="position:absolute;top:${top}px;width:100%;display:flex;justify-content:center;align-items:flex-start">
      ${imgs}
    </div>
  </div>`, w, h);
}

(async () => {
  const browser = await chromium.launch({ args: ['--allow-file-access-from-files'] });
  const a = (...p) => path.join(root, ...p);

  // アプリのアイコン（iOS は透過なし）と、Android のアダプティブアイコンの前景。
  await shoot(browser, page(iconSvg(true), 1024, 1024), 1024, 1024, a('assets/icon/icon.png'));
  await shoot(browser, page(iconSvg(false), 1024, 1024), 1024, 1024, a('assets/icon/icon_foreground.png'), { transparent: true });
  // Google Play のアイコンとフィーチャーグラフィック。
  await shoot(browser, page(iconSvg(true), 1024, 1024).replace('width="1024" height="1024"', 'width="512" height="512"'), 512, 512, a('store/icon_512.png'));
  await shoot(browser, featureHtml(), 1024, 500, a('store/feature_graphic.png'));
  // スプラッシュ：だるまの頭だけ（透過）。
  await shoot(browser, page(`<svg xmlns="http://www.w3.org/2000/svg" width="512" height="512" viewBox="0 0 512 512">
    <g transform="translate(76,30) scale(0.6)">${daruma({ eyes: 1, brows: true, base: false })}</g></svg>`, 512, 512), 512, 512, a('assets/splash/splash_icon.png'), { transparent: true });

  if (shotsDir) {
    // 4枚目：ホーム画面に置いたウィジェット（合成。Android のホーム画面を模した 440×956 @3x）。
    const widgetShot = path.join(shotsDir, '04_widget.png');
    if (!fs.existsSync(widgetShot)) {
      const W = 1320, H = 2868;
      await shoot(browser, page(`
        <div style="width:${W}px;height:${H}px;position:relative;overflow:hidden;
             background:linear-gradient(160deg,#2B3A55 0%,#1B2438 60%,#121827 100%)">
          <div style="position:absolute;top:60px;width:100%;text-align:center;color:#fff;font-size:44px;opacity:.9">9:41</div>
          <div style="position:absolute;top:300px;left:120px;width:520px;height:520px;border-radius:72px;background:${PAPER};
               box-shadow:0 30px 80px rgba(0,0,0,.4);display:flex;flex-direction:column;align-items:center;padding:28px 20px;box-sizing:border-box">
            <svg width="300" height="330" viewBox="0 0 600 760">${daruma({ eyes: 1, brows: true, beard: true, stripes: 2 })}</svg>
            <div style="font-size:54px;font-weight:700;color:${INK};margin-top:6px">あと73日</div>
            <div style="font-size:30px;color:${INK_DIM};margin-top:4px">共通テスト</div>
          </div>
          ${[[720, 300], [120, 880], [720, 880], [120, 1460], [720, 1460]].map(([x, y]) => `
            <div style="position:absolute;top:${y}px;left:${x}px;width:480px;height:${y === 300 ? 520 : 440}px;border-radius:72px;
                 background:rgba(255,255,255,.08)"></div>`).join('')}
          <div style="position:absolute;bottom:120px;left:0;width:100%;display:flex;justify-content:center;gap:90px">
            ${[0, 1, 2, 3].map(() => `<div style="width:150px;height:150px;border-radius:48px;background:rgba(255,255,255,.14)"></div>`).join('')}
          </div>
        </div>`, W, H), W, H, widgetShot);
    }
    for (const cap of captions) {
      const src = path.join(shotsDir, cap[0] + '.png');
      if (!fs.existsSync(src)) { console.log('skip (no capture):', cap[0]); continue; }
      await shoot(browser, shotHtml(1080, 1920, cap, [src]), 1080, 1920, a('store/screens/android', cap[0] + '.png'));
      await shoot(browser, shotHtml(1320, 2868, cap, [src]), 1320, 2868, a('store/screens/ios', cap[0] + '.png'));
    }
  }
  await browser.close();
})();
