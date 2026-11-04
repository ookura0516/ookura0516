// store/src/shots_main.dart の Web ビルドを開き、アプリの画面を撮る。
//   node store/src/capture.js <出力フォルダ>    （http://localhost:8765/ で配信しておく）
const { chromium } = require('playwright');
const out = process.argv[2];
(async () => {
  const opts = process.env.HTTPS_PROXY
    ? { proxy: { server: process.env.HTTPS_PROXY, bypass: 'localhost' } } : {};
  const b = await chromium.launch(opts);
  const p = await b.newPage({ viewport: { width: 440, height: 956 }, deviceScaleFactor: 3, ignoreHTTPSErrors: true });
  const go = async (q) => { await p.goto('http://localhost:8765/' + q); await p.waitForTimeout(4000);
    // 日本語の字形は Web では後から読み込まれるので、もう一度描かせてから待つ。
    await p.mouse.move(5, 5); await p.waitForTimeout(4000); };
  const press = async (label) => {
    await p.locator('flt-semantics[role="button"]').filter({ hasText: new RegExp(`^${label}$`) }).first().click();
    await p.waitForTimeout(300);
  };
  // 今日の切符：途中まで入れて、途中結果を出す（7 × 2 − 4）
  await go('');
  for (const k of ['7', '×', '2', '−', '4']) await press(k);
  await p.waitForTimeout(500);
  await p.screenshot({ path: out + '/typing.png' });
  await go('?v=solved'); await p.screenshot({ path: out + '/solved.png' });
  await go('?v=back&n=1225'); await p.screenshot({ path: out + '/back.png' });
  await go('?v=share&n=1225'); await p.screenshot({ path: out + '/share.png' });
  await go('?v=collection'); await p.screenshot({ path: out + '/collection.png' });
  await b.close();
})();
