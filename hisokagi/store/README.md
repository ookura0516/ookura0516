# ストア素材

| ファイル | 用途 | 大きさ |
| --- | --- | --- |
| `icon_512.png` | Google Play のアイコン | 512×512 |
| `feature_graphic.png` | Google Play のフィーチャーグラフィック | 1024×500 |
| `screens/ios/*.png` | App Store のスクリーンショット（6.9インチ） | 1320×2868 |
| `screens/android/*.png` | Google Play のスクリーンショット（縦横比 2:1 以内） | 1080×1920 |
| `listing_ja.md` | 掲載文（アプリ名・説明・キーワードなど） | ― |

アプリのアイコンは `../assets/icon/`、スプラッシュは `../assets/splash/` にあります。
スプラッシュ下の「kiyokura」の表記は、ほかのアプリと共通の画像です。

## アイコンのデザイン

夜空の紺に、縦に2つに割れた鍵。上半分は金、下半分は淡い青で、ふたりが半分ずつ手がかりを持っていることを表しています。鍵の頭の穴には星。
LOCKD（黒地に金の南京錠）と見た目が似ないように、色・形とも変えています（App Store 4.3 対策）。

## 作り直しかた

アイコン・スプラッシュ・フィーチャーグラフィックは `src/render.js` が SVG から描きます。

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

撮影には Playwright（Chromium）を使います。画面は部屋番号 122 332（シード 233）で撮っています。
