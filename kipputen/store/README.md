# ストア素材

| ファイル | 用途 | 大きさ |
| --- | --- | --- |
| `icon_512.png` | Google Play のアイコン | 512×512 |
| `feature_graphic.png` | Google Play のフィーチャーグラフィック | 1024×500 |
| `screens/ios/*.png` | App Store のスクリーンショット（6.9インチ） | 1320×2868 |
| `screens/android/*.png` | Google Play のスクリーンショット（縦横比 2:1 以内） | 1080×1920 |
| `listing_ja.md` | 掲載文（アプリ名・説明・キーワードなど） | ― |

アプリのアイコンは `../assets/icon/`、スプラッシュは `../assets/splash/` にあります。
スプラッシュの下の「kiyokura」の表記は、ほかのアプリと共通の画像（ひそかぎと同じもの）です。

## アイコンのデザイン

深緑の地に、少し傾けた若草色の硬券を1枚置き、「10」を大きく印字しました。上の辺の右寄りには、入鋏の V 字の切り欠きがあります。地紋は自作の波線です。実在の切符・地紋・鉄道事業者にちなむものは描いていません。

ほかの自作の数字アプリ（脳ベンチ、今日の一手、ゾロメ）やメクマデ・ナゾノートとアイコンが似ないよう、「切符の形」と「深緑×若草」の配色にしています（App Store 4.3 対策）。

## スプラッシュ

- 明るいモード：アプリの画面と同じ生成り色（#F3EFE4）に、切符と濃い文字のブランド表記
- 暗いモード：アイコンの深緑（#1F4A37）に、切符と白い文字のブランド表記
- Android 12 以降は、OS の決まりにより中央にランチャーアイコンが出ます（背景 #2D6A4F）

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

スクリーンショットは、アプリを Web で動かして画面を撮り、見出しをつけて仕上げます。Web 版はスクリーンショットのためだけに使い、リポジトリには入れません。日付は 2026年11月4日に固定し、図鑑と連続日数には見本の記録を入れています（`src/shots_main.dart`）。

1. プロジェクトを別の場所にコピーし、そこで `flutter create --platforms web .` を実行する
2. `flutter build web --release --no-web-resources-cdn -t store/src/shots_main.dart` を実行し、`build/web` を `http://localhost:8765/` で配信する
3. `node store/src/capture.js <撮った画面の保存先>` を実行する
4. `node store/src/render.js . <撮った画面の保存先>` を実行する

スクリーンショットは Web ビルドで撮ったもので、実機の画面ではありません（文字の形などが少し違います）。
