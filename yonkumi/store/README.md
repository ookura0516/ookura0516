# ストア素材

| ファイル | 用途 | 大きさ |
| --- | --- | --- |
| `icon_512.png` | Google Play のアイコン | 512×512 |
| `feature_graphic.png` | Google Play のフィーチャーグラフィック | 1024×500 |
| `screens/ios/*.png` | App Store のスクリーンショット（6.9インチ） | 1320×2868 |
| `screens/android/*.png` | Google Play のスクリーンショット（縦横比 2:1 以内） | 1080×1920 |
| `listing_ja.md` | 掲載文（アプリ名・説明・キーワードなど） | ― |
| `privacy_policy_ja.md` | プライバシーポリシー（公開する場所を決めて載せる） | ― |

アプリのアイコンは `../assets/icon/`、スプラッシュは `../assets/splash/` にあります。
スプラッシュ下の「kiyokura」の表記は、ほかのアプリと共通の画像（明るい地用）です。

## アイコンのデザイン

和紙の地に、4×4の盤。上の2段は当てた組の帯（柿・紅）、下の2段は語のタイルで、2つを選んでいるところ。アプリの画面と同じ色です。
NYT の同型パズルの4色（黄・緑・青・紫）は使っていません。

## 作り直しかた

アイコン・スプラッシュ・フィーチャーグラフィックは `src/render.js` が SVG から描きます（Playwright の Chromium を使う）。

```bash
node store/src/render.js .
```

```bash
dart run flutter_launcher_icons
```

```bash
dart run flutter_native_splash:create
```

スクリーンショットは、アプリの画面をテストの仕組みで撮り（`src/shots_test.dart`）、見出しをつけて仕上げます。日本語のフォント（.ttf / .otf）を1つ指定します。

```bash
YONKUMI_SHOTS=/tmp/yonkumi_shots YONKUMI_FONT=/path/to/font.otf FLUTTER_ROOT=$(dirname $(dirname $(which flutter))) flutter test store/src/shots_test.dart
```

```bash
node store/src/render.js . /tmp/yonkumi_shots
```

画面は第20問（11月20日）の日に、第14〜19問を解いた記録を入れて撮っています。いまの画像は IPA ゴシックで撮ったもので、実機の文字（ヒラギノなど）とは書体が違います。
