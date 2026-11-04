# ストアに出すまでの手順

コードとストア素材はそろっています。ここに書いてあるのは、人が Mac・ストアの管理画面・実機でやる作業です。上から順に進めてください。

## 0. 法規制の確認（最初に）

**まだ誰も確認していません。** 提出の前に必ず人が確認してください。この文書もコードも法的な助言ではありません。

- [ ] 郵便切手類模造等取締法と郵便法の条文を読み、「郵便切手と紛らわしい外観」に当たらないかを確かめる
- [ ] 既存の「切手風フレーム」アプリが、ストアとアプリ内でどう表記しているかを調べる（設計書「作る前の検証」）
- [ ] アイコン・スクリーンショット・掲載文（`store/listing_ja.md`）・共有画像（斜めの切手、透明 PNG、月のシート、旅の小型シート、年間ポスター）を見て、額面・通貨記号・郵便を思わせる文字が無いことを確かめる
- [ ] 不安が残る場合は、設計書のとおり「シール」に改題する（コードの見た目は変わらない。名前と文言を直す）

コードで入れた予防策は `README.md` の「法規制への配慮」にまとめてあります。

## 1. 名前とストア検索の確認

- [ ] 「ケシイン」を App Store・Google Play・J-PlatPat で検索し、重複が無いかを確かめる
- [ ] 「写真 切手」「写真日記 1日1枚」で両ストアの上位10本の評価件数と★を記録し、`store/listing_ja.md` のキーワードを見直す

## 2. 署名と識別子

| 項目 | 値 |
| --- | --- |
| iOS の Bundle ID | `com.ookura.keshiin` |
| Android のパッケージ名 | `com.ookura.keshiin` |
| App Group | `group.com.ookura.keshiin` |
| バージョン | `pubspec.yaml` の `version: 1.0.0+1` |

### Android の署名鍵

1. 鍵を作る（作った鍵とパスワードは、なくさない場所に保管する。リポジトリには入れない）

