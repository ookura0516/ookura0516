# ストアに出すまでの手順

コードとストア素材は用意済みです。ここに書いてあるのは、Apple・Google・AdMob の管理画面と、Mac・実機で人がやる作業です。上から順に進めてください。

| 名前 | 値 |
| --- | --- |
| アプリ名 | ヨンクミ |
| Bundle ID / パッケージ名 | `com.ookura.yonkumi` |
| ウィジェットの Bundle ID（iOS） | `com.ookura.yonkumi.YonkumiWidget` |
| App Group（iOS） | `group.com.ookura.yonkumi` |
| 課金の商品 ID（非消耗型） | `yonkumi_fullpack`（¥600） |
| バージョン | 1.0.0（ビルド 1）。`pubspec.yaml` の `version` |

## 0. 第1問の日を決める

`lib/core/schedule.dart` の `kFirstDay` が第1問の日（いまは 2026-11-01）。

- **このままでよい場合**：公開日が12月なら、公開日に「第30問」などから始まる。アーカイブで直近7日分を遊べるので、最初の日から遊べる問題が多い
- **公開日を第1問にしたい場合**：`kFirstDay` を公開日にして、`dart run tool/yonkumi.dart build` でアセットを作り直す（暗号の鍵が日付から決まるため）。60問で約2か月分。それまでに問題を足す

どちらにしても、収録した最後の日（いまは第60問）を過ぎると再出題になる。アプリの更新で問題を足していく。

## 1. iOS：ウィジェットと App Group を Xcode に組み込む（Mac）

1. `flutter pub get` のあと、Xcode で `ios/Runner.xcworkspace` を開く
2. File → New → Target → **Widget Extension**、名前は「YonkumiWidget」（Include Configuration Intent はオフ）
3. できたひな形の Swift を `ios/YonkumiWidget/YonkumiWidget.swift` の中身に、Info.plist を `ios/YonkumiWidget/Info.plist` の中身に置き換える
4. Runner と YonkumiWidget の両方の Signing & Capabilities に **App Groups** を足し、`group.com.ookura.yonkumi` を選ぶ（`Runner/Runner.entitlements` と `YonkumiWidget/YonkumiWidget.entitlements` に同じ値を書いてある）
5. YonkumiWidget の Deployment Target を Runner と同じ（iOS 15.0）にする
6. 実機で、ホーム画面にウィジェット「今日のヨンクミ」を置けることを確かめる

## 2. Android：リリースの署名鍵を作る

