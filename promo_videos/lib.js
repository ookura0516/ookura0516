// 共通の描画部品（SVG 文字列を組み立てる）
// どの関数も「時刻 → その瞬間の絵」を返すだけで、状態を持たない。
// そのため同じ時刻なら何度描いても同じ絵になり、1コマずつ書き出せる。
const L = {};

L.clamp = (x, a = 0, b = 1) => Math.max(a, Math.min(b, x));
L.lerp = (a, b, t) => a + (b - a) * t;
L.seg = (t, a, b) => L.clamp((t - a) / (b - a)); // t が [a, b] のどこにいるか（0〜1）
L.ease = t => (t < 0.5 ? 4 * t * t * t : 1 - Math.pow(-2 * t + 2, 3) / 2);
L.easeOut = t => 1 - Math.pow(1 - t, 3);
L.easeIn = t => t * t * t;
L.back = t => { const c1 = 1.70158, c3 = c1 + 1; return 1 + c3 * Math.pow(t - 1, 3) + c1 * Math.pow(t - 1, 2); };
L.rng = seed => { let s = (seed >>> 0) || 1; return () => { s ^= s << 13; s >>>= 0; s ^= s >> 17; s ^= s << 5; s >>>= 0; return s / 4294967296; }; };
L.esc = s => String(s).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
L.attrs = o => Object.entries(o).filter(([, v]) => v !== undefined && v !== null && v !== false).map(([k, v]) => `${k}="${v}"`).join(' ');
L.el = (tag, a = {}, inner = '') => `<${tag} ${L.attrs(a)}>${inner}</${tag}>`;
L.g = (a, inner) => L.el('g', a, inner);
L.tr = (x, y, s = 1, inner = '') => `<g transform="translate(${x} ${y}) scale(${s})">${inner}</g>`;
L.op = (o, inner) => (o <= 0.001 ? '' : `<g opacity="${L.clamp(o).toFixed(3)}">${inner}</g>`);
L.rect = (x, y, w, h, a = {}) => L.el('rect', { x, y, width: Math.max(0, w), height: Math.max(0, h), ...a });
L.circle = (cx, cy, r, a = {}) => L.el('circle', { cx, cy, r: Math.max(0, r), ...a });
L.line = (x1, y1, x2, y2, a = {}) => L.el('line', { x1, y1, x2, y2, ...a });
L.path = (d, a = {}) => L.el('path', { d, ...a });

// 文字。family は 'sans' | 'maru' | 'mincho'
L.FAM = { sans: "'Noto Sans JP'", maru: "'Zen Maru Gothic'", mincho: "'Shippori Mincho'" };
L.text = (x, y, str, o = {}) => {
  const { size = 40, weight = 500, fam = 'sans', fill = '#222', anchor = 'middle', ls, extra = {} } = o;
  return L.el('text', {
    x, y, 'font-family': L.FAM[fam] || fam, 'font-size': size, 'font-weight': weight, fill,
    'text-anchor': anchor, 'dominant-baseline': 'middle', 'letter-spacing': ls, ...extra,
  }, L.esc(str));
};
// 文字を左から順に出す（入力しているように見せる）
L.typed = (str, p) => { const n = Math.floor(L.clamp(p) * [...str].length + 1e-6); return [...str].slice(0, n).join(''); };

// 1コマごとに使い捨ての id（clipPath など）
L._id = 0;
L.uid = p => `${p}${++L._id}`;
L.resetIds = () => { L._id = 0; };

// 角丸の板
L.card = (x, y, w, h, o = {}) => {
  const { r = 28, fill = '#fff', stroke = 'none', sw = 0, shadow = true, opacity } = o;
  const sh = shadow ? L.rect(x + 6, y + 10, w, h, { rx: r, fill: 'rgba(0,0,0,0.18)', opacity }) : '';
  return sh + L.rect(x, y, w, h, { rx: r, fill, stroke, 'stroke-width': sw, opacity });
};