```bash
keytool -genkey -v -keystore ~/keshiin-upload.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

2. `android/key.properties` を作る（`.gitignore` 済み）

```
storePassword=<鍵ストアのパスワード>
keyPassword=<鍵のパスワード>
keyAlias=upload
storeFile=/Users/<あなた>/keshiin-upload.jks
```

3. Play Console では「Play アプリ署名」を使い、この鍵はアップロード鍵として登録する

`key.properties` が無いと、リリースビルドもデバッグ鍵で署名されます（ストアには出せません）。

### iOS

1. Xcode で `ios/Runner.xcworkspace` を開き、Signing & Capabilities で Team を選ぶ
2. Runner には App Group の entitlements（`Runner/Runner.entitlements`）を設定済み。Apple Developer で `group.com.ookura.keshiin` が作られることを確かめる
3. ホーム画面のウィジェットのターゲット（`KeshiinWidgetExtension`）は Xcode のプロジェクトに入れてある（[ios/KeshiinWidget/README.md](../ios/KeshiinWidget/README.md)）。Signing & Capabilities で、ウィジェットにも同じ Team と App Group が付いていることを確かめる

## 3. ビルドの確認

GitHub Actions（`.github/workflows/keshiin.yml`）が、push のたびに `flutter analyze`・`flutter test`・署名なしの Android（AAB・APK）と iOS のビルドを行います。Android のウィジェット（Kotlin）と、iOS のアプリ・ウィジェット（Swift）のコンパイルはここで確かめます。結果は GitHub の Actions タブで見られます。

手元で作るときは次のとおりです。

```bash
flutter build appbundle --release
```

```bash
flutter build ipa --release
```

- [ ] iOS：App Store に上げたときに、`Info.plist` の `NSPhotoLibraryUsageDescription`・`NSCameraUsageDescription` について警告が出ないか（image_picker がこれらの API を参照するため入れてある。カメラは使っていない）

## 4. 「記念」の商品を作る

リリースビルドは自動でストアの購入（`StorePurchaseService`）を使います。デバッグビルドは端末内だけの仮の購入です（`lib/main.dart` の `usesStorePurchases`）。

### App Store Connect

1. アプリ「ケシイン」（Bundle ID `com.ookura.keshiin`）を作る
2. 「App内課金」で **非消耗型** を追加する
   - 製品ID：`keshiin_kinen`（コードと完全に一致させる）
   - 参照名：記念
   - 価格：¥730
   - 表示名：記念
   - 説明：追加フレーム、旅の小型シート、年間ポスター、1日に複数枚、高解像度の書き出し
3. 審査用のスクリーンショットに、購入の案内（設定 →「記念について」）を使う
4. 最初の審査は、アプリ本体と一緒に App内課金 を提出する

### Google Play Console

1. アプリ「ケシイン」（パッケージ名 `com.ookura.keshiin`）を作る
2. 「収益化 → アプリ内アイテム」で **アイテム** を追加する
   - アイテムID：`keshiin_kinen`
   - 名前・説明・価格は App Store と同じ
3. 内部テストのトラックにアップロードしてから、ライセンステスターで購入を試す
4. 共通の技術方針のとおり、**12人×14日のクローズドテスト**を行ってから本番に出す

## 5. プライバシーの申告

アプリは広告・解析の SDK を含まず、運営者に情報を送りません。

- **プライバシーポリシーの URL**：[docs/PRIVACY.md](PRIVACY.md) の本文を、ほかのアプリと同じ場所に置いて URL を両ストアに入れる（アプリ内には「設定 → プライバシーポリシー」で同じ文章がある）
- **App Store のプライバシー**：「データを収集していない」で回答する想定。写真と記録は端末の中だけ。海外の写真の地名を調べる逆ジオコーディングは Apple の CLGeocoder が処理する。購入は Apple が処理する
- **Google Play のデータセーフティ**：「データの収集なし・共有なし」で回答する想定。逆ジオコーディングは Android の Geocoder（Google）が処理する
- 申告の前に、使っているパッケージ（`pubspec.yaml`）の最新のデータ開示を確認する
- **通知の権限**：Android 13 以降は、設定でリマインダーをオンにしたときにだけ許可を求める
- **写真の権限**：権限の要らないピッカー（iOS の PHPicker、Android の Photo Picker）を使う。写真ライブラリ全体の権限は求めない

## 6. 審査メモ（App Store）

次の内容を英語で書いておくと、確認が速くなります。

- This is a photo journal. Users pick one photo per day; the app turns it into a stamp-style image with a postmark (date and town) and collects them on a monthly sheet
- The design is stamp-like decoration only. It has no denomination, no currency symbols and no postal wording, and the app says it cannot be used as postage
- Photos are chosen with the system photo picker (no photo-library permission). Data stays on the device; there is no account or server
- The non-consumable IAP "記念" (keshiin_kinen) unlocks extra frames, extra postmark fonts, trip mini sheets, a yearly poster, multiple stamps per day and high-resolution export
- The home-screen widget shows this month's progress. Reminders are off by default

## 7. 実機で確かめること

共通の技術方針のとおり、古い iPhone を含む3機種で確認してから提出します。

- [ ] 写真を選ぶ→保存：権限のダイアログが出ない。撮影日と場所（市区町村）が消印に入る
- [ ] Android の Photo Picker で選んだ写真に位置情報が残るか（消える場合は場所が空欄になり、履歴から選ぶ）
- [ ] 海外の写真：通信できるときは地名が入る。機内モードでは空欄
- [ ] 古い端末で、月のシートの共有画像（1080×1350）と年間ポスターが数秒以内にでき、落ちない
- [ ] ウィジェット：保存のあとに埋まり具合が変わる。0時を過ぎると、アプリを開かなくても翌日の空欄になる。タップで写真の選択が開く
- [ ] リマインダー：オンにすると許可を求める。決めた時刻に届く。その日に貼ってあれば届かない。タップで写真の選択が開く。再起動のあとも届く
- [ ] 購入：Sandbox／ライセンステスターで購入→アプリを消して入れ直し→復元で「記念」が戻る。途中でキャンセルしても有効にならない
- [ ] ZIP の書き出し：「ファイル」に保存でき、中に JSON と元の写真が入っている
- [ ] 評価依頼：1枚目の保存の直後に出る（出すかどうかは OS が決める）

## 8. GitHub Actions でのビルドとアップロード

Actions → keshiin → Run workflow で `upload` を選ぶと、署名してストアのテスト用の場所に上げます。

| upload | 上げる先 |
| --- | --- |
| `play-internal` | Google Play の内部テスト（下書き） |
| `testflight` | App Store Connect（TestFlight） |
| `both` | 両方 |

一般公開（Google Play の製品版への昇格、App Store の審査への提出）は、ストアの管理画面で人が行います。ワークフローはしません。

### 前もってストアの管理画面でやること

- Google Play：アプリを作り、**最初の AAB は Play Console に手で上げる**（API で上げられるのは2本目から）。Actions の成果物 `keshiin-android` の `app-release.aab` を使ってよい（署名鍵のシークレットを入れたあとのもの）
- App Store Connect：アプリ（Bundle ID `com.ookura.keshiin`）を作る

### シークレット（Settings → Secrets and variables → Actions）

| 名前 | 中身 |
| --- | --- |
| `ANDROID_KEYSTORE_BASE64` | アップロード鍵（`.jks`）を base64 にしたもの（`base64 -i keshiin-upload.jks`） |
| `ANDROID_KEYSTORE_PASSWORD` | 鍵ストアのパスワード |
| `ANDROID_KEY_ALIAS` | 鍵の別名（`upload`） |
| `ANDROID_KEY_PASSWORD` | 鍵のパスワード |
| `PLAY_SERVICE_ACCOUNT_JSON` | Play Console の API アクセスで作ったサービスアカウントの JSON（「リリース」の権限） |
| `APPLE_TEAM_ID` | Apple Developer のチーム ID（10文字） |
| `ASC_KEY_ID` | App Store Connect の API キーの ID（役割は「App Manager」以上） |
| `ASC_ISSUER_ID` | API キーの Issuer ID |
| `ASC_KEY_P8_BASE64` | API キー（`AuthKey_XXXX.p8`）を base64 にしたもの |

署名鍵のシークレットが無いと、Android はデバッグ鍵で署名されます（ビルドの確認にはなるが、ストアには出せません）。
iOS の署名は自動（API キーで証明書とプロビジョニングプロファイルを作る）です。

