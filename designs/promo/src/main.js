// 場面の並びを時刻に割り当て、背景・スマホ・字幕・終わりの画面を重ねて1コマを描く。
// ?app=kozeni|meirobin|monkiri&fmt=v|h で開く。v は縦 1080×1920、h は横 1920×1080。
(function () {
  const q = new URLSearchParams(location.search);
  const appName = q.get('app') || 'kozeni';
  const fmt = q.get('fmt') === 'h' ? 'h' : 'v';
  const W = fmt === 'v' ? 1080 : 1920;
  const H = fmt === 'v' ? 1920 : 1080;
  const FPS = 30;
  const cv = document.getElementById('c');
  cv.width = W;
  cv.height = H;
  const ctx = cv.getContext('2d');
  const app = window.APPS[appName];
  if (!app) throw new Error('unknown app ' + appName);
  E.W = W;
  E.H = H;
  E.fmt = fmt;
  const T = app.theme;

  const scenes = app.scenes.map((s) => ({ ...s, d: s.dur[fmt] }));
  let acc = 0;
  for (const s of scenes) {
    s.t0 = acc;
    acc += s.d;
  }
  const duration = acc;
  const endScene = scenes.find((s) => s.end);

  const L =
    fmt === 'v'
      ? { cx: 540, top: 456, scale: 1.64 }
      : { cx: 600, top: 55, scale: 1.12 };

  function sceneIndex(t) {
    for (let i = scenes.length - 1; i >= 0; i--) if (t >= scenes[i].t0) return i;
    return 0;
  }

  // 字幕。縦は上の帯に1〜2行、横は右側に見出しと説明
  function drawCaption(s, local) {
    const caps = (s.cap && s.cap[fmt]) || [];
    for (const c of caps) {
      const ta = (c.a || 0) * s.d;
      const tb = (c.b ?? 1) * s.d;
      if (local < ta || local >= tb) continue;
      const kin = E.ease.outCubic(E.seg(local, ta, ta + 0.32));
      const kout = 1 - E.seg(local, tb - 0.16, tb);
      const k = Math.min(kin, kout);
      if (fmt === 'v') {
        E.text(ctx, c.text, W / 2, 272 + (1 - kin) * 26, {
          size: T.capSize || 84,
          weight: T.capWeight || 900,
          family: T.capFamily,
          color: T.ink,
          align: 'center',
          baseline: 'middle',
          valign: 'middle',
          lineHeight: 1.26,
          maxWidth: 980,
          alpha: k,
        });
      } else {
        const x = 1010 + (1 - kin) * 30;
        let hx = x;
        if (c.step) {
          ctx.save();
          ctx.globalAlpha *= k;
          E.circle(ctx, x + 46, 506, 46, T.accent);
          E.text(ctx, c.step, x + 46, 509, {
            size: 56, weight: 900, color: '#fff', align: 'center', baseline: 'middle',
            family: T.capFamily,
          });
          ctx.restore();
          hx = x + 116;
        }
        E.text(ctx, c.h, hx, 536, {
          size: T.capSizeH || 88,
          weight: T.capWeight || 900,
          family: T.capFamily,
          color: T.ink,
          maxWidth: 1860 - hx,
          alpha: k,
        });
        E.text(ctx, c.s || '', x, 640, {
          size: 44,
          weight: 700,
          family: 'Zen Maru Gothic',
          color: T.sub,
          wrap: 840,
          lineHeight: 1.5,
          alpha: k,
        });
      }
    }
  }

  // 横の動画の右上に出すアプリ名
  function drawSideLabel(t) {
    if (fmt !== 'h') return;
    app.logo(ctx, 1010, 360, 68, 1);
  }

  function drawFrame(t) {
    ctx.save();
    ctx.setTransform(1, 0, 0, 1, 0, 0);
    ctx.globalAlpha = 1;
    app.bg(ctx, t, W, H);
    const i = sceneIndex(t);
    const s = scenes[i];
    const local = t - s.t0;
    const f = E.clamp(local / s.d);
    const showPhone = !s.end || local < 0.5;
    if (showPhone) {
      const shown = s.end ? scenes[i - 1] : s;
      const sl = s.end ? shown.d : local;
      const sf = s.end ? 1 : f;
      E.phone(
        ctx,
        L.cx,
        L.top,
        L.scale,
        (c) => {
          const xf = 0.24;
          const prev = scenes[i - 1];
          if (!s.end && prev && !prev.end && local < xf && s.xfade !== false) {
            prev.screen(c, prev.d, 1, prev.d, T);
            c.save();
            c.globalAlpha = E.ease.inOutQuad(local / xf);
            s.screen(c, sl, sf, shown.d, T);
            c.restore();
          } else {
            shown.screen(c, sl, sf, shown.d, T);
          }
        },
        T.screen,
      );
      if (!s.end) drawCaption(s, local);
      drawSideLabel(t);
    }
    if (endScene && t >= endScene.t0) {
      const k = E.ease.outCubic(E.seg(t, endScene.t0, endScene.t0 + 0.5));
      app.endCard(ctx, t - endScene.t0, k, W, H, fmt);
    }
    ctx.restore();
  }

  // 効果音のきっかけ（秒）
  function cues() {
    const out = [];
    for (const s of scenes) {
      if (!s.cues) continue;
      for (const c of s.cues(s.d, fmt)) out.push({ ...c, t: +(s.t0 + c.t).toFixed(3) });
    }
    if (endScene) out.push({ t: endScene.t0, kind: 'end' });
    out.sort((a, b) => a.t - b.t);
    return out;
  }

  async function loadFonts() {
    // 全部の時刻を一度描いて、使う文字を集める
    for (let t = 0; t < duration; t += 1 / 10) drawFrame(t);
    drawFrame(duration - 1e-3);
    const all = Array.from(E.texts).join('') + '0123456789';
    const faces = [
      '500 40px "Zen Maru Gothic"',
      '700 40px "Zen Maru Gothic"',
      '900 40px "Zen Maru Gothic"',
      '700 40px "Shippori Mincho"',
      '800 40px "Shippori Mincho"',
      '400 40px "Dela Gothic One"',
    ];
    await Promise.all(faces.map((f) => document.fonts.load(f, all)));
    await document.fonts.ready;
  }

  window.PROMO = {
    app: appName,
    fmt,
    W,
    H,
    fps: FPS,
    duration,
    frames: Math.round(duration * FPS),
    scenes: scenes.map((s) => ({ name: s.name, t0: s.t0, d: s.d })),
    cues: cues(),
    ready: loadFonts().then(() => true),
    draw: drawFrame,
    frameJpeg(t, q = 0.94) {
      drawFrame(t);
      return cv.toDataURL('image/jpeg', q);
    },
    framePng(t) {
      drawFrame(t);
      return cv.toDataURL('image/png');
    },
  };
})();
