// ホシムスビ（星座づくり）
(function () {
  const TH = {
    ink: '#f6efdb', sub: '#b9c3e6', accent: '#e8c46a', onAccent: '#1a2142',
    capBg: 'rgba(8,14,38,0.84)', capInk: '#fff7e0', faint: 'rgba(220,225,245,0.55)', gold: '#f3d27a',
  };
  // 作る星座（枠の中の位置 0〜1）と、結ぶ順番
  const PTS = [[0.14, 0.64], [0.3, 0.44], [0.47, 0.53], [0.62, 0.3], [0.82, 0.38], [0.72, 0.62], [0.5, 0.8]];
  const EDGES = [[0, 1], [1, 2], [2, 3], [3, 4], [4, 5], [5, 2], [2, 6]];
  const HOOK = [0.1, 0.72];   // hs_hook で線を引く区間（場面の進み具合）
  const CONN = [0.08, 0.55];  // hs_connect で線を引く区間

  function starsLayer(seed, n, x0, y0, w, h, t, o = {}) {
    const { rmin = 0.8, rmax = 2.8, fill = '#fff' } = o;
    const r = L.rng(seed);
    let s = '';
    for (let i = 0; i < n; i++) {
      const x = x0 + r() * w, y = y0 + r() * h, rr = rmin + Math.pow(r(), 3) * (rmax - rmin);
      const ph = r() * 6.28, sp = 0.6 + r() * 1.8;
      const a = 0.45 + 0.55 * (0.5 + 0.5 * Math.sin(t * sp + ph));
      s += L.circle(x.toFixed(1), y.toFixed(1), rr.toFixed(2), { fill, opacity: a.toFixed(2) });
    }
    return s;
  }

  // 星座。prog は線を引き終えた割合（0〜1）
  function constellation(x, y, w, h, prog, o = {}) {
    const { lw = 5, sr = 9, label, labelSize = 46, glow = true, color = TH.gold } = o;
    const P = PTS.map(([u, v]) => [x + u * w, y + v * h]);
    let s = '';
    const k = prog * EDGES.length;
    EDGES.forEach(([a, b], i) => {
      const e = L.clamp(k - i);
      if (e <= 0) return;
      const [x1, y1] = P[a], [x2, y2] = P[b];
      const xe = L.lerp(x1, x2, e), ye = L.lerp(y1, y2, e);
      if (glow) s += L.line(x1, y1, xe, ye, { stroke: color, 'stroke-width': lw * 3.2, 'stroke-linecap': 'round', opacity: 0.18 });
      s += L.line(x1, y1, xe, ye, { stroke: color, 'stroke-width': lw, 'stroke-linecap': 'round' });
    });
    P.forEach(([px, py]) => {
      if (glow) s += L.circle(px, py, sr * 2.6, { fill: '#fff6d6', opacity: 0.16 });
      s += L.circle(px, py, sr, { fill: '#fffaf0' });
    });
    if (label) s += L.op(L.seg(prog, 0.98, 1), L.text(x + w * 0.5, y + h + labelSize * 0.6, label, { size: labelSize, weight: 800, fill: TH.gold, fam: 'mincho' }));
    return { svg: s, P };
  }

  function edgeEndAt(prog, x, y, w, h) {
    const k = Math.min(EDGES.length - 1e-6, prog * EDGES.length);
    const i = Math.floor(k), e = k - i;
    const [a, b] = EDGES[i];
    const [x1, y1] = [x + PTS[a][0] * w, y + PTS[a][1] * h], [x2, y2] = [x + PTS[b][0] * w, y + PTS[b][1] * h];
    return [L.lerp(x1, x2, e), L.lerp(y1, y2, e)];
  }

  function cues(tl) {
    const out = [];
    for (const s of tl.scenes) {
      const at = f => +(s.start + f * s.dur).toFixed(3);
      if (s.fig === 'hs_hook') {
        EDGES.forEach((_, k) => out.push({ type: 'chime', t: at(L.lerp(HOOK[0], HOOK[1], (k + 1) / EDGES.length)), n: k }));
        out.push({ type: 'sparkle', t: at(HOOK[1] + 0.04), n: 2 });
      }
      if (s.fig === 'hs_connect') {
        EDGES.forEach((_, k) => out.push({ type: 'chime', t: at(L.lerp(CONN[0], CONN[1], (k + 1) / EDGES.length)), n: k + 1 }));
        out.push({ type: 'sparkle', t: at(0.86), n: 1 });
      }
      if (s.fig === 'hs_dates') [0.12, 0.38, 0.64].forEach((f, k) => out.push({ type: 'chime', t: at(f), n: k * 2 }));
      if (s.fig === 'hs_pick') out.push({ type: 'sparkle', t: at(0.5), n: 0 });
      if (s.fig === 'hs_share') out.push({ type: 'sparkle', t: at(0.5), n: 3 });
      if (s.fig === 'hs_ar') out.push({ type: 'chime', t: at(0.55), n: 4 });
      if (s.fig === 'end') out.push({ type: 'sparkle', t: at(0.08), n: 0 });
    }
    return out.sort((a, b) => a.t - b.t);
  }

  // ── 場面 ──
  function hs_hook(ctx) {
    const { p, w, h, vert } = ctx;
    const [bw, bh] = vert ? [880, 640] : [1100, 560];
    const x = (w - bw) / 2, y = vert ? 160 : 40;
    const prog = L.seg(p, HOOK[0], HOOK[1]);
    return constellation(x, y, bw, bh, prog, { label: 'ふたりの星', labelSize: vert ? 64 : 56, lw: 6, sr: 11 }).svg;
  }

  function hs_dates(ctx) {
    const { lt, dur, w } = ctx;
    const items = [['誕生日', '5月3日', 260, 170], ['記念日', '10月10日', w / 2, 430], ['出会った日', '7月7日', w - 260, 210]];
    let s = '';
    items.forEach(([a, b, x, y], k) => {
      const e = L.back(L.seg(lt, (0.08 + k * 0.26) * dur, (0.2 + k * 0.26) * dur));
      if (e <= 0) return;
      s += L.tr(x, y + Math.sin(ctx.t * 1.2 + k) * 8, e,
        L.card(-200, -110, 400, 220, { r: 34, fill: 'rgba(20,30,70,0.78)', stroke: 'rgba(243,210,122,0.6)', sw: 2, shadow: false })
        + L.text(0, -38, a, { size: 40, weight: 700, fill: TH.sub })
        + L.text(0, 34, b, { size: 64, weight: 800, fill: TH.gold, fam: 'mincho' }));
    });
    return s;
  }

  function skyDome(cx, cy, r, rot, t, showConst) {
    const id = L.uid('dome');
    let s = `<clipPath id="${id}">${L.circle(cx, cy, r)}</clipPath>`;
    s += L.circle(cx, cy, r + 10, { fill: 'none', stroke: 'rgba(243,210,122,0.5)', 'stroke-width': 3 });
    s += `<g clip-path="url(#${id})">` + L.circle(cx, cy, r, { fill: '#0b1434' })
      + `<g transform="rotate(${rot} ${cx} ${cy})">` + starsLayer(41, 170, cx - r, cy - r, r * 2, r * 2, t, { rmax: 3.4 })
      + (showConst ? constellation(cx - r * 0.55, cy - r * 0.45, r * 1.1, r * 0.8, 1, { lw: 4, sr: 7 }).svg : '') + '</g></g>';
    [['北', 0, -1], ['東', -1, 0], ['南', 0, 1], ['西', 1, 0]].forEach(([d, dx, dy]) => {
      s += L.text(cx + dx * (r + 44), cy + dy * (r + 44), d, { size: 34, weight: 700, fill: TH.sub });
    });
    return s;
  }

  function pickCard(x, y, w, p) {
    const hour = L.lerp(19, 21, L.ease(L.seg(p, 0.15, 0.45)));
    const hh = Math.floor(hour), mm = Math.round((hour - hh) * 60 / 10) * 10 % 60;
    let s = L.card(x, y, w, 330, { r: 34, fill: 'rgba(20,30,70,0.85)', stroke: 'rgba(243,210,122,0.5)', sw: 2, shadow: false });
    const row = (k, label, value) => L.text(x + 50, y + 70 + k * 80, label, { size: 34, weight: 700, fill: TH.sub, anchor: 'start' })
      + L.text(x + w - 50, y + 70 + k * 80, value, { size: 42, weight: 800, fill: TH.ink, anchor: 'end', fam: 'mincho' });
    s += row(0, '日付', '2026年11月22日') + row(1, '町', '東京');
    s += L.text(x + 50, y + 230, '時刻', { size: 34, weight: 700, fill: TH.sub, anchor: 'start' });
    s += L.text(x + w - 50, y + 230, `${hh}:${String(mm).padStart(2, '0')}`, { size: 42, weight: 800, fill: TH.gold, anchor: 'end', fam: 'mincho' });
    const sx = x + 50, sw = w - 100, kx = sx + sw * ((hour - 18) / 6);
    s += L.rect(sx, y + 280, sw, 10, { rx: 5, fill: 'rgba(255,255,255,0.2)' }) + L.rect(sx, y + 280, kx - sx, 10, { rx: 5, fill: TH.gold })
      + L.circle(kx, y + 285, 20, { fill: '#fff' });
    return { svg: s, hour };
  }

  function hs_pick(ctx) {
    const { p, t, w, vert } = ctx;
    const [cx, cy, cw] = vert ? [100, 20, 800] : [40, 180, 700];
    const card = pickCard(cx, cy, cw, p);
    const a = L.easeOut(L.seg(p, 0.4, 0.6));
    const [dx, dy, r] = vert ? [500, 760, 300] : [1250, 380, 330];
    return card.svg + L.op(a, L.tr(dx, dy, 0.85 + 0.15 * a, skyDome(0, 0, r, (card.hour - 21) * 15, t, false)))
      + L.op(L.seg(p, 0.6, 0.7), L.text(dx, dy + r + (vert ? 100 : 95), '2026年11月22日 21:00 東京の空', { size: 34, weight: 700, fill: TH.gold, fam: 'mincho' }));
  }

  function phoneSky(t, prog, sw, sh, o = {}) {
    let s = L.rect(0, 0, sw, sh, { fill: 'url(#hsPhone)' }) + starsLayer(77, 90, 0, 0, sw, sh * 0.75, t, { rmax: 3 });
    const c = constellation(sw * 0.06, sh * 0.14, sw * 0.88, sh * 0.42, prog, { lw: 4, sr: 8 });
    s += c.svg;
    return { svg: s, box: [sw * 0.06, sh * 0.14, sw * 0.88, sh * 0.42] };
  }

  function hs_connect(ctx) {
    const { p, t, w, vert } = ctx;
    const [pw, ph] = vert ? [540, 1040] : [400, 760];
    const px = w / 2 - pw / 2, py = vert ? 20 : 0;
    const prog = L.seg(p, CONN[0], CONN[1]);
    let fingerXY = null;
    const screen = (sw, sh) => {
      const sky = phoneSky(t, prog, sw, sh);
      let s = sky.svg;
      if (prog > 0 && prog < 1) {
        const [fx, fy] = edgeEndAt(prog, ...sky.box);
        fingerXY = [fx, fy];
        s += L.finger(fx + 8, fy + 12, 0.5, 'rgba(255,255,255,0.85)');
      }
      const sheet = L.easeOut(L.seg(p, 0.58, 0.68));
      if (sheet > 0) {
        const sy = sh - sheet * sh * 0.42;
        s += L.rect(0, sy, sw, sh * 0.5, { rx: 36, fill: '#f8f3e6' });
        s += L.text(sw * 0.08, sy + 60, '名前', { size: sw * 0.05, weight: 700, fill: '#7a7f99', anchor: 'start' });
        s += L.text(sw * 0.08, sy + 120, L.typed('ふたりの星', L.seg(p, 0.66, 0.74)), { size: sw * 0.08, weight: 800, fill: '#1a2142', anchor: 'start', fam: 'mincho' });
        s += L.text(sw * 0.08, sy + 190, '一言', { size: sw * 0.05, weight: 700, fill: '#7a7f99', anchor: 'start' });
        s += L.text(sw * 0.08, sy + 245, L.typed('いつもありがとう', L.seg(p, 0.74, 0.82)), { size: sw * 0.06, weight: 700, fill: '#1a2142', anchor: 'start' });
        const press = 1 - 0.06 * Math.max(0, 1 - Math.abs(p - 0.86) / 0.03);
        s += L.tr(sw / 2, sy + 330, press, L.rect(-sw * 0.36, -40, sw * 0.72, 80, { rx: 40, fill: '#1a2142' }) + L.text(0, 2, 'リンクで贈る', { size: sw * 0.06, weight: 800, fill: TH.gold }));
      }
      return s;
    };
    return L.phone(px, py, pw, ph, screen, { body: '#3a4475' });
  }

  function hs_share(ctx) {
    const { t, p } = ctx;
    const left = (sw, sh) => phoneSky(t, 1, sw, sh).svg + L.text(sw / 2, sh * 0.72, 'ふたりの星', { size: sw * 0.1, weight: 800, fill: TH.gold, fam: 'mincho' });
    const right = (bw, bh) => L.rect(0, 0, bw, bh, { fill: 'url(#hsPhone)' }) + starsLayer(91, 120, 0, 0, bw, bh, t, { rmax: 3 })
      + constellation(bw * 0.18, bh * 0.1, bw * 0.64, bh * 0.62, L.seg(p, 0.55, 0.9), { lw: 4, sr: 7 }).svg
      + L.op(L.seg(p, 0.88, 0.95), L.text(bw / 2, bh * 0.86, 'ふたりの星 ― 2026年11月22日 東京の夜空', { size: Math.min(34, bw * 0.045), weight: 800, fill: TH.gold, fam: 'mincho' }));
    return L.flow(ctx, { left, right, rightLabel: 'ブラウザで、その夜空が開く', labelFill: TH.ink, labelFam: 'mincho', arrowColor: 'rgba(255,255,255,0.45)' });
  }

  function landscape(w, y, h) {
    const r = L.rng(5);
    let d = `M0 ${y + h}L0 ${y + h * 0.45}`;
    for (let x = 0; x <= w; x += 40) d += `L${x} ${y + h * (0.35 + 0.15 * Math.sin(x / 180) + r() * 0.06)}`;
    d += `L${w} ${y + h}Z`;
    let s = L.path(d, { fill: '#050915' });
    for (let i = 0; i < 9; i++) {
      const bx = 60 + i * (w - 120) / 9 + r() * 30, bh = 60 + r() * 120, bw = 50 + r() * 50;
      s += L.rect(bx, y + h * 0.55 - bh, bw, bh + h * 0.45, { fill: '#050915' });
      for (let j = 0; j < 4; j++) if (r() > 0.5) s += L.rect(bx + 10 + (j % 2) * 20, y + h * 0.55 - bh + 15 + Math.floor(j / 2) * 25, 8, 10, { fill: '#e9c46a', opacity: 0.6 });
    }
    return s;
  }

  function hs_ar(ctx) {
    const { t, p, w, h, vert } = ctx;
    let s = landscape(w, h - (vert ? 300 : 230), vert ? 300 : 230);
    const [pw, ph] = vert ? [470, 880] : [340, 640];
    const sway = Math.sin(t * 1.3) * 3;
    const px = w / 2 - pw / 2 + (vert ? 40 : 120), py = vert ? 30 : 10;
    const screen = (sw, sh) => {
      let q = L.rect(0, 0, sw, sh, { fill: '#0d1636' }) + starsLayer(13, 70, 0, 0, sw, sh * 0.8, t, { rmax: 3 });
      q += L.path(`M0 ${sh * 0.82}Q${sw * 0.3} ${sh * 0.76} ${sw * 0.55} ${sh * 0.8}T${sw} ${sh * 0.78}L${sw} ${sh}L0 ${sh}Z`, { fill: '#04070f' });
      const a = L.easeOut(L.seg(p, 0.25, 0.45));
      q += L.op(a, constellation(sw * 0.1, sh * 0.16, sw * 0.8, sh * 0.36, 1, { lw: 4, sr: 7 }).svg);
      q += L.op(a, L.text(sw / 2, sh * 0.6, 'ふたりの星', { size: sw * 0.09, weight: 800, fill: TH.gold, fam: 'mincho' }));
      q += L.op(L.seg(p, 0.45, 0.6), L.rect(sw * 0.1, sh * 0.66, sw * 0.8, sh * 0.09, { rx: sh * 0.045, fill: 'rgba(0,0,0,0.55)' })
        + L.text(sw / 2, sh * 0.705, '南東・高さ40°', { size: sw * 0.065, weight: 800, fill: '#fff' }));
      q += L.op(L.seg(p, 0.1, 0.25) * (1 - L.seg(p, 0.3, 0.4)), L.arrow(sw * 0.5, sh * 0.6, sw * 0.8, sh * 0.25, { color: TH.gold, w: 10, head: 36 }));
      return q;
    };
    s += L.phone(px, py, pw, ph, screen, { body: '#3a4475', tilt: -4 + sway });
    return s;
  }

  function motif(ctx) {
    return constellation(-260, -170, 520, 300, 1, { lw: 5, sr: 9 }).svg;
  }

  function bg(ctx) {
    const { W, H, t } = ctx;
    return L.rect(0, 0, W, H, { fill: 'url(#hsBg)' })
      + L.el('ellipse', { cx: W * 0.5, cy: H * 0.35, rx: W * 0.9, ry: H * 0.12, fill: '#8fa0ff', opacity: 0.06, transform: `rotate(-25 ${W / 2} ${H * 0.35})` })
      + starsLayer(3, Math.round(W * H / 7000), 0, 0, W, H, t);
  }
  function defs() {
    return '<linearGradient id="hsBg" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#060b20"/><stop offset="1" stop-color="#1c2756"/></linearGradient>'
      + '<linearGradient id="hsPhone" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#091130"/><stop offset="1" stop-color="#26346a"/></linearGradient>';
  }

  APPS.hoshimusubi = {
    name: 'ホシムスビ', category: '星座づくりアプリ', release: '2027年6月', catch: 'あの日の夜空に、ふたりだけの星座を。',
    fam: "'Shippori Mincho'", theme: TH, bg, defs, motif, cues,
    audio: { kind: 'stars' },
    figs: { hs_hook, hs_dates, hs_pick, hs_connect, hs_share, hs_ar },
    scripts: {
      V: [
        { fig: 'hs_hook', text: 'あの日の夜空に、|ふたりだけの星座を。' },
        { fig: 'hs_pick', text: '日付と町を選ぶと、|その夜の本当の星空が出ます。' },
        { fig: 'hs_connect', text: '星を指でつないで名前をつけたら、|リンクで贈れます。' },
        { fig: 'end', text: '星座づくりアプリ、|ホシムスビ。2027年6月公開予定。', say: '星座づくりアプリ、ホシムスビ。二〇二七年六月、公開予定。' },
      ],
      H: [
        { fig: 'hs_dates', text: '誕生日、記念日、出会った日。' },
        { fig: 'hs_hook', text: 'あの日の夜空に、|自分だけの星座を結びませんか。' },
        { fig: 'hs_pick', text: '日付と町を選ぶと、|その夜21時の、本当の星空が表示されます。', say: '日付と町を選ぶと、その夜九時の、本当の星空が表示されます。' },
        { fig: 'hs_connect', text: '星を指でなぞってつなぎ、|名前と一言をつけるだけ。', say: '星を指でなぞってつなぎ、名前とひとことをつけるだけ。' },
        { fig: 'hs_share', text: 'できた星座はリンクで贈れます。|受け取った人は、ブラウザでその夜空を見られます。' },
        { fig: 'hs_ar', text: 'アプリでは、スマホを空にかざすと、|今夜その星座がどこに出ているかがわかります。' },
        { fig: 'end', text: 'ホシムスビ。|2027年6月、公開予定です。', say: 'ホシムスビ。二〇二七年六月、公開予定です。' },
      ],
    },
  };
})();
