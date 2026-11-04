// アイコン・スプラッシュ・ストア素材・スクリーンショット用の見本の絵を書き出す。
//
//   node store/src/render.js <出力先のルート（keshiin/）> [アプリ画面のPNGがあるフォルダ]
//
// Chromium（Playwright）で SVG / HTML を描いて PNG にする。
// - いつも書き出すもの：アイコン、スプラッシュの絵、Play のアイコンとフィーチャーグラフィック、
//   スクリーンショット用の見本の絵（store/src/photos/、リポジトリには入れない）
// - アプリ画面のフォルダを渡したときだけ：ストアのスクリーンショット
//
// 切手はすべてこのアプリのための自作の形で、額面・通貨記号・郵便を思わせる文字は入れない。
const fs = require('fs');
const path = require('path');
const { chromium } = require('playwright');

const root = path.resolve(process.argv[2] || '.');
const shotsDir = process.argv[3] ? path.resolve(process.argv[3]) : null;

const PAPER = '#F4EFE4';
const CARD = '#FBFAF6';
const INK = '#26303F';
const SHU = '#B8432F';

// ---- 目打ち：アプリ（lib/core/perforation.dart）と同じく、辺ごとに穴の数を先に決めて等分する ----
function perfCenters(x, y, w, h, pitch) {
  const pts = [];
  const corners = [[x, y], [x + w, y], [x + w, y + h], [x, y + h]];
  for (let i = 0; i < 4; i++) {
    const [ax, ay] = corners[i];
    const [bx, by] = corners[(i + 1) % 4];
    const len = Math.hypot(bx - ax, by - ay);
    const n = Math.max(1, Math.round(len / pitch));
    for (let k = 0; k < n; k++) pts.push([ax + (bx - ax) * k / n, ay + (by - ay) * k / n]);
  }
  return pts;
}

let uid = 0;
/// 切手1枚（SVG の <g>）。中心 (cx, cy)、幅 w、高さ h、回転 rot。scene は窓の中の絵（0..1 の座標で描く）。
function stamp({ cx, cy, w, h, rot = 0, scene, postmark = true, paper = CARD, shadow = true }) {
  const id = `s${uid++}`;
  const pitch = Math.min(w, h) * 0.075;
  const r = pitch * 0.36;
  const x = -w / 2, y = -h / 2;
  const holes = perfCenters(x, y, w, h, pitch).map(([px, py]) => `<circle cx="${px}" cy="${py}" r="${r}" fill="black"/>`).join('');
  const m = Math.min(w, h) * 0.085 + r;
  const ww = w - m * 2, wh = h - m * 2;
  const d = Math.min(w, h) * 0.5;
  const pm = postmark ? postmarkSvg(x + w * 0.36, y + h * 0.66, d) : '';
  return `
  <g transform="translate(${cx},${cy}) rotate(${rot})">
    <defs>
      <mask id="${id}m" maskUnits="userSpaceOnUse" x="${x - r * 2}" y="${y - r * 2}" width="${w + r * 4}" height="${h + r * 4}">
        <rect x="${x}" y="${y}" width="${w}" height="${h}" fill="white"/>${holes}
      </mask>
      <clipPath id="${id}c"><rect x="${x + m}" y="${y + m}" width="${ww}" height="${wh}"/></clipPath>
      <filter id="${id}f" x="-10%" y="-10%" width="120%" height="120%">
        <feDropShadow dx="${w * 0.006}" dy="${w * 0.012}" stdDeviation="${w * 0.012}" flood-color="#000" flood-opacity="0.28"/>
      </filter>
    </defs>
    <g ${shadow ? `filter="url(#${id}f)"` : ''}>
      <rect x="${x}" y="${y}" width="${w}" height="${h}" fill="${paper}" mask="url(#${id}m)"/>
    </g>
    <g clip-path="url(#${id}c)">
      <g transform="translate(${x + m},${y + m}) scale(${ww},${wh})">${scene}</g>
    </g>
    <rect x="${x + m}" y="${y + m}" width="${ww}" height="${wh}" fill="none" stroke="#D8D3C8" stroke-width="${w * 0.006}"/>
    ${pm}
  </g>`;
}

