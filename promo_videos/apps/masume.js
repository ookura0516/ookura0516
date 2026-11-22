// マスメ（すごろくメーカー）
(function () {
  const TH = {
    ink: '#2b2d42', sub: '#5c6178', accent: '#ff6b4a', onAccent: '#fff',
    capBg: 'rgba(43,45,66,0.92)', capInk: '#ffffff', faint: 'rgba(43,45,66,0.5)',
  };
  const COLORS = ['#ff8a65', '#2ec4b6', '#ffca3a', '#5aa9ff', '#ff8fb1', '#8ac926'];
  const LABELS = ['口ぐせを|まねる', '3マス|進む', '思い出を|一言', '1回|休み', '歌って|次へ', '乾杯！', '変顔で|写真', '2マス|戻る', '秘密を|ひとつ', 'ワープ！', '好きな|食べ物', 'みんなに|感謝', 'もう一度|ふる', '初めて|会った日', '最近の|ニュース', 'あだ名の|由来', '一発ギャグ', '5マス|進む'];
  const PIECES = [['#ff6b4a', 'A'], ['#2ec4b6', 'B'], ['#3d405b', 'C']];

  function layout(cols, rows) {
    const cells = [];
    for (let r = 0; r < rows; r++) for (let c = 0; c < cols; c++) cells.push([r % 2 ? cols - 1 - c : c, r]);
    return cells;
  }
  function labelOf(i, n) { return i === 0 ? 'スタート' : i === n - 1 ? 'ゴール' : LABELS[(i - 1) % LABELS.length]; }

  // すごろくの盤。shown は現れたマスの数（小数で途中）、pos は各コマの位置（マス番号、小数で移動中）
  function board(x, y, w, h, cols, rows, shown, pos = [], o = {}) {
    const { fs = 26, gap = 14 } = o;
    const cells = layout(cols, rows), n = cells.length;
    const cw = (w - gap * (cols - 1)) / cols, ch = (h - gap * (rows - 1)) / rows;
    const ctr = i => [x + cells[i][0] * (cw + gap) + cw / 2, y + cells[i][1] * (ch + gap) + ch / 2];
    let s = '';
    let d = '';
    for (let i = 0; i < n; i++) { const [cx, cy] = ctr(i); d += (i ? 'L' : 'M') + cx + ' ' + cy; }
    s += L.path(d, { fill: 'none', stroke: 'rgba(43,45,66,0.15)', 'stroke-width': Math.min(cw, ch) * 0.35, 'stroke-linejoin': 'round', 'stroke-linecap': 'round' });
    for (let i = 0; i < n; i++) {
      const a = L.back(L.clamp(shown - i));
      if (a <= 0) continue;
      const [cx, cy] = ctr(i);
      const edge = i === 0 || i === n - 1;
      const fill = edge ? TH.ink : COLORS[i % COLORS.length];
      let q = L.rect(-cw / 2, -ch / 2, cw, ch, { rx: Math.min(cw, ch) * 0.2, fill, stroke: '#fff', 'stroke-width': 4 });
      const lines = labelOf(i, n).split('|');
      lines.forEach((t, k) => { q += L.text(0, (k - (lines.length - 1) / 2) * fs * 1.2 + 1, t, { size: t.length > 5 ? fs * 0.85 : fs, weight: 900, fill: '#fff', fam: 'maru' }); });
      s += L.tr(cx, cy, Math.max(0.01, a), q);
    }
    pos.forEach((pp, k) => {
      if (pp === null || pp === undefined) return;
      const i0 = Math.floor(pp), f = pp - i0;
      const [x0, y0] = ctr(Math.min(n - 1, i0)), [x1, y1] = ctr(Math.min(n - 1, i0 + 1));
      const hop = Math.sin(Math.PI * f) * ch * 0.35;
      const px = L.lerp(x0, x1, f) + (k - 1) * cw * 0.22, py = L.lerp(y0, y1, f) + ch * 0.28 - hop;
      s += L.circle(px, py + 4, cw * 0.13, { fill: 'rgba(0,0,0,0.2)' }) + L.circle(px, py, cw * 0.13, { fill: PIECES[k][0], stroke: '#fff', 'stroke-width': 4 })
        + L.text(px, py + 1, PIECES[k][1], { size: cw * 0.13, weight: 900, fill: '#fff' });
    });
    return s;
  }

  const PIPS = { 1: [[0, 0]], 2: [[-1, -1], [1, 1]], 3: [[-1, -1], [0, 0], [1, 1]], 4: [[-1, -1], [1, -1], [-1, 1], [1, 1]], 5: [[-1, -1], [1, -1], [0, 0], [-1, 1], [1, 1]], 6: [[-1, -1], [1, -1], [-1, 0], [1, 0], [-1, 1], [1, 1]] };
  function die(cx, cy, size, face, rot = 0) {
    let s = `<g transform="translate(${cx} ${cy}) rotate(${rot})">` + L.rect(-size / 2 + 5, -size / 2 + 8, size, size, { rx: size * 0.2, fill: 'rgba(0,0,0,0.2)' })
      + L.rect(-size / 2, -size / 2, size, size, { rx: size * 0.2, fill: '#fff', stroke: '#e3e3ea', 'stroke-width': 3 });
    for (const [dx, dy] of PIPS[face]) s += L.circle(dx * size * 0.26, dy * size * 0.26, size * 0.09, { fill: face === 1 ? TH.accent : TH.ink });
    return s + '</g>';
  }
  // 振ってから result で止まるサイコロ
  function rolling(lt, t0, t1, result) {
    if (lt < t0) return { face: result === 1 ? 6 : 1, rot: 0, y: 0 };
    if (lt >= t1) return { face: result, rot: 0, y: 0 };
    const u = (lt - t0) / (t1 - t0);
    const k = Math.floor(lt * 14);
    return { face: (k * 7 + 3) % 6 + 1, rot: (1 - u) * 540 * Math.sin(u * 3), y: -Math.sin(Math.PI * u) * 60 };
  }

  // 場面ごとの出来事（cues と絵で同じものを使う）
  const BOARD_T = { fill: [0.08, 0.5], roll: [0.56, 0.68], move: [0.7, 0.9], result: 4 };

  function cues(tl) {
    const out = [];
    for (const s of tl.scenes) {
      const at = f => +(s.start + f * s.dur).toFixed(3);
      const n = tl.fmt === 'V' ? 20 : 18;
      if (s.fig === 'ms_board') {
        for (let i = 0; i < n; i += 2) out.push({ type: 'pop', t: at(L.lerp(BOARD_T.fill[0], BOARD_T.fill[1], i / n)), n: i });
        out.push({ type: 'dice', t: at(BOARD_T.roll[0]) });
        for (let k = 0; k < BOARD_T.result; k++) out.push({ type: 'step', t: at(L.lerp(BOARD_T.move[0], BOARD_T.move[1], (k + 0.5) / BOARD_T.result)) });
      }
      if (s.fig === 'ms_hook') [0.15, 0.3, 0.45].forEach((f, k) => out.push({ type: 'pop', t: at(f), n: k * 3 }));
      if (s.fig === 'ms_edit') { out.push({ type: 'pop', t: at(0.12), n: 2 }); out.push({ type: 'ding', t: at(0.8) }); }
      if (s.fig === 'ms_deck') [0.25, 0.6].forEach(f => out.push({ type: 'flip', t: at(f) }));
      if (s.fig === 'ms_tv') { out.push({ type: 'dice', t: at(0.62) }); [0.78, 0.84, 0.9].forEach(f => out.push({ type: 'step', t: at(f) })); }
      if (s.fig === 'ms_print') out.push({ type: 'pop', t: at(0.2), n: 6 });
      if (s.fig === 'end') out.push({ type: 'ding', t: at(0.1) });
    }
    return out.sort((a, b) => a.t - b.t);
  }

  function bunting(w, y, t, count = 12) {
    let s = L.path(`M0 ${y}Q${w / 2} ${y + 70} ${w} ${y}`, { fill: 'none', stroke: TH.sub, 'stroke-width': 3 });
    for (let i = 0; i < count; i++) {
      const u = (i + 0.5) / count, x = u * w, yy = y + 70 * 2 * u * (1 - u) * 1 + 0;
      const sw = Math.sin(t * 2 + i) * 4;
      s += L.path(`M${x - 26} ${yy}L${x + 26} ${yy}L${x + sw} ${yy + 60}Z`, { fill: COLORS[i % COLORS.length] });
    }
    return s;
  }

  // ── 場面 ──
  function ms_hook(ctx) {
    const { lt, dur, w, h, t, vert } = ctx;
    let s = bunting(w, 10, t, vert ? 9 : 14);
    const items = ['送別会', '同窓会', '二次会'];
    items.forEach((label, k) => {
      const a = L.back(L.seg(lt, (0.12 + k * 0.15) * dur, (0.25 + k * 0.15) * dur));
      if (a <= 0) return;
      const [cx, cy] = vert ? [500, 330 + k * 250] : [330 + k * 520, 360];
      const rot = (k - 1) * 4;
      s += L.tr(cx, cy, a, `<g transform="rotate(${rot})">` + L.card(-200, -95, 400, 190, { r: 36, fill: '#fff' })
        + L.text(0, 4, label, { size: 64, weight: 900, fill: COLORS[k * 2 % COLORS.length], fam: 'maru' }) + '</g>'
        + L.op(L.seg(lt, (0.3 + k * 0.15) * dur, (0.38 + k * 0.15) * dur), L.tr(vert ? 230 : 150, vert ? -60 : -150, 1,
          L.circle(0, 0, 52, { fill: TH.accent }) + L.text(0, 4, '？', { size: 64, weight: 900, fill: '#fff', fam: 'maru' }))));
    });
    return s;
  }

  function ms_board(ctx) {
    const { lt, dur, p, w, h, vert } = ctx;
    const [cols, rows] = vert ? [4, 5] : [6, 3];
    const n = cols * rows;
    const shown = L.seg(p, BOARD_T.fill[0], BOARD_T.fill[1]) * (n + 1);
    const move = L.seg(p, BOARD_T.move[0], BOARD_T.move[1]) * BOARD_T.result;
    const pos = p < BOARD_T.fill[1] ? [] : [move, 0, 0];
    const [bx, by, bw, bh] = vert ? [40, 20, 920, 860] : [40, 20, 1280, 700];
    let s = L.card(bx - 24, by - 24, bw + 48, bh + 48, { r: 40, fill: '#fffdf8' });
    s += board(bx, by, bw, bh, cols, rows, shown, pos, { fs: vert ? 30 : 28 });
    const r = rolling(lt, BOARD_T.roll[0] * dur, BOARD_T.roll[1] * dur, BOARD_T.result);
    const [dx, dy] = vert ? [500, 1010] : [1520, 360];
    s += L.op(L.seg(p, 0.5, 0.56), die(dx, dy + r.y, 150, r.face, r.rot));
    return s;
  }

  function ms_edit(ctx) {
    const { p, w, vert } = ctx;
    let s = '';
    const tpl = ['送別会', '同窓会', '結婚式の二次会', '家族旅行', 'お正月'];
    tpl.forEach((t, k) => {
      const on = k === 0;
      s += L.card(40, 30 + k * 130, 380, 104, { r: 28, fill: on ? TH.accent : '#fff' })
        + L.text(230, 82 + k * 130, t, { size: 40, weight: 900, fill: on ? '#fff' : TH.ink, fam: 'maru' });
    });
    s += L.text(230, 720, 'テンプレート', { size: 34, weight: 700, fill: TH.sub });
    const a = L.back(L.seg(p, 0.08, 0.2));
    s += L.tr(1060, 360, Math.max(0.01, a),
      L.card(-520, -330, 1040, 660, { r: 50, fill: '#fff' })
      + L.text(-460, -260, 'マスの中身', { size: 40, weight: 700, fill: TH.sub, anchor: 'start' })
      + ['進む', '戻る', '休み', 'お題'].map((c, i) => {
        const on = i === 3;
        return L.rect(-460 + i * 190, -210, 170, 80, { rx: 40, fill: on ? '#2ec4b6' : '#f1f2f6' }) + L.text(-375 + i * 190, -168, c, { size: 38, weight: 900, fill: on ? '#fff' : TH.ink, fam: 'maru' });
      }).join('')
      + L.rect(-460, -80, 920, 260, { rx: 36, fill: '#2ec4b6' })
      + L.text(0, 50, L.typed('〇〇さんの口ぐせをまねる', L.seg(p, 0.25, 0.75)), { size: 62, weight: 900, fill: '#fff', fam: 'maru' })
      + L.op(L.seg(p, 0.78, 0.85), L.text(0, 250, '✓ 保存しました', { size: 40, weight: 800, fill: '#2ec4b6' })));
    return s;
  }

  function card(cx, cy, rot, face, text, scaleX = 1) {
    const w = 360, h = 500;
    let s = `<g transform="translate(${cx} ${cy}) rotate(${rot}) scale(${Math.max(0.02, Math.abs(scaleX))} 1)">`;
    s += L.rect(-w / 2 + 6, -h / 2 + 10, w, h, { rx: 32, fill: 'rgba(0,0,0,0.18)' });
    if (face && scaleX > 0) {
      s += L.rect(-w / 2, -h / 2, w, h, { rx: 32, fill: '#fff', stroke: '#ffca3a', 'stroke-width': 10 })
        + L.text(0, -150, 'お題', { size: 44, weight: 900, fill: TH.accent, fam: 'maru' });
      const ls = text.split('|'); ls.forEach((t, k) => { s += L.text(0, 10 + (k - (ls.length - 1) / 2) * 72, t, { size: 52, weight: 900, fill: TH.ink, fam: 'maru' }); });
    } else {
      s += L.rect(-w / 2, -h / 2, w, h, { rx: 32, fill: '#2ec4b6', stroke: '#fff', 'stroke-width': 10 })
        + L.circle(0, 0, 90, { fill: 'rgba(255,255,255,0.18)' }) + L.text(0, 4, 'お題', { size: 64, weight: 900, fill: '#fff', fam: 'maru' });
    }
    return s + '</g>';
  }
  function ms_deck(ctx) {
    const { p, w } = ctx;
    let s = '';
    for (let k = 4; k >= 0; k--) s += card(520 + k * 14, 380 + k * 6, -12 + k * 5, false, '');
    const flip1 = L.seg(p, 0.2, 0.32), flip2 = L.seg(p, 0.55, 0.67);
    const c1x = L.lerp(560, 1000, L.ease(flip1));
    s += card(c1x, 380, L.lerp(-4, 4, flip1), flip1 > 0.5, '好きな給食を|発表する', Math.cos(Math.PI * flip1) * -1 || 0.02);
    if (flip2 > 0) {
      const c2x = L.lerp(560, 1420, L.ease(flip2));
      s += card(c2x, 380, L.lerp(-4, 6, flip2), flip2 > 0.5, '最近|うれしかった|こと', Math.cos(Math.PI * flip2) * -1 || 0.02);
    }
    s += L.tr(300, 100, 1, L.circle(0, 0, 110, { fill: TH.accent }) + L.text(0, -18, '300', { size: 76, weight: 900, fill: '#fff', fam: 'maru' }) + L.text(0, 48, '枚', { size: 40, weight: 900, fill: '#fff', fam: 'maru' }));
    return s;
  }

  function tv(x, y, w, h, inner) {
    return L.rect(x + 8, y + 14, w, h, { rx: 22, fill: 'rgba(0,0,0,0.2)' }) + L.rect(x, y, w, h, { rx: 22, fill: '#22232e' })
      + L.rect(x + 18, y + 18, w - 36, h - 36, { rx: 8, fill: '#fffdf8' })
      + `<g transform="translate(${x + 18} ${y + 18})">${inner(w - 36, h - 36)}</g>`
      + L.rect(x + w / 2 - 20, y + h, 40, 50, { fill: '#22232e' }) + L.rect(x + w / 2 - 140, y + h + 46, 280, 16, { rx: 8, fill: '#22232e' });
  }
  function ms_tv(ctx) {
    const { lt, p, dur, w, h, vert } = ctx;
    const aL = L.easeOut(L.seg(p, 0, 0.18)), aLink = L.seg(p, 0.18, 0.42), aR = L.easeOut(L.seg(p, 0.38, 0.58));
    const move = L.seg(p, 0.75, 0.93) * 3;
    const inner = (iw, ih) => board(iw * 0.05, ih * 0.08, iw * 0.9, ih * 0.84, 6, 3, 99, [move, 1, 0], { fs: iw / 50, gap: 8 });
    const phoneIn = (sw, sh) => L.rect(0, 0, sw, sh, { fill: '#fffdf8' }) + L.text(sw / 2, sh * 0.12, '送別会すごろく', { size: sw * 0.08, weight: 900, fill: TH.ink, fam: 'maru' })
      + board(sw * 0.08, sh * 0.2, sw * 0.84, sh * 0.5, 3, 4, 99, [], { fs: sw / 26, gap: 6 })
      + L.rect(sw * 0.15, sh * 0.8, sw * 0.7, sh * 0.08, { rx: sh * 0.04, fill: TH.accent }) + L.text(sw / 2, sh * 0.84, 'リンクで送る', { size: sw * 0.07, weight: 900, fill: '#fff' });
    let s = '';
    const r = rolling(lt, 0.62 * dur, 0.74 * dur, 3);
    if (vert) {
      s += L.op(aL, L.phone(350, 0, 300, 560, phoneIn));
      s += L.op(L.seg(p, 0.15, 0.25), L.arrow(500, 580, 500, 660, { color: 'rgba(43,45,66,0.35)', w: 6, dash: '2 16', head: 26 }));
      s += L.op(aLink > 0 && aLink < 1 ? 1 : 0, L.linkIcon(500, L.lerp(580, 660, L.ease(aLink)), 44));
      s += L.op(aR, tv(60, 660, 880, 320, inner));
      s += L.op(L.seg(p, 0.6, 0.65), die(840, 560, 110, r.face, r.rot));
    } else {
      s += L.op(aL, L.phone(80, 70, 330, 620, phoneIn));
      s += L.op(L.seg(p, 0.15, 0.25), L.arrow(440, 380, 560, 380, { color: 'rgba(43,45,66,0.35)', w: 6, dash: '2 16', head: 26 }));
      s += L.op(aLink > 0 && aLink < 1 ? 1 : 0, L.linkIcon(L.lerp(440, 560, L.ease(aLink)), 380, 44));
      s += L.op(aR, tv(600, 50, 1000, 540, inner));
      s += L.op(L.seg(p, 0.6, 0.65), die(1560, 90, 130, r.face, r.rot));
    }
    s += L.op(L.seg(p, 0.55, 0.7), L.text(vert ? 500 : 1100, vert ? 1090 : 728, 'その場ですぐ遊べる', { size: 42, weight: 900, fill: TH.ink, fam: 'maru' }));
    return s;
  }

  function ms_print(ctx) {
    const { p } = ctx;
    const a = L.easeOut(L.seg(p, 0.1, 0.35));
    const pw = 800, ph = pw * 297 / 420;
    const x = 850 - pw / 2, y = 60 + (1 - a) * 60;
    let s = L.op(a, L.rect(x + 12, y + 18, pw, ph, { fill: 'rgba(0,0,0,0.18)' }) + L.rect(x, y, pw, ph, { fill: '#fff', stroke: '#e5e5ec', 'stroke-width': 2 })
      + L.text(x + pw / 2, y + 50, '送別会すごろく', { size: 40, weight: 900, fill: TH.ink, fam: 'maru' })
      + board(x + 40, y + 90, pw - 80, ph - 130, 6, 3, 99, [], { fs: 20, gap: 10 }));
    s += L.op(L.seg(p, 0.35, 0.5), L.arrow(x, y + ph + 40, x + pw, y + ph + 40, { color: TH.sub, w: 4, head: 18 }) + L.arrow(x + pw, y + ph + 40, x, y + ph + 40, { color: TH.sub, w: 4, head: 18 })
      + L.text(x + pw / 2, y + ph + 82, 'A3（420×297mm）', { size: 38, weight: 800, fill: TH.ink }));
    s += L.op(L.seg(p, 0.5, 0.65), L.text(x + pw + 60, y + ph / 2 - 20, '紙でも', { size: 56, weight: 900, fill: TH.accent, anchor: 'start', fam: 'maru' })
      + L.text(x + pw + 60, y + ph / 2 + 50, '遊べる', { size: 56, weight: 900, fill: TH.accent, anchor: 'start', fam: 'maru' }));
    return s;
  }

  function motif(ctx) {
    const r = rolling(ctx.lt, 0.2, 0.9, 6);
    return board(-230, -150, 380, 240, 3, 2, 99, [], { fs: 20, gap: 10 }) + die(230, -10 + r.y * 0.5, 120, r.face, r.rot);
  }

  function bg(ctx) {
    const { W, H, t } = ctx;
    const r = L.rng(4);
    let s = L.rect(0, 0, W, H, { fill: '#fff4e6' });
    for (let i = 0; i < 46; i++) {
      const x = r() * W, y = (r() * H + t * (8 + r() * 10)) % H, c = COLORS[i % COLORS.length];
      s += r() > 0.5 ? L.circle(x, y, 6 + r() * 8, { fill: c, opacity: 0.35 }) : `<rect x="${x}" y="${y}" width="16" height="8" rx="3" fill="${c}" opacity="0.35" transform="rotate(${(r() * 180 + t * 40).toFixed(1)} ${x} ${y})"/>`;
    }
    return s;
  }

  APPS.masume = {
    name: 'マスメ', category: 'すごろくメーカー', release: '2027年4月', catch: 'みんなのネタが、マスになる。',
    fam: "'Zen Maru Gothic'", theme: TH, bg, defs: () => '', motif, cues,
    audio: { kind: 'party' },
    figs: { ms_hook, ms_board, ms_edit, ms_deck, ms_tv, ms_print },
    scripts: {
      V: [
        { fig: 'ms_hook', text: '送別会の余興、|どうしよう？', min: 3.0 },
        { fig: 'ms_board', text: '仲間のネタでマスを埋めて、|自分たちだけのすごろくに。', min: 6.0 },
        { fig: 'ms_tv', text: 'リンクを開けば、その場の|スマホやテレビですぐ遊べます。', min: 5.8 },
        { fig: 'end', text: 'すごろくメーカー、|マスメ。2027年4月公開予定。', say: 'すごろくメーカー、マスメ。二〇二七年四月、公開予定。' },
      ],
      H: [
        { fig: 'ms_hook', text: '送別会、同窓会、結婚式の二次会。|余興の準備、大変ですよね。' },
        { fig: 'ms_board', text: 'マスメなら、仲間のネタでマスを埋めるだけで、|自分たちだけのすごろくができます。', min: 7.0 },
        { fig: 'ms_edit', text: 'テンプレートを選んで、マスに|『〇〇さんの口ぐせをまねる』などのお題を入れる。', say: 'テンプレートを選んで、マスに、まるまるさんの口ぐせをまねる、などのお題を入れる。' },
        { fig: 'ms_deck', text: 'お題が思いつかなくても、|300枚のお題の山札から引けます。', say: 'お題が思いつかなくても、三百枚のお題の山札から引けます。' },
        { fig: 'ms_tv', text: 'できた盤はリンクで送れて、開けば|その場のスマホやテレビですぐ遊べます。', min: 6.0 },
        { fig: 'ms_print', text: 'A3で印刷すれば、|紙のすごろくにもなります。', say: 'エースリーで印刷すれば、紙のすごろくにもなります。' },
        { fig: 'end', text: 'すごろくメーカー、マスメ。|2027年4月、公開予定です。', say: 'すごろくメーカー、マスメ。二〇二七年四月、公開予定です。' },
      ],
    },
  };
})();
