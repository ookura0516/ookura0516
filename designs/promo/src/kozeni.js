// コゼニ：財布の小銭がいちばん減る払い方を当てる。
// 例は設計書の「864円、硬貨9枚の財布」。千円札だけだと小銭15枚、1,064円出すと5枚（全部の払い方を計算して確かめた例）。
(function () {
  const T = {
    bg: '#FFF1CC',
    ink: '#3B2A1A',
    sub: '#6E5843',
    accent: '#E5533C',
    good: '#1F9460',
    screen: '#FFF9EE',
    panel: '#2E3440',
    lcd: '#FFE08A',
    capFamily: 'Zen Maru Gothic',
    capWeight: 900,
  };

  // 硬貨は「色の付いた丸に額面の数字だけ」。本物の図柄は描かない
  const COIN = {
    1: { d: 38, c1: '#F4F6F8', c2: '#BCC3CC', ink: '#737B86', hole: false },
    5: { d: 42, c1: '#F7DA7E', c2: '#C8962E', ink: '#6E4F0E', hole: true },
    10: { d: 45, c1: '#E9A677', c2: '#A65C31', ink: '#5F2E12', hole: false },
    50: { d: 40, c1: '#F0F2F5', c2: '#AAB2BC', ink: '#626A74', hole: true },
    100: { d: 43, c1: '#EBEEF2', c2: '#A3ABB6', ink: '#56606B', hole: false },
    500: { d: 50, c1: '#F5E4A3', c2: '#BEA04A', ink: '#65521A', hole: false },
  };
  const COIN_DENOMS = [500, 100, 50, 10, 5, 1];

  function coin(ctx, x, y, den, o = {}) {
    const c = COIN[den];
    const s = o.scale ?? 1;
    const r = (c.d / 2) * s;
    ctx.save();
    if (o.alpha != null) ctx.globalAlpha *= o.alpha;
    ctx.shadowColor = 'rgba(70,45,10,0.28)';
    ctx.shadowBlur = 5 * s;
    ctx.shadowOffsetY = 2.5 * s;
    const g = ctx.createRadialGradient(x - r * 0.35, y - r * 0.4, r * 0.1, x, y, r * 1.05);
    g.addColorStop(0, c.c1);
    g.addColorStop(1, c.c2);
    ctx.beginPath();
    ctx.arc(x, y, r, 0, E.TAU);
    ctx.fillStyle = g;
    ctx.fill();
    ctx.shadowColor = 'transparent';
    ctx.lineWidth = 1.4 * s;
    ctx.strokeStyle = 'rgba(0,0,0,0.20)';
    ctx.stroke();
    ctx.beginPath();
    ctx.arc(x, y, r * 0.8, 0, E.TAU);
    ctx.strokeStyle = 'rgba(255,255,255,0.5)';
    ctx.lineWidth = 1.2 * s;
    ctx.stroke();
    const label = String(den);
    if (c.hole) {
      ctx.beginPath();
      ctx.arc(x, y, r * 0.2, 0, E.TAU);
      ctx.fillStyle = o.holeColor || 'rgba(120,90,50,0.35)';
      ctx.fill();
      ctx.strokeStyle = 'rgba(0,0,0,0.25)';
      ctx.lineWidth = 1 * s;
      ctx.stroke();
      E.text(ctx, label, x, y - r * 0.42, {
        size: r * 0.5, weight: 900, color: c.ink, align: 'center', baseline: 'middle',
      });
    } else {
      E.text(ctx, label, x, y + r * 0.03, {
        size: r * (label.length >= 3 ? 0.56 : 0.72), weight: 900, color: c.ink,
        align: 'center', baseline: 'middle',
      });
    }
    ctx.restore();
  }

  // お札は「角の丸い長方形に額面の数字だけ」
  function bill(ctx, x, y, w, o = {}) {
    const h = w * 0.5;
    ctx.save();
    if (o.alpha != null) ctx.globalAlpha *= o.alpha;
    ctx.translate(x, y);
    if (o.rot) ctx.rotate(o.rot);
    E.fillRR(ctx, -w / 2, -h / 2, w, h, 7, '#B9D6EA', {
      shadow: 'rgba(40,60,80,0.25)', blur: 8, dy: 3, stroke: '#7FA6C6', lw: 1.6,
    });
    E.rr(ctx, -w / 2 + 6, -h / 2 + 6, w - 12, h - 12, 4);
    ctx.strokeStyle = 'rgba(70,110,150,0.45)';
    ctx.lineWidth = 1.2;
    ctx.stroke();
    E.circle(ctx, -w * 0.26, 0, h * 0.26, 'rgba(255,255,255,0.45)');
    E.text(ctx, '1000', w * 0.12, 2, {
      size: h * 0.42, weight: 900, color: '#2F5677', align: 'center', baseline: 'middle',
    });
    ctx.restore();
  }

  // ---- 画面の配置（390×844 の座標） ----
  const REG = { x: 22, y: 92, w: 346, h: 150 };
  const TRAY = { x: 22, y: 262, w: 346, h: 156 };
  const WAL = { x: 22, y: 484, w: 346, h: 278 };
  const BILL_SLOT = { x: 120, y: 534 };
  const slotX = (den) => 52 + COIN_DENOMS.indexOf(den) * 57;
  const SLOT_BASE = 690;
  const slotPos = (den, i) => [slotX(den), SLOT_BASE - i * 9];
  const trayCoinPos = (i) => [62 + (i % 7) * 44, 372 + Math.floor(i / 7) * 40];
  const TRAY_BILL = [118, 322];
  const REG_OUT = [300, 168];
  const PAY_BTN = { x: 30, y: 778, w: 330, h: 50 };

  const BASE = { 1000: 1, 500: 0, 100: 1, 50: 1, 10: 2, 5: 1, 1: 4 };
  const coinsIn = (w) => COIN_DENOMS.reduce((a, d) => a + (w[d] || 0), 0);

  // 動き：{den, from:'wallet'|'register', to:'tray'|'wallet', a, b}（a〜b は場面の中の割合）
  function buildPlan(pay, change, tPay, tStart, gap, flight) {
    const moves = [];
    let t = tStart;
    for (const den of pay) {
      moves.push({ den, from: 'wallet', to: 'tray', a: t, b: t + flight });
      t += gap;
    }
    let tc = tPay + 0.1;
    let tLand = tPay;
    for (const den of change) {
      const m = { den, from: 'register', to: 'wallet', a: tc, b: tc + flight * 1.1 };
      moves.push(m);
      tLand = Math.max(tLand, m.b);
      tc += gap * 0.8;
    }
    // tLand：お釣りが全部財布に入った時点
    return { moves, tPay, tLand };
  }

  // 割合 f の時点の財布・トレー・飛んでいる物を求める
  function stateAt(plan, f) {
    const w = { ...BASE };
    const tray = [];
    const flying = [];
    const landedIdx = {};
    for (const d of Object.keys(BASE)) landedIdx[d] = BASE[d];
    // 出すときは財布のいちばん上から取る
    const taken = {};
    for (const m of plan.moves) {
      if (m.from === 'wallet') {
        if (f >= m.a) {
          w[m.den]--;
          const k = (taken[m.den] = (taken[m.den] || 0) + 1);
          m.srcIdx = BASE[m.den] - k;
        }
      }
    }
    for (const m of plan.moves) {
      if (m.to === 'tray') {
        if (f >= m.b) tray.push(m);
        else if (f >= m.a) flying.push(m);
      } else if (m.to === 'wallet') {
        if (f >= m.b) {
          m.dstIdx = w[m.den];
          w[m.den]++;
        } else if (f >= m.a) {
          flying.push(m);
        }
      }
    }
    // 飛んでいるお釣りの行き先
    const ahead = {};
    for (const m of flying) {
      if (m.to !== 'wallet') continue;
      m.dstIdx = w[m.den] + (ahead[m.den] || 0);
      ahead[m.den] = (ahead[m.den] || 0) + 1;
    }
    return { w, tray, flying };
  }

  function drawRegister(ctx, label, amount, o = {}) {
    E.fillRR(ctx, REG.x, REG.y, REG.w, REG.h, 22, T.panel, { shadow: 'rgba(0,0,0,0.2)', blur: 14, dy: 5 });
    E.text(ctx, label, REG.x + 24, REG.y + 40, { size: 19, weight: 700, color: '#AEB7C6' });
    ctx.save();
    const s = o.pop ?? 1;
    ctx.translate(REG.x + REG.w - 24, REG.y + 108);
    ctx.scale(s, s);
    E.text(ctx, amount, 0, 0, {
      size: 64, family: 'Dela Gothic One', weight: 400, color: o.color || T.lcd, align: 'right',
    });
    ctx.restore();
  }

  function drawTray(ctx, total) {
    E.fillRR(ctx, TRAY.x, TRAY.y, TRAY.w, TRAY.h, 20, '#F2E3C4', { stroke: '#E2CDA3', lw: 2 });
    E.text(ctx, 'トレー', TRAY.x + 18, TRAY.y + 30, { size: 16, weight: 700, color: '#9C8458' });
    if (total > 0) {
      E.text(ctx, `出した金額 ${total.toLocaleString('ja-JP')}円`, TRAY.x + TRAY.w - 18, TRAY.y + 30, {
        size: 17, weight: 900, color: T.ink, align: 'right',
      });
    }
  }

  function drawWallet(ctx, w, o = {}) {
    E.fillRR(ctx, WAL.x, WAL.y, WAL.w, WAL.h, 24, '#9A6440', { shadow: 'rgba(60,30,10,0.25)', blur: 16, dy: 6 });
    E.fillRR(ctx, WAL.x + 10, WAL.y + 10, WAL.w - 20, WAL.h - 20, 18, '#F6E9D2');
    E.text(ctx, 'さいふ', WAL.x + 26, WAL.y + 38, { size: 16, weight: 700, color: '#9C7A55' });
    for (let i = 0; i < (w[1000] || 0); i++) bill(ctx, BILL_SLOT.x + i * 6, BILL_SLOT.y, 140);
    for (const den of COIN_DENOMS) {
      const n = w[den] || 0;
      const x = slotX(den);
      E.fillRR(ctx, x - 25, SLOT_BASE - 70, 50, 96, 14, 'rgba(154,100,64,0.10)');
      for (let i = 0; i < n; i++) {
        const [cx, cy] = slotPos(den, i);
        coin(ctx, cx, cy, den, { holeColor: '#E9DBC0' });
      }
      E.text(ctx, `×${n}`, x, SLOT_BASE + 48, {
        size: 17, weight: 900, color: n ? T.ink : '#C4B08F', align: 'center',
      });
    }
  }

  function drawCounter(ctx, n, o = {}) {
    E.text(ctx, '財布の小銭', 34, 462, { size: 19, weight: 700, color: T.sub });
    const col = o.color || T.ink;
    ctx.save();
    const s = o.pop ?? 1;
    ctx.translate(182, 462);
    ctx.scale(s, s);
    E.text(ctx, `${n}枚`, 0, 0, { size: 30, weight: 900, color: col });
    ctx.restore();
    if (o.note) {
      E.text(ctx, o.note, 356, 462, {
        size: 19, weight: 900, color: col, align: 'right', alpha: o.noteAlpha ?? 1,
      });
    }
  }

  function header(ctx, n) {
    E.statusBar(ctx, T.ink);
    E.text(ctx, `第${n}問`, 28, 76, { size: 18, weight: 900, color: T.ink });
    E.fillRR(ctx, 150, 56, 90, 28, 14, '#FFE3B0');
    E.text(ctx, 'コンビニ', 195, 71, { size: 15, weight: 900, color: '#8A5A14', align: 'center', baseline: 'middle' });
    E.text(ctx, '0:12', 362, 76, { size: 17, weight: 700, color: T.sub, align: 'right' });
  }

  function walletSrcPos(m) {
    if (m.den === 1000) return [BILL_SLOT.x, BILL_SLOT.y];
    return slotPos(m.den, m.srcIdx ?? 0);
  }
  function trayDstPos(plan, m) {
    if (m.den === 1000) return TRAY_BILL;
    const coinsToTray = plan.moves.filter((x) => x.to === 'tray' && x.den !== 1000);
    return trayCoinPos(coinsToTray.indexOf(m));
  }
  function drawItem(ctx, den, x, y, o = {}) {
    if (den === 1000) bill(ctx, x, y, o.billW || 140, o);
    else coin(ctx, x, y, den, o);
  }

  // 払う場面の共通部分
  function payScene(ctx, f, d, plan, opt) {
    header(ctx, 1);
    const st = stateAt(plan, f);
    const paid = f >= plan.tPay;
    const trayTotal = st.tray.reduce((a, m) => a + m.den, 0);
    const changeAmount = opt.changeAmount;
    if (!paid) {
      drawRegister(ctx, 'お会計', '864円');
    } else {
      const k = E.ease.outBack(E.seg(f, plan.tPay, plan.tPay + 0.06));
      drawRegister(ctx, 'お釣り', `${changeAmount}円`, { pop: 0.8 + 0.2 * k, color: '#9FF0BE' });
    }
    drawTray(ctx, paid ? 0 : trayTotal);
    // トレーに置いた物。払ったらレジへ吸い込まれる
    const kPay = E.ease.inCubic(E.seg(f, plan.tPay, plan.tPay + 0.07));
    for (const m of st.tray) {
      const [x, y] = trayDstPos(plan, m);
      if (kPay >= 1) continue;
      const px = E.lerp(x, REG_OUT[0], kPay);
      const py = E.lerp(y, REG_OUT[1], kPay);
      drawItem(ctx, m.den, px, py, { alpha: 1 - kPay, scale: 1 - 0.4 * kPay, billW: 140 * (1 - 0.4 * kPay), holeColor: '#F2E3C4' });
    }
    drawCounter(ctx, coinsIn(st.w), opt.counter(f, st));
    drawWallet(ctx, st.w);
    // 飛んでいる物
    for (const m of st.flying) {
      const p = E.ease.inOutCubic(E.seg(f, m.a, m.b));
      let a, b;
      if (m.from === 'wallet') {
        a = walletSrcPos(m);
        b = trayDstPos(plan, m);
      } else {
        a = REG_OUT;
        b = slotPos(m.den, m.dstIdx);
      }
      const [x, y] = E.arc(a[0], a[1], b[0], b[1], p, 70);
      drawItem(ctx, m.den, x, y, { scale: 1 + 0.15 * Math.sin(p * Math.PI), billW: 140 });
    }
    // はらうボタン
    const pressP = E.seg(f, plan.tPay - 0.05, plan.tPay + 0.02);
    E.button(ctx, PAY_BTN.x, PAY_BTN.y, PAY_BTN.w, PAY_BTN.h, 'はらう', {
      fill: T.accent, size: 22, weight: 900, press: Math.sin(pressP * Math.PI),
    });
    // 指
    for (const m of plan.moves) {
      if (m.from !== 'wallet') continue;
      const [x, y] = m.den === 1000 ? [BILL_SLOT.x, BILL_SLOT.y] : slotPos(m.den, Math.max(0, (m.srcIdx ?? BASE[m.den] - 1)));
      E.tap(ctx, x, y, E.seg(f, m.a - 0.035, m.a + 0.07));
    }
    E.tap(ctx, PAY_BTN.x + PAY_BTN.w / 2, PAY_BTN.y + PAY_BTN.h / 2, E.seg(f, plan.tPay - 0.05, plan.tPay + 0.08));
    if (opt.after) opt.after(ctx, f, st);
  }

  // 千円札だけ：お釣りは 100・10・10・10・5・1（136円）
  const NAIVE = buildPlan([1000], [100, 10, 10, 10, 5, 1], 0.3, 0.06, 0.06, 0.12);
  // いちばん減る払い方：1000・50・10・1・1・1・1 で 1,064円、お釣り 200円
  const BEST = buildPlan([1000, 50, 10, 1, 1, 1, 1], [100, 100], 0.56, 0.08, 0.055, 0.1);

  function stamp(ctx, f0, f, mark, color, label) {
    const k = E.seg(f, f0, f0 + 0.1);
    if (k <= 0) return;
    const s = 1.6 - 0.6 * E.ease.outBack(k);
    ctx.save();
    ctx.globalAlpha *= Math.min(1, k * 2);
    ctx.translate(292, 330);
    ctx.rotate(-0.18);
    ctx.scale(s, s);
    E.circle(ctx, 0, 0, 62, 'rgba(255,255,255,0.92)', { stroke: color, lw: 7 });
    E.text(ctx, mark, 0, 4, { size: 76, weight: 900, color, align: 'center', baseline: 'middle' });
    ctx.restore();
    if (label) {
      E.fillRR(ctx, 40, 228, 210, 44, 22, color, { alpha: Math.min(1, k * 2) });
      E.text(ctx, label, 145, 251, {
        size: 19, weight: 900, color: '#fff', align: 'center', baseline: 'middle', alpha: Math.min(1, k * 2),
      });
    }
  }

  // ---- 場面 ----
  function sHook(ctx, local, f, d) {
    header(ctx, 1);
    const k = E.ease.outBack(E.seg(f, 0.05, 0.35));
    drawRegister(ctx, 'お会計', '864円', { pop: 0.6 + 0.4 * k });
    drawTray(ctx, 0);
    // はてなが跳ねる
    const b = Math.abs(Math.sin(local * 5.5)) * 14;
    E.text(ctx, '？', 195, 362 - b, {
      size: 72, weight: 900, color: T.accent, align: 'center', baseline: 'middle',
      alpha: E.seg(f, 0.25, 0.45),
    });
    drawCounter(ctx, coinsIn(BASE));
    drawWallet(ctx, BASE);
    E.button(ctx, PAY_BTN.x, PAY_BTN.y, PAY_BTN.w, PAY_BTN.h, 'はらう', { fill: T.accent, size: 22, weight: 900 });
  }

  function sNaive(ctx, local, f, d) {
    payScene(ctx, f, d, NAIVE, {
      changeAmount: 136,
      counter: (f, st) => {
        const n = coinsIn(st.w);
        const bad = n > 9;
        return {
          color: bad ? T.accent : T.ink,
          note: bad ? `+${n - 9}枚` : '',
        };
      },
      after: (ctx, f) => stamp(ctx, NAIVE.tLand + 0.03, f, '△', '#C98A1B', '小銭が増えた…'),
    });
  }

  function sBest(ctx, local, f, d) {
    payScene(ctx, f, d, BEST, {
      changeAmount: 200,
      counter: (f, st) => {
        const n = coinsIn(st.w);
        const good = f >= BEST.tLand;
        return {
          color: good ? T.good : T.ink,
          note: good ? '9枚 → 5枚' : '',
          pop: good ? 1 + 0.25 * Math.max(0, 1 - E.seg(f, BEST.tLand, BEST.tLand + 0.08)) : 1,
        };
      },
      after: (ctx, f) => {
        // はじめに「もう一回」
        const k = 1 - E.seg(f, 0.0, 0.07);
        if (k > 0) {
          E.fillRR(ctx, 115, 262, 160, 44, 22, T.ink, { alpha: k });
          E.text(ctx, '↺ もう一回', 195, 285, {
            size: 19, weight: 900, color: '#fff', align: 'center', baseline: 'middle', alpha: k,
          });
        }
        stamp(ctx, BEST.tLand + 0.02, f, '◎', T.good, 'いちばん少ない！');
      },
    });
  }

  const RECEIPT = [
    ['1', '864円', '◎'],
    ['2', '460円', '◎'],
    ['3', '680円', '○'],
    ['4', '378円', '◎'],
    ['5', '1,236円', '◎'],
  ];
  function sReceipt(ctx, local, f, d) {
    E.statusBar(ctx, T.ink);
    E.text(ctx, '今日の5問', 195, 84, { size: 22, weight: 900, color: T.ink, align: 'center' });
    // 印字口
    E.fillRR(ctx, 40, 108, 310, 22, 11, T.panel);
    const full = 520;
    const len = full * E.ease.outCubic(E.seg(f, 0.04, 0.62));
    ctx.save();
    ctx.beginPath();
    ctx.rect(0, 119, 390, 700);
    ctx.clip();
    const top = 119 + len - full;
    ctx.save();
    ctx.shadowColor = 'rgba(80,60,30,0.18)';
    ctx.shadowBlur = 14;
    ctx.shadowOffsetY = 4;
    ctx.beginPath();
    ctx.moveTo(58, top);
    ctx.lineTo(332, top);
    ctx.lineTo(332, top + full);
    for (let x = 332; x > 58; x -= 12) {
      ctx.lineTo(x - 6, top + full - 8);
      ctx.lineTo(x - 12, top + full);
    }
    ctx.closePath();
    ctx.fillStyle = '#FFFFFF';
    ctx.fill();
    ctx.restore();
    const ink = '#3A3A3A';
    E.text(ctx, 'コゼニ', 195, top + 62, { size: 34, family: 'Dela Gothic One', weight: 400, color: T.accent, align: 'center' });
    E.text(ctx, '第45回　2026.11.22', 195, top + 96, { size: 15, weight: 700, color: '#8A8A8A', align: 'center' });
    const dash = (y) => {
      ctx.save();
      ctx.setLineDash([5, 5]);
      ctx.strokeStyle = '#C9C9C9';
      ctx.lineWidth = 1.5;
      ctx.beginPath();
      ctx.moveTo(76, y);
      ctx.lineTo(314, y);
      ctx.stroke();
      ctx.restore();
    };
    dash(top + 118);
    RECEIPT.forEach((r, i) => {
      const y = top + 162 + i * 52;
      E.text(ctx, r[0], 84, y, { size: 18, weight: 700, color: '#9A9A9A' });
      E.text(ctx, r[1], 236, y, { size: 26, weight: 900, color: ink, align: 'right' });
      E.text(ctx, r[2], 296, y + 1, { size: 30, weight: 900, color: r[2] === '◎' ? T.good : '#C98A1B', align: 'center' });
    });
    dash(top + 418);
    E.text(ctx, '◎4  ○1', 84, top + 460, { size: 22, weight: 900, color: ink });
    E.text(ctx, '38.2秒', 306, top + 460, { size: 22, weight: 900, color: ink, align: 'right' });
    ctx.restore();
    const kb = E.ease.outBack(E.seg(f, 0.66, 0.8));
    if (kb > 0) {
      ctx.save();
      ctx.globalAlpha *= E.clamp(kb);
      ctx.translate(0, (1 - kb) * 40);
      E.button(ctx, 30, 700, 160, 52, '画像で共有', { fill: '#fff', color: T.ink, size: 18, weight: 900, stroke: '#E8D9BE', lw: 2 });
      E.button(ctx, 200, 700, 160, 52, '挑戦状を送る', { fill: T.accent, size: 18, weight: 900, press: Math.sin(E.seg(f, 0.86, 0.94) * Math.PI) });
      ctx.restore();
      E.tap(ctx, 280, 726, E.seg(f, 0.86, 0.99));
    }
  }

  function chatHeader(ctx, name) {
    E.statusBar(ctx, T.ink);
    E.fillRR(ctx, 0, 50, 390, 58, 0, '#FFF9EE');
    E.text(ctx, '‹', 24, 88, { size: 34, weight: 700, color: T.sub });
    E.circle(ctx, 70, 79, 17, '#F4B860');
    E.text(ctx, name[0], 70, 80, { size: 16, weight: 900, color: '#fff', align: 'center', baseline: 'middle' });
    E.text(ctx, name, 96, 86, { size: 19, weight: 900, color: T.ink });
    ctx.fillStyle = 'rgba(0,0,0,0.06)';
    ctx.fillRect(0, 108, 390, 1.5);
  }

  function sChallenge(ctx, local, f, d) {
    const swap = 0.42;
    if (f < swap) {
      ctx.fillStyle = '#F3EBDD';
      ctx.fillRect(0, 0, 390, 844);
      chatHeader(ctx, 'ゆうき');
      const k1 = E.ease.outBack(E.seg(f, 0.02, 0.12));
      E.fillRR(ctx, 24, 140, 220, 46, 20, '#fff', { alpha: E.clamp(k1) });
      E.text(ctx, '今日のコゼニやった？', 40, 170, { size: 16, weight: 700, color: T.ink, alpha: E.clamp(k1) });
      const k2 = E.ease.outBack(E.seg(f, 0.1, 0.22));
      ctx.save();
      ctx.globalAlpha *= E.clamp(k2);
      ctx.translate(0, (1 - k2) * 30);
      E.fillRR(ctx, 24, 200, 272, 238, 20, '#fff', { shadow: 'rgba(0,0,0,0.08)', blur: 10, dy: 3 });
      E.fillRR(ctx, 24, 200, 272, 120, [20, 20, 0, 0], '#FFE7B5');
      // ミニレシート
      E.fillRR(ctx, 120, 214, 80, 96, 4, '#fff', { shadow: 'rgba(0,0,0,0.12)', blur: 6, dy: 2 });
      E.text(ctx, '◎◎○', 160, 250, { size: 15, weight: 900, color: T.good, align: 'center' });
      E.text(ctx, '◎◎', 160, 272, { size: 15, weight: 900, color: T.good, align: 'center' });
      E.text(ctx, '38.2秒', 160, 296, { size: 12, weight: 900, color: '#666', align: 'center' });
      E.text(ctx, 'ゆうきさんから挑戦状', 42, 352, { size: 18, weight: 900, color: T.ink });
      E.text(ctx, '◎4つ・38.2秒　同じ5問で勝負！', 42, 380, { size: 14, weight: 700, color: T.sub });
      E.text(ctx, 'タップしてブラウザで勝負', 42, 414, { size: 13, weight: 700, color: T.accent });
      ctx.restore();
      E.tap(ctx, 160, 300, E.seg(f, 0.3, 0.42));
    } else {
      const g = E.seg(f, swap, swap + 0.1);
      ctx.save();
      ctx.translate((1 - E.ease.outCubic(g)) * 390, 0);
      ctx.fillStyle = T.screen;
      ctx.fillRect(0, 0, 390, 844);
      E.statusBar(ctx, T.ink);
      E.text(ctx, 'コゼニ', 195, 120, { size: 40, family: 'Dela Gothic One', weight: 400, color: T.accent, align: 'center' });
      E.text(ctx, '挑戦状', 195, 200, { size: 46, weight: 900, color: T.ink, align: 'center' });
      E.text(ctx, 'ゆうきさんより', 195, 240, { size: 19, weight: 700, color: T.sub, align: 'center' });
      E.fillRR(ctx, 60, 280, 270, 200, 24, '#fff', { shadow: 'rgba(0,0,0,0.08)', blur: 14, dy: 4 });
      E.text(ctx, '◎4つ', 195, 360, { size: 52, weight: 900, color: T.good, align: 'center' });
      E.text(ctx, '38.2秒', 195, 430, { size: 34, weight: 900, color: T.ink, align: 'center' });
      E.text(ctx, '同じ5問で勝負します', 195, 540, { size: 19, weight: 700, color: T.sub, align: 'center' });
      const pulse = 1 + 0.04 * Math.sin(local * 9);
      ctx.save();
      ctx.translate(195, 626);
      ctx.scale(pulse, pulse);
      E.button(ctx, -140, -32, 280, 64, '勝負する', { fill: T.accent, size: 26, weight: 900, press: Math.sin(E.seg(f, 0.86, 0.95) * Math.PI) });
      ctx.restore();
      E.tap(ctx, 195, 626, E.seg(f, 0.86, 0.99));
      ctx.restore();
    }
  }

  function bg(ctx, t, W, H) {
    ctx.fillStyle = T.bg;
    ctx.fillRect(0, 0, W, H);
    // うしろでゆっくり漂う硬貨
    const R = E.rng(7);
    for (let i = 0; i < 14; i++) {
      const den = COIN_DENOMS[i % 6];
      const x0 = R() * W, y0 = R() * H, sp = 10 + R() * 18, ph = R() * 6;
      const x = (x0 + Math.sin(t * 0.5 + ph) * 30) % W;
      const y = (y0 - t * sp + H * 2) % (H + 120) - 60;
      coin(ctx, x, y, den, { scale: 1.6 + R() * 1.4, alpha: 0.13 });
    }
  }

  function logo(ctx, x, y, size, alpha) {
    E.text(ctx, 'コゼニ', x, y, { size, family: 'Dela Gothic One', weight: 400, color: T.accent, alpha });
  }

  function icon(ctx, cx, cy, s) {
    E.fillRR(ctx, cx - s / 2, cy - s / 2, s, s, s * 0.23, T.accent, { shadow: 'rgba(120,40,20,0.3)', blur: s * 0.12, dy: s * 0.05 });
    coin(ctx, cx - s * 0.12, cy + s * 0.08, 100, { scale: s / 75 });
    coin(ctx, cx + s * 0.16, cy - s * 0.1, 5, { scale: s / 85, holeColor: T.accent });
  }

  function endCard(ctx, local, k, W, H, fmt) {
    ctx.save();
    ctx.globalAlpha = k;
    ctx.fillStyle = T.bg;
    ctx.fillRect(0, 0, W, H);
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
    E.text(ctx, 'コゼニ', 0, v ? 80 : 60, { size: v ? 170 : 140, family: 'Dela Gothic One', weight: 400, color: T.accent, align: 'center' });
    E.text(ctx, '財布の小銭が、いちばん減る払い方。', 0, v ? 200 : 150, { size: v ? 52 : 46, weight: 900, color: T.ink, align: 'center', maxWidth: W - 120 });
    ctx.restore();
    const b = E.seg(local, 0.5, 0.9);
    ctx.save();
    ctx.globalAlpha *= b;
    const py = v ? 1160 : 650;
    E.fillRR(ctx, cx - 330, py - 46, 660, 92, 46, T.ink);
    E.text(ctx, 'ブラウザで、そのまま遊べる', cx, py + 2, { size: 40, weight: 900, color: '#fff', align: 'center', baseline: 'middle' });
    E.text(ctx, 'App Store・Google Play で配信', cx, py + (v ? 130 : 112), { size: v ? 40 : 36, weight: 700, color: T.sub, align: 'center' });
    E.text(ctx, '※画面は開発中のイメージです', cx, H - (v ? 90 : 50), { size: 26, weight: 500, color: T.sub, align: 'center' });
    ctx.restore();
  }

  // 効果音のきっかけ（秒）
  function payCues(plan, d) {
    const out = [];
    for (const m of plan.moves) {
      if (m.from === 'wallet') {
        out.push({ t: (m.a - 0.02) * d, kind: 'tap' });
        out.push({ t: m.b * d, kind: m.den === 1000 ? 'bill' : 'coin', p: m.den });
      } else {
        out.push({ t: m.b * d, kind: 'coin', p: m.den });
      }
    }
    out.push({ t: (plan.tPay - 0.02) * d, kind: 'tap' });
    out.push({ t: plan.tPay * d, kind: 'register' });
    return out;
  }

  window.APPS.kozeni = {
    theme: T,
    bg,
    logo,
    endCard,
    scenes: [
      {
        name: 'hook',
        dur: { v: 2.3, h: 3.2 },
        screen: sHook,
        cap: {
          v: [{ text: '864円。\nどう払う？' }],
          h: [{ h: '864円、どう払う？', s: '財布の小銭がいちばん減る払い方を\n当てるパズル' }],
        },
        cues: (d) => [{ t: 0.1, kind: 'pop' }, { t: d * 0.3, kind: 'boing' }],
      },
      {
        name: 'naive',
        dur: { v: 3.6, h: 5.4 },
        screen: sNaive,
        cap: {
          v: [{ text: '千円札だけ出すと…' , b: 0.55 }, { a: 0.55, text: '小銭が\n15枚に増える' }],
          h: [{ h: '千円札だけだと…', s: 'お釣りで、財布の小銭が\n9枚 → 15枚' }],
        },
        cues: (d) => [...payCues(NAIVE, d), { t: (NAIVE.tLand + 0.03) * d, kind: 'bad' }],
      },
      {
        name: 'best',
        dur: { v: 5.0, h: 7.4 },
        screen: sBest,
        cap: {
          v: [{ text: '1,064円 出せば', b: 0.8 }, { a: 0.8, text: 'お釣りは100円玉2枚\n小銭は5枚に！' }],
          h: [{ h: '1,064円 出すのが正解', s: 'お釣りは100円玉2枚。\n財布の小銭は 9枚 → 5枚' }],
        },
        cues: (d) => [{ t: 0.02, kind: 'rewind' }, ...payCues(BEST, d), { t: (BEST.tLand + 0.02) * d, kind: 'good' }],
      },
      {
        name: 'receipt',
        dur: { v: 3.3, h: 5.0 },
        screen: sReceipt,
        cap: {
          v: [{ text: '毎日5問。\n結果はレシートで' }],
          h: [{ h: '毎日5問、全員同じ問題', s: '結果はレシートの画像にして\nそのまま共有できる' }],
        },
        cues: (d) => [
          { t: 0.04 * d, kind: 'print', dur: 0.58 * d },
          { t: 0.66 * d, kind: 'pop' },
          { t: 0.86 * d, kind: 'tap' },
        ],
      },
      {
        name: 'challenge',
        dur: { v: 3.2, h: 4.6 },
        screen: sChallenge,
        cap: {
          v: [{ text: '同じ5問で\n友だちに挑戦状' }],
          h: [{ h: 'リンクで挑戦状', s: '受け取った人は、ブラウザで\nそのまま同じ5問に挑める' }],
        },
        cues: (d) => [
          { t: 0.02 * d, kind: 'msg' },
          { t: 0.1 * d, kind: 'msg' },
          { t: 0.3 * d, kind: 'tap' },
          { t: 0.42 * d, kind: 'swoosh' },
          { t: 0.86 * d, kind: 'tap' },
        ],
      },
      { name: 'end', end: true, dur: { v: 2.6, h: 4.4 }, screen: () => {} },
    ],
  };
})();
