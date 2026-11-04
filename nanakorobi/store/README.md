# ストア素材

| ファイル | 用途 | 大きさ |
| --- | --- | --- |
| `icon_512.png` | Google Play のアイコン | 512×512 |
| `feature_graphic.png` | Google Play のフィーチャーグラフィック | 1024×500 |
| `screens/ios/*.png` | App Store のスクリーンショット（6.9インチ） | 1320×2868 |
| `screens/android/*.png` | Google Play のスクリーンショット（縦横比 2:1 以内） | 1080×1920 |
| `listing_ja.md` | 掲載文（アプリ名・説明・キーワード・審査メモ） | ― |
| `privacy_policy.md` | プライバシーポリシー（日本語・英語）。ストアに登録する URL に載せる | ― |

アプリのアイコンは `../assets/icon/`、スプラッシュは `../assets/splash/` にあります。スプラッシュ下の「kiyokura」の表記は、ほかのアプリと共通の画像（ひそかぎと同じ）です。

## アイコンのデザイン

和紙の生成りに、片目を入れた赤いだるま。眉がそろった7筆の姿で、台座には金の筋が3本（七転び八起き）。アプリ本体と同じ CustomPainter で描いているので、画面のだるまと同じ顔です。

## 作り直しかた

アイコン・スプラッシュ・フィーチャーグラフィック・スクリーンショットは、Flutter のテスト実行で描きます（Web ビルドや Playwright は使いません）。

```bash
sh store/src/fetch_fonts.sh
```

```bash
flutter test store/src/render_store_test.dart --dart-define=STORE=1
```

```bash
dart run flutter_launcher_icons
```

```bash
dart run flutter_native_splash:create
```

- `fetch_fonts.sh` は、スクリーンショットの文字に使う Noto Sans JP（SIL OFL）を `store/src/fonts/` に取ってきます（Git には入れません）。アプリ本体には同梱しません
- スクリーンショットは、画面を実際に組み立てて撮り、上に見出しを乗せています。だるまは記録を仕込んだ見本（開眼から12日、起き上がり2回など）です
- `--dart-define=STORE=1` を付けないと、このテストは何もしません（通常の `flutter test` には影響しません）。1場面だけ作り直すときは `--dart-define=STORE_ONLY=02_eye` のように場面の名前を足します
