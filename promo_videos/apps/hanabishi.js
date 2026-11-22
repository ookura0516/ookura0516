// ハナビシ（花火づくり）
// 画面全体を光らせる演出は使わない（光過敏への配慮）。光るのは花火の粒だけ。
(function () {
  const TH = {
    ink: '#fff3e0', sub: '#c9c2e8', accent: '#d9473d', onAccent: '#fff',
    capBg: 'rgba(10,8,30,0.84)', capInk: '#fff6e8', faint: 'rgba(230,225,255,0.55)',
  };
  const RISE = 1.0; // 打ち上げてから開くまでの秒数
  const TYPES = {
    kiku: { n: 64, speed: 330, life: 2.3, trail: 0.22, grav: 70, drag: 1.1, size: 4.5 },
    botan: { n: 72, speed: 310, life: 2.0, trail: 0, grav: 50, drag: 1.2, size: 6.5 },
    kamuro: { n: 60, speed: 300, life: 3.4, trail: 0.55, grav: 95, drag: 1.4, size: 4, glitter: true },
    yanagi: { n: 48, speed: 230, life: 3.8, trail: 0.8, grav: 125, drag: 1.7, size: 3.6 },
  };
  const NAME = { kiku: '菊', botan: '牡丹', kamuro: '冠菊', yanagi: '柳' };
  const COL = {
    kiku: ['#ffd27a', '#ff5a4e'], botan: ['#8ab8ff', '#c690ff'], kamuro: ['#ffd27a', '#e8b04f'], yanagi: ['#ffcf6b', '#d99a3a'],
  };

  // 場面ごとの打ち上げ予定。at は場面の頭からの秒（打ち上げの時刻）
  function bursts(fig, dur, vert) {
    const B = (at, x, y, type, o = {}) => ({ at, x, y, type, colors: o.colors || COL[type], core: o.core || null, cores: o.cores || 1, size: o.size || 1, seed: Math.round(at * 100 + x * 1000 + y * 7) });
    switch (fig) {
      case 'hb_hook': return [B(0.0, 0.5, 0.3, 'kiku', { core: '#7fd1ff', size: 1.15 }), B(0.8, 0.24, 0.45, 'botan'), B(1.5, 0.76, 0.38, 'yanagi'), B(2.2, 0.42, 0.22, 'kamuro', { size: 0.9 })];
      case 'hb_types': return ['kiku', 'botan', 'kamuro', 'yanagi'].map((ty, k) => B(0.15 + k * 0.7, 0.14 + k * 0.24, 0.36, ty, { size: 0.75 }));
      case 'hb_editor': {
        const px = vert ? 0.5 : 0.74, py = vert ? 0.24 : 0.36;
        if (vert) return [B(0.1, px, py, 'kiku', { core: '#7fd1ff', size: 0.85 }), B(dur * 0.36, px, py, 'botan', { size: 0.85 }), B(dur * 0.62, px, py, 'yanagi', { size: 0.85 })];
        return [B(0.1, px, py, 'kiku', { colors: ['#ff5a4e', '#ffd27a', '#6be07a'], core: '#7fd1ff', cores: 2, size: 0.9 }),
          B(dur * 0.52, px, py, 'kiku', { colors: ['#ff5a4e', '#ffd27a', '#6be07a'], core: '#7fd1ff', cores: 2, size: 0.9 })];
      }
      case 'hb_show': return SHOW.map((m, k) => B(L.lerp(0.1, 0.8, m.u) * dur, m.x, m.y, m.type, { core: m.core, size: 0.85 }));
      case 'hb_share': return [B(dur * 0.5, 0.35, 0.4, 'kiku', { size: 0.6 }), B(dur * 0.62, 0.65, 0.35, 'botan', { size: 0.6 })];
      case 'hb_ar': return [B(0.3, 0.5, 0.3, 'kiku', { core: '#7fd1ff', size: 0.55 }), B(dur * 0.5, 0.5, 0.26, 'kamuro', { size: 0.55 })];
      case 'end': return [B(0.0, 0.5, 0.5, 'kiku', { core: '#7fd1ff', size: 0.8 })];
      default: return [];
    }
  }
  const SHOW = [
    { u: 0.0, x: 0.2, y: 0.36, type: 'kiku', core: '#7fd1ff' }, { u: 0.22, x: 0.62, y: 0.28, type: 'botan' },
    { u: 0.45, x: 0.4, y: 0.42, type: 'yanagi' }, { u: 0.66, x: 0.8, y: 0.38, type: 'kiku', core: '#ff9de0' }, { u: 0.86, x: 0.5, y: 0.22, type: 'kamuro' },
  ];

  // 1発ぶんの絵。s は打ち上げからの秒、(ox,oy) は開く位置、gy は地面
  function shell(b, s, ox, oy, gy, k = 1) {
    if (s < 0) return '';
    const T = TYPES[b.type];
    let out = '';
    if (s < RISE) {
      const e = L.easeOut(s / RISE);
      const y = L.lerp(gy, oy, e), y2 = L.lerp(gy, oy, L.easeOut(Math.max(0, s - 0.12) / RISE));
      return L.line(ox, y2, ox, y, { stroke: '#ffe3b0', 'stroke-width': 3 * k, 'stroke-linecap': 'round', opacity: 0.7 }) + L.circle(ox, y, 3.5 * k, { fill: '#fff4d6' });
    }
    const st = s - RISE;
    const layers = [[T.n, 1, b.colors, T.life]];
    if (b.core) for (let c = 0; c < b.cores; c++) layers.push([26, 0.42 - c * 0.14, [b.core], T.life * 0.8]);
    const r = L.rng(b.seed);
    for (const [n, spd, cols, life] of layers) {
      if (st > life) continue;
      const fade = 1 - L.seg(st, life * 0.68, life);
      const pos = tt => {
        const d = T.drag;
        return (1 - Math.exp(-d * tt)) / d;
      };
      for (let i = 0; i < n; i++) {
        const th = r() * Math.PI * 2, z = r() * 2 - 1, rr = Math.sqrt(1 - z * z);
        const vx = Math.cos(th) * rr, vy = Math.sin(th) * rr;
        const v = T.speed * spd * b.size * k * (0.9 + r() * 0.2);
        const px = ox + vx * v * pos(st), py = oy + vy * v * pos(st) + 0.5 * T.grav * k * st * st;
        const ci = Math.min(cols.length - 1, Math.floor(st / life * cols.length));
        const col = cols[ci];
        let a = fade;
        if (T.glitter) a *= 0.55 + 0.45 * Math.sin(st * 38 + i * 1.7);
        if (T.trail > 0) {
          const t0 = Math.max(0, st - T.trail);
          const qx = ox + vx * v * pos(t0), qy = oy + vy * v * pos(t0) + 0.5 * T.grav * k * t0 * t0;
          out += L.line(qx.toFixed(1), qy.toFixed(1), px.toFixed(1), py.toFixed(1), { stroke: col, 'stroke-width': (T.size * 0.55 * k).toFixed(2), 'stroke-linecap': 'round', opacity: (a * 0.55).toFixed(2) });
        }
        out += L.circle(px.toFixed(1), py.toFixed(1), (T.size * k * (1 - 0.45 * st / life)).toFixed(2), { fill: col, opacity: a.toFixed(2) });
      }
    }
    return out;
  }

  function fireworks(ctx, list, w, h, k = 1, gy = null) {
    let s = '';
    for (const b of list) s += shell(b, ctx.lt - b.at, b.x * w, b.y * h, gy ?? h + 40, k);
    return `<g filter="url(#hbGlow)">${s}</g>`;
  }

  function cues(tl) {
    const out = [];
    for (const sc of tl.scenes) {
      for (const b of bursts(sc.fig, sc.dur, tl.fmt === 'V')) {
        if (b.at > sc.dur - 0.3) continue;
        const pan = (b.x - 0.5) * 1.4;
        if (sc.fig !== 'end') out.push({ type: 'launch', t: +(sc.start + b.at).toFixed(3), pan });
        out.push({ type: 'boom', t: +(sc.start + b.at + (sc.fig === 'end' ? 0.3 : RISE)).toFixed(3), pan, size: Math.min(1.1, 0.6 + b.size * 0.4), crackle: b.type === 'kamuro' || b.type === 'yanagi' });
      }
    }
    return out.sort((a, b) => a.t - b.t);
  }

  // ── 場面 ──
  function hb_hook(ctx) {
    return fireworks(ctx, bursts('hb_hook', ctx.dur, ctx.vert), ctx.w, ctx.h, ctx.vert ? 1.05 : 1.0);
  }

  function hb_types(ctx) {
    const { w, h, lt } = ctx;
    const list = bursts('hb_types', ctx.dur, false);
    let s = fireworks(ctx, list, w, h, 0.85, h * 0.92);
    list.forEach((b, k) => {
      const a = L.easeOut(L.seg(lt, b.at + RISE - 0.1, b.at + RISE + 0.4));
      s += L.op(a, L.text(b.x * w, h * 0.86, NAME[b.type], { size: 64, weight: 800, fill: TH.ink, fam: 'mincho' }));
    });
    return s;
  }

  function chip(x, y, label, on, size = 44) {
    const w = label.length * size + 60;
    return L.rect(x, y, w, size + 36, { rx: (size + 36) / 2, fill: on ? TH.accent : 'rgba(255,255,255,0.08)', stroke: on ? 'none' : 'rgba(255,255,255,0.3)', 'stroke-width': 2 })
      + L.text(x + w / 2, y + (size + 36) / 2 + 2, label, { size, weight: 800, fill: '#fff', fam: 'mincho' });
  }

  function hb_editor(ctx) {
    const { w, h, lt, p, dur, vert } = ctx;
    const list = bursts('hb_editor', dur, vert);
    let s = fireworks(ctx, list, w, h, vert ? 1 : 0.9, vert ? h * 0.55 : h * 0.95);
    const [x, y, pw, ph] = vert ? [60, 620, 880, 460] : [40, 60, 800, 640];
    s += L.card(x, y, pw, ph, { r: 36, fill: 'rgba(22,18,52,0.9)', stroke: 'rgba(255,255,255,0.18)', sw: 2, shadow: false });
    s += L.text(x + 50, y + 60, '型', { size: 36, weight: 700, fill: TH.sub, anchor: 'start' });
    let sel = 'kiku';
    if (vert) sel = lt >= dur * 0.62 ? 'yanagi' : lt >= dur * 0.36 ? 'botan' : 'kiku';
    let cx = x + 50;
    for (const ty of ['kiku', 'botan', 'kamuro', 'yanagi']) {
      s += chip(cx, y + 90, NAME[ty], ty === sel, vert ? 44 : 40);
      cx += NAME[ty].length * (vert ? 44 : 40) + 80;
    }
    s += L.text(x + 50, y + 225, '色の順番', { size: 36, weight: 700, fill: TH.sub, anchor: 'start' });
    const seq = vert ? COL[sel] : ['#ff5a4e', '#ffd27a', '#6be07a'];
    seq.forEach((c, i) => {
      const a = vert ? 1 : L.back(L.seg(p, 0.1 + i * 0.1, 0.2 + i * 0.1));
      s += L.op(L.clamp(a), L.tr(x + 90 + i * 150, y + 300, Math.max(0.01, a), L.circle(0, 0, 40, { fill: c })));
      if (i < seq.length - 1) s += L.op(L.clamp(a), L.arrow(x + 140 + i * 150, y + 300, x + 190 + i * 150, y + 300, { color: 'rgba(255,255,255,0.6)', w: 5, head: 16 }));
    });
    if (!vert || ph > 420) {
      s += L.text(x + 50, y + (vert ? 395 : 410), '芯', { size: 36, weight: 700, fill: TH.sub, anchor: 'start' });
      const coreSel = vert ? 1 : (p > 0.42 ? 2 : 1);
      ['一重', '二重', '三重'].forEach((label, i) => { s += chip(x + 130 + i * 190, y + (vert ? 360 : 375), label, i === coreSel - 1 || (vert && i === 0), 36); });
      if (!vert) {
        s += L.tr(x + pw / 2, y + 540, 1, [3, 2, 1].map(n => L.circle(0, 0, 26 * n, { fill: 'none', stroke: n <= coreSel + 1 ? '#7fd1ff' : 'rgba(255,255,255,0.2)', 'stroke-width': 6 })).join(''));
      }
    }
    return s;
  }

  function hb_show(ctx) {
    const { w, h, lt, dur, vert } = ctx;
    const list = bursts('hb_show', dur, vert);
    const ty = vert ? h - 120 : h - 90;
    let s = fireworks(ctx, list, w, h, vert ? 0.95 : 0.85, ty - 60);
    const x0 = 80, x1 = w - 80;
    s += L.rect(x0 - 30, ty - 60, x1 - x0 + 60, 120, { rx: 30, fill: 'rgba(22,18,52,0.85)', stroke: 'rgba(255,255,255,0.18)', 'stroke-width': 2 });
    s += L.line(x0, ty, x1, ty, { stroke: 'rgba(255,255,255,0.35)', 'stroke-width': 6, 'stroke-linecap': 'round' });
    SHOW.forEach((m, k) => {
      const mx = L.lerp(x0, x1, L.lerp(0.06, 0.94, m.u));
      s += L.circle(mx, ty, 22, { fill: COL[m.type][0], stroke: '#fff', 'stroke-width': 4 });
    });
    const u = L.seg(lt, 0.1 * dur, 0.8 * dur);
    const hx = L.lerp(x0, x1, L.lerp(0.06, 0.94, u));
    s += L.line(hx, ty - 46, hx, ty + 46, { stroke: '#fff', 'stroke-width': 5 });
    s += L.text(x0, ty - 90, '花火大会', { size: 40, weight: 800, fill: TH.ink, anchor: 'start', fam: 'mincho' });
    return s;
  }

  function hb_share(ctx) {
    const { lt, dur } = ctx;
    const list = bursts('hb_share', dur, ctx.vert);
    const left = (sw, sh) => L.rect(0, 0, sw, sh, { fill: 'url(#hbSky)' })
      + `<g transform="translate(0 ${sh * 0.05})">${fireworks({ lt: lt % 2.6 + 0.6 }, [{ at: 0, x: 0.5, y: 0.35, type: 'kiku', colors: COL.kiku, core: '#7fd1ff', cores: 1, size: 0.45, seed: 9 }], sw, sh * 0.8, 1)}</g>`
      + L.text(sw / 2, sh * 0.13, 'ゆうたの花火大会', { size: sw * 0.075, weight: 800, fill: TH.ink, fam: 'mincho' })
      + L.rect(sw * 0.15, sh * 0.8, sw * 0.7, sh * 0.08, { rx: sh * 0.04, fill: TH.accent }) + L.text(sw / 2, sh * 0.84, 'リンクで送る', { size: sw * 0.07, weight: 800, fill: '#fff' });
    const right = (bw, bh) => L.rect(0, 0, bw, bh, { fill: 'url(#hbSky)' }) + fireworks(ctx, list, bw, bh, bw / 1100, bh + 20)
      + L.op(L.seg(ctx.p, 0.45, 0.55), L.text(bw / 2, bh * 0.12, 'ゆうたの花火大会', { size: Math.min(40, bw * 0.05), weight: 800, fill: TH.ink, fam: 'mincho' }));
    return L.flow(ctx, { left, right, rightLabel: '相手のブラウザで、そのまま打ち上がる', labelFill: TH.ink, labelFam: 'mincho', arrowColor: 'rgba(255,255,255,0.45)', linkColor: '#d9473d' });
  }

  function skyline(w, y, h, lit, fill) {
    const r = L.rng(21);
    let s = '';
    let x = 0;
    while (x < w) {
      const bw = 50 + r() * 90, bh = h * (0.3 + r() * 0.6);
      s += L.rect(x, y + h - bh, bw + 2, bh, { fill });
      for (let wy = y + h - bh + 16; wy < y + h - 16; wy += 26) for (let wx = x + 10; wx < x + bw - 14; wx += 22) if (r() < lit) s += L.rect(wx, wy, 9, 12, { fill: '#ffd98a', opacity: 0.55 });
      x += bw + 4;
    }
    return s;
  }

  function hb_ar(ctx) {
    const { w, h, t, vert } = ctx;
    const [pw, ph] = vert ? [500, 940] : [360, 680];
    const px = w / 2 - pw / 2, py = vert ? 20 : 0;
    const list = bursts('hb_ar', ctx.dur, vert);
    const screen = (sw, sh) => L.rect(0, 0, sw, sh, { fill: '#26304f' }) + skyline(sw, sh * 0.62, sh * 0.38, 0.35, '#3a4468')
      + fireworks(ctx, list, sw, sh, sw / 900, sh * 0.62)
      + L.circle(sw * 0.1, sh * 0.06, 10, { fill: '#ff4d4d', opacity: 0.6 + 0.4 * Math.sin(t * 6) }) + L.text(sw * 0.1 + 22, sh * 0.06 + 1, '録画中', { size: sw * 0.05, weight: 700, fill: '#fff', anchor: 'start' });
    return L.phone(px, py, pw, ph, screen, { body: '#2b2f45', tilt: Math.sin(t * 1.1) * 2 });
  }

  function motif(ctx) {
    const lt = (ctx.lt % 3.2);
    const b = { at: 0, x: 0, y: 0, type: 'kiku', colors: COL.kiku, core: '#7fd1ff', cores: 1, size: 0.7, seed: 5 };
    return `<g filter="url(#hbGlow)">${shell(b, lt + RISE - 0.3, 0, 0, 0, 1)}</g>`;
  }

  function bg(ctx) {
    const { W, H, t, vert } = ctx;
    const r = L.rng(8);
    let s = L.rect(0, 0, W, H, { fill: 'url(#hbBg)' });
    for (let i = 0; i < 90; i++) s += L.circle(r() * W, r() * H * 0.7, 0.8 + r() * 1.6, { fill: '#fff', opacity: 0.25 + 0.2 * Math.sin(t + i) });
    const sy = vert ? 1250 : 800, sh = vert ? 260 : 160;
    s += skyline(W, sy, sh, 0.2, '#0a0b1c');
    s += L.rect(0, sy + sh, W, H - sy - sh, { fill: '#0b1028' });
    for (let i = 0; i < 14; i++) s += L.rect(r() * W, sy + sh + 20 + r() * (H - sy - sh - 40), 60 + r() * 160, 3, { fill: '#ffd98a', opacity: 0.12 + 0.1 * Math.sin(t * 2 + i) });
    return s;
  }
  function defs() {
    return '<linearGradient id="hbBg" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#05061a"/><stop offset="1" stop-color="#1f1a4a"/></linearGradient>'
      + '<linearGradient id="hbSky" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#070826"/><stop offset="1" stop-color="#262058"/></linearGradient>'
      + '<filter id="hbGlow" x="-20%" y="-20%" width="140%" height="140%"><feGaussianBlur stdDeviation="3.5" result="b"/><feMerge><feMergeNode in="b"/><feMergeNode in="SourceGraphic"/></feMerge></filter>';
  }

  APPS.hanabishi = {
    name: 'ハナビシ', category: '花火づくりアプリ', release: '2027年7月', catch: '夜空に、あなたの一発を。',
    fam: "'Shippori Mincho'", theme: TH, bg, defs, motif, cues,
    audio: { kind: 'fireworks' },
    figs: { hb_hook, hb_types, hb_editor, hb_show, hb_share, hb_ar },
    scripts: {
      V: [
        { fig: 'hb_hook', text: '自分だけの花火を、|夜空に打ち上げよう。' },
        { fig: 'hb_editor', text: '菊、牡丹、柳。|型と色を選んで、玉をつくる。', min: 5.2 },
        { fig: 'hb_show', text: '並べて自分の花火大会にしたら、|リンクで送れます。', min: 5.6 },
        { fig: 'end', text: '花火づくりアプリ、|ハナビシ。2027年7月公開予定。', say: '花火づくりアプリ、ハナビシ。二〇二七年七月、公開予定。' },
      ],
      H: [
        { fig: 'hb_hook', text: '花火師になって、|自分の花火を打ち上げる。', min: 4.2 },
        { fig: 'hb_types', text: '菊、牡丹、冠菊、柳。|日本の花火の型から選びます。', min: 5.0 },
        { fig: 'hb_editor', text: '開いてから色が変わる順番や、|内側の芯の数も決められます。', min: 5.6 },
        { fig: 'hb_show', text: 'つくった玉を時間の線に並べれば、|自分だけの花火大会に。', min: 6.0 },
        { fig: 'hb_share', text: 'リンクを送れば、|相手のブラウザで、そのまま打ち上がります。' },
        { fig: 'hb_ar', text: 'アプリでは、カメラの景色に重ねて、|目の前の空に打ち上げることもできます。' },
        { fig: 'end', text: 'ハナビシ。|2027年7月、公開予定です。', say: 'ハナビシ。二〇二七年七月、公開予定です。' },
      ],
    },
  };
})();