// スマホの枠。inner は画面の座標（0,0 が画面の左上）で描く
L.phone = (x, y, w, h, inner, o = {}) => {
  const { body = '#1d1f27', screen = '#fff', tilt = 0 } = o;
  const r = w * 0.13, pad = w * 0.045, id = L.uid('ph');
  const sw = w - pad * 2, sh = h - pad * 2;
  return `<g transform="translate(${x + w / 2} ${y + h / 2}) rotate(${tilt}) translate(${-w / 2} ${-h / 2})">`
    + L.rect(8, 14, w, h, { rx: r, fill: 'rgba(0,0,0,0.25)' })
    + L.rect(0, 0, w, h, { rx: r, fill: body })
    + `<clipPath id="${id}">${L.rect(pad, pad, sw, sh, { rx: r - pad })}</clipPath>`
    + `<g clip-path="url(#${id})">${L.rect(pad, pad, sw, sh, { fill: screen })}<g transform="translate(${pad} ${pad})">${inner(sw, sh)}</g></g>`
    + L.rect(w / 2 - w * 0.14, pad + 10, w * 0.28, w * 0.06, { rx: w * 0.03, fill: body })
    + '</g>';
};

// ブラウザの窓。アプリなしで開けることを見せる
L.browser = (x, y, w, h, inner, o = {}) => {
  const { screen = '#fff', label = 'リンクを開くだけ', barFill = '#eceef3', ink = '#555' } = o;
  const bar = Math.max(56, h * 0.11), id = L.uid('br');
  return L.rect(x + 8, y + 14, w, h, { rx: 24, fill: 'rgba(0,0,0,0.22)' })
    + L.rect(x, y, w, h, { rx: 24, fill: screen })
    + `<clipPath id="${id}">${L.rect(x, y, w, h, { rx: 24 })}</clipPath>`
    + `<g clip-path="url(#${id})">`
    + L.rect(x, y, w, bar, { fill: barFill })
    + [0, 1, 2].map(i => L.circle(x + 30 + i * 28, y + bar / 2, 8, { fill: ['#ff6058', '#ffbd2e', '#28c940'][i] })).join('')
    + L.rect(x + 120, y + bar * 0.22, w - 150, bar * 0.56, { rx: bar * 0.28, fill: '#fff' })
    + L.text(x + 150, y + bar / 2 + 1, '🔒', { size: bar * 0.3, anchor: 'start' })
    + L.text(x + 150 + bar * 0.45, y + bar / 2 + 1, label, { size: bar * 0.32, anchor: 'start', fill: ink, weight: 500 })
    + `<g transform="translate(${x} ${y + bar})">${inner(w, h - bar)}</g>`
    + '</g>';
};

// リンクの印（鎖）
L.linkIcon = (cx, cy, s, color = '#fff', bg = '#3478f6') => {
  return L.circle(cx, cy, s, { fill: bg })
    + `<g transform="translate(${cx} ${cy}) rotate(-45) scale(${s / 60})" fill="none" stroke="${color}" stroke-width="9" stroke-linecap="round">`
    + L.rect(-34, -13, 38, 26, { rx: 13 }) + L.rect(-4, -13, 38, 26, { rx: 13 }) + '</g>';
};

// 矢印
L.arrow = (x1, y1, x2, y2, o = {}) => {
  const { color = '#888', w = 6, head = 22, dash } = o;
  const a = Math.atan2(y2 - y1, x2 - x1);
  const hx = x2 - Math.cos(a) * head, hy = y2 - Math.sin(a) * head;
  const p1 = [hx + Math.cos(a + Math.PI / 2) * head * 0.6, hy + Math.sin(a + Math.PI / 2) * head * 0.6];
  const p2 = [hx + Math.cos(a - Math.PI / 2) * head * 0.6, hy + Math.sin(a - Math.PI / 2) * head * 0.6];
  return L.line(x1, y1, hx, hy, { stroke: color, 'stroke-width': w, 'stroke-linecap': 'round', 'stroke-dasharray': dash })
    + L.path(`M${x2} ${y2}L${p1[0]} ${p1[1]}L${p2[0]} ${p2[1]}Z`, { fill: color });
};

