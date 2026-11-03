// store/src/shots_main.dart の Web ビルドを開き、アプリの画面を撮る。
//   node store/src/capture.js <出力フォルダ>    （http://localhost:8765/ で配信しておく）
const { chromium } = require('playwright');
const out = process.argv[2];
(async () => {
  const b = await chromium.launch();
  const p = await b.newPage({ viewport: { width: 440, height: 956 }, deviceScaleFactor: 3 });
  const go = async (q) => { await p.goto('http://localhost:8765/' + q); await p.waitForTimeout(3500); };
  const collapse = async () => { await p.mouse.click(200, 95); await p.waitForTimeout(900); };
  await go(''); await p.screenshot({ path: out + '/title.png' });
  await go('?v=room'); await p.screenshot({ path: out + '/room.png' });
  await go('?stage=0&role=a'); await collapse(); await p.screenshot({ path: out + '/door_a.png' });
  // 正解を入れて合言葉のダイアログを出す
  const input = p.locator('input, textarea').first();
  await input.click(); await p.keyboard.type('4356'); await p.waitForTimeout(400);
  await p.locator('flt-semantics[role="button"]').filter({ hasText: '答える' }).first().click();
  await p.waitForTimeout(1500); await p.screenshot({ path: out + '/passphrase.png' });
  await go('?stage=0&role=b'); await collapse(); await p.screenshot({ path: out + '/door_b.png' });
  await go('?stage=2&role=a'); await p.screenshot({ path: out + '/clock_a.png' });
  await go('?stage=3&role=b'); await p.screenshot({ path: out + '/grid_b.png' });
  await b.close();
})();
