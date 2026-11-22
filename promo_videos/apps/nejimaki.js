// ネジマキ（オルゴール作曲）
(function () {
  const TH = {
    ink: '#3b2a1a', sub: '#7a5a3a', accent: '#a8642a', onAccent: '#fff8ec',
    capBg: 'rgba(59,42,26,0.9)', capInk: '#fff8ec', faint: 'rgba(59,42,26,0.5)',
    paper: '#fffaf0', hole: '#3b2a1a', note: '#b0662a',
  };
  const BEAT = 0.5; // 1拍の秒数
  const PX_PER_SEC = 130; // テープが流れる速さ（オルゴールの座標で）
  // きらきら星（著作権の切れた曲）。[音の番号, 拍]。音の番号 0〜14 は 15音（ドからド2オクターブ上）
  const P1 = [[7, 1], [7, 1], [11, 1], [11, 1], [12, 1], [12, 1], [11, 2]];
  const P2 = [[10, 1], [10, 1], [9, 1], [9, 1], [8, 1], [8, 1], [7, 2]];
  const P3 = [[11, 1], [11, 1], [10, 1], [10, 1], [9, 1], [9, 1], [8, 2]];
  const MEL = [...P1, ...P2, ...P3, ...P3, ...P1, ...P2];
  const BASS = [0, 0, 3, 0, 3, 0, 4, 0, 0, 3, 0, 4, 0, 3, 0, 4, 0, 0, 3, 0, 3, 0, 4, 0]; // 2拍ごと
  const LOOP = 48; // 拍
  const MEL_FIGS = ['nm_hook', 'nm_phone_intro', 'nm_share', 'nm_occasions', 'end'];
  const TAPS = [0.16, 0.26, 0.36, 0.46, 0.56, 0.66];
  const NAMES = ['ド', 'レ', 'ミ', 'ファ', 'ソ', 'ラ', 'シ', 'ド', 'レ', 'ミ', 'ファ', 'ソ', 'ラ', 'シ', 'ド'];

  // 手回しの速さ（1秒あたりの回転数）。場面の進み具合 u（0〜1）で決める
  function crankRps(u) {
    if (u < 0.18) return L.lerp(0, 1.4, u / 0.18);
    if (u < 0.5) return 1.4;
    if (u < 0.62) return L.lerp(1.4, 0.35, (u - 0.5) / 0.12);
    if (u < 0.78) return 0.35;
    if (u < 0.86) return L.lerp(0.35, 0, (u - 0.78) / 0.08);
    return 0;
  }
  function crankAngle(lt, dur) { // 度
    let a = 0; const dt = 1 / 240;
    for (let s = 0; s < lt; s += dt) a += crankRps(s / dur) * 360 * dt;
    return a;
  }

  function melodyNotes(t0, t1) {
    const out = [];
    let beat = 0;
    for (let rep = 0; t0 + beat * BEAT < t1; rep++) {
      let b = 0;
      for (const [idx, len] of MEL) {
        const t = t0 + (beat + b) * BEAT;
        if (t < t1 - 0.1) out.push({ type: 'note', part: 'mel', t: +t.toFixed(3), idx, len: len * BEAT });
        b += len;
      }
      BASS.forEach((idx, k) => {
        const t = t0 + (beat + k * 2) * BEAT;
        if (t < t1 - 0.1) out.push({ type: 'note', part: 'bass', t: +t.toFixed(3), idx, len: 2 * BEAT });
      });
      beat += LOOP;
      if (rep > 10) break;
    }
    return out;
  }

  function cues(tl) {
    const out = [];
    // 続けてメロディが鳴る場面をひとまとまりにし、その頭から曲を始める
    let seg = null;
    const segs = [];
    for (const s of tl.scenes) {
      if (MEL_FIGS.includes(s.fig)) {
        if (!seg) { seg = [s.start, s.start + s.dur]; segs.push(seg); } else seg[1] = s.start + s.dur;
      } else seg = null;
    }
    for (const [a, b] of segs) out.push(...melodyNotes(a + 0.35, b - 0.3));
    for (const s of tl.scenes) {
      if (s.fig === 'nm_step1') {
        TAPS.forEach((f, k) => out.push({ type: 'note', part: 'tap', t: +(s.start + f * s.dur).toFixed(3), idx: MEL[k][0], len: 0.5 }));
      }
      if (s.fig === 'nm_step2') {
        let prev = 0, k = 0;
        for (let lt = 0; lt < s.dur; lt += 1 / 120) {
          const a = crankAngle(lt, s.dur);
          if (Math.floor(a / 120) > Math.floor(prev / 120)) {
            out.push({ type: 'note', part: 'crank', t: +(s.start + lt).toFixed(3), idx: MEL[k % MEL.length][0], len: 0.5 });
            k++;
          }
          prev = a;
        }
      }
    }
    return out.sort((x, y) => x.t - y.t);
  }

  // ── 部品 ──
  function mbox(ang) {
    let s = '';
    s += L.el('ellipse', { cx: 0, cy: 132, rx: 255, ry: 18, fill: 'rgba(60,30,10,0.18)' });
    s += L.rect(-260, -110, 520, 232, { rx: 26, fill: 'url(#nmWood)' });
    s += L.rect(-246, -102, 492, 22, { rx: 11, fill: 'rgba(255,255,255,0.16)' });
    s += L.rect(-224, -80, 290, 128, { rx: 16, fill: '#5b3519' });
    s += L.rect(-210, -68, 262, 36, { rx: 8, fill: 'url(#nmBrass)' });
    for (let i = 0; i < 15; i++) {
      const x = -204 + i * 17.2, len = 70 - i * 2.4;
      s += L.rect(x, -34, 10, len, { rx: 3, fill: 'url(#nmBrass)', stroke: 'rgba(110,70,20,0.5)', 'stroke-width': 1 });
    }
    s += L.rect(86, -80, 140, 128, { rx: 16, fill: '#5b3519' });
    s += `<g transform="translate(156 -16) rotate(${(ang * 0.6).toFixed(2)})">`
      + Array.from({ length: 12 }, (_, i) => `<rect x="-5" y="-50" width="10" height="16" rx="2" fill="#c99a3a" transform="rotate(${i * 30})"/>`).join('')
      + L.circle(0, 0, 38, { fill: 'url(#nmBrass)', stroke: '#8a6420', 'stroke-width': 3 })
      + L.circle(0, 0, 10, { fill: '#8a6420' }) + L.line(0, -30, 0, 30, { stroke: '#8a6420', 'stroke-width': 5 }) + L.line(-30, 0, 30, 0, { stroke: '#8a6420', 'stroke-width': 5 })
      + '</g>';
    s += L.rect(-186, 110, 372, 12, { rx: 6, fill: '#3a2210' });
    s += `<g transform="translate(276 12) rotate(${ang.toFixed(2)})">`
      + L.rect(-9, -98, 18, 100, { rx: 9, fill: '#7a4a22' })
      + L.circle(0, -98, 24, { fill: '#d9a066', stroke: '#7a4a22', 'stroke-width': 4 })
      + '</g>'
      + L.circle(276, 12, 18, { fill: 'url(#nmBrass)', stroke: '#8a6420', 'stroke-width': 3 });
    return s;
  }
  const colX = (idx, x0 = -180, w = 360) => x0 + w / 15 * (idx + 0.5);

  // 縦に流れるテープ。yTop が鳴る位置
  function strip(now, notes, yTop, yBottom, o = {}) {
    const { x0 = -180, w = 360, pps = PX_PER_SEC } = o;
    let s = L.rect(x0, yTop, w, yBottom - yTop, { fill: TH.paper, stroke: 'rgba(120,80,40,0.25)', 'stroke-width': 2 });
    for (let i = 1; i < 15; i++) s += L.line(x0 + w / 15 * i, yTop, x0 + w / 15 * i, yBottom, { stroke: 'rgba(120,80,40,0.12)', 'stroke-width': 1.5 });
    const rowPx = BEAT * pps;
    const off = ((now % BEAT) / BEAT) * rowPx;
    for (let y = yTop - off; y < yBottom; y += rowPx) if (y > yTop) s += L.line(x0, y, x0 + w, y, { stroke: 'rgba(120,80,40,0.18)', 'stroke-width': 1.5 });
    for (const n of notes) {
      if (n.part !== 'mel' && n.part !== 'bass') continue;
      const y = yTop + (n.t - now) * pps;
      if (y < yTop - 4 || y > yBottom - 10) continue;
      const cw = w / 15;
      s += L.rect(x0 + cw * n.idx + cw * 0.2, y - 8, cw * 0.6, 16, { rx: 7, fill: TH.hole, opacity: n.part === 'bass' ? 0.75 : 1 });
    }
    return s;
  }

  function noteGlyphs(now, notes, baseY, xOf, parts = ['mel']) {
    let s = '';
    for (const n of notes) {
      if (!parts.includes(n.part)) continue;
      const age = now - n.t;
      if (age < 0 || age > 1.5) continue;
      const x = xOf(n.idx) + Math.sin(age * 4 + n.idx) * 12;
      const y = baseY - age * 120;
      s += L.op(1 - age / 1.5, L.text(x, y, n.idx % 2 ? '♪' : '♫', { size: 54, weight: 700, fill: TH.note }));
    }
    return s;
  }

  const notesOf = ctx => ctx.tl.cues;

  // ── 場面 ──
  function nm_hook(ctx) {
    const { t, w, h, vert } = ctx;
    const cx = w / 2, cy = vert ? 330 : 250, sc = vert ? 1.4 : 1.12;
    const ang = t * 200;
    const yb = (h - cy) / sc;
    return L.tr(cx, cy, sc, strip(t, notesOf(ctx), 117, yb) + mbox(ang) + noteGlyphs(t, notesOf(ctx), -140, i => colX(i, -204, 258)));
  }

  function appScreen(t, notes, sw, sh) {
    let s = L.rect(0, 0, sw, sh, { fill: '#fffaf3' });
    s += L.rect(0, 0, sw, sh * 0.12, { fill: '#f1dfc2' });
    s += L.text(sw / 2, sh * 0.075, 'あたらしい曲', { size: sw * 0.07, weight: 700, fill: TH.ink, fam: 'maru' });
    const gx = sw * 0.06, gw = sw * 0.88, gy = sh * 0.2, gb = sh * 0.76;
    const k = gw / 360;
    s += [0, 7, 14].map(i => L.text(gx + gw / 15 * (i + 0.5), sh * 0.165, 'ド', { size: sw * 0.04, weight: 700, fill: TH.sub })).join('');
    s += L.tr(gx + gw / 2, gy, k, strip(t, notes, 0, (gb - gy) / k));
    s += L.rect(gx - 6, gy - 7, gw + 12, 14, { rx: 7, fill: '#c99a3a' });
    s += L.tr(sw * 0.5, sh * 0.87, sw / 1500, mbox(t * 200));
    return s;
  }

  function nm_phone_intro(ctx) {
    const { t, lt, w, vert } = ctx;
    const a = L.easeOut(L.seg(lt, 0, 0.5));
    const [pw, ph] = vert ? [520, 1020] : [390, 740];
    const px = w / 2 - pw / 2, py = vert ? 40 : 4;
    return L.tr(0, (1 - a) * 60, 1, L.phone(px, py, pw, ph, (sw, sh) => appScreen(t, notesOf(ctx), sw, sh)));
  }

  function nm_step1(ctx) {
    const { lt, dur, w, vert } = ctx;
    const [cx0, cy0, cw, ch] = vert ? [60, 90, 880, 900] : [330, 30, 1040, 700];
    let s = L.card(cx0, cy0, cw, ch, { r: 36, fill: '#fffaf3' });
    const gx = cx0 + 110, gy = cy0 + 150, gw = cw - 160, gh = ch - 210;
    const cols = 15, rows = 8, cwid = gw / cols, rh = gh / rows;
    s += L.text(gx + gw / 2, cy0 + 60, '音の高さ →', { size: 40, weight: 700, fill: TH.sub, fam: 'maru' });
    s += `<g transform="translate(${cx0 + 55} ${gy + gh / 2}) rotate(-90)">${L.text(0, 0, '時間 →', { size: 40, weight: 700, fill: TH.sub, fam: 'maru' })}</g>`;
    NAMES.forEach((n, i) => { s += L.text(gx + cwid * (i + 0.5), gy - 30, n, { size: n.length > 1 ? 18 : 24, weight: 700, fill: TH.sub }); });
    s += L.rect(gx, gy, gw, gh, { fill: TH.paper, stroke: 'rgba(120,80,40,0.3)', 'stroke-width': 2 });
    for (let i = 1; i < cols; i++) s += L.line(gx + cwid * i, gy, gx + cwid * i, gy + gh, { stroke: 'rgba(120,80,40,0.15)', 'stroke-width': 1.5 });
    for (let j = 1; j < rows; j++) s += L.line(gx, gy + rh * j, gx + gw, gy + rh * j, { stroke: 'rgba(120,80,40,0.15)', 'stroke-width': 1.5 });
    const cell = k => [gx + cwid * (MEL[k][0] + 0.5), gy + rh * (k + 0.5)];
    let fx = gx + gw * 0.8, fy = gy + gh + 60, press = 0;
    TAPS.forEach((f, k) => {
      const tk = f * dur;
      if (lt >= tk) {
        const a = L.back(L.seg(lt, tk, tk + 0.25));
        const [x, y] = cell(k);
        s += L.rect(x - cwid * 0.3 * a, y - 10 * a, cwid * 0.6 * a, 20 * a, { rx: 8, fill: TH.hole });
      }
    });
    for (let k = 0; k < TAPS.length; k++) {
      const tk = TAPS[k] * dur, tprev = k ? TAPS[k - 1] * dur : 0;
      if (lt <= tk) {
        const [x, y] = cell(k);
        const [x0, y0] = k ? cell(k - 1) : [fx, fy];
        const m = L.ease(L.seg(lt, tprev + 0.08, tk));
        fx = L.lerp(x0, x, m); fy = L.lerp(y0, y, m);
        press = Math.max(0, 1 - Math.abs(lt - tk) / 0.12);
        break;
      }
      const [x, y] = cell(k); fx = x; fy = y;
      press = Math.max(0, 1 - Math.abs(lt - tk) / 0.12);
    }
    s += L.finger(fx + 6, fy + 10, press, 'rgba(168,100,42,0.85)');
    s += L.stepBadge(cx0 + 10, cy0 + 10, 1, TH.accent, '#fff', "'Zen Maru Gothic'");
    return s;
  }

  function nm_step2(ctx) {
    const { lt, dur, w, h, vert } = ctx;
    const ang = crankAngle(lt, dur);
    const rps = crankRps(lt / dur);
    const [bx, by, sc] = vert ? [440, 470, 1.25] : [640, 400, 1.1];
    let s = '';
    const notes = notesOf(ctx).filter(n => n.part === 'crank');
    s += L.tr(bx, by, sc, mbox(ang)
      + L.el('circle', { cx: 276, cy: 12, r: 128, fill: 'none', stroke: 'rgba(168,100,42,0.5)', 'stroke-width': 6, 'stroke-dasharray': '4 18', 'stroke-linecap': 'round' })
      + noteGlyphs(ctx.t, notes, -140, i => colX(i, -204, 258), ['crank']));
    const kr = ang * Math.PI / 180;
    const kx = bx + (276 + 98 * Math.sin(kr)) * sc, ky = by + (12 - 98 * Math.cos(kr)) * sc;
    s += L.finger(kx, ky, rps > 0.05 ? 0.4 : 0, 'rgba(255,255,255,0.92)');
    const [gx, gy, gw] = vert ? [180, 900, 640] : [1180, 300, 440];
    s += L.card(gx - 40, gy - 90, gw + 80, 190, { r: 30, fill: '#fffaf3' });
    s += L.text(gx, gy - 40, 'おそい', { size: 34, weight: 700, fill: TH.sub, anchor: 'start', fam: 'maru' });
    s += L.text(gx + gw, gy - 40, 'はやい', { size: 34, weight: 700, fill: TH.sub, anchor: 'end', fam: 'maru' });
    s += L.rect(gx, gy, gw, 22, { rx: 11, fill: '#ead6b6' });
    s += L.rect(gx, gy, gw * L.clamp(rps / 1.4), 22, { rx: 11, fill: TH.accent });
    s += L.circle(gx + gw * L.clamp(rps / 1.4), gy + 11, 22, { fill: '#fff', stroke: TH.accent, 'stroke-width': 6 });
    s += L.text(gx + gw / 2, gy + 70, rps < 0.02 ? 'とまった' : `テンポ ${Math.round(60 * rps * 3)}`, { size: 30, weight: 700, fill: TH.ink });
    s += L.stepBadge(vert ? 70 : 150, vert ? 70 : 60, 2, TH.accent, '#fff', "'Zen Maru Gothic'");
    return s;
  }

  function field(x, y, w, label, value, active) {
    return L.text(x, y, label, { size: 34, weight: 700, fill: TH.sub, anchor: 'start' })
      + L.rect(x, y + 30, w, 90, { rx: 18, fill: '#fff', stroke: active ? TH.accent : '#e3cfae', 'stroke-width': active ? 5 : 3 })
      + L.text(x + 30, y + 77, value, { size: 44, weight: 700, fill: TH.ink, anchor: 'start', fam: 'maru' });
  }
  function nm_step3(ctx) {
    const { p, vert } = ctx;
    const [x, y, cw, ch] = vert ? [100, 60, 800, 760] : [190, 40, 780, 660];
    let s = L.card(x, y, cw, ch, { r: 36, fill: '#fffaf3' });
    s += L.text(x + cw / 2, y + 80, '曲を贈る', { size: 52, weight: 900, fill: TH.ink, fam: 'maru' });
    s += L.tr(x + cw / 2, y + (vert ? 190 : 150), 0.32, mbox(ctx.t * 120));
    const fy = y + (vert ? 300 : 230), gapY = vert ? 160 : 140;
    s += field(x + 60, fy, cw - 120, '曲名', L.typed('ありがとう', L.seg(p, 0.08, 0.3)), p > 0.06 && p < 0.32);
    s += field(x + 60, fy + gapY, cw - 120, '宛名', L.typed('お母さんへ', L.seg(p, 0.34, 0.56)), p > 0.32 && p < 0.58);
    const press = 1 - 0.06 * Math.max(0, 1 - Math.abs(p - 0.66) / 0.04);
    const by = fy + gapY + (vert ? 170 : 150);
    s += L.tr(x + cw / 2, by + 50, press, L.rect(-230, -50, 460, 100, { rx: 50, fill: TH.accent }) + L.text(0, 2, 'リンクで贈る', { size: 44, weight: 900, fill: '#fff' }));
    const lk = L.back(L.seg(p, 0.7, 0.8));
    const [lx, ly] = vert ? [ctx.w / 2, 920] : [1330, 300];
    s += L.op(L.seg(p, 0.7, 0.74), L.tr(lx, ly, Math.max(0.01, lk), L.linkIcon(0, 0, 90, '#fff', '#3478f6')));
    const ty = vert ? 125 : 160;
    s += L.op(L.seg(p, 0.76, 0.82), L.tr(lx, ly, 1,
      L.rect(-250, ty - 40, 500, 80, { rx: 40, fill: 'rgba(59,42,26,0.85)' })
      + L.text(0, ty + 2, 'リンクをコピーしました', { size: 34, weight: 700, fill: '#fff' })));
    s += L.stepBadge(x + 10, y + 10, 3, TH.accent, '#fff', "'Zen Maru Gothic'");
    return s;
  }

  function shareLeft(t) {
    return (sw, sh) => L.rect(0, 0, sw, sh, { fill: '#fffaf3' })
      + L.text(sw / 2, sh * 0.16, 'ありがとう', { size: sw * 0.11, weight: 900, fill: TH.ink, fam: 'maru' })
      + L.text(sw / 2, sh * 0.25, 'お母さんへ', { size: sw * 0.07, weight: 700, fill: TH.sub, fam: 'maru' })
      + L.tr(sw / 2, sh * 0.52, sw / 720, mbox(t * 160))
      + L.rect(sw * 0.15, sh * 0.78, sw * 0.7, sh * 0.08, { rx: sh * 0.04, fill: TH.accent })
      + L.text(sw / 2, sh * 0.82, 'リンクで贈る', { size: sw * 0.07, weight: 900, fill: '#fff' });
  }
  function shareRight(ctx) {
    return (bw, bh) => {
      const k = Math.min(bw / 760, bh / 470);
      return L.rect(0, 0, bw, bh, { fill: '#fff8ee' })
        + L.text(bw / 2, bh * 0.13, 'お母さんへ ♪ ありがとう', { size: 40 * k * 1.2, weight: 900, fill: TH.ink, fam: 'maru' })
        + L.tr(bw / 2, bh * 0.6, k, mbox(ctx.t * 200) + noteGlyphs(ctx.t, notesOf(ctx), -130, i => colX(i, -204, 258)));
    };
  }
  function nm_share(ctx) {
    return L.flow(ctx, { left: shareLeft(ctx.t), right: shareRight(ctx), rightLabel: 'アプリがなくても、ブラウザで聴ける', labelFill: TH.ink, labelFam: 'maru', arrowColor: 'rgba(59,42,26,0.35)' });
  }

  function iconGift() {
    return L.rect(-60, -30, 120, 90, { rx: 10, fill: '#e2788c' }) + L.rect(-70, -52, 140, 30, { rx: 8, fill: '#ef93a5' })
      + L.rect(-10, -52, 20, 112, { fill: '#fff' }) + L.el('ellipse', { cx: -24, cy: -62, rx: 26, ry: 16, fill: 'none', stroke: '#fff', 'stroke-width': 10 })
      + L.el('ellipse', { cx: 24, cy: -62, rx: 26, ry: 16, fill: 'none', stroke: '#fff', 'stroke-width': 10 });
  }
  function iconSakura() {
    let s = '';
    for (let i = 0; i < 5; i++) s += `<ellipse cx="0" cy="-36" rx="26" ry="38" fill="#f6b3c6" transform="rotate(${i * 72})"/>`;
    return s + L.circle(0, 0, 14, { fill: '#e07a93' });
  }
  function iconCarnation() {
    let s = L.line(0, 10, 0, 80, { stroke: '#5a9a4a', 'stroke-width': 8 }) + `<ellipse cx="-22" cy="52" rx="22" ry="9" fill="#5a9a4a" transform="rotate(-30 -22 52)"/>`;
    const r = L.rng(7);
    for (let i = 0; i < 14; i++) s += L.circle((r() - 0.5) * 70, -20 + (r() - 0.5) * 50, 20 + r() * 8, { fill: i % 3 ? '#d9415b' : '#ef6b80' });
    return s;
  }
  function nm_occasions(ctx) {
    const { lt, vert } = ctx;
    const items = [['ホワイトデー', iconGift()], ['卒業・送別', iconSakura()], ['母の日', iconCarnation()]];
    let s = '';
    items.forEach(([label, icon], k) => {
      const a = L.back(L.seg(lt, 0.15 + k * 0.35, 0.55 + k * 0.35));
      if (a <= 0) return;
      if (vert) {
        const y = 60 + k * 330;
        s += L.tr(500, y + 130, a, L.card(-380, -130, 760, 260, { r: 40, fill: '#fffaf3' }) + L.tr(-240, 0, 1.2, icon)
          + L.text(-80, -20, label, { size: 64, weight: 900, fill: TH.ink, anchor: 'start', fam: 'maru' })
          + L.text(-80, 60, '♪ メロディを贈る', { size: 38, weight: 700, fill: TH.accent, anchor: 'start' }));
      } else {
        const x = 300 + k * 550;
        s += L.tr(x, 380, a, L.card(-240, -300, 480, 600, { r: 44, fill: '#fffaf3' }) + L.tr(0, -100, 1.6, icon)
          + L.text(0, 130, label, { size: 60, weight: 900, fill: TH.ink, fam: 'maru' })
          + L.text(0, 210, '♪ メロディを贈る', { size: 36, weight: 700, fill: TH.accent }));
      }
    });
    return s;
  }

  function motif(ctx) {
    return L.tr(0, 0, 0.62, mbox(ctx.t * 200) + noteGlyphs(ctx.t, notesOf(ctx), -140, i => colX(i, -204, 258)));
  }

  function bg(ctx) {
    const { W, H, t } = ctx;
    let s = L.rect(0, 0, W, H, { fill: 'url(#nmBg)' });
    const r = L.rng(11);
    for (let i = 0; i < 9; i++) {
      const x = r() * W, y = r() * H, rr = 80 + r() * 220;
      s += L.circle(x + Math.sin(t * 0.3 + i) * 30, y + Math.cos(t * 0.25 + i) * 30, rr, { fill: '#fff6e3', opacity: 0.35 });
    }
    return s;
  }
  function defs() {
    return '<linearGradient id="nmBg" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#fbf1e1"/><stop offset="1" stop-color="#ecd3ab"/></linearGradient>'
      + '<linearGradient id="nmWood" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#c88c50"/><stop offset="1" stop-color="#8b5427"/></linearGradient>'
      + '<linearGradient id="nmBrass" x1="0" y1="0" x2="1" y2="1"><stop offset="0" stop-color="#f6d98a"/><stop offset="0.5" stop-color="#d9ae4c"/><stop offset="1" stop-color="#b0832a"/></linearGradient>';
  }

  APPS.nejimaki = {
    name: 'ネジマキ', category: 'オルゴール作曲アプリ', release: '2027年3月', catch: '回すと鳴る、手づくりのメロディ。',
    fam: "'Zen Maru Gothic'", theme: TH, bg, defs, motif, cues,
    audio: { kind: 'musicbox', beat: BEAT },
    figs: { nm_hook, nm_phone_intro, nm_step1, nm_step2, nm_step3, nm_share, nm_occasions },
    scripts: {
      V: [
        { fig: 'nm_hook', text: '穴をあけて、|ネジを回すと――', say: '穴をあけて、ネジを回すと。' },
        { fig: 'nm_phone_intro', text: 'あなたの作ったメロディが、|オルゴールで鳴ります。' },
        { fig: 'nm_share', text: 'できた曲はリンクで贈れて、|相手はブラウザで回して聴けます。' },
        { fig: 'end', text: 'オルゴール作曲アプリ、|ネジマキ。2027年3月公開予定。', say: 'オルゴール作曲アプリ、ネジマキ。二〇二七年三月、公開予定。' },
      ],
      H: [
        { fig: 'nm_hook', text: '紙テープに穴をあけて、ネジを回す。' },
        { fig: 'nm_phone_intro', text: '手回しオルゴールの作曲を、|スマホでそのまま楽しめるアプリです。' },
        { fig: 'nm_step1', text: '使い方は3つだけ。|音の高さと時間のマスをタップして、穴をあける。', say: '使い方は三つだけ。音の高さと時間のマスをタップして、穴をあける。' },
        { fig: 'nm_step2', text: '右下のネジを指で回す。|速く回せば速く、止めれば止まります。' },
        { fig: 'nm_step3', text: 'できた曲に名前と宛名をつけて、|リンクで贈る。' },
        { fig: 'nm_share', text: '受け取った人は、アプリがなくても、|ブラウザでネジを回して聴けます。' },
        { fig: 'nm_occasions', text: 'ホワイトデーや卒業、母の日の、|音のメッセージカードに。' },
        { fig: 'end', text: 'ネジマキ。|2027年3月、公開予定です。', say: 'ネジマキ。二〇二七年三月、公開予定です。' },
      ],
    },
  };
})();
