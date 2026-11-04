# ストア素材

| ファイル | 用途 | 大きさ |
| --- | --- | --- |
| `icon_512.png` | Google Play のアイコン | 512×512 |
| `feature_graphic.png` | Google Play のフィーチャーグラフィック | 1024×500 |
| `screens/ios/*.png` | App Store のスクリーンショット（6.9インチ） | 1320×2868 |
| `screens/android/*.png` | Google Play のスクリーンショット（縦横比 2:1 以内） | 1080×1920 |
| `listing_ja.md` | 掲載文（アプリ名・説明・キーワードなど） | ― |

アプリのアイコンは `../assets/icon/`、スプラッシュは `../assets/splash/` にあります。
スプラッシュ下の「kiyokura」の表記は、ほかのアプリと共通の画像です（紙の色の地なので、濃い色の版を使っています）。

> **スクリーンショットの写真は、イラストの見本です。** この開発環境からは写真素材を取得できなかったため、`src/render.js` で描いた絵（海・山・夜の街・猫など12枚）を写真の代わりに切手にしています。提出の前に、権利のはっきりした実際の写真（自分で撮ったものなど）に差し替えることをすすめます。差し替えは `src/photos/` に同じ名前の PNG（1200×900）を置いて、下の手順の3〜4をやり直すだけです。

## アイコンのデザイン

朱の地に、少し傾けた生成りの切手。目打ち、白縁、夕方の海、右下に二重丸と波線の消印。
文字・数字・額面は入れていません（郵便切手と紛らわしくしないため）。

## 作り直しかた

アイコン・スプラッシュ・フィーチャーグラフィック・見本の絵は `src/render.js` が SVG から描きます。撮影には Playwright（Chromium）を使います。

```bash
node store/src/render.js .
```

```bash
dart run flutter_launcher_icons
```

```bash
dart run flutter_native_splash:create
```

スクリーンショットは、アプリの画面を Flutter のテスト環境で 1320×2868 に描いて撮り、見出しを付けて仕上げます（Web 版は使いません）。日本語のフォントのパスを `FONT` で渡します（初期値は IPA ゴシック）。

1. `node store/src/render.js .`（見本の絵を作る）
2. 次のコマンドで画面を撮る（`<保存先>` は任意のフォルダ）

```bash
flutter test store/src/shots_test.dart --dart-define=OUT=<保存先> --dart-define=FONT=/usr/share/fonts/opentype/ipafont-gothic/ipag.ttf
```

3. `node store/src/render.js . <保存先>`（見出しを付けて `screens/` に書き出す）

画面は 2026年11月24日、10月は全部のマスが埋まり、11月はところどころ空欄がある状態で撮っています。