/// 消印（二重円と波線）。文字は入れない（アイコン用）。
function postmarkSvg(cx, cy, d) {
  const R = d / 2, r = R * 0.64;
  const waves = [];
  for (let i = 0; i < 5; i++) {
    const yy = cy + (i - 2) * d * 0.15;
    let p = `M ${cx + R * 1.12} ${yy}`;
    for (let s = 1; s <= 24; s++) {
      const xx = cx + R * 1.12 + d * 0.95 * s / 24;
      p += ` L ${xx} ${yy + Math.sin(s / 24 * Math.PI * 4) * d * 0.035}`;
    }
    waves.push(`<path d="${p}" fill="none" stroke="${INK}" stroke-width="${d * 0.03}" stroke-linecap="round"/>`);
  }
  return `<g opacity="0.9" transform="rotate(-9 ${cx} ${cy})">
    <circle cx="${cx}" cy="${cy}" r="${R}" fill="none" stroke="${INK}" stroke-width="${d * 0.04}"/>
    <circle cx="${cx}" cy="${cy}" r="${r}" fill="none" stroke="${INK}" stroke-width="${d * 0.026}"/>
    <line x1="${cx - r * 0.75}" y1="${cy - r * 0.4}" x2="${cx + r * 0.75}" y2="${cy - r * 0.4}" stroke="${INK}" stroke-width="${d * 0.022}"/>
    <line x1="${cx - r * 0.75}" y1="${cy + r * 0.4}" x2="${cx + r * 0.75}" y2="${cy + r * 0.4}" stroke="${INK}" stroke-width="${d * 0.022}"/>
    ${waves.join('')}
  </g>`;
}

// ---- 見本の絵（0..1 の座標）。スクリーンショットで写真の代わりに使う ----
const lin = (id, a, b, vertical = true) =>
  `<linearGradient id="${id}" x1="0" y1="0" x2="${vertical ? 0 : 1}" y2="${vertical ? 1 : 0}"><stop offset="0" stop-color="${a}"/><stop offset="1" stop-color="${b}"/></linearGradient>`;

