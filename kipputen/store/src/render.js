// アイコンとスプラッシュの絵を書き出す。
//
//   node store/src/render.js <出力先のルート（kipputen/）>
//
// Chromium（Playwright）で SVG を描いて PNG にする。書き出したあと、
//   dart run flutter_launcher_icons
//   dart run flutter_native_splash:create
// で各プラットフォームの画像を作る。
//
// 絵柄はすべて自作。実在の切符・地紋・鉄道事業者にちなむものは描かない。
const fs = require('fs');
const path = require('path');
const { chromium } = require('playwright');

const root = path.resolve(process.argv[2] || '.');

// アプリの配色（lib/ui/theme.dart・ticket_design.dart の「若草」と同じ）
const C = {
  bgTop: '#3A7A5B',
  bgBottom: '#1F4A37',
  paper: '#E6EFD9',
  ink: '#263A2C',
  accent: '#B9CFA5',
  punch: '#B3412F',
};

/// 自作の地紋：位相をずらした波線。
function waves(w, h, rows = 9) {
  let out = '';
  for (let i = 0; i < rows; i++) {
    const y0 = (h * (i + 0.5)) / rows;
    let d = `M0 ${y0.toFixed(1)}`;
    for (let x = 0; x <= w; x += w / 60) {
      const y = y0 + Math.sin((x / w) * Math.PI * 5 + i * 0.9) * h * 0.022;
      d += ` L${x.toFixed(1)} ${y.toFixed(1)}`;
    }
    out += `<path d="${d}" fill="none" stroke="${C.accent}" stroke-width="${(w * 0.006).toFixed(1)}" opacity="0.85"/>`;
  }
  return out;
}

/// 硬券1枚。中心 (cx, cy)、幅 w。上の辺の右寄りに入鋏の切り欠き。
function ticket(cx, cy, w, { tilt = -8, id = 't' } = {}) {
  const h = w / (57.5 / 30.5);
  const r = w * 0.035;
  const nx = w * 0.74; // 切り欠きの位置
  const ns = w * 0.11; // 切り欠きの大きさ
  const inset = w * 0.035;
  return `
  <defs>
    <mask id="${id}-cut">
      <rect width="${w}" height="${h}" rx="${r}" fill="#fff"/>
      <path d="M${nx - ns / 2} -2 L${nx + ns / 2} -2 L${nx} ${ns * 0.85} Z" fill="#000"/>
    </mask>
    <clipPath id="${id}-clip"><rect width="${w}" height="${h}" rx="${r}"/></clipPath>
    <filter id="${id}-shadow" x="-20%" y="-20%" width="140%" height="150%">
      <feDropShadow dx="0" dy="${w * 0.025}" stdDeviation="${w * 0.03}" flood-color="#000" flood-opacity="0.32"/>
    </filter>
  </defs>
  <g transform="translate(${cx},${cy}) rotate(${tilt}) translate(${-w / 2},${-h / 2})">
    <g filter="url(#${id}-shadow)">
      <g mask="url(#${id}-cut)">
        <rect width="${w}" height="${h}" rx="${r}" fill="${C.paper}"/>
        <g clip-path="url(#${id}-clip)">${waves(w, h)}</g>
        <rect x="${inset}" y="${inset}" width="${w - inset * 2}" height="${h - inset * 2}" rx="${r * 0.6}"
              fill="none" stroke="${C.ink}" stroke-opacity="0.45" stroke-width="${w * 0.008}"/>
        <text x="${w / 2}" y="${h * 0.74}" text-anchor="middle" fill="${C.ink}"
              font-family="Inter, 'DejaVu Sans', sans-serif" font-weight="800"
              font-size="${h * 0.66}" letter-spacing="${w * 0.01}">10</text>
        <rect x="${w * 0.14}" y="${h * 0.16}" width="${w * 0.2}" height="${h * 0.045}" rx="${h * 0.02}" fill="${C.ink}" opacity="0.55"/>
        <rect x="${w * 0.14}" y="${h * 0.84}" width="${w * 0.32}" height="${h * 0.04}" rx="${h * 0.02}" fill="${C.ink}" opacity="0.35"/>
      </g>
    </g>
  </g>`;
}

const svg = (size, body, bg = true) => `
<svg xmlns="http://www.w3.org/2000/svg" width="${size}" height="${size}" viewBox="0 0 1024 1024">
  <defs>
    <linearGradient id="bg" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0" stop-color="${C.bgTop}"/><stop offset="1" stop-color="${C.bgBottom}"/>
    </linearGradient>
  </defs>
  ${bg ? '<rect width="1024" height="1024" fill="url(#bg)"/>' : ''}
  ${body}
</svg>`;

const page = (body, w, h) => `<!doctype html><html><head><meta charset="utf-8">
<style>html,body{margin:0;width:${w}px;height:${h}px;overflow:hidden;background:transparent}</style>
</head><body>${body}</body></html>`;

async function shoot(browser, html, w, h, out, { transparent = false } = {}) {
  const p = await browser.newPage({ viewport: { width: w, height: h }, deviceScaleFactor: 1 });
  await p.setContent(html, { waitUntil: 'load' });
  await p.waitForTimeout(150);
  fs.mkdirSync(path.dirname(out), { recursive: true });
  await p.screenshot({ path: out, omitBackground: transparent });
  await p.close();
  console.log('wrote', path.relative(root, out));
}

(async () => {
  const browser = await chromium.launch();
  const a = (...p) => path.join(root, ...p);

  // アプリのアイコン（iOS は透過なし）。切符を少し傾けて大きく。
  await shoot(browser, page(svg(1024, ticket(512, 520, 790)), 1024, 1024), 1024, 1024,
    a('assets/icon/icon.png'));

  // Android のアダプティブアイコンの前景。端が丸く切られるので、中央の 66% に収める。
  await shoot(browser, page(svg(1024, ticket(512, 520, 600), false), 1024, 1024), 1024, 1024,
    a('assets/icon/icon_foreground.png'), { transparent: true });

  // スプラッシュの中央の絵（切符だけ、透過）
  await shoot(browser, page(svg(384, ticket(512, 512, 820), false), 384, 384), 384, 384,
    a('assets/splash/splash_icon.png'), { transparent: true });

  // Play ストアの 512 アイコン
  await shoot(browser, page(svg(512, ticket(512, 520, 790)), 512, 512), 512, 512,
    a('store/icon_512.png'));

  await browser.close();
})();
