// 台本から時間割を作り、時刻 t の1コマを描く
window.APPS = window.APPS || {};

const FMT = {
  // 縦型。下の約300pxと右端はSNSのボタンがかぶるので、字幕はその上に置く
  V: { W: 1080, H: 1920, vert: true, region: { x: 40, y: 250, w: 1000, h: 1100 }, cap: { y: 1490, size: 58, maxW: 980 } },
  // 横型
  H: { W: 1920, H: 1080, vert: false, region: { x: 110, y: 92, w: 1700, h: 760 }, cap: { y: 945, size: 52, maxW: 1760 } },
};

// 読み上げの速さの見込み（1秒あたりの文字数）。声が遅いときは小さくして作り直す
const DEFAULT_CPS = 6.2;

function buildTimeline(appKey, fmt, cps = DEFAULT_CPS) {
  const app = APPS[appKey], F = FMT[fmt];
  const lines = app.scripts[fmt];
  const scenes = [];
  let t = 0;
  lines.forEach((ln, i) => {
    const plain = ln.text.replace(/\|/g, '');
    const chars = [...plain.replace(/\s/g, '')].length;
    const first = i === 0, last = i === lines.length - 1;
    let dur = Math.max(ln.min || 0, chars / cps + 0.9);
    if (first) dur += 0.3;
    if (last) dur += 1.6;
    const voStart = t + (first ? 0.6 : 0.3);
    const voSlot = dur - (first ? 0.9 : 0.5) - (last ? 1.4 : 0);
    scenes.push({
      i, fig: ln.fig, cap: ln.text, text: plain, say: ln.say || plain,
      start: +t.toFixed(3), dur: +dur.toFixed(3),
      vo: { start: +voStart.toFixed(3), slot: +voSlot.toFixed(3) },
    });
    t += dur;
  });
  const tl = { app: appKey, fmt, fps: 30, W: F.W, H: F.H, duration: +t.toFixed(3), cps, scenes, cues: [] };
  tl.cues = app.cues ? app.cues(tl) : [];
  tl.audio = app.audio || {};
  return tl;
}

let ST = null;

window.setup = (appKey, fmt, cps) => {
  const tl = buildTimeline(appKey, fmt, cps || DEFAULT_CPS);
  ST = { app: appKey, fmt, tl };
  const stage = document.getElementById('stage');
  stage.style.width = FMT[fmt].W + 'px';
  stage.style.height = FMT[fmt].H + 'px';
  return tl;
};

// 文字幅のおおよその見積もり（全角1、半角0.58）
function textW(str, size) {
  let w = 0;
  for (const ch of str) w += (ch.charCodeAt(0) > 0xff ? 1 : 0.58);
  return w * size;
}

function caption(sc, lt, F, app) {
  if (sc.fig === 'end') return '';
  const th = app.theme;
  const a = Math.min(1, lt / 0.18, (sc.dur - lt) / 0.18);
  if (a <= 0) return '';
  const lines = L.capLines(sc.cap);
  let size = F.cap.size;
  const widest = Math.max(...lines.map(s => textW(s, size)));
  if (widest > F.cap.maxW - 80) size = size * (F.cap.maxW - 80) / widest;
  const lh = size * 1.42;
  const bw = Math.max(...lines.map(s => textW(s, size))) + 80;
  const bh = lh * lines.length + 44;
  const cx = F.W / 2, y0 = F.cap.y - bh / 2;
  let out = L.rect(cx - bw / 2, y0, bw, bh, { rx: 26, fill: th.capBg });
  lines.forEach((s, i) => {
    out += L.text(cx, y0 + 22 + lh * (i + 0.5) + 2, s, { size, weight: 700, fill: th.capInk, fam: 'sans' });
  });
  return L.op(a, out);
}

function topLabel(F, app, sc, lt) {
  const th = app.theme;
  if (sc.fig === 'end') return '';
  if (F.vert) {
    const name = app.name, cat = app.category;
    const w1 = textW(name, 50) + 50, w2 = textW(cat, 34) + 40;
    const x = F.W / 2 - (w1 + w2 + 16) / 2;
    return L.rect(x, 118, w1, 84, { rx: 42, fill: th.accent })
      + L.text(x + w1 / 2, 162, name, { size: 50, weight: 900, fill: th.onAccent || '#fff', fam: app.fam })
      + L.text(x + w1 + 16 + w2 / 2, 162, cat, { size: 34, weight: 700, fill: th.sub, fam: 'sans' });
  }
  const name = app.name;
  const w1 = textW(name, 40) + 44;
  return L.rect(48, 30, w1, 62, { rx: 31, fill: th.accent })
    + L.text(48 + w1 / 2, 62, name, { size: 40, weight: 900, fill: th.onAccent || '#fff', fam: app.fam })
    + L.text(48 + w1 + 20, 62, app.category, { size: 30, weight: 700, fill: th.sub, anchor: 'start' });
}