const scenes = {
  // 夕方の海
  umi: `<defs>${lin('umi1', '#F7B57E', '#F6D7A7')}${lin('umi2', '#3C6E91', '#22445E')}</defs>
    <rect width="1" height="0.62" fill="url(#umi1)"/><circle cx="0.62" cy="0.5" r="0.12" fill="#FFE9C2"/>
    <rect y="0.6" width="1" height="0.4" fill="url(#umi2)"/>
    <rect x="0.48" y="0.62" width="0.28" height="0.012" fill="#FFE9C2" opacity="0.7"/><rect x="0.53" y="0.68" width="0.18" height="0.01" fill="#FFE9C2" opacity="0.5"/>`,
  // 山と空
  yama: `<defs>${lin('ya1', '#8EC5E8', '#D9EEF7')}</defs><rect width="1" height="1" fill="url(#ya1)"/>
    <path d="M0 0.75 L0.3 0.35 L0.45 0.5 L0.62 0.28 L1 0.72 L1 1 L0 1Z" fill="#6E8FA8"/>
    <path d="M0.53 0.4 L0.62 0.28 L0.7 0.38 L0.65 0.37 L0.6 0.41 L0.57 0.38Z" fill="#F4F7FA"/>
    <path d="M0 0.85 Q0.3 0.65 0.6 0.82 T1 0.78 L1 1 L0 1Z" fill="#4E7D4A"/>`,
  // 夜の街
  machi: `<defs>${lin('ma1', '#1C2541', '#3A506B')}</defs><rect width="1" height="1" fill="url(#ma1)"/>
    <circle cx="0.8" cy="0.2" r="0.06" fill="#F3E9C6"/>
    ${[[0.02, 0.5, 0.14], [0.17, 0.38, 0.12], [0.3, 0.55, 0.1], [0.41, 0.3, 0.15], [0.57, 0.48, 0.12], [0.7, 0.42, 0.13], [0.84, 0.58, 0.14]]
      .map(([x, y, w]) => `<rect x="${x}" y="${y}" width="${w}" height="${1 - y}" fill="#0E1424"/>` +
        Array.from({ length: 6 }, (_, i) => `<rect x="${x + 0.02 + (i % 2) * w * 0.45}" y="${y + 0.05 + Math.floor(i / 2) * 0.1}" width="0.025" height="0.035" fill="#F6C76B" opacity="${0.5 + (i % 3) * 0.2}"/>`).join('')).join('')}`,
  // 喫茶店のカップ
  cafe: `<rect width="1" height="1" fill="#C9A27E"/><rect y="0.62" width="1" height="0.38" fill="#7A5236"/>
    <ellipse cx="0.5" cy="0.68" rx="0.3" ry="0.07" fill="#F1EDE6"/>
    <path d="M0.32 0.4 L0.68 0.4 L0.64 0.66 Q0.5 0.72 0.36 0.66Z" fill="#F7F4EF"/>
    <ellipse cx="0.5" cy="0.4" rx="0.18" ry="0.045" fill="#5A3621"/>
    <path d="M0.68 0.45 Q0.8 0.47 0.75 0.56 Q0.7 0.6 0.65 0.58" fill="none" stroke="#F7F4EF" stroke-width="0.03"/>
    <path d="M0.45 0.33 Q0.42 0.25 0.47 0.18 M0.53 0.33 Q0.5 0.24 0.56 0.16" fill="none" stroke="#FFFFFF" stroke-width="0.012" opacity="0.6"/>`,
  // 花
  hana: `<rect width="1" height="1" fill="#E8F1DE"/>
    ${[[0.3, 0.4, '#F29CA3'], [0.62, 0.32, '#F7C6CC'], [0.5, 0.65, '#EE7F8B'], [0.18, 0.75, '#F7C6CC'], [0.82, 0.7, '#F29CA3']]
      .map(([x, y, c]) => Array.from({ length: 5 }, (_, i) => {
        const a = i / 5 * Math.PI * 2;
        return `<circle cx="${x + Math.cos(a) * 0.06}" cy="${y + Math.sin(a) * 0.06}" r="0.055" fill="${c}"/>`;
      }).join('') + `<circle cx="${x}" cy="${y}" r="0.03" fill="#F6D365"/>`).join('')}`,
  // 電車の窓
  densha: `<rect width="1" height="1" fill="#E3DED3"/>
    <rect x="0.08" y="0.12" width="0.84" height="0.6" rx="0.06" fill="#9CC9E3"/>
    <path d="M0.08 0.55 Q0.3 0.45 0.5 0.55 T0.92 0.5 L0.92 0.72 L0.08 0.72Z" fill="#7BA05B"/>
    <circle cx="0.75" cy="0.28" r="0.06" fill="#FFF3D1"/>
    <rect y="0.78" width="1" height="0.22" fill="#7C8A9A"/><rect x="0.05" y="0.82" width="0.9" height="0.05" fill="#5B6876"/>`,
  // 紅葉
  momiji: `<defs>${lin('mo1', '#F3D9B1', '#E9B783')}</defs><rect width="1" height="1" fill="url(#mo1)"/>
    ${Array.from({ length: 14 }, (_, i) => {
      const x = (i * 0.37) % 1, y = (i * 0.53 + 0.1) % 1, c = ['#D2512E', '#E67E22', '#C0392B', '#F0A04B'][i % 4];
      return `<g transform="translate(${x},${y}) rotate(${i * 37}) scale(0.09)"><path d="M0 -1 L0.25 -0.35 L0.95 -0.45 L0.4 0.05 L0.6 0.8 L0 0.35 L-0.6 0.8 L-0.4 0.05 L-0.95 -0.45 L-0.25 -0.35Z" fill="${c}"/></g>`;
    }).join('')}`,
  // ごはん
  gohan: `<rect width="1" height="1" fill="#E9D8BE"/>
    <circle cx="0.5" cy="0.55" r="0.33" fill="#FFFFFF"/><circle cx="0.5" cy="0.55" r="0.27" fill="#F4E3C3"/>
    <circle cx="0.42" cy="0.5" r="0.09" fill="#E8A33D"/><circle cx="0.58" cy="0.58" r="0.08" fill="#7FB069"/><circle cx="0.5" cy="0.65" r="0.06" fill="#D9534F"/>`,
  // 猫
  neko: `<rect width="1" height="1" fill="#F2E6D0"/><rect y="0.7" width="1" height="0.3" fill="#C8B28E"/>
    <ellipse cx="0.5" cy="0.7" rx="0.24" ry="0.14" fill="#5B5550"/>
    <circle cx="0.5" cy="0.48" r="0.14" fill="#5B5550"/>
    <path d="M0.38 0.42 L0.4 0.3 L0.47 0.37Z M0.62 0.42 L0.6 0.3 L0.53 0.37Z" fill="#5B5550"/>
    <circle cx="0.45" cy="0.48" r="0.018" fill="#F6D365"/><circle cx="0.55" cy="0.48" r="0.018" fill="#F6D365"/>
    <path d="M0.72 0.72 Q0.85 0.65 0.8 0.5" fill="none" stroke="#5B5550" stroke-width="0.04" stroke-linecap="round"/>`,
  // 雪
  yuki: `<defs>${lin('yu1', '#B8CCE0', '#E8EEF4')}</defs><rect width="1" height="1" fill="url(#yu1)"/>
    <path d="M0 0.7 Q0.4 0.6 1 0.72 L1 1 L0 1Z" fill="#FFFFFF"/>
    <path d="M0.25 0.68 L0.32 0.45 L0.39 0.68Z M0.62 0.7 L0.7 0.4 L0.78 0.7Z" fill="#3F6B5A"/>
    ${Array.from({ length: 24 }, (_, i) => `<circle cx="${(i * 0.41) % 1}" cy="${(i * 0.29) % 0.7}" r="0.012" fill="#FFFFFF"/>`).join('')}`,
  // 公園の木
  koen: `<rect width="1" height="1" fill="#CFE6F2"/><rect y="0.72" width="1" height="0.28" fill="#8DBF6B"/>
    <rect x="0.47" y="0.45" width="0.06" height="0.3" fill="#7A5A3A"/><circle cx="0.5" cy="0.38" r="0.2" fill="#5E9E4F"/>
    <circle cx="0.38" cy="0.45" r="0.12" fill="#6FB05E"/><circle cx="0.62" cy="0.44" r="0.13" fill="#4F8F43"/>
    <rect x="0.1" y="0.68" width="0.2" height="0.03" fill="#9A7B55"/>`,
  // 灯台
  todai: `<defs>${lin('to1', '#9FD0E8', '#E7F4FA')}</defs><rect width="1" height="1" fill="url(#to1)"/>
    <rect y="0.7" width="1" height="0.3" fill="#3D7EA6"/><path d="M0.55 0.72 L0.85 0.72 L0.8 0.62 L0.6 0.62Z" fill="#8A8170"/>
    <path d="M0.65 0.62 L0.75 0.62 L0.73 0.25 L0.67 0.25Z" fill="#FFFFFF"/><rect x="0.665" y="0.38" width="0.07" height="0.06" fill="${SHU}"/>
    <rect x="0.66" y="0.2" width="0.08" height="0.06" fill="#4A5560"/>`,
};

