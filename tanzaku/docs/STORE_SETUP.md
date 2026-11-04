# ストアに出すまでの手順

コードは組み込み済みです。ここに書いてあるのは、Apple・Google の管理画面と Mac で人がやる作業です。上から順に進めてください。

## 1. ID を登録する（Apple Developer）

| 種類 | ID |
| --- | --- |
| App ID（本体） | `com.ookura.tanzaku`（App Groups にチェック） |
| App ID（ウィジェット） | `com.ookura.tanzaku.TanzakuWidget`（App Groups にチェック） |
| App Group | `group.com.ookura.tanzaku`（上の2つの両方に付ける） |

ウィジェットはこの App Group で、アプリが書いた今日の季語を読みます。ID が違うと、ウィジェットに「タンザク」とだけ出て季語が出ません。

## 2. Xcode で署名する（Mac）

```bash
cd tanzaku && flutter pub get && cd ios && pod install
```

1. `ios/Runner.xcworkspace` を開く
2. 「Signing & Capabilities」で、`Runner` と `TanzakuWidgetExtension` の両方に開発チームを選ぶ（Automatically manage signing のまま）
3. どちらにも App Groups の `group.com.ookura.tanzaku` が付いていることを確かめる（entitlements はコミット済み）
4. 実機でビルドして、ホーム画面にウィジェットを置き、今日の季語と連続日数が出ることを確かめる

ウィジェットのターゲットは Xcode のない環境で `tool/add_ios_widget_target.rb` を使って足しました。Xcode が設定を直したいと言ってきたら（「Update to recommended settings」）、受け入れてかまいません。

## 3. すずりの商品を作る

### App Store Connect

1. アプリ「タンザク」（Bundle ID `com.ookura.tanzaku`）を作る
2. 「App内課金」で **非消耗型** を追加する
   - 製品ID：`tanzaku_suzuri`（コードと完全に一致させる）
   - 参照名：すずり
   - 価格：¥730
   - 表示名：すずり
   - 説明：書体・和紙・色紙・落款のカスタム・月の十句・縦書き PDF が使えます
3. 審査用のスクリーンショットに、購入の画面（設定 → すずり）を使う
4. 最初の審査は、アプリ本体と一緒に App内課金 を提出する
5. 審査メモに「購入の入口は、短冊の画面で鍵の付いた書体・和紙を選んだとき、句帳の右上（月の十句）、設定の『すずり』」と書く

### Google Play Console

1. アプリ「タンザク」（パッケージ名 `com.ookura.tanzaku`）を作る
2. 「収益化 → アプリ内アイテム」で **アイテム** を追加する
   - アイテムID：`tanzaku_suzuri`
   - 名前・説明・価格は App Store と同じ
3. 内部テストのトラックにアップロードしてから、ライセンステスターで購入と「購入を復元」を試す

購入の記録は端末に保存します。Android は起動時に購入を同期し、iOS は「購入を復元」を押したときだけ問い合わせます（Apple ID の確認を勝手に出さないため）。

## 4. Android のリリース署名

鍵を作る（1回だけ。鍵とパスワードはなくさないよう、リポジトリの外に保管する）。

```bash
keytool -genkey -v -keystore ~/keys/tanzaku-upload.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

`android/key.properties` を作る（`.gitignore` 済み。コミットしない）。

```properties
storePassword=（鍵ストアのパスワード）
keyPassword=（鍵のパスワード）
keyAlias=upload
storeFile=/home/you/keys/tanzaku-upload.jks
```

```bash
flutter build appbundle --release
```

`key.properties` がないと、デバッグ鍵で署名されます（Play には上げられない）。Play App Signing を使い、上の鍵はアップロード鍵にする。

## 5. プライバシーの申告

- プライバシーポリシー：[PRIVACY.md](PRIVACY.md) をウェブで公開し、その URL を両ストアに登録する（「お問い合わせ」の連絡先を書き足す）
- App Store の「App のプライバシー」：**データの収集なし**
- Google Play の「データ セーフティ」：データの収集なし・共有なし。データは端末内で暗号化されない（SQLite と設定ファイル）。ユーザーはアプリを削除すればデータを消せる
- 輸出コンプライアンス：独自の暗号を使っていない（`ITSAppUsesNonExemptEncryption` は `false` にしてある）
- 年齢レーティング：4+ ／ IARC 全年齢（[../store/listing_ja.md](../store/listing_ja.md)）

## 6. 出す前の確認（設計書「共通の技術方針」と「リスクと対策」）

- [ ] 実機3台（古い iPhone を含む）で、短冊の保存・共有、十句ポスター、縦書き PDF、ウィジェットの0時の切り替えを確かめる
- [ ] 文字サイズを最大にして、詠む画面の入力欄と短冊の画面が崩れないか見る
- [ ] 通知をオンにして、翌朝に今日の季語の通知が来ること、タップで「詠む」が開くことを確かめる
- [ ] 機内モードで起動・詠む・短冊の保存ができる（購入済みなら有料の書体も使える）
- [ ] 書き出した JSON を別の端末で読み込める
- [ ] Google Play：クローズドテスト（12人以上 × 14日間）を終える
- [ ] App Store とストア検索の上位10本を見て、キーワードとアプリ名を決める（設計書「作る前の検証」）
- [ ] 名前の重複：「タンザク」を両ストアと J-PlatPat で検索する

## 7. 提出

- iOS を先に出し、Android は同じ週に審査へ（設計書）
- 素材は [../store](../store)（アイコン、フィーチャーグラフィック、スクリーンショット、掲載文）
- バージョンは `pubspec.yaml` の `version`（今は 1.0.0+1）。ウィジェットも同じ番号になる