function disclaimer(F, app) {
  const s = '画面は開発中のイメージです';
  return F.vert
    ? L.text(F.W / 2, 1700, s, { size: 26, weight: 500, fill: app.theme.faint })
    : L.text(F.W - 40, 1050, s, { size: 24, weight: 500, fill: app.theme.faint, anchor: 'end' });
}

// 最後の画面（名前・ひとこと・公開予定）
function endCard(ctx) {
  const { w, h, lt, vert, app } = ctx;
  const th = app.theme;
  const a = k => L.easeOut(L.seg(lt, 0.15 + k * 0.18, 0.55 + k * 0.18));
  const cx = w / 2;
  const s = vert ? 1 : 0.9;
  const y0 = vert ? 120 : 20;
  let out = '';
  out += L.op(a(0), L.tr(cx, y0 + 170 * s, s, app.motif(ctx)));
  out += L.op(a(1), L.text(cx, y0 + 440 * s, app.name, { size: 170 * s, weight: 900, fill: th.ink, fam: app.fam, ls: 6 }));
  out += L.op(a(1), L.text(cx, y0 + 560 * s, app.category, { size: 52 * s, weight: 700, fill: th.sub }));
  out += L.op(a(2), L.text(cx, y0 + 660 * s, app.catch, { size: 50 * s, weight: 700, fill: th.ink, fam: app.fam }));
  const rel = `${app.release} 公開予定`;
  const rw = textW(rel, 50 * s) + 90 * s;
  out += L.op(a(3), L.rect(cx - rw / 2, y0 + 730 * s, rw, 92 * s, { rx: 46 * s, fill: th.accent })
    + L.text(cx, y0 + 778 * s, rel, { size: 50 * s, weight: 900, fill: th.onAccent || '#fff' }));
  out += L.op(a(4), L.text(cx, y0 + 880 * s, 'Webですぐに試せます', { size: 40 * s, weight: 700, fill: th.sub }));
  return out;
}

window.renderAt = t => {
  L.resetIds();
  const app = APPS[ST.app], F = FMT[ST.fmt], tl = ST.tl;
  const last = tl.scenes[tl.scenes.length - 1];
  const sc = tl.scenes.find(s => t >= s.start && t < s.start + s.dur) || last;
  const lt = t - sc.start, p = L.clamp(lt / sc.dur);
  const ctx = { t, lt, p, dur: sc.dur, w: F.region.w, h: F.region.h, vert: F.vert, fmt: ST.fmt, th: app.theme, app, tl, sc, W: F.W, H: F.H };
  const fade = sc === last ? Math.min(1, lt / 0.3) : Math.min(1, lt / 0.3, (sc.dur - lt) / 0.3);
  const fig = sc.fig === 'end' ? endCard : app.figs[sc.fig];
  if (!fig) throw new Error('図がありません: ' + sc.fig);
  let svg = `<svg xmlns="http://www.w3.org/2000/svg" width="${F.W}" height="${F.H}" viewBox="0 0 ${F.W} ${F.H}">`;
  svg += `<defs>${app.defs ? app.defs(ctx) : ''}</defs>`;
  svg += app.bg(ctx);
  const zoom = 0.97 + 0.03 * L.easeOut(L.clamp(lt / 0.5));
  const rx = F.region.x + F.region.w / 2, ry = F.region.y + F.region.h / 2;
  svg += L.op(fade, `<g transform="translate(${rx} ${ry}) scale(${zoom}) translate(${-F.region.w / 2} ${-F.region.h / 2})">${fig(ctx)}</g>`);
  svg += topLabel(F, app, sc, lt);
  svg += caption(sc, lt, F, app);
  svg += disclaimer(F, app);
  svg += '</svg>';
  document.getElementById('stage').innerHTML = svg;
};

// 字体の読み込み待ち用：すべての場面を一度ずつ描いて、使う文字の字体を読ませる
window.warmup = async () => {
  const tl = ST.tl;
  for (const s of tl.scenes) {
    for (const f of [0.2, 0.5, 0.9]) { window.renderAt(s.start + s.dur * f); await document.fonts.ready; }
  }
  await new Promise(r => setTimeout(r, 300));
  await document.fonts.ready;
};
