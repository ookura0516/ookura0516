// store/src/shots_main.dart の Web ビルドを開き、アプリの画面を撮る。
//   node store/src/capture.js <出力フォルダ>    （http://localhost:8765/ で配信しておく）
const { chromium } = require('playwright');
const out = process.argv[2];
(async () => {
  const b = await chromium.launch();
  const p = await b.newPage({ viewport: { width: 440, height: 956 }, deviceScaleFactor: 3 });
  const go = async (q) => { await p.goto('http://localhost:8765/' + q); await p.waitForTimeout(4000); };
  await go('?v=eye'); await p.screenshot({ path: out + '/01_eye.png' });
  await go('?v=home'); await p.screenshot({ path: out + '/02_home.png' });
  await go('?v=fallen'); await p.screenshot({ path: out + '/03_fallen.png' });
  await go('?v=detail'); await p.screenshot({ path: out + '/06_detail.png' });
  await go('?v=shelf'); await p.screenshot({ path: out + '/05_shelf.png' });
  await go('?v=new'); await p.screenshot({ path: out + '/07_new.png' });
  await b.close();
})();