```bash
keytool -genkey -v -keystore ~/yonkumi-upload.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

`android/key.properties` を作る（リポジトリには入らない。`.gitignore` 済み）。

```
storePassword=<鍵のパスワード>
keyPassword=<鍵のパスワード>
keyAlias=upload
storeFile=/Users/<あなた>/yonkumi-upload.jks
```

鍵とパスワードは失くすと更新を出せなくなるので、パスワード管理に保管する。Play Console では「Play アプリ署名」を使う。

## 3. AdMob の本番 ID に切り替える

1. AdMob でアプリ「ヨンクミ」を iOS と Android で1つずつ作る
2. 各アプリに広告ユニットを1つ作る：**バナー**（結果画面の下）
3. 次の3か所を書き換える

| ファイル | 書き換えるところ |
| --- | --- |
| `lib/monetize/ad_unit_ids.dart` | `_bannerAndroid` `_bannerIos` を本番 ID に。`isPlaceholder` を `false` に |
| `ios/Runner/Info.plist` | `GADApplicationIdentifier` を iOS の本番アプリ ID（`ca-app-pub-…~…`）に |
| `android/app/src/main/AndroidManifest.xml` | `com.google.android.gms.ads.APPLICATION_ID` を Android の本番アプリ ID に |

- `isPlaceholder` が `true` のままリリースビルドを作ると、広告は出ない。テスト広告が本番で出ることはない
- デバッグビルドでは、常に Google のテスト広告が出る
- AdMob の「プライバシーとメッセージ」で、EEA・英国向けの同意メッセージ（GDPR）を作成・公開する。アプリは起動時に自動で表示し、設定画面に「広告のプライバシー設定」が出る
- AdMob の「ブロックのコントロール」で、広告の最大コンテンツレーティングを G にする（アプリ側でも G に絞っている）
- AdMob の「app-ads.txt」は、ストアに載せる開発者サイトに置く（ほかのアプリと共通）

## 4. 全問パックの商品を作る

### App Store Connect

1. アプリ「ヨンクミ」（Bundle ID `com.ookura.yonkumi`）を作る
2. 「App内課金」で **非消耗型** を追加する
   - 製品ID：`yonkumi_fullpack`（コードと完全に一致させる）
   - 参照名：全問パック
   - 価格：¥600
   - 表示名：全問パック
   - 説明：広告を消し、過去の問題をすべて遊べます
3. 審査用のスクリーンショットに、購入の画面（結果画面の「広告を消す」で開く）を使う
4. 最初の審査は、アプリ本体と一緒に App内課金 を提出する

### Google Play Console

1. アプリ「ヨンクミ」（パッケージ名 `com.ookura.yonkumi`）を作る
2. 「収益化 → アプリ内アイテム」で **アイテム** を追加する
   - アイテムID：`yonkumi_fullpack`
   - 名前・説明・価格は App Store と同じ
3. 内部テストのトラックにアップロードしてから、ライセンステスターで購入を試す

## 5. プライバシーポリシーを公開する

1. `store/privacy_policy_ja.md` を、誰でも見られる URL に置く（開発者サイト、または公開リポジトリ）
2. その URL を `lib/ui/links.dart` の `kPrivacyPolicyUrl` に入れる（いまは、このリポジトリの既定ブランチに入ったときの GitHub の URL。リポジトリが非公開なら見られないので、必ず差し替える）
3. 同じ URL を App Store Connect と Play Console の掲載情報に入れる

## 6. 掲載情報とプライバシーの申告

- 掲載文・キーワード・カテゴリ・年齢レーティングは `store/listing_ja.md`
- アイコン・スクリーンショット・フィーチャーグラフィックは `store/`（`store/README.md`）
- **App Store のプライバシー**：Google の案内（[AdMob のデータ開示](https://developers.google.com/admob/ios/privacy/data-disclosure)）に沿って回答する。ATT は出さないので、「トラッキングに使用」は付けない。アプリ自体が集めるデータはない
- **Google Play のデータセーフティ**：Google の案内（[Google Mobile Ads SDK のデータ開示](https://developers.google.com/admob/android/privacy/play-data-disclosure)）に沿って回答する。Android の `AD_ID` 権限は広告SDKが自動で足すので、「広告ID」を申告する
- **Google Play の広告の申告**：「広告を含む」にする
- **輸出コンプライアンス（iOS）**：`Info.plist` に `ITSAppUsesNonExemptEncryption = false` を入れてある（問題データの簡易暗号は、内容を隠すための難読化で、暗号化の申告の対象外）

## 7. ビルドして提出する

```bash
flutter build ipa --release
```

```bash
flutter build appbundle --release
```

- iOS は Xcode の Organizer（または Transporter）で App Store Connect にアップロードし、TestFlight で実機確認してから審査に出す
- Android は Play Console の**クローズドテスト**に出し、**12人以上が14日間**テストしてから製品版に申請する（個人の開発者アカウントの条件。設計書の工程どおり）
- 設計書の方針どおり iOS を先に出し、Android は同じ週に審査へ

### 審査メモ（App Store、英語で書く）

- A daily word puzzle: sort 16 words into 4 groups of 4. A new puzzle unlocks at 00:00 JST every day.
- The first launch shows a short tutorial puzzle (it can be skipped with "とばす").
- If the reviewer wants to see the result screen quickly: make 4 wrong guesses; the answers and explanations are shown even when the puzzle is failed.
- "全問パック" is a non-consumable IAP: removes the banner ad on the result screen, unlocks the archive older than 7 days, and shows per-category stats.
- Network is used only for ads and the App Store. The puzzle itself works offline.

## 8. 実機で確かめること（3台。古い iPhone を含む）

- [ ] 初回起動でチュートリアル問が出て、終えると今日の問題になる
- [ ] 日本時間の0時をまたいで開いたまま待つと、次の問題に替わる
- [ ] 結果画像（縦長・正方形）が共有シートに出て、X・LINE・写真に保存できる。文字の共有も崩れない
- [ ] ウィジェット：解くと「解決済み」になる。アプリを開かずに0時を過ぎると、次の番号と「未解決」になる（iOS・Android とも）
- [ ] 通知：設定でオンにすると許可を求め、指定の時刻に「第N問が出ました」が1件だけ届く。解いた日は届かない
- [ ] iOS：Sandbox アカウントで購入 → アプリを消して入れ直し →「購入を復元」で戻る
- [ ] Android：ライセンステスターで購入 → アプリを消して入れ直し → 起動するだけで戻る
- [ ] 購入の途中でキャンセルしても、購入済みにならず、エラーも出ない
- [ ] テスト広告：結果画面の下にだけバナーが出る。問題の画面には出ない。購入すると消える
- [ ] 機内モード：問題・結果・アーカイブ・成績が使える（広告は出ないだけ）
- [ ] EEA の端末（または UMP のテスト設定）：起動時に同意フォームが出て、設定に「広告のプライバシー設定」が出る
- [ ] 文字を最大まで大きくしても、タイルの文字が枠に収まる
