# ストア素材

| ファイル | 用途 | 大きさ |
| --- | --- | --- |
| `icon_512.png` | Google Play のアイコン | 512×512 |
| `feature_graphic.png` | Google Play のフィーチャーグラフィック | 1024×500 |
| `screens/ios/*.png` | App Store のスクリーンショット（6.9インチ） | 1320×2868 |
| `screens/android/*.png` | Google Play のスクリーンショット | 1080×1920 |
| `listing_ja.md` | 掲載文（アプリ名・説明・キーワードなど） | ― |

アプリのアイコンは `../assets/icon/`、スプラッシュは `../assets/splash/` にあります。
スプラッシュ下の「kiyokura」の表記は、ほかのアプリと共通の画像です（ひそかぎと同じ）。

## アイコンのデザイン

朱の地に、金の紐で下がった生成りの短冊。短冊には筆の書体（Yuji Syuku）で「句」の一字と、落款の朱の印。
ひそかぎ（紺の地に金の鍵）とは地の色も形も変え、書き初めのアプリ（筆と半紙）とも見た目が重ならないようにしています（App Store 4.3 対策）。

## 作り直しかた

アイコン・スプラッシュ・フィーチャーグラフィックは、アプリと同じ描画のコードとフォントで描きます。

```bash
flutter test tool/render_assets_test.dart --dart-define=WRITE=true
```

```bash
dart run flutter_launcher_icons
```

```bash
dart run flutter_native_splash:create
```

`flutter_launcher_icons` は iOS のプロジェクトの `ASSETCATALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS` を `AppIcon` に書き換えてしまうので、`YES` に戻す（`git diff ios/Runner.xcodeproj` で確かめる）。

スクリーンショットは、実際の画面を見本の句（書き下ろし）で描いて、見出しを付けます。画面の文字には端末のシステムの日本語フォントの代わりに Noto Sans JP を使います（リポジトリには入れない。Google Fonts の可変フォントから太さ400と700を作り、同じフォルダに `NotoSansJP-Regular.ttf` と `NotoSansJP-Bold.ttf` として置く）。

```bash
flutter test store/src/screenshots_test.dart --dart-define=SANS=/path/to/NotoSansJP-Regular.ttf --dart-define=OUT=store/screens
```

App Store Connect は透明度付きの画像を受け付けないので、最後に RGB にします。

```bash
python3 -c "import glob; from PIL import Image; [Image.open(f).convert('RGB').save(f) for f in glob.glob('store/screens/*/*.png')]"
```

日付は 2026年11月4日（霜降、兼題は「鰯雲」）、雅号は「月庵」で撮っています。
