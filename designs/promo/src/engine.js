// 宣伝動画の共通部品。1コマずつ時刻 t（秒）を渡して描く。実時間のアニメーションは使わない。
(function () {
  const E = {};
  E.TAU = Math.PI * 2;
  E.rad = (d) => (d * Math.PI) / 180;
  E.clamp = (x, a = 0, b = 1) => Math.max(a, Math.min(b, x));
  E.lerp = (a, b, t) => a + (b - a) * t;
  // t が a から b に進むあいだの進み具合（0〜1）
  E.seg = (t, a, b) => E.clamp((t - a) / (b - a));
  E.ease = {
    linear: (t) => t,
    inQuad: (t) => t * t,
    outQuad: (t) => 1 - (1 - t) * (1 - t),
    inOutQuad: (t) => (t < 0.5 ? 2 * t * t : 1 - Math.pow(-2 * t + 2, 2) / 2),
    inCubic: (t) => t * t * t,
    outCubic: (t) => 1 - Math.pow(1 - t, 3),
    inOutCubic: (t) => (t < 0.5 ? 4 * t * t * t : 1 - Math.pow(-2 * t + 2, 3) / 2),
    outBack: (t) => {
      const c1 = 1.70158, c3 = c1 + 1;
      return 1 + c3 * Math.pow(t - 1, 3) + c1 * Math.pow(t - 1, 2);
    },
    outElastic: (t) => {
      if (t === 0 || t === 1) return t;
      return Math.pow(2, -10 * t) * Math.sin((t * 10 - 0.75) * ((2 * Math.PI) / 3)) + 1;
    },
  };

  // 決定的な乱数（mulberry32）
  E.rng = function (seed) {
    let a = seed >>> 0;
    return function () {
      a |= 0;
      a = (a + 0x6d2b79f5) | 0;
      let t = Math.imul(a ^ (a >>> 15), 1 | a);
      t = (t + Math.imul(t ^ (t >>> 7), 61 | t)) ^ t;
      return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
    };
  };

  // ---- 文字 ----
  // 使った文字を集めておき、描き始める前にフォントを読み込む
  E.texts = new Set();
  E.fontStr = (weight, size, family) => `${weight} ${size}px "${family}"`;

  function applyFont(ctx, o) {
    ctx.font = E.fontStr(o.weight || 700, o.size || 32, o.family || 'Zen Maru Gothic');
    ctx.letterSpacing = (o.letterSpacing || 0) + 'px';
  }

  E.measure = function (ctx, str, o = {}) {
    ctx.save();
    applyFont(ctx, o);
    const w = ctx.measureText(str).width;
    ctx.restore();
    return w;
  };

  // 行頭に来てはいけない文字（簡単な禁則）
  const NO_HEAD = '、。，．・：；！？!?）」』】ーぁぃぅぇぉっゃゅょゎァィゥェォッャュョ…';
  E.wrap = function (ctx, str, maxW, o = {}) {
    const out = [];
    for (const para of String(str).split('\n')) {
      let line = '';
      for (const ch of para) {
        const test = line + ch;
        if (line && E.measure(ctx, test, o) > maxW && !NO_HEAD.includes(ch)) {
          out.push(line);
          line = ch;
        } else {
          line = test;
        }
      }
      out.push(line);
    }
    return out;
  };

  // o: size, weight, family, color, align, baseline, valign('middle'), lineHeight, alpha,
  //    letterSpacing, maxWidth（超えたら縮める）, wrap（折り返す幅）, stroke, strokeColor, shadow
  E.text = function (ctx, str, x, y, o = {}) {
    str = String(str);
    E.texts.add(str);
    ctx.save();
    let size = o.size || 32;
    let lines = o.wrap ? E.wrap(ctx, str, o.wrap, { ...o, size }) : str.split('\n');
    if (o.maxWidth) {
      const widest = Math.max(...lines.map((l) => E.measure(ctx, l, { ...o, size })));
      if (widest > o.maxWidth) size = size * (o.maxWidth / widest);
    }
    applyFont(ctx, { ...o, size });
    ctx.fillStyle = o.color || '#000';
    ctx.textAlign = o.align || 'left';
    ctx.textBaseline = o.baseline || 'alphabetic';
    if (o.alpha != null) ctx.globalAlpha *= o.alpha;
    if (o.shadow) {
      ctx.shadowColor = o.shadow;
      ctx.shadowBlur = o.shadowBlur || size * 0.25;
      ctx.shadowOffsetY = o.shadowY || size * 0.06;
    }
    const lh = (o.lineHeight || 1.35) * size;
    let y0 = y;
    if (o.valign === 'middle') y0 = y - ((lines.length - 1) * lh) / 2;
    lines.forEach((ln, i) => {
      if (o.stroke) {
        ctx.lineWidth = o.stroke;
        ctx.strokeStyle = o.strokeColor || '#fff';
        ctx.lineJoin = 'round';
        ctx.strokeText(ln, x, y0 + i * lh);
      }
      ctx.fillText(ln, x, y0 + i * lh);
    });
    ctx.restore();
    return { lines, size, lh };
  };

  // ---- 図形 ----
  E.rr = function (ctx, x, y, w, h, r) {
    ctx.beginPath();
    ctx.roundRect(x, y, w, h, r);
  };
  E.fillRR = function (ctx, x, y, w, h, r, fill, o = {}) {
    ctx.save();
    if (o.alpha != null) ctx.globalAlpha *= o.alpha;
    if (o.shadow) {
      ctx.shadowColor = o.shadow;
      ctx.shadowBlur = o.blur ?? 16;
      ctx.shadowOffsetY = o.dy ?? 6;
    }
    E.rr(ctx, x, y, w, h, r);
    ctx.fillStyle = fill;
    ctx.fill();
    if (o.stroke) {
      ctx.shadowColor = 'transparent';
      ctx.lineWidth = o.lw || 2;
      ctx.strokeStyle = o.stroke;
      ctx.stroke();
    }
    ctx.restore();
  };
  E.circle = function (ctx, x, y, r, fill, o = {}) {
    ctx.save();
    if (o.alpha != null) ctx.globalAlpha *= o.alpha;
    ctx.beginPath();
    ctx.arc(x, y, r, 0, E.TAU);
    if (fill) {
      ctx.fillStyle = fill;
      ctx.fill();
    }
    if (o.stroke) {
      ctx.lineWidth = o.lw || 2;
      ctx.strokeStyle = o.stroke;
      ctx.stroke();
    }
    ctx.restore();
  };

  // ---- スマホの枠 ----
  // 画面の中は 390×844 の座標で描く
  E.SW = 390;
  E.SH = 844;
  E.phone = function (ctx, cx, top, scale, drawScreen, screenBg) {
    const bez = 11 * scale;
    const w = E.SW * scale + bez * 2;
    const h = E.SH * scale + bez * 2;
    const x = cx - w / 2;
    const y = top;
    ctx.save();
    ctx.shadowColor = 'rgba(30,20,10,0.30)';
    ctx.shadowBlur = 70 * scale;
    ctx.shadowOffsetY = 26 * scale;
    E.rr(ctx, x, y, w, h, 64 * scale);
    ctx.fillStyle = '#17181c';
    ctx.fill();
    ctx.restore();
    ctx.save();
    E.rr(ctx, x + 1.5, y + 1.5, w - 3, h - 3, 63 * scale);
    ctx.strokeStyle = 'rgba(255,255,255,0.16)';
    ctx.lineWidth = 2;
    ctx.stroke();
    ctx.restore();

    ctx.save();
    E.rr(ctx, x + bez, y + bez, E.SW * scale, E.SH * scale, 54 * scale);
    ctx.clip();
    ctx.translate(x + bez, y + bez);
    ctx.scale(scale, scale);
    ctx.fillStyle = screenBg || '#fff';
    ctx.fillRect(0, 0, E.SW, E.SH);
    drawScreen(ctx);
    ctx.restore();

    ctx.save();
    E.rr(ctx, cx - 46 * scale, y + bez + 12 * scale, 92 * scale, 27 * scale, 13.5 * scale);
    ctx.fillStyle = '#0b0b0d';
    ctx.fill();
    ctx.restore();
  };

  E.statusBar = function (ctx, color) {
    E.text(ctx, '10:08', 40, 37, { size: 15, weight: 700, color });
    ctx.save();
    ctx.fillStyle = color;
    for (let i = 0; i < 4; i++) ctx.fillRect(296 + i * 6, 33 - i * 3, 4, 4 + i * 3);
    E.rr(ctx, 326, 26, 26, 12, 3.5);
    ctx.strokeStyle = color;
    ctx.lineWidth = 1.4;
    ctx.stroke();
    ctx.fillRect(328.5, 28.5, 17, 7);
    ctx.restore();
  };

  // 指で押したしるし。p は押してからの進み具合（0〜1）
  E.tap = function (ctx, x, y, p, color = 'rgba(255,255,255,0.95)') {
    if (p <= 0 || p >= 1) return;
    const k = E.ease.outCubic(p);
    ctx.save();
    ctx.globalAlpha *= 1 - p;
    E.circle(ctx, x, y, 14 + 26 * k, null, { stroke: color, lw: 3 });
    ctx.globalAlpha *= 1;
    ctx.restore();
    ctx.save();
    ctx.globalAlpha *= p < 0.6 ? 0.85 : 0.85 * (1 - (p - 0.6) / 0.4);
    ctx.shadowColor = 'rgba(0,0,0,0.25)';
    ctx.shadowBlur = 10;
    E.circle(ctx, x, y, 15 * (1 - 0.15 * Math.sin(p * Math.PI)), 'rgba(255,255,255,0.9)', {
      stroke: 'rgba(0,0,0,0.12)',
      lw: 1.5,
    });
    ctx.restore();
  };

  // ボタン。press は押されている度合い（0〜1）
  E.button = function (ctx, x, y, w, h, label, o = {}) {
    const press = o.press || 0;
    const s = 1 - 0.05 * press;
    ctx.save();
    ctx.translate(x + w / 2, y + h / 2);
    ctx.scale(s, s);
    if (o.alpha != null) ctx.globalAlpha *= o.alpha;
    E.fillRR(ctx, -w / 2, -h / 2, w, h, o.r ?? h / 2, o.fill || '#333', {
      shadow: o.shadow === false ? null : 'rgba(0,0,0,0.18)',
      blur: 12,
      dy: 4,
      stroke: o.stroke,
      lw: o.lw,
    });
    E.text(ctx, label, 0, 1, {
      size: o.size || 20,
      weight: o.weight || 700,
      color: o.color || '#fff',
      align: 'center',
      baseline: 'middle',
      family: o.family,
    });
    ctx.restore();
  };

  // 2点のあいだを弧で飛ぶ位置
  E.arc = function (x0, y0, x1, y1, t, lift = 60) {
    return [E.lerp(x0, x1, t), E.lerp(y0, y1, t) - Math.sin(t * Math.PI) * lift];
  };

  // 作業用のキャンバス（切り紙の穴あけなど）
  const offs = {};
  E.offscreen = function (key, w, h) {
    let c = offs[key];
    if (!c || c.width !== w || c.height !== h) {
      c = document.createElement('canvas');
      c.width = w;
      c.height = h;
      offs[key] = c;
    }
    return c;
  };

  window.E = E;
  window.APPS = window.APPS || {};
})();