// 「作る → リンク → 開く」の流れ。left / right は (w,h) を受けて中身を描く関数
L.flow = (ctx, o) => {
  const { w, h, p, vert } = ctx;
  const { left, right, linkColor = '#3478f6', arrowColor = 'rgba(0,0,0,0.35)', leftLabel, rightLabel, labelFill = '#333', labelFam = 'sans' } = o;
  const aL = L.easeOut(L.seg(p, 0, 0.18)), aLink = L.seg(p, 0.18, 0.42), aR = L.easeOut(L.seg(p, 0.38, 0.58));
  let out = '';
  if (vert) {
    const pw = 300, ph = 560, bx = 120, bw = w - 240, bh = 380;
    const px = w / 2 - pw / 2, py = 0, by = h - bh - 70;
    out += L.op(aL, L.tr(0, (1 - aL) * 40, 1, L.phone(px, py, pw, ph, left)));
    const ay1 = py + ph + 20, ay2 = by - 20;
    out += L.op(L.seg(p, 0.15, 0.25), L.arrow(w / 2, ay1, w / 2, ay2, { color: arrowColor, w: 6, dash: '2 16', head: 26 }));
    const ly = L.lerp(ay1, ay2, L.ease(aLink));
    out += L.op(aLink > 0 && aLink < 1 ? 1 : (aLink >= 1 ? 1 - L.seg(p, 0.42, 0.5) : 0), L.linkIcon(w / 2, ly, 46, '#fff', linkColor));
    out += L.op(aR, L.tr(0, (1 - aR) * 40, 1, L.browser(bx, by, bw, bh, right)));
    if (rightLabel) out += L.op(L.seg(p, 0.55, 0.7), L.text(w / 2, by + bh + 42, rightLabel, { size: 40, weight: 700, fill: labelFill, fam: labelFam }));
    if (leftLabel) out += L.op(aL, L.text(px + pw + 30, py + ph / 2, leftLabel, { size: 34, weight: 700, fill: labelFill, anchor: 'start', fam: labelFam }));
  } else {
    const pw = 330, ph = 620, bw = 760, bh = 520;
    const px = 120, py = (h - ph) / 2, bx = w - bw - 60, by = (h - bh) / 2 - 10;
    out += L.op(aL, L.tr((1 - aL) * -40, 0, 1, L.phone(px, py, pw, ph, left)));
    const ax1 = px + pw + 30, ax2 = bx - 30, ay = h / 2;
    out += L.op(L.seg(p, 0.15, 0.25), L.arrow(ax1, ay, ax2, ay, { color: arrowColor, w: 6, dash: '2 16', head: 26 }));
    const lx = L.lerp(ax1, ax2, L.ease(aLink));
    out += L.op(aLink > 0 && aLink < 1 ? 1 : (aLink >= 1 ? 1 - L.seg(p, 0.42, 0.5) : 0), L.linkIcon(lx, ay, 46, '#fff', linkColor));
    out += L.op(aR, L.tr((1 - aR) * 40, 0, 1, L.browser(bx, by, bw, bh, right)));
    if (rightLabel) out += L.op(L.seg(p, 0.55, 0.7), L.text(bx + bw / 2, by + bh + 46, rightLabel, { size: 40, weight: 700, fill: labelFill, fam: labelFam }));
    if (leftLabel) out += L.op(aL, L.text(px + pw / 2, py + ph + 46, leftLabel, { size: 36, weight: 700, fill: labelFill, fam: labelFam }));
  }
  return out;
};

// 手順の番号
L.stepBadge = (x, y, n, color = '#333', ink = '#fff', fam = 'sans') =>
  L.circle(x, y, 44, { fill: color }) + L.text(x, y + 2, String(n), { size: 50, weight: 900, fill: ink, fam });

// 指先（タップの位置）
L.finger = (x, y, pressed = 0, color = 'rgba(255,255,255,0.9)') =>
  L.circle(x, y, 34 + pressed * 26, { fill: 'none', stroke: color, 'stroke-width': 4, opacity: pressed * 0.8 })
  + L.circle(x, y, 26, { fill: color, stroke: 'rgba(0,0,0,0.25)', 'stroke-width': 3 });

// 字幕を「|」で改行する
L.capLines = cap => cap.split('|');