const page = (body, w, h, extraCss = '') => `<!doctype html><html><head><meta charset="utf-8">
<style>
  html,body{margin:0;width:${w}px;height:${h}px;overflow:hidden;background:transparent}
  body{font-family:"Noto Sans CJK JP","Hiragino Sans","IPAGothic","IPAPGothic",sans-serif}
  ${extraCss}
</style></head><body>${body}</body></html>`;

async function shoot(browser, html, w, h, out, { transparent = false } = {}) {
  const p = await browser.newPage({ viewport: { width: w, height: h }, deviceScaleFactor: 1 });
  await p.setContent(html, { waitUntil: 'load' });
  await p.waitForTimeout(100);
  fs.mkdirSync(path.dirname(out), { recursive: true });
  await p.screenshot({ path: out, omitBackground: transparent });
  await p.close();
  console.log('wrote', path.relative(root, out));
}

const svg = (w, h, body) => `<svg xmlns="http://www.w3.org/2000/svg" width="${w}" height="${h}" viewBox="0 0 ${w} ${h}">${body}</svg>`;

/// アイコン：朱の地に、少し傾けた切手と消印。文字は入れない。
function iconBody(opaque, scale = 1) {
  const s = scale;
  return `${opaque ? `<rect width="1024" height="1024" fill="${SHU}"/>` : ''}
    ${stamp({ cx: 500, cy: 520, w: 600 * s, h: 600 * s, rot: -8, scene: scenes.umi, shadow: opaque })}`;
}

// ---- スクリーンショット ----
const captions = [
  ['01_sheet', '今日の1枚が、切手になる', '1日1枚、月のシートに貼っていく'],
  ['02_create', 'フレームを選んで、消印を押す', '選ぶ、トリミング、保存の3タップ'],
  ['03_detail', '日付と場所は写真から', '撮影日と市区町村が消印に入る'],
  ['04_month', '月末に、シートが完成', '空欄は空欄のまま残る。あとから貼ってもいい'],
  ['05_share', 'そのまま投稿できる画像に', '斜めに置いた1枚、透明なPNG、月のシート'],
];

const SCREEN_RATIO = 956 / 440;

