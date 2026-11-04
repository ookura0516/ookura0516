# ストア素材

| ファイル | 用途 | 大きさ |
| --- | --- | --- |
| `icon_512.png` | Google Play のアイコン | 512×512 |
| `feature_graphic.png` | Google Play のフィーチャーグラフィック | 1024×500 |
| `screens/android/*.png` | Google Play のスクリーンショット | 1080×1920 |
| `screens/ios/*.png` | App Store のスクリーンショット（6.9インチ） | 1320×2868 |
| `listing_ja.md` | 掲載文（アプリ名・説明・キーワードなど） | ― |

アプリのアイコンは `../assets/icon/`、スプラッシュは `../assets/splash/` にあります。

## アイコンのデザイン

生成りの地に、片目を入れた赤いだるま。眉は鶴、顔の縁は金。向かって右の目（だるまの左目）が入っていて、腹に「合格」。
アプリの中のだるま（`lib/paint/daruma_painter.dart`）と同じ線を SVG に写したもの。

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

スクリーンショットは、アプリを Web で動かして画面を撮り、見出しをつけて仕上げます。Web 版はスクリーンショットのためだけに使い、リポジトリには入れません。

1. プロジェクトを別の場所にコピーし、そこで `flutter create --platforms web .` を実行する
2. `flutter build web --release -t store/src/shots_main.dart` を実行し、`build/web` を `http://localhost:8765/` で配信する
3. `node store/src/capture.js <撮った画面の保存先>` を実行する
4. `node store/src/render.js . <撮った画面の保存先>` を実行する

撮影には Playwright（Chromium）を使います。画面は 2026-11-04 を今日として、2026-10-22 に開眼・筆12・起き上がり2・共通テストまで73日の状態で撮っています。4枚目のウィジェットだけは `src/render.js` が合成します。
