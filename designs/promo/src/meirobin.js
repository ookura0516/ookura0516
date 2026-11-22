// メイロ便：解いた人だけが読める、迷路の手紙。
// 迷路は設計書どおり「入口から掘り進めて戻る」方法で作り、正しい道の上に文字を等間隔に置く。
(function () {
  const T = {
    bg: '#E8EEFA',
    ink: '#22304A',
    sub: '#56627A',
    accent: '#FF6F61',
    gold: '#FFB547',
    screen: '#F8FAFF',
    wall: '#2B3A55',
    paper: '#FFFDF7',
    capFamily: 'Zen Maru Gothic',
    capWeight: 900,
  };

  const MSG = 'おたんじょうびおめでとう！';
  const DECOY_POOL = 'かさのにまるいえ';

  // ---- 迷路 ----
  function genMaze(W, H, seed) {
    const R = E.rng(seed);
    const N = W * H;
    const adj = Array.from({ length: N }, () => []);
    const seen = new Uint8Array(N);
    const order = [];
    const st = [0];
    seen[0] = 1;
    while (st.length) {
      const c = st[st.length - 1];
      const x = c % W, y = (c / W) | 0;
      const nb = [];
      if (x > 0 && !seen[c - 1]) nb.push(c - 1);
      if (x < W - 1 && !seen[c + 1]) nb.push(c + 1);
      if (y > 0 && !seen[c - W]) nb.push(c - W);
      if (y < H - 1 && !seen[c + W]) nb.push(c + W);
      if (!nb.length) {
        st.pop();
        continue;
      }
      const n = nb[(R() * nb.length) | 0];
      seen[n] = 1;
      adj[c].push(n);
      adj[n].push(c);
      order.push([c, n]);
      st.push(n);
    }
    const par = new Int32Array(N).fill(-1);
    const dist = new Int32Array(N).fill(-1);
    dist[0] = 0;
    const q = [0];
    for (let i = 0; i < q.length; i++) {
      const c = q[i];
      for (const n of adj[c]) if (dist[n] < 0) {
        dist[n] = dist[c] + 1;
        par[n] = c;
        q.push(n);
      }
    }
    let exit = -1;
    for (let c = 1; c < N; c++) {
      const x = c % W, y = (c / W) | 0;
      if (x === 0 || y === 0 || x === W - 1 || y === H - 1) if (exit < 0 || dist[c] > dist[exit]) exit = c;
    }
    const path = [];
    for (let c = exit; c >= 0; c = par[c]) path.push(c);
    path.reverse();
    return { W, H, N, adj, par, dist, path, exit, order };
  }

  // 正しい道から外れる枝のうち、行き止まりまで3〜6マスのもの
  function findBranch(m, j) {
    const onPath = new Set(m.path);
    const c = m.path[j];
    for (const n of m.adj[c]) {
      if (onPath.has(n)) continue;
      // n から先のいちばん長い道
      let best = null;
      const dfs = (cur, from, chain) => {
        const next = m.adj[cur].filter((x) => x !== from);
        if (!next.length) {
          if (!best || chain.length > best.length) best = chain.slice();
          return;
        }
        for (const x of next) {
          chain.push(x);
          dfs(x, cur, chain);
          chain.pop();
        }
      };
      dfs(n, c, [n]);
      if (best && best.length >= 3 && best.length <= 6) return best;
    }
    return null;
  }

  function build(W, H) {
    for (let seed = 1; seed < 2000; seed++) {
      const m = genMaze(W, H, seed);
      const L = m.path.length;
      if (L < 58 || L > 74) continue;
      for (let j = Math.floor(L * 0.22); j < L * 0.42; j++) {
        const br = findBranch(m, j);
        if (!br) continue;
        // 文字を正しい道に等間隔で置く
        const letters = new Map();
        const n = [...MSG].length;
        const a = 3, b = L - 3;
        [...MSG].forEach((ch, i) => letters.set(m.path[Math.round(a + (i * (b - a)) / (n - 1))], ch));
        if (letters.has(m.path[j])) continue;
        // 回り道に「か」、ほかの行き止まりにもにせ文字
        const decoys = new Map([[br[1], 'か']]);
        const onPath = new Set(m.path);
        const R = E.rng(seed * 7 + 1);
        for (let c = 0; c < m.N && decoys.size < 7; c++) {
          if (onPath.has(c) || br.includes(c) || m.adj[c].length !== 1) continue;
          if (m.adj[m.adj[c][0]].some((x) => onPath.has(x))) continue;
          if (R() < 0.5) decoys.set(c, DECOY_POOL[(R() * DECOY_POOL.length) | 0]);
        }
        // 歩く順：入口→分かれ道→枝の奥→戻る→出口
        const seq = [...m.path.slice(0, j + 1), ...br, ...br.slice(0, -1).reverse(), ...m.path.slice(j)];
        return { m, letters, decoys, seq, j, br, seed };
      }
    }
    throw new Error('maze not found');
  }

  const MZ = build(9, 11);
  const CELL = 38;
  const MX = (390 - 9 * CELL) / 2;
  const MY = 236;
  const cellXY = (c) => [MX + (c % 9) * CELL + CELL / 2, MY + ((c / 9) | 0) * CELL + CELL / 2];

  // 歩く速さ。行き止まりで少し止まる
  const STEP_T = [];
  (function () {
    let t = 0;
    MZ.seq.forEach((c, i) => {
      STEP_T.push(t);
      t += i === MZ.j + MZ.br.length ? 4 : 1;
    });
    STEP_T.total = t;
  })();
  function walkerAt(p) {
    const tt = p * STEP_T.total;
    let i = 0;
    while (i < STEP_T.length - 1 && STEP_T[i + 1] <= tt) i++;
    const span = i < STEP_T.length - 1 ? STEP_T[i + 1] - STEP_T[i] : 1;
    const frac = i < STEP_T.length - 1 ? E.clamp(tt - STEP_T[i] - (span - 1)) : 0;
    return { i, frac };
  }
  const SOLVE_A = 0.02, SOLVE_B = 0.92;
  const solveP = (f) => E.ease.inOutQuad(E.seg(f, SOLVE_A, SOLVE_B));
  function pToF(pp) {
    let lo = SOLVE_A, hi = SOLVE_B;
    for (let k = 0; k < 40; k++) {
      const mid = (lo + hi) / 2;
      if (solveP(mid) < pp) lo = mid; else hi = mid;
    }
    return lo;
  }
  const detourStart = STEP_T[MZ.j] / STEP_T.total;
  const detourEnd = STEP_T[MZ.j + 2 * MZ.br.length] / STEP_T.total;

  // 入口から c までの道（木なのでひとつに決まる）
  function rootPath(c) {
    const out = [];
    for (let x = c; x >= 0; x = MZ.m.par[x]) out.push(x);
    return out.reverse();
  }

  function drawMaze(ctx, o = {}) {
    const { m } = MZ;
    const W = 9, H = 11;
    E.fillRR(ctx, MX - 12, MY - 12, W * CELL + 24, H * CELL + 24, 16, T.paper, {
      shadow: 'rgba(30,40,70,0.12)', blur: 16, dy: 5,
    });
    {
      const [gx0, gy0] = cellXY(m.exit);
      E.fillRR(ctx, gx0 - CELL / 2 + 3, gy0 - CELL / 2 + 3, CELL - 6, CELL - 6, 6, 'rgba(255,111,97,0.16)');
    }
    // 通った道
    if (o.trail && o.trail.length) {
      ctx.save();
      ctx.lineCap = 'round';
      ctx.lineJoin = 'round';
      ctx.strokeStyle = 'rgba(255,111,97,0.55)';
      ctx.lineWidth = 12;
      ctx.beginPath();
      const [sx, sy] = cellXY(o.trail[0]);
      ctx.moveTo(sx - CELL / 2 - 8, sy);
      o.trail.forEach((c) => ctx.lineTo(...cellXY(c)));
      if (o.tip) ctx.lineTo(...o.tip);
      ctx.stroke();
      ctx.restore();
    }
    // 壁
    ctx.save();
    ctx.strokeStyle = T.wall;
    ctx.lineWidth = 3.2;
    ctx.lineCap = 'round';
    ctx.beginPath();
    const conn = (a, b) => m.adj[a].includes(b);
    const exX = m.exit % W, exY = (m.exit / W) | 0;
    const side = exX === W - 1 ? 'R' : exY === H - 1 ? 'B' : exY === 0 ? 'T' : 'L';
    const seg = (x0, y0, x1, y1) => { ctx.moveTo(x0, y0); ctx.lineTo(x1, y1); };
    for (let y = 0; y < H; y++) {
      for (let x = 0; x < W; x++) {
        const c = y * W + x;
        const px = MX + x * CELL, py = MY + y * CELL;
        const openR = x === W - 1 ? c === m.exit && side === 'R' : conn(c, c + 1);
        const openB = y === H - 1 ? c === m.exit && side === 'B' : conn(c, c + W);
        if (!openR) seg(px + CELL, py, px + CELL, py + CELL);
        if (!openB) seg(px, py + CELL, px + CELL, py + CELL);
      }
    }
    for (let x = 0; x < W; x++) if (!(side === 'T' && x === exX)) seg(MX + x * CELL, MY, MX + (x + 1) * CELL, MY);
    for (let y = 1; y < H; y++) if (!(side === 'L' && y === exY)) seg(MX, MY + y * CELL, MX, MY + (y + 1) * CELL);
    ctx.stroke();
    ctx.restore();
    // 入口と出口
    E.text(ctx, '▶', MX - 9, MY + CELL / 2 + 1, { size: 13, color: T.accent, align: 'center', baseline: 'middle' });
    const [ex, ey] = cellXY(m.exit);
    const gx = side === 'R' ? ex + CELL / 2 + 9 : side === 'L' ? ex - CELL / 2 - 9 : ex;
    const gy = side === 'B' ? ey + CELL / 2 + 9 : side === 'T' ? ey - CELL / 2 - 9 : ey;
    const arrow = { R: '▶', L: '◀', B: '▼', T: '▲' }[side];
    E.text(ctx, arrow, gx, gy + 1, { size: 13, color: T.accent, align: 'center', baseline: 'middle' });
    // 文字のマス
    const tiles = [...MZ.letters, ...MZ.decoys];
    for (const [c, ch] of tiles) {
      const [x, y] = cellXY(c);
      const lit = o.lit && o.lit.has(c);
      const pop = o.popAt ? o.popAt(c) : 0;
      const s = 1 + 0.35 * pop;
      ctx.save();
      ctx.translate(x, y);
      ctx.scale(s, s);
      E.fillRR(ctx, -14, -14, 28, 28, 8, lit ? T.accent : '#fff', { stroke: lit ? T.accent : '#C9D2E6', lw: 1.5 });
      E.text(ctx, ch, 0, 1, { size: 17, weight: 900, color: lit ? '#fff' : T.ink, align: 'center', baseline: 'middle' });
      ctx.restore();
    }
    if (o.walker) {
      const [x, y] = o.walker;
      E.circle(ctx, x, y, 17, 'rgba(255,181,71,0.35)');
      E.circle(ctx, x, y, 10, T.gold, { stroke: '#fff', lw: 3 });
    }
  }

  function strip(ctx, chars, o = {}) {
    E.fillRR(ctx, 20, 96, 350, 112, 18, T.paper, { shadow: 'rgba(30,40,70,0.10)', blur: 12, dy: 4 });
    E.text(ctx, 'ゆうき さんからの手紙', 38, 126, { size: 15, weight: 700, color: T.sub });
    const n = [...MSG].length;
    const sw = 24.5;
    const x0 = 195 - (n * sw) / 2;
    for (let i = 0; i < n; i++) {
      ctx.fillStyle = '#D5DCEB';
      ctx.fillRect(x0 + i * sw + 3, 184, sw - 6, 2.5);
    }
    chars.forEach((c, i) => {
      const k = E.ease.outBack(E.clamp(c.k ?? 1));
      ctx.save();
      ctx.translate(x0 + i * sw + sw / 2, 168);
      ctx.scale(k, k);
      E.text(ctx, c.ch, 0, 0, { size: 22, weight: 900, color: c.decoy ? '#E2574A' : T.ink, align: 'center', baseline: 'middle' });
      ctx.restore();
    });
  }

  function chatHeader(ctx) {
    E.statusBar(ctx, T.ink);
    E.text(ctx, '‹', 24, 88, { size: 34, weight: 700, color: T.sub });
    E.circle(ctx, 70, 79, 17, '#7FA3E8');
    E.text(ctx, 'ゆ', 70, 80, { size: 16, weight: 900, color: '#fff', align: 'center', baseline: 'middle' });
    E.text(ctx, 'ゆうき', 96, 86, { size: 19, weight: 900, color: T.ink });
    ctx.fillStyle = 'rgba(0,0,0,0.06)';
    ctx.fillRect(0, 108, 390, 1.5);
  }

  // 小さな迷路（7×7）を描く
  function miniMaze(ctx, ox, oy, C, lw, carved) {
    ctx.save();
    ctx.strokeStyle = T.wall;
    ctx.lineWidth = lw;
    ctx.lineCap = 'round';
    ctx.beginPath();
    const open = (a, b) => (carved ? carved.has(a + ',' + b) : MINI.adj[a].includes(b));
    for (let y = 0; y < 7; y++) for (let x = 0; x < 7; x++) {
      const c = y * 7 + x, px = ox + x * C, py = oy + y * C;
      if (x === 6 || !open(c, c + 1)) { ctx.moveTo(px + C, py); ctx.lineTo(px + C, py + C); }
      if (y === 6 || !open(c, c + 7)) { ctx.moveTo(px, py + C); ctx.lineTo(px + C, py + C); }
    }
    ctx.moveTo(ox, oy); ctx.lineTo(ox + 7 * C, oy);
    ctx.moveTo(ox, oy + C); ctx.lineTo(ox, oy + 7 * C);
    ctx.stroke();
    ctx.restore();
  }

  // 封筒。open は ふたの開き具合（0〜1）、sheet は便箋の出具合
  function envelope(ctx, cx, cy, w, open, o = {}) {
    const h = w * 0.62;
    const fy = Math.cos(open * Math.PI);
    const flap = () => {
      ctx.fillStyle = fy > 0 ? '#FFD08C' : '#F2BE74';
      ctx.beginPath();
      ctx.moveTo(-w / 2, -h / 2);
      ctx.lineTo(0, -h / 2 + h * 0.62 * fy);
      ctx.lineTo(w / 2, -h / 2);
      ctx.closePath();
      ctx.fill();
    };
    ctx.save();
    ctx.translate(cx, cy);
    // うしろの面と、開いたふた（便箋より奥）
    E.fillRR(ctx, -w / 2, -h / 2, w, h, 10, '#F7C98A', { shadow: 'rgba(60,40,10,0.18)', blur: 14, dy: 5 });
    if (fy <= 0) flap();
    // 便箋（迷路）
    if (o.sheet) {
      const up = o.sheet * h * 0.95;
      E.fillRR(ctx, -w * 0.4, -h * 0.42 - up, w * 0.8, h * 0.84, 8, '#fff', { shadow: 'rgba(0,0,0,0.12)', blur: 8, dy: 2 });
      miniMaze(ctx, -w * 0.4 + w * 0.08, -h * 0.42 - up + w * 0.05, (w * 0.64) / 7, Math.max(1.4, w / 140));
    }
    // 手前のポケット（下と左右の三角）
    ctx.fillStyle = '#FFE6BF';
    ctx.beginPath();
    ctx.moveTo(-w / 2, -h / 2 + 10);
    ctx.lineTo(0, h * 0.08);
    ctx.lineTo(w / 2, -h / 2 + 10);
    ctx.lineTo(w / 2, h / 2 - 10);
    ctx.quadraticCurveTo(w / 2, h / 2, w / 2 - 10, h / 2);
    ctx.lineTo(-w / 2 + 10, h / 2);
    ctx.quadraticCurveTo(-w / 2, h / 2, -w / 2, h / 2 - 10);
    ctx.closePath();
    ctx.fill();
    ctx.fillStyle = '#FFDCA8';
    ctx.beginPath();
    ctx.moveTo(-w / 2 + 6, h / 2);
    ctx.lineTo(0, h * 0.02);
    ctx.lineTo(w / 2 - 6, h / 2);
    ctx.closePath();
    ctx.fill();
    if (fy > 0) {
      flap();
      E.circle(ctx, 0, -h / 2 + h * 0.62 * fy - 4, Math.max(8, w / 22), T.accent);
      E.text(ctx, '♡', 0, -h / 2 + h * 0.62 * fy - 3, { size: Math.max(9, w / 20), color: '#fff', align: 'center', baseline: 'middle' });
    }
    ctx.restore();
  }

  // ---- 場面 ----
  function sHook(ctx, local, f, d) {
    const swap = 0.48;
    if (f < swap) {
      ctx.fillStyle = '#EDF1F8';
      ctx.fillRect(0, 0, 390, 844);
      chatHeader(ctx);
      const k1 = E.ease.outBack(E.seg(f, 0.02, 0.16));
      E.fillRR(ctx, 24, 140, 160, 46, 20, '#fff', { alpha: E.clamp(k1) });
      E.text(ctx, '解いてみて！', 42, 170, { size: 16, weight: 700, color: T.ink, alpha: E.clamp(k1) });
      const k2 = E.ease.outBack(E.seg(f, 0.12, 0.28));
      ctx.save();
      ctx.globalAlpha *= E.clamp(k2);
      ctx.translate(0, (1 - k2) * 30);
      E.fillRR(ctx, 24, 200, 272, 236, 20, '#fff', { shadow: 'rgba(0,0,0,0.08)', blur: 10, dy: 3 });
      E.fillRR(ctx, 24, 200, 272, 126, [20, 20, 0, 0], '#DCE6FA');
      envelope(ctx, 160, 264, 120, 0);
      E.text(ctx, '手紙がとどきました', 42, 360, { size: 18, weight: 900, color: T.ink });
      E.text(ctx, '迷路を解けたら読めます', 42, 388, { size: 14, weight: 700, color: T.sub });
      E.text(ctx, 'タップしてブラウザで解く', 42, 418, { size: 13, weight: 700, color: T.accent });
      ctx.restore();
      E.tap(ctx, 160, 280, E.seg(f, 0.36, 0.5));
    } else {
      ctx.fillStyle = T.screen;
      ctx.fillRect(0, 0, 390, 844);
      E.statusBar(ctx, T.ink);
      const o = E.ease.inOutCubic(E.seg(f, 0.56, 0.74));
      const sh = E.ease.outCubic(E.seg(f, 0.74, 0.98));
      const k = E.ease.outBack(E.seg(f, swap, swap + 0.1));
      ctx.save();
      ctx.translate(195, 470);
      ctx.scale(0.7 + 0.3 * k, 0.7 + 0.3 * k);
      envelope(ctx, 0, 0, 280, o, { sheet: sh });
      ctx.restore();
    }
  }

  function sSolve(ctx, local, f, d) {
    ctx.fillStyle = T.screen;
    ctx.fillRect(0, 0, 390, 844);
    E.statusBar(ctx, T.ink);
    E.text(ctx, '0:' + String(18 + Math.floor(local * 3)).padStart(2, '0'), 360, 76, { size: 16, weight: 700, color: T.sub, align: 'right' });
    E.text(ctx, '迷路の手紙', 30, 76, { size: 17, weight: 900, color: T.ink });
    const p = solveP(f);
    const w = walkerAt(p);
    const cur = MZ.seq[w.i];
    const nxt = MZ.seq[Math.min(w.i + 1, MZ.seq.length - 1)];
    const [ax, ay] = cellXY(cur);
    const [bx, by] = cellXY(nxt);
    const pos = [E.lerp(ax, bx, w.frac), E.lerp(ay, by, w.frac)];
    const rp = rootPath(cur);
    const lit = new Set(rp.filter((c) => MZ.letters.has(c) || MZ.decoys.has(c)));
    // 文字を拾った時刻（直近に通った順）
    const popAt = (c) => {
      const idx = MZ.seq.lastIndexOf(c, w.i);
      if (idx < 0 || !lit.has(c)) return 0;
      const dt = local - pToF(STEP_T[idx] / STEP_T.total) * d;
      return dt >= 0 && dt < 0.25 ? Math.sin((dt / 0.25) * Math.PI) : 0;
    };
    const chars = rp
      .filter((c) => lit.has(c))
      .map((c) => {
        const idx = MZ.seq.lastIndexOf(c, w.i);
        const tt = pToF(STEP_T[idx] / STEP_T.total) * d;
        return { ch: MZ.letters.get(c) || MZ.decoys.get(c), decoy: MZ.decoys.has(c), k: (local - tt) / 0.22 };
      });
    strip(ctx, chars);
    drawMaze(ctx, { trail: rp, tip: pos, walker: pos, lit, popAt });
    E.button(ctx, 30, 760, 150, 48, 'ヒント 3', { fill: '#fff', color: T.ink, size: 17, weight: 900, stroke: '#D5DCEB', lw: 2, shadow: false });
    E.text(ctx, 'スワイプで進む', 290, 790, { size: 15, weight: 700, color: T.sub, align: 'center' });
    // 行き止まりの吹き出し
    const kd = E.seg(p, detourStart + (detourEnd - detourStart) * 0.45, detourStart + (detourEnd - detourStart) * 0.5);
    const kd2 = 1 - E.seg(p, detourEnd, detourEnd + 0.04);
    if (kd > 0 && kd2 > 0) {
      const [bx2, by2] = cellXY(MZ.br[MZ.br.length - 1]);
      const a = Math.min(kd, kd2);
      const lx = E.clamp(bx2, 80, 310);
      E.fillRR(ctx, lx - 62, by2 - 66, 124, 38, 19, T.ink, { alpha: a });
      E.text(ctx, '行き止まり', lx, by2 - 46, { size: 15, weight: 900, color: '#fff', align: 'center', baseline: 'middle', alpha: a });
    }
  }

  function sRead(ctx, local, f, d) {
    ctx.fillStyle = T.screen;
    ctx.fillRect(0, 0, 390, 844);
    E.statusBar(ctx, T.ink);
    // 紙ふぶき
    const R = E.rng(11);
    for (let i = 0; i < 46; i++) {
      const x = R() * 390, sp = 120 + R() * 160, ph = R() * 0.3;
      const y = -30 + (local - ph) * sp;
      if (y < -30 || y > 860) continue;
      ctx.save();
      ctx.translate(x + Math.sin(local * 3 + i) * 12, y);
      ctx.rotate(local * 3 + i);
      ctx.fillStyle = [T.accent, T.gold, '#7FA3E8', '#8ED1B0'][i % 4];
      ctx.fillRect(-5, -3, 10, 6);
      ctx.restore();
    }
    const k = E.ease.outBack(E.seg(f, 0.02, 0.22));
    ctx.save();
    ctx.translate(195, 380);
    ctx.scale(0.6 + 0.4 * k, 0.6 + 0.4 * k);
    ctx.globalAlpha *= E.clamp(k * 1.5);
    E.fillRR(ctx, -160, -200, 320, 400, 18, T.paper, { shadow: 'rgba(30,40,70,0.18)', blur: 22, dy: 8 });
    ctx.strokeStyle = '#E4E9F3';
    ctx.lineWidth = 1.5;
    for (let i = 0; i < 6; i++) {
      ctx.beginPath();
      ctx.moveTo(-130, -110 + i * 52);
      ctx.lineTo(130, -110 + i * 52);
      ctx.stroke();
    }
    E.text(ctx, 'おたんじょうび\nおめでとう！', 0, -50, {
      size: 38, weight: 900, color: T.ink, align: 'center', baseline: 'middle', valign: 'middle', lineHeight: 1.45,
    });
    E.text(ctx, 'ゆうき より', 120, 120, { size: 19, weight: 700, color: T.sub, align: 'right' });
    E.text(ctx, 'かかった時間 0:42', 0, 172, { size: 15, weight: 700, color: '#8A94A8', align: 'center' });
    ctx.restore();
    const kb = E.ease.outBack(E.seg(f, 0.35, 0.55));
    ctx.save();
    ctx.globalAlpha *= E.clamp(kb);
    ctx.translate(0, (1 - kb) * 30);
    E.button(ctx, 30, 660, 330, 56, '返事を書く', { fill: T.accent, size: 21, weight: 900, press: Math.sin(E.seg(f, 0.85, 0.95) * Math.PI) });
    E.button(ctx, 30, 730, 330, 50, '画像を保存', { fill: '#fff', color: T.ink, size: 18, weight: 900, stroke: '#D5DCEB', lw: 2, shadow: false });
    ctx.restore();
    E.tap(ctx, 195, 688, E.seg(f, 0.85, 0.99));
  }

  // 書く画面で作って見せる小さな迷路（7×7）
  const MINI = genMaze(7, 7, 21);
  function sWrite(ctx, local, f, d) {
    ctx.fillStyle = T.screen;
    ctx.fillRect(0, 0, 390, 844);
    E.statusBar(ctx, T.ink);
    E.text(ctx, '手紙を書く', 195, 84, { size: 21, weight: 900, color: T.ink, align: 'center' });
    const msg = [...'ありがとう！またね'];
    const typed = Math.floor(E.seg(f, 0.04, 0.4) * msg.length + 0.0001);
    E.fillRR(ctx, 24, 110, 342, 120, 16, '#fff', { stroke: '#D5DCEB', lw: 2 });
    E.text(ctx, msg.slice(0, typed).join(''), 44, 160, { size: 28, weight: 900, color: T.ink });
    const tw = E.measure(ctx, msg.slice(0, typed).join(''), { size: 28, weight: 900 });
    if (Math.floor(local * 2.5) % 2 === 0 || f < 0.4) {
      ctx.fillStyle = T.accent;
      ctx.fillRect(46 + tw, 136, 2.5, 32);
    }
    E.text(ctx, `${typed} / 24文字`, 350, 214, { size: 14, weight: 700, color: T.sub, align: 'right' });
    E.text(ctx, 'かな・数字で書けます', 44, 214, { size: 13, weight: 700, color: '#8A94A8' });
    E.text(ctx, 'むずかしさ', 28, 268, { size: 15, weight: 900, color: T.sub });
    ['やさしい', 'ふつう', 'むずかしい'].forEach((s, i) => {
      const on = i === 1;
      E.fillRR(ctx, 28 + i * 112, 282, 104, 40, 20, on ? T.ink : '#fff', { stroke: on ? T.ink : '#D5DCEB', lw: 1.5 });
      E.text(ctx, s, 80 + i * 112, 303, { size: 15, weight: 900, color: on ? '#fff' : T.ink, align: 'center', baseline: 'middle' });
    });
    E.text(ctx, 'かたち', 28, 358, { size: 15, weight: 900, color: T.sub });
    ['四角', 'ハート', '星', '丸'].forEach((s, i) => {
      const on = i === 1;
      E.fillRR(ctx, 28 + i * 84, 372, 76, 40, 20, on ? T.accent : '#fff', { stroke: on ? T.accent : '#D5DCEB', lw: 1.5 });
      E.text(ctx, s, 66 + i * 84, 393, { size: 15, weight: 900, color: on ? '#fff' : T.ink, align: 'center', baseline: 'middle' });
    });
    // 迷路を作る
    const tMake = 0.46;
    E.button(ctx, 30, 440, 330, 54, '迷路をつくる', { fill: T.ink, size: 20, weight: 900, press: Math.sin(E.seg(f, tMake - 0.04, tMake + 0.03) * Math.PI) });
    E.tap(ctx, 195, 467, E.seg(f, tMake - 0.04, tMake + 0.08));
    const g = E.seg(f, tMake + 0.04, 0.78);
    if (g > 0) {
      const C = 34, ox = 195 - 3.5 * C, oy = 520;
      E.fillRR(ctx, ox - 10, oy - 10, 7 * C + 20, 7 * C + 20, 14, T.paper, { shadow: 'rgba(30,40,70,0.1)', blur: 10, dy: 3 });
      const carved = new Set();
      const nOpen = Math.floor(g * MINI.order.length);
      for (let i = 0; i < nOpen; i++) {
        const [a, b] = MINI.order[i];
        carved.add(a + ',' + b);
        carved.add(b + ',' + a);
      }
      miniMaze(ctx, ox, oy, C, 2.6, carved);
      // 文字が置かれる
      const k = E.seg(f, 0.72, 0.8);
      if (k > 0) {
        const path = MINI.path;
        msg.forEach((ch, i) => {
          const c = path[Math.round(1 + (i * (path.length - 2)) / (msg.length - 1))];
          if (c == null) return;
          const x = ox + (c % 7) * C + C / 2, y = oy + ((c / 7) | 0) * C + C / 2;
          const kk = E.ease.outBack(E.clamp(k * msg.length - i * 0.6));
          if (kk <= 0) return;
          ctx.save();
          ctx.translate(x, y);
          ctx.scale(kk, kk);
          E.fillRR(ctx, -12, -12, 24, 24, 7, '#fff', { stroke: '#C9D2E6', lw: 1.3 });
          E.text(ctx, ch, 0, 1, { size: 14, weight: 900, color: T.ink, align: 'center', baseline: 'middle' });
          ctx.restore();
        });
      }
    }
    // 送る
    const ks = E.ease.outCubic(E.seg(f, 0.8, 0.9));
    if (ks > 0) {
      ctx.save();
      ctx.fillStyle = `rgba(20,30,50,${0.35 * ks})`;
      ctx.fillRect(0, 0, 390, 844);
      ctx.translate(0, (1 - ks) * 260);
      E.fillRR(ctx, 0, 600, 390, 260, [26, 26, 0, 0], '#fff');
      E.text(ctx, '送る', 195, 646, { size: 19, weight: 900, color: T.ink, align: 'center' });
      ['リンク', 'QR', '画像', 'PDF'].forEach((s, i) => {
        const x = 62 + i * 89;
        const press = i === 0 ? Math.sin(E.seg(f, 0.9, 0.97) * Math.PI) : 0;
        E.fillRR(ctx, x - 32, 676 - press * 3, 64, 64, 18, i === 0 ? T.accent : '#EEF2FA');
        shareIcon(ctx, i, x, 708, i === 0 ? '#fff' : T.ink);
        E.text(ctx, s, x, 768, { size: 15, weight: 900, color: T.ink, align: 'center' });
      });
      ctx.restore();
      E.tap(ctx, 62, 708, E.seg(f, 0.9, 0.99));
    }
  }

  function shareIcon(ctx, kind, x, y, col) {
    ctx.save();
    ctx.translate(x, y);
    ctx.strokeStyle = col;
    ctx.fillStyle = col;
    ctx.lineWidth = 3;
    if (kind === 0) {
      ctx.rotate(-Math.PI / 4);
      E.rr(ctx, -15, -6, 17, 12, 6); ctx.stroke();
      E.rr(ctx, -2, -6, 17, 12, 6); ctx.stroke();
    } else if (kind === 1) {
      for (const [a, b] of [[-14, -14], [4, -14], [-14, 4]]) { ctx.strokeRect(a + 1.5, b + 1.5, 7, 7); }
      for (const [a, b] of [[6, 6], [12, 10], [8, 12], [12, 4]]) ctx.fillRect(a, b, 3, 3);
    } else if (kind === 2) {
      E.rr(ctx, -15, -12, 30, 24, 4); ctx.stroke();
      ctx.beginPath(); ctx.moveTo(-11, 9); ctx.lineTo(-3, 0); ctx.lineTo(3, 6); ctx.lineTo(7, 2); ctx.lineTo(12, 9); ctx.fill();
      E.circle(ctx, 7, -5, 3, col);
    } else {
      ctx.beginPath(); ctx.moveTo(-11, -15); ctx.lineTo(5, -15); ctx.lineTo(11, -9); ctx.lineTo(11, 15); ctx.lineTo(-11, 15); ctx.closePath(); ctx.stroke();
      E.text(ctx, 'PDF', 0, 5, { size: 9, weight: 900, color: col, align: 'center', baseline: 'middle' });
    }
    ctx.restore();
  }

  function bg(ctx, t, W, H) {
    ctx.fillStyle = T.bg;
    ctx.fillRect(0, 0, W, H);
    // うしろにうすい迷路の模様
    const C = 90;
    const R = E.rng(3);
    ctx.save();
    ctx.strokeStyle = 'rgba(43,58,85,0.07)';
    ctx.lineWidth = 6;
    ctx.lineCap = 'round';
    ctx.beginPath();
    const off = (t * 12) % C;
    for (let y = -1; y < H / C + 1; y++) for (let x = 0; x < W / C + 1; x++) {
      const px = x * C, py = y * C + off;
      if (R() < 0.5) { ctx.moveTo(px, py); ctx.lineTo(px + C, py); } else { ctx.moveTo(px, py); ctx.lineTo(px, py + C); }
    }
    ctx.stroke();
    ctx.restore();
  }

  function logo(ctx, x, y, size, alpha) {
    E.text(ctx, 'メイロ便', x, y, { size, weight: 900, color: T.accent, alpha });
  }

  function icon(ctx, cx, cy, s) {
    E.fillRR(ctx, cx - s / 2, cy - s / 2, s, s, s * 0.23, T.ink, { shadow: 'rgba(20,30,60,0.3)', blur: s * 0.12, dy: s * 0.05 });
    ctx.save();
    ctx.translate(cx, cy + s * 0.04);
    envelope(ctx, 0, 0, s * 0.66, 0);
    ctx.restore();
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
    icon(ctx, 0, -(v ? 260 : 190), v ? 230 : 190);
    E.text(ctx, 'メイロ便', 0, v ? 80 : 60, { size: v ? 160 : 140, weight: 900, color: T.accent, align: 'center' });
    E.text(ctx, '解いた人だけが読める、迷路の手紙。', 0, v ? 200 : 150, { size: v ? 52 : 46, weight: 900, color: T.ink, align: 'center', maxWidth: W - 120 });
    ctx.restore();
    const b = E.seg(local, 0.5, 0.9);
    ctx.save();
    ctx.globalAlpha *= b;
    const py = v ? 1160 : 650;
    E.fillRR(ctx, cx - 330, py - 46, 660, 92, 46, T.ink);
    E.text(ctx, 'ブラウザで、そのまま解ける', cx, py + 2, { size: 40, weight: 900, color: '#fff', align: 'center', baseline: 'middle' });
    E.text(ctx, 'App Store・Google Play で配信', cx, py + (v ? 130 : 112), { size: v ? 40 : 36, weight: 700, color: T.sub, align: 'center' });
    E.text(ctx, '※画面は開発中のイメージです', cx, H - (v ? 90 : 50), { size: 26, weight: 500, color: T.sub, align: 'center' });
    ctx.restore();
  }

  // 文字を拾った時刻（効果音用）
  function letterCues(d) {
    const out = [];
    let n = 0;
    MZ.seq.forEach((c, i) => {
      if (!(MZ.letters.has(c) || MZ.decoys.has(c))) return;
      const first = MZ.seq.indexOf(c) === i;
      if (!first) return;
      const decoy = MZ.decoys.has(c);
      out.push({ t: pToF(STEP_T[i] / STEP_T.total) * d, kind: decoy ? 'pickDecoy' : 'pick', p: decoy ? 0 : n++ });
    });
    // 戻って「か」が消えるとき
    const back = MZ.j + MZ.br.length * 2 - 1;
    out.push({ t: pToF(STEP_T[back] / STEP_T.total) * d, kind: 'unpick' });
    out.push({ t: 0.93 * d, kind: 'good' });
    return out;
  }

  window.APPS.meirobin = {
    theme: T,
    bg,
    logo,
    endCard,
    info: { seed: MZ.seed, pathLength: MZ.m.path.length },
    scenes: [
      {
        name: 'hook',
        dur: { v: 2.8, h: 4.0 },
        screen: sHook,
        cap: {
          v: [{ text: 'とどいたのは、\n迷路の手紙' }],
          h: [{ h: '迷路の手紙が、とどいた', s: 'リンクを開くと、ブラウザで\nそのまま解ける' }],
        },
        cues: (d) => [
          { t: 0.02 * d, kind: 'msg' },
          { t: 0.12 * d, kind: 'msg' },
          { t: 0.36 * d, kind: 'tap' },
          { t: 0.56 * d, kind: 'envelope' },
          { t: 0.74 * d, kind: 'slide' },
        ],
      },
      {
        name: 'solve',
        dur: { v: 7.0, h: 9.6 },
        screen: sSolve,
        cap: {
          v: [
            { text: '道を進むと、\n文字がつながる', b: pToF(detourStart) - 0.04 },
            { a: pToF(detourStart) - 0.04, b: pToF(detourEnd) + 0.1, text: '行き止まりの文字は\n戻ると消える' },
            { a: pToF(detourEnd) + 0.1, text: 'ゴールまで行くと…' },
          ],
          h: [
            { h: '道を進むと、文字がつながる', s: '通ったマスの文字が、\n上の便箋に並んでいく', b: pToF(detourStart) - 0.04 },
            { a: pToF(detourStart) - 0.04, b: pToF(detourEnd) + 0.1, h: '行き止まりの文字は、消える', s: '回り道で拾った文字は、\n戻ると便箋から消える' },
            { a: pToF(detourEnd) + 0.1, h: 'ゴールまで進むと…', s: '13文字がそろう' },
          ],
        },
        cues: letterCues,
      },
      {
        name: 'read',
        dur: { v: 3.0, h: 4.4 },
        screen: sRead,
        cap: {
          v: [{ text: '解いた人だけが\n読める手紙' }],
          h: [{ h: 'ゴールで、手紙が読める', s: '解いた人だけが読めるメッセージ' }],
        },
        cues: (d) => [{ t: 0.02 * d, kind: 'fanfare' }, { t: 0.35 * d, kind: 'pop' }, { t: 0.85 * d, kind: 'tap' }],
      },
      {
        name: 'write',
        dur: { v: 4.4, h: 6.6 },
        screen: sWrite,
        cap: {
          v: [{ text: 'かなで書くと、\n迷路になる', b: 0.8 }, { a: 0.8, text: 'リンクで送れば\nブラウザで解ける' }],
          h: [{ h: '書いて、送るだけ', s: 'かなで24文字まで。\nリンク・QR・画像・PDFで送れる' }],
        },
        cues: (d) => {
          const out = [];
          for (let i = 0; i < 9; i++) out.push({ t: (0.04 + (i * 0.36) / 9) * d, kind: 'type' });
          out.push({ t: 0.43 * d, kind: 'tap' });
          out.push({ t: 0.5 * d, kind: 'carve', dur: 0.28 * d });
          out.push({ t: 0.8 * d, kind: 'slide' });
          out.push({ t: 0.9 * d, kind: 'tap' });
          return out;
        },
      },
      { name: 'end', end: true, dur: { v: 2.8, h: 4.4 }, screen: () => {} },
    ],
  };
})();