function shotHtml(w, h, [, title, sub], src, crop) {
  const s = w / 1320;
  const top = 430 * s;
  const maxH = h - top - 80 * s;
  let phoneW = 1080 * s;
  if (phoneW * SCREEN_RATIO * crop > maxH) phoneW = maxH / (SCREEN_RATIO * crop);
  const phoneH = phoneW * SCREEN_RATIO * crop;
  const fade = crop < 1
    ? `<div style="position:absolute;left:0;right:0;bottom:0;height:${phoneH * 0.14}px;background:linear-gradient(180deg,rgba(244,239,228,0),${PAPER})"></div>`
    : '';
  return page(`
  <div style="width:${w}px;height:${h}px;position:relative;overflow:hidden;background:${PAPER}">
    <div style="position:absolute;top:${140 * s}px;width:100%;text-align:center;color:${INK};
         font-size:${86 * s}px;font-weight:700;letter-spacing:${2 * s}px">${title}</div>
    <div style="position:absolute;top:${270 * s}px;width:100%;text-align:center;color:#6B6459;font-size:${46 * s}px">${sub}</div>
    <div style="position:absolute;top:${top}px;left:${(w - phoneW) / 2}px;width:${phoneW}px;height:${phoneH}px;overflow:hidden;
         border-radius:${52 * s}px;border:${10 * s}px solid #2E3440;box-shadow:0 ${24 * s}px ${70 * s}px rgba(0,0,0,.25);background:${PAPER}">
      <img src="${src}" style="display:block;width:100%">${fade}
    </div>
  </div>`, w, h);
}

(async () => {
  const browser = await chromium.launch();
  const a = (...p) => path.join(root, ...p);

  // アプリのアイコン（iOS は透過なし）と、Android のアダプティブアイコンの前景（安全域に収める）
  await shoot(browser, page(svg(1024, 1024, iconBody(true)), 1024, 1024), 1024, 1024, a('assets/icon/icon.png'));
  await shoot(browser, page(svg(1024, 1024, iconBody(false, 0.7)), 1024, 1024), 1024, 1024,
    a('assets/icon/icon_foreground.png'), { transparent: true });
  // スプラッシュの中央の絵
  await shoot(browser, page(`<div style="width:384px;height:384px">${svg(384, 384, `<g transform="scale(0.375)">${iconBody(false, 0.8)}</g>`)}</div>`, 384, 384),
    384, 384, a('assets/splash/splash_icon.png'), { transparent: true });

  // Play ストア：512 アイコンと 1024×500 のフィーチャーグラフィック
  await shoot(browser, page(svg(512, 512, `<g transform="scale(0.5)">${iconBody(true)}</g>`), 512, 512), 512, 512, a('store/icon_512.png'));
  await shoot(browser, page(`
    <div style="width:1024px;height:500px;position:relative;overflow:hidden;background:${PAPER}">
      <svg width="1024" height="500" style="position:absolute;inset:0">
        ${stamp({ cx: 700, cy: 270, w: 230, h: 300, rot: -7, scene: scenes.yama })}
        ${stamp({ cx: 880, cy: 230, w: 210, h: 210, rot: 6, scene: scenes.cafe })}
        ${stamp({ cx: 820, cy: 400, w: 190, h: 190, rot: -3, scene: scenes.umi })}
      </svg>
      <div style="position:absolute;left:70px;top:110px;color:${INK};font-size:96px;font-weight:700;letter-spacing:10px">ケシイン</div>
      <div style="position:absolute;left:74px;top:250px;color:${INK};font-size:34px;line-height:1.6">今日の1枚が、切手と消印になる。<br>月末にはシートが完成</div>
      <div style="position:absolute;left:74px;top:392px;color:#6B6459;font-size:22px">広告なし ・ 写真は端末の中だけ</div>
    </div>`, 1024, 500), 1024, 500, a('store/feature_graphic.png'));

  // スクリーンショット用の見本の絵（1200×900）。写真の代わり。リポジトリには入れない
  for (const [name, body] of Object.entries(scenes)) {
    await shoot(browser, page(svg(1200, 900, `<g transform="scale(1200,900)">${body}</g>`), 1200, 900),
      1200, 900, a('store/src/photos', `${name}.png`));
  }

  if (shotsDir) {
    const img = (n) => 'data:image/png;base64,' + fs.readFileSync(path.join(shotsDir, n)).toString('base64');
    const sources = {
      '01_sheet': [img('sheet.png'), 0.86],
      '02_create': [img('create.png'), 1],
      '03_detail': [img('detail.png'), 0.86],
      '04_month': [img('month.png'), 0.8],
      '05_share': [img('share.png'), 1],
    };
    // App Store（6.9インチ：1320×2868）と Google Play（1080×1920）
    for (const [dir, w, h] of [['ios', 1320, 2868], ['android', 1080, 1920]]) {
      for (const c of captions) {
        await shoot(browser, shotHtml(w, h, c, ...sources[c[0]]), w, h, a(`store/screens/${dir}/${c[0]}.png`));
      }
    }
  }
  await browser.close();
})();
