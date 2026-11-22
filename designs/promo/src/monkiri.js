// モンキリ：折って、切って、ひらく切り紙。
// 重なる枚数を 2n とすると、たたんだ紙は 180°/n の扇形。切り取りを n 回の回転と鏡映で写すと、ひらいた形になる（設計書の「折り方」）。
(function () {
  const T = {
    bg: '#F3ECE0',
    ink: '#2B2420',
    sub: '#6B5E52',
    accent: '#C8443A',
    screen: '#FBF7F0',
    capFamily: 'Shippori Mincho',
    capWeight: 800,
    capSize: 88,
    capSizeH: 96,
  };
  const COL = {
    ai: '#2E4A7D',
    sakura: '#E89AB0',
    wakakusa: '#6E9B4F',
    moegi: '#86B25E',
    shu: '#C8443A',
    yamabuki: '#E2A935',
  };

  // ---- 形の作り方 ----
  // 点は [r, φ]。r は扇の半径を1とした距離、φ は折り目（0°）からの角度
  function outside(fn, theta, steps = 36) {
    const pts = [[1.5, -4]];
    for (let i = 0; i <= steps; i++) {
      const phi = (theta * i) / steps;
      pts.push([fn(phi), phi]);
    }
    pts.push([1.5, theta + 4]);
    return pts;
  }
  // 扇の座標で円を描く（中心 r, φ、半径 rad）
  function circlePoly(rc, pc, rad, n = 14) {
    const cx = rc * Math.cos(E.rad(pc)), cy = rc * Math.sin(E.rad(pc));
    const pts = [];
    for (let i = 0; i < n; i++) {
      const a = (i / n) * E.TAU;
      const x = cx + rad * Math.cos(a), y = cy + rad * Math.sin(a);
      pts.push([Math.hypot(x, y), (Math.atan2(y, x) * 180) / Math.PI]);
    }
    return pts;
  }
  const centerHole = (theta, r) => [[0, theta / 2], [r, -6], [r, theta + 6]];
  const hex = (a, phi) => (a * Math.cos(E.rad(30))) / Math.cos(E.rad(30 - phi));

  const PATTERNS = {
    yuki: {
      name: '雪', n: 6, color: COL.ai,
      cuts: [
        [[1.14, 9], [0.8, 15], [1.14, 21]],
        [[0.64, 15], [0.53, 10.5], [0.42, 15], [0.53, 19.5]],
        [[0.7, -3], [0.8, 5.5], [0.9, -3]],
        [[0.2, 33], [0.24, 24], [0.33, 21.5], [0.41, 25], [0.43, 33]],
        [[0, 15], [0.12, -4], [0.12, 34]],
      ],
    },
    sakura: {
      name: '桜', n: 5, color: COL.sakura,
      cuts: [
        outside((p) => {
          const x = p / 36;
          let b = 0.4 + 0.58 * Math.pow(Math.cos((x * Math.PI) / 2), 0.7);
          if (x < 0.16) b -= 0.17 * Math.pow(1 - x / 0.16, 1.4);
          return b;
        }, 36),
        [[0.48, -3], [0.6, 3.5], [0.72, -3]],
        centerHole(36, 0.1),
        circlePoly(0.27, 18, 0.035, 10),
      ],
    },
    asanoha: {
      name: '麻の葉', n: 6, color: COL.wakakusa,
      cuts: [
        outside((p) => hex(0.97, p), 30),
        [[0.18, 27.5], [0.8, 30.4], [0.18, 33.5]],
        [[0.2, -3.5], [0.84, -0.4], [0.2, 3.5]],
        [[0.3, 3], [0.66, 25], [0.6, 27.5], [0.26, 6.5]],
        centerHole(30, 0.08),
      ],
    },
    yotsuba: {
      name: '四つ葉', n: 2, color: COL.moegi,
      cuts: [
        outside((p) => {
          const x = Math.min(p, 90 - p) / 45;
          let b = 0.3 + 0.66 * Math.pow(Math.max(0, 1 - x * x), 0.55);
          if (x < 0.17) b -= 0.22 * Math.pow(1 - x / 0.17, 1.3);
          return b;
        }, 90, 60),
        [[0.3, -2], [0.62, 0.6], [0.3, 2]],
        centerHole(90, 0.08),
      ],
    },
    ume: {
      name: '梅', n: 5, color: COL.shu,
      cuts: [
        outside((p) => {
          const x = p / 36;
          return 0.5 + 0.47 * Math.sqrt(Math.max(0, 1 - Math.pow(x, 2.2)));
        }, 36),
        circlePoly(0.3, 18, 0.05, 12),
        circlePoly(0.62, 0, 0.06, 12),
        centerHole(36, 0.11),
      ],
    },
    kikko: {
      name: '亀甲', n: 6, color: COL.yamabuki,
      cuts: [
        outside((p) => hex(0.97, p), 30),
        (() => {
          const pts = [];
          for (let p = 5; p <= 25; p += 2) pts.push([hex(0.72, p), p]);
          for (let p = 25; p >= 5; p -= 2) pts.push([hex(0.6, p), p]);
          return pts;
        })(),
        circlePoly(0.33, 0, 0.07, 12),
        centerHole(30, 0.1),
      ],
    },
  };

  // ---- 紙を描く ----
  // A：見えている角度（扇＝180/n 〜 円＝360）。cutsUpTo：切り終えた数。trace：切っている途中の線
  const CX = 195, CY = 440;
  function geom(A) {
    if (A >= 359.9) return { R: 168, apx: CX, apy: CY };
    if (A > 180) {
      const t = (A - 180) / 180;
      return { R: E.lerp(172, 168, t), apx: CX, apy: E.lerp(CY + 86, CY, t) };
    }
    const R = Math.min(540, 172 / Math.sin(E.rad(A / 2)));
    return { R, apx: CX, apy: CY + R / 2 };
  }
  // 扇の座標 → 画面
  function toXY(g, theta, r, phi, k = 0, mirror = false) {
    const a = E.rad(-90 - theta / 2 + 2 * k * theta + (mirror ? -phi : phi));
    return [g.apx + g.R * r * Math.cos(a), g.apy + g.R * r * Math.sin(a)];
  }

  function drawPaper(ctx, pat, A, o = {}) {
    const theta = 180 / pat.n;
    const g = o.g || geom(A);
    const m = ctx.getTransform();
    const cv = ctx.canvas;
    const off = E.offscreen('paper', cv.width, cv.height);
    const oc = off.getContext('2d');
    // 紙のまわりだけを使う
    const pad = g.R * 1.1 + 20;
    const corners = [[-1, -1], [1, -1], [1, 1], [-1, 1]].map(([a, b]) => m.transformPoint(new DOMPoint(g.apx + a * pad, g.apy + b * pad)));
    const xs = corners.map((q) => q.x), ys = corners.map((q) => q.y);
    const bx = Math.max(0, Math.floor(Math.min(...xs))), by = Math.max(0, Math.floor(Math.min(...ys)));
    const bw = Math.min(cv.width, Math.ceil(Math.max(...xs))) - bx;
    const bh = Math.min(cv.height, Math.ceil(Math.max(...ys))) - by;
    if (bw <= 0 || bh <= 0) return;
    oc.setTransform(1, 0, 0, 1, 0, 0);
    oc.globalCompositeOperation = 'source-over';
    oc.clearRect(bx, by, bw, bh);
    oc.setTransform(m);
    oc.save();
    oc.beginPath();
    const sec = o.sector || [-A / 2, A / 2];
    if (sec[1] - sec[0] >= 359.9) oc.arc(g.apx, g.apy, g.R, 0, E.TAU);
    else {
      oc.moveTo(g.apx, g.apy);
      oc.arc(g.apx, g.apy, g.R, E.rad(-90 + sec[0]), E.rad(-90 + sec[1]));
      oc.closePath();
    }
    const grad = oc.createRadialGradient(g.apx - g.R * 0.3, g.apy - g.R * 0.4, g.R * 0.1, g.apx, g.apy, g.R * 1.2);
    grad.addColorStop(0, o.light || shade(pat.color, 0.12));
    grad.addColorStop(1, pat.color);
    oc.fillStyle = grad;
    oc.fill();
    // 折り目のあと
    if (o.creases && A >= 359.9) {
      oc.strokeStyle = 'rgba(255,255,255,0.13)';
      oc.lineWidth = 1.2;
      oc.beginPath();
      for (let k = 0; k < 2 * pat.n; k++) {
        const a = E.rad(-90 - theta / 2 + k * theta);
        oc.moveTo(g.apx, g.apy);
        oc.lineTo(g.apx + g.R * Math.cos(a), g.apy + g.R * Math.sin(a));
      }
      oc.stroke();
    }
    // 切り取り
    oc.globalCompositeOperation = 'destination-out';
    const n = o.cutsUpTo ?? pat.cuts.length;
    oc.fillStyle = '#000';
    for (let ci = 0; ci < n; ci++) {
      const poly = pat.cuts[ci];
      for (let k = 0; k < pat.n; k++) {
        for (const mir of [false, true]) {
          oc.beginPath();
          poly.forEach(([r, phi], i) => {
            const [x, y] = toXY(g, theta, r, phi, k, mir);
            if (i) oc.lineTo(x, y); else oc.moveTo(x, y);
          });
          oc.closePath();
          oc.fill();
        }
      }
    }
    oc.restore();
    if (o.dim) {
      // 裏返っている途中の紙を少し暗く（作業用のキャンバスの紙の上だけ）
      oc.save();
      oc.setTransform(1, 0, 0, 1, 0, 0);
      oc.globalCompositeOperation = 'source-atop';
      oc.fillStyle = `rgba(0,0,0,${o.dim})`;
      oc.fillRect(bx, by, bw, bh);
      oc.restore();
    }
    ctx.save();
    ctx.setTransform(1, 0, 0, 1, 0, 0);
    ctx.shadowColor = 'rgba(60,30,10,0.28)';
    ctx.shadowBlur = 16 * m.a;
    ctx.shadowOffsetY = 6 * m.a;
    if (o.alpha != null) ctx.globalAlpha *= o.alpha;
    ctx.drawImage(off, bx, by, bw, bh, bx, by, bw, bh);
    ctx.restore();
  }
  function shade(hexCol, k) {
    const n = parseInt(hexCol.slice(1), 16);
    const c = [(n >> 16) & 255, (n >> 8) & 255, n & 255].map((v) => Math.round(v + (255 - v) * k));
    return `rgb(${c[0]},${c[1]},${c[2]})`;
  }

  // 段階 [[f, A], ...] のうち、いまどこにいるか
  function stageAt(stages, f) {
    if (f <= stages[0][0]) return { from: stages[0][1], to: stages[0][1], p: 0 };
    for (let i = 1; i < stages.length; i++) {
      const [f0, a0] = stages[i - 1], [f1, a1] = stages[i];
      if (f <= f1) return { from: a0, to: a1, p: E.seg(f, f0, f1) };
    }
    const last = stages[stages.length - 1][1];
    return { from: last, to: last, p: 0 };
  }

  // 折る・ひらく途中を描く。まん中の扇は動かさず、両側の紙を折り線のまわりに裏返す
  function drawFolding(ctx, pat, st, o = {}) {
    const e = E.ease.inOutCubic(st.p);
    const g0 = geom(st.from), g1 = geom(st.to);
    // 大きさは先に合わせる（ひらくときは早めに縮め、折るときは遅めに大きくする）
    const ge = st.to > st.from ? E.ease.outCubic(st.p) : E.ease.inCubic(st.p);
    const g = { R: E.lerp(g0.R, g1.R, ge), apx: E.lerp(g0.apx, g1.apx, ge), apy: E.lerp(g0.apy, g1.apy, ge) };
    if (st.from === st.to || st.p <= 0) {
      drawPaper(ctx, pat, st.from, { ...o, g, creases: o.creases && st.from >= 359.9 });
      return g;
    }
    const lo = Math.min(st.from, st.to), hi = Math.max(st.from, st.to);
    // folded：0 ならひらいた状態、1 なら折り重なった状態
    const folded = st.to > st.from ? 1 - e : e;
    drawPaper(ctx, pat, lo, { ...o, g, sector: [-lo / 2, lo / 2] });
    for (const side of [1, -1]) {
      const line = E.rad(-90 + (side * lo) / 2);
      const c = Math.cos(Math.PI * folded);
      ctx.save();
      ctx.translate(g.apx, g.apy);
      ctx.rotate(line);
      ctx.scale(1, c === 0 ? 0.001 : c);
      ctx.rotate(-line);
      ctx.translate(-g.apx, -g.apy);
      const sector = side > 0 ? [lo / 2, hi / 2] : [-hi / 2, -lo / 2];
      drawPaper(ctx, pat, hi, { ...o, g, sector, dim: 0.18 * Math.sin(Math.PI * folded) });
      ctx.restore();
    }
    return g;
  }

  function sparkle(ctx, f, cx, cy, R, seed = 1) {
    if (f <= 0 || f >= 1) return;
    const rnd = E.rng(seed);
    for (let i = 0; i < 14; i++) {
      const a = rnd() * E.TAU, d = R * (0.7 + rnd() * 0.6);
      const p = E.clamp(f * 1.4 - rnd() * 0.4);
      if (p <= 0 || p >= 1) continue;
      const x = cx + Math.cos(a) * d * (0.8 + 0.3 * p), y = cy + Math.sin(a) * d * (0.8 + 0.3 * p);
      const s = 7 * Math.sin(p * Math.PI);
      ctx.save();
      ctx.translate(x, y);
      ctx.fillStyle = '#F5C451';
      ctx.beginPath();
      ctx.moveTo(0, -s * 1.8); ctx.lineTo(s * 0.4, -s * 0.4); ctx.lineTo(s * 1.8, 0); ctx.lineTo(s * 0.4, s * 0.4);
      ctx.lineTo(0, s * 1.8); ctx.lineTo(-s * 0.4, s * 0.4); ctx.lineTo(-s * 1.8, 0); ctx.lineTo(-s * 0.4, -s * 0.4);
      ctx.closePath();
      ctx.fill();
      ctx.restore();
    }
  }

  function topBar(ctx, label) {
    E.statusBar(ctx, T.ink);
    E.fillRR(ctx, 24, 58, 148, 34, 17, '#fff', { stroke: '#E3D8C6', lw: 1.5 });
    E.text(ctx, label, 98, 76, { size: 15, weight: 900, color: T.ink, align: 'center', baseline: 'middle' });
    E.text(ctx, '↶', 318, 84, { size: 24, weight: 700, color: T.sub, align: 'center' });
    E.text(ctx, '↷', 356, 84, { size: 24, weight: 700, color: '#C7BBAA', align: 'center' });
  }
  function tools(ctx) {
    E.fillRR(ctx, 24, 106, 110, 34, 17, T.ink);
    E.text(ctx, 'なぞる', 79, 124, { size: 15, weight: 900, color: '#fff', align: 'center', baseline: 'middle' });
    E.fillRR(ctx, 142, 106, 128, 34, 17, '#fff', { stroke: '#E3D8C6', lw: 1.5 });
    E.text(ctx, '点でつなぐ', 206, 124, { size: 15, weight: 900, color: T.ink, align: 'center', baseline: 'middle' });
  }
  const OPEN_BTN = { x: 30, y: 760, w: 330, h: 56 };
  function openButton(ctx, press = 0, alpha = 1) {
    E.button(ctx, OPEN_BTN.x, OPEN_BTN.y, OPEN_BTN.w, OPEN_BTN.h, 'ひらく', {
      fill: T.accent, size: 23, weight: 900, family: 'Shippori Mincho', press, alpha,
    });
  }

  // ---- 場面 ----
  const FOLD_STAGES = [[0.08, 360], [0.32, 180], [0.38, 180], [0.62, 60], [0.68, 60], [0.9, 30]];
  function sFold(ctx, local, f, d) {
    topBar(ctx, '雪折り・12枚');
    tools(ctx);
    drawFolding(ctx, { ...PATTERNS.yuki, cuts: [] }, stageAt(FOLD_STAGES, f));
    openButton(ctx, 0, 0.5);
  }

  // 切る順と時間
  const CUT_A = 0.05, CUT_B = 0.95;
  const CUT_PLAN = (() => {
    const pat = PATTERNS.yuki;
    const g = geom(30);
    const lens = pat.cuts.map((poly) => {
      let L = 0;
      for (let i = 0; i < poly.length; i++) {
        const [a, b] = [poly[i], poly[(i + 1) % poly.length]];
        const p = toXY(g, 30, a[0], a[1]), q = toXY(g, 30, b[0], b[1]);
        L += Math.hypot(p[0] - q[0], p[1] - q[1]);
      }
      return L + 160;
    });
    const total = lens.reduce((a, b) => a + b, 0);
    let t = CUT_A;
    return lens.map((L) => {
      const span = ((CUT_B - CUT_A) * L) / total;
      const r = { a: t, b: t + span * 0.82 };
      t += span;
      return r;
    });
  })();

  function pointOnPoly(g, poly, q) {
    const pts = poly.map(([r, p]) => toXY(g, 30, r, p));
    pts.push(pts[0]);
    const segs = [];
    let L = 0;
    for (let i = 0; i < pts.length - 1; i++) {
      const l = Math.hypot(pts[i + 1][0] - pts[i][0], pts[i + 1][1] - pts[i][1]);
      segs.push(l);
      L += l;
    }
    let want = q * L;
    const done = [pts[0]];
    for (let i = 0; i < segs.length; i++) {
      if (want <= segs[i]) {
        const k = segs[i] ? want / segs[i] : 0;
        const p = [E.lerp(pts[i][0], pts[i + 1][0], k), E.lerp(pts[i][1], pts[i + 1][1], k)];
        done.push(p);
        return { tip: p, done };
      }
      want -= segs[i];
      done.push(pts[i + 1]);
    }
    return { tip: pts[pts.length - 1], done };
  }

  function sCut(ctx, local, f, d) {
    topBar(ctx, '雪折り・12枚');
    tools(ctx);
    const pat = PATTERNS.yuki;
    const g = geom(30);
    let finished = 0;
    CUT_PLAN.forEach((c, i) => { if (f >= c.b) finished = i + 1; });
    drawPaper(ctx, pat, 30, { cutsUpTo: finished });
    // 切ったばかりの所を光らせる
    CUT_PLAN.forEach((c, i) => {
      const k = E.seg(f, c.b, c.b + 0.05);
      if (k <= 0 || k >= 1) return;
      ctx.save();
      ctx.globalAlpha *= 1 - k;
      ctx.strokeStyle = '#F5C451';
      ctx.lineWidth = 5;
      ctx.beginPath();
      pat.cuts[i].forEach(([r, p], j) => {
        const [x, y] = toXY(g, 30, r, p);
        if (j) ctx.lineTo(x, y); else ctx.moveTo(x, y);
      });
      ctx.closePath();
      ctx.stroke();
      ctx.restore();
    });
    // なぞっている線と指
    const cur = CUT_PLAN.findIndex((c) => f >= c.a && f < c.b);
    if (cur >= 0) {
      const c = CUT_PLAN[cur];
      const q = E.ease.inOutQuad(E.seg(f, c.a, c.b));
      const { tip, done } = pointOnPoly(g, pat.cuts[cur], q);
      ctx.save();
      ctx.setLineDash([7, 6]);
      ctx.lineDashOffset = -local * 40;
      ctx.strokeStyle = '#FFF6E4';
      ctx.lineWidth = 3;
      ctx.lineJoin = 'round';
      ctx.beginPath();
      done.forEach(([x, y], j) => (j ? ctx.lineTo(x, y) : ctx.moveTo(x, y)));
      ctx.stroke();
      ctx.restore();
      ctx.save();
      ctx.shadowColor = 'rgba(0,0,0,0.3)';
      ctx.shadowBlur = 10;
      E.circle(ctx, tip[0], tip[1], 15, 'rgba(255,255,255,0.9)', { stroke: 'rgba(0,0,0,0.15)', lw: 1.5 });
      ctx.restore();
    }
    openButton(ctx, 0, 0.5 + 0.5 * E.seg(f, 0.9, 1));
  }

  const UNFOLD_STAGES = [[0.12, 30], [0.3, 60], [0.36, 60], [0.54, 180], [0.6, 180], [0.8, 360]];
  function sUnfold(ctx, local, f, d) {
    topBar(ctx, '雪折り・12枚');
    const pat = PATTERNS.yuki;
    const st = stageAt(UNFOLD_STAGES, f);
    const spin = E.ease.outCubic(E.seg(f, 0.8, 1)) * 0.25;
    ctx.save();
    if (st.from >= 359.9) {
      ctx.translate(CX, CY);
      ctx.rotate(spin);
      const s = 1 + 0.08 * Math.sin(E.seg(f, 0.8, 0.95) * Math.PI);
      ctx.scale(s, s);
      ctx.translate(-CX, -CY);
    }
    drawFolding(ctx, pat, st, { creases: true });
    ctx.restore();
    sparkle(ctx, E.seg(f, 0.8, 1), CX, CY, 200, 3);
    const kb = E.seg(f, 0.82, 0.98);
    if (kb > 0) {
      ctx.save();
      ctx.globalAlpha *= kb;
      ['保存', '共有', 'たたみ直す'].forEach((s, i) => {
        E.button(ctx, 30 + i * 114, 760, 102, 50, s, {
          fill: i === 1 ? T.accent : '#fff', color: i === 1 ? '#fff' : T.ink, size: 17, weight: 900,
          stroke: i === 1 ? null : '#E3D8C6', lw: 1.5, shadow: false,
        });
      });
      ctx.restore();
    } else {
      openButton(ctx, Math.sin(E.seg(f, 0.03, 0.1) * Math.PI), 1 - E.seg(f, 0.1, 0.2));
      E.tap(ctx, 195, 788, E.seg(f, 0.02, 0.14));
    }
  }

  const GALLERY = [
    { key: 'yuki', at: -1 },
    { key: 'sakura', at: 0.12 },
    { key: 'asanoha', at: 0.32 },
    { key: 'yotsuba', at: 0.52 },
    { key: 'ume', at: null },
    { key: 'kikko', at: null },
  ];
  function sGallery(ctx, local, f, d) {
    E.statusBar(ctx, T.ink);
    E.text(ctx, '図鑑', 30, 92, { size: 28, weight: 800, family: 'Shippori Mincho', color: T.ink });
    const got = GALLERY.filter((x) => x.at != null && f >= x.at).length;
    E.text(ctx, `${got} / 36`, 360, 90, { size: 17, weight: 900, color: T.sub, align: 'right' });
    ['すべて', '雪', '花', '紋'].forEach((s, i) => {
      const on = i === 0;
      E.fillRR(ctx, 30 + i * 74, 112, 66, 32, 16, on ? T.ink : '#fff', { stroke: on ? T.ink : '#E3D8C6', lw: 1.5 });
      E.text(ctx, s, 63 + i * 74, 129, { size: 14, weight: 900, color: on ? '#fff' : T.ink, align: 'center', baseline: 'middle' });
    });
    GALLERY.forEach((item, i) => {
      const col = i % 2, row = Math.floor(i / 2);
      const x = 30 + col * 170, y = 160 + row * 212;
      E.fillRR(ctx, x, y, 160, 200, 18, '#fff', { stroke: '#EDE4D6', lw: 1.5 });
      const pat = PATTERNS[item.key];
      const cx = x + 80, cy = y + 88;
      const shown = item.at != null && f >= item.at;
      if (shown) {
        const k = item.at < 0 ? 1 : E.ease.outBack(E.seg(f, item.at, item.at + 0.12));
        ctx.save();
        ctx.translate(cx, cy);
        ctx.rotate((1 - E.clamp(k)) * -1.2);
        ctx.scale(k, k);
        ctx.translate(-cx, -cy);
        drawPaper(ctx, pat, 360, { g: { R: 62, apx: cx, apy: cy } });
        ctx.restore();
        E.text(ctx, pat.name, cx, y + 182, { size: 18, weight: 800, family: 'Shippori Mincho', color: T.ink, align: 'center' });
        if (item.at >= 0) {
          const nb = E.seg(f, item.at + 0.05, item.at + 0.12);
          E.fillRR(ctx, x + 104, y + 10, 46, 22, 11, T.accent, { alpha: nb });
          E.text(ctx, 'NEW', x + 127, y + 22, { size: 12, weight: 900, color: '#fff', align: 'center', baseline: 'middle', alpha: nb });
        }
      } else {
        E.circle(ctx, cx, cy, 60, '#EFE8DC');
        E.text(ctx, '？', cx, cy + 2, { size: 40, weight: 800, family: 'Shippori Mincho', color: '#CDBFAB', align: 'center', baseline: 'middle' });
        E.text(ctx, '？？', cx, y + 182, { size: 18, weight: 800, family: 'Shippori Mincho', color: '#CDBFAB', align: 'center' });
      }
    });
  }

  function chatHeader(ctx) {
    E.statusBar(ctx, T.ink);
    E.text(ctx, '‹', 24, 88, { size: 34, weight: 700, color: T.sub });
    E.circle(ctx, 70, 79, 17, '#E2A935');
    E.text(ctx, 'は', 70, 80, { size: 16, weight: 900, color: '#fff', align: 'center', baseline: 'middle' });
    E.text(ctx, 'はるか', 96, 86, { size: 19, weight: 900, color: T.ink });
    ctx.fillStyle = 'rgba(0,0,0,0.06)';
    ctx.fillRect(0, 108, 390, 1.5);
  }

  const SHARE_STAGES = [[0.56, 36], [0.68, 180], [0.72, 180], [0.84, 360]];
  function sShare(ctx, local, f, d) {
    const swap = 0.36;
    const pat = PATTERNS.ume;
    if (f < swap) {
      ctx.fillStyle = '#F1EADF';
      ctx.fillRect(0, 0, 390, 844);
      chatHeader(ctx);
      const k1 = E.ease.outBack(E.seg(f, 0.02, 0.16));
      ctx.save();
      ctx.globalAlpha *= E.clamp(k1);
      ctx.translate(0, (1 - k1) * 30);
      E.fillRR(ctx, 24, 140, 272, 250, 20, '#fff', { shadow: 'rgba(0,0,0,0.08)', blur: 10, dy: 3 });
      E.fillRR(ctx, 24, 140, 272, 140, [20, 20, 0, 0], '#F4E3CF');
      drawPaper(ctx, pat, 36, { g: { R: 118, apx: 160, apy: 270 } });
      E.text(ctx, '紙がとどきました', 42, 318, { size: 18, weight: 900, color: T.ink });
      E.text(ctx, 'ひらいてみて', 42, 346, { size: 14, weight: 700, color: T.sub });
      E.text(ctx, 'タップしてブラウザでひらく', 42, 374, { size: 13, weight: 700, color: T.accent });
      ctx.restore();
      E.tap(ctx, 160, 230, E.seg(f, 0.24, 0.36));
    } else {
      E.statusBar(ctx, T.ink);
      E.text(ctx, 'はるか さんから', 195, 96, { size: 17, weight: 700, color: T.sub, align: 'center' });
      E.text(ctx, '梅折り・10枚', 195, 128, { size: 22, weight: 800, family: 'Shippori Mincho', color: T.ink, align: 'center' });
      const st = stageAt(SHARE_STAGES, f);
      const k = E.ease.outBack(E.seg(f, swap, swap + 0.08));
      ctx.save();
      ctx.translate(CX, CY);
      ctx.scale(0.8 + 0.2 * k, 0.8 + 0.2 * k);
      ctx.translate(-CX, -CY);
      drawFolding(ctx, pat, st, { creases: true });
      ctx.restore();
      sparkle(ctx, E.seg(f, 0.84, 1), CX, CY, 200, 9);
      if (f < 0.58) {
        const pulse = 1 + 0.035 * Math.sin(local * 9);
        ctx.save();
        ctx.translate(195, 788);
        ctx.scale(pulse, pulse);
        ctx.translate(-195, -788);
        openButton(ctx, Math.sin(E.seg(f, 0.48, 0.56) * Math.PI), 1 - E.seg(f, 0.56, 0.6));
        ctx.restore();
        E.tap(ctx, 195, 788, E.seg(f, 0.47, 0.6));
      }
      const kb = E.seg(f, 0.86, 0.98);
      if (kb > 0) {
        E.button(ctx, 30, 760, 330, 54, '自分も切ってみる', {
          fill: T.ink, size: 20, weight: 900, alpha: kb, family: 'Shippori Mincho',
        });
      }
    }
  }

  // ---- 背景・ロゴ・終わり ----
  let bgTex = null;
  function bg(ctx, t, W, H) {
    if (!bgTex || bgTex.width !== W) {
      bgTex = document.createElement('canvas');
      bgTex.width = W;
      bgTex.height = H;
      const b = bgTex.getContext('2d');
      b.fillStyle = T.bg;
      b.fillRect(0, 0, W, H);
      // 和紙の繊維
      const R = E.rng(17);
      b.strokeStyle = 'rgba(120,90,60,0.06)';
      b.lineWidth = 1.2;
      for (let i = 0; i < 900; i++) {
        const x = R() * W, y = R() * H, a = R() * E.TAU, l = 8 + R() * 26;
        b.beginPath();
        b.moveTo(x, y);
        b.quadraticCurveTo(x + Math.cos(a + 0.6) * l * 0.5, y + Math.sin(a + 0.6) * l * 0.5, x + Math.cos(a) * l, y + Math.sin(a) * l);
        b.stroke();
      }
      // 麻の葉のうすい線
      b.strokeStyle = 'rgba(200,68,58,0.06)';
      b.lineWidth = 2;
      const S = 120;
      for (let y = -1; y < H / S + 1; y++) for (let x = -1; x < W / S + 1; x++) {
        const cx = x * S + (y % 2 ? S / 2 : 0), cy = y * S * 0.87;
        b.beginPath();
        for (let k = 0; k < 6; k++) {
          const a = (k / 6) * E.TAU + Math.PI / 6;
          b.moveTo(cx, cy);
          b.lineTo(cx + (Math.cos(a) * S) / 1.73, cy + (Math.sin(a) * S) / 1.73);
        }
        b.stroke();
      }
    }
    ctx.drawImage(bgTex, 0, 0);
  }

  function logo(ctx, x, y, size, alpha) {
    E.text(ctx, 'モンキリ', x, y, { size, weight: 800, family: 'Shippori Mincho', color: T.accent, alpha });
  }

  function icon(ctx, cx, cy, s) {
    E.fillRR(ctx, cx - s / 2, cy - s / 2, s, s, s * 0.23, T.accent, { shadow: 'rgba(120,40,20,0.3)', blur: s * 0.12, dy: s * 0.05 });
    drawPaper(ctx, { ...PATTERNS.yuki, color: '#FFF6EA' }, 360, { g: { R: s * 0.36, apx: cx, apy: cy }, light: '#FFFFFF' });
  }

  function endCard(ctx, local, k, W, H, fmt) {
    ctx.save();
    ctx.globalAlpha = k;
    bg(ctx, 0, W, H);
    ctx.restore();
    const cx = W / 2;
    const v = fmt === 'v';
    const cy = v ? 760 : 380;
    const a = E.seg(local, 0.15, 0.6);
    ctx.save();
    ctx.globalAlpha *= a;
    const s = 0.9 + 0.1 * E.ease.outBack(a);
    ctx.translate(cx, cy);
    ctx.scale(s, s);
    ctx.save();
    ctx.translate(0, -(v ? 260 : 190));
    ctx.rotate((1 - a) * -0.6);
    icon(ctx, 0, 0, v ? 230 : 190);
    ctx.restore();
    E.text(ctx, 'モンキリ', 0, v ? 80 : 60, { size: v ? 170 : 140, weight: 800, family: 'Shippori Mincho', color: T.accent, align: 'center' });
    E.text(ctx, '折って、切って、ひらく。', 0, v ? 200 : 150, { size: v ? 58 : 50, weight: 800, family: 'Shippori Mincho', color: T.ink, align: 'center' });
    ctx.restore();
    const b = E.seg(local, 0.5, 0.9);
    ctx.save();
    ctx.globalAlpha *= b;
    const py = v ? 1160 : 650;
    E.fillRR(ctx, cx - 330, py - 46, 660, 92, 46, T.ink);
    E.text(ctx, 'ブラウザで、そのまま切れる', cx, py + 2, { size: 40, weight: 900, color: '#fff', align: 'center', baseline: 'middle' });
    E.text(ctx, 'App Store・Google Play で配信', cx, py + (v ? 130 : 112), { size: v ? 40 : 36, weight: 700, color: T.sub, align: 'center' });
    E.text(ctx, '※画面は開発中のイメージです', cx, H - (v ? 90 : 50), { size: 26, weight: 500, color: T.sub, align: 'center' });
    ctx.restore();
  }

  const stageCues = (stages, d, kind) => {
    const out = [];
    for (let i = 1; i < stages.length; i++) if (stages[i][1] !== stages[i - 1][1]) out.push({ t: stages[i - 1][0] * d, kind });
    return out;
  };

  window.APPS.monkiri = {
    theme: T,
    bg,
    logo,
    endCard,
    scenes: [
      {
        name: 'fold',
        dur: { v: 2.4, h: 3.6 },
        screen: sFold,
        cap: {
          v: [{ text: '紙を折って、' }],
          h: [{ step: '1', h: '折る', s: '折り方は6種類。\n雪折りは12枚重ね' }],
        },
        cues: (d) => stageCues(FOLD_STAGES, d, 'fold'),
      },
      {
        name: 'cut',
        dur: { v: 4.4, h: 6.4 },
        screen: sCut,
        cap: {
          v: [{ text: '指でなぞって、\n切る' }],
          h: [{ step: '2', h: '切る', s: '指でなぞった形が、\nそのまま切り取られる' }],
        },
        cues: (d) => CUT_PLAN.flatMap((c) => [
          { t: c.a * d, kind: 'trace', dur: (c.b - c.a) * d },
          { t: c.b * d, kind: 'snip' },
        ]),
      },
      {
        name: 'unfold',
        dur: { v: 3.8, h: 5.4 },
        screen: sUnfold,
        cap: {
          v: [{ text: 'ひらくまで、\nわからない。', b: 0.8 }, { a: 0.8, text: 'ひらく。' }],
          h: [{ step: '3', h: 'ひらく', s: 'ひらくまで、\nどんな模様になるかわからない' }],
        },
        cues: (d) => [{ t: 0.03 * d, kind: 'tap' }, ...stageCues(UNFOLD_STAGES, d, 'unfold'), { t: 0.8 * d, kind: 'sparkle' }],
      },
      {
        name: 'gallery',
        dur: { v: 3.2, h: 4.8 },
        screen: sGallery,
        cap: {
          v: [{ text: '雪、桜、麻の葉。\n紋を切って集める' }],
          h: [{ h: '紋の型紙で覚える', s: '雪・桜・麻の葉。\n切った紋が図鑑に入る' }],
        },
        cues: (d) => GALLERY.filter((x) => x.at > 0).map((x, i) => ({ t: x.at * d, kind: 'pop', p: i })),
      },
      {
        name: 'share',
        dur: { v: 3.8, h: 5.4 },
        screen: sShare,
        cap: {
          v: [{ text: '送った相手も、\nブラウザでひらける' }],
          h: [{ h: 'リンクで贈る', s: '受け取った人は、ブラウザで\n「ひらく」を押すだけ' }],
        },
        cues: (d) => [
          { t: 0.02 * d, kind: 'msg' },
          { t: 0.24 * d, kind: 'tap' },
          { t: 0.48 * d, kind: 'tap' },
          ...stageCues(SHARE_STAGES, d, 'unfold'),
          { t: 0.84 * d, kind: 'sparkle' },
        ],
      },
      { name: 'end', end: true, dur: { v: 2.6, h: 4.4 }, screen: () => {} },
    ],
  };
})();
