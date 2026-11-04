# ストア提出までの手順

コードは組み込み済みです。ここに書いてあるのは、Xcode・ストアの管理画面・AdMob で人がやる作業です。上から順に進めてください。

| 項目 | 値 |
| --- | --- |
| アプリ名 | キップテン |
| Bundle ID / パッケージ名 | `com.ookura.kipputen` |
| バージョン | 1.0.0（ビルド 1）。`pubspec.yaml` の `version` |
| 対応端末 | iPhone（iPad では iPhone 版として動く）、Android。縦向きのみ |
| 商品 | `kipputen_remove_ads`（広告削除 ¥480）、`kipputen_design_pack`（硬券デザインパック ¥320）。どちらも非消耗型 |
| 広告 | AdMob のバナー1つ（図鑑画面の下だけ） |

## 1. iOS のウィジェットを target に入れる（提出前に必須）

掲載文でホーム画面のウィジェットを案内しているので、iOS でも入れてから提出する。

1. Xcode で `ios/Runner.xcworkspace` を開き、File → New → Target → **Widget Extension** を `KipputenWidget` という名前で作る（Include Configuration App Intent は外す。デプロイ先は iOS 17 以上）
2. 作られた Swift ファイルを消し、`ios/KipputenWidget/KipputenWidget.swift` を KipputenWidget の target に入れる
3. Runner と KipputenWidget の両方の Signing & Capabilities に **App Groups** を足し、`group.com.ookura.kipputen` を選ぶ（Apple Developer で App Group も作る）
4. 実機で、ウィジェットに今日の4桁が出ること、解いたあと「✂ 入鋏済み」になること、0時に次の番号へ変わることを確かめる

## 2. Android の署名

1. アップロード鍵を作る（1回だけ。鍵とパスワードはリポジトリに入れず、安全な場所に保管する）

```bash
keytool -genkey -v -keystore ~/kipputen-upload.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

2. `android/key.properties` を作る（`.gitignore` 済み）

```
storeFile=/Users/<あなた>/kipputen-upload.jks
storePassword=<鍵ストアのパスワード>
keyAlias=upload
keyPassword=<鍵のパスワード>
```

3. `flutter build appbundle` で `build/app/outputs/bundle/release/app-release.aab` を作る。`key.properties` がないとデバッグの鍵で署名され、Play Console には上げられない
4. Play Console では「Google Play アプリ署名」を使う

## 3. 購入の商品を作る

### App Store Connect

1. アプリ「キップテン」（Bundle ID `com.ookura.kipputen`）を作る
2. 「App内課金」で **非消耗型** を2つ追加する

| 製品ID（コードと完全に一致させる） | 参照名・表示名 | 価格 | 説明 |
| --- | --- | --- | --- |
| `kipputen_remove_ads` | 広告削除 | ¥480 | 図鑑画面の下の広告が出なくなります |
| `kipputen_design_pack` | 硬券デザインパック | ¥320 | 切符の地色・書体・入鋏の形が4種類増えます |

3. 審査用のスクリーンショットに、設定画面の「購入」の欄を使う
4. 最初の審査は、アプリ本体と一緒に App内課金 を提出する

### Google Play Console

1. アプリ「キップテン」（パッケージ名 `com.ookura.kipputen`）を作る
2. 「収益化 → アプリ内アイテム」で **アイテム** を2つ追加する（ID・名前・価格は上と同じ）
3. 内部テストのトラックにアップロードしてから、ライセンステスターで購入を試す

## 4. AdMob の本番 ID に切り替える

1. AdMob でアプリ「キップテン」を iOS と Android で1つずつ作る
2. 各アプリに **バナー** の広告ユニットを1つ作る
3. 次の3か所を書き換える

| ファイル | 書き換えるところ |
| --- | --- |
| `lib/monetize/ad_unit_ids.dart` | `_bannerAndroid` `_bannerIos` を本番 ID に。`isPlaceholder` を `false` に |
| `ios/Runner/Info.plist` | `GADApplicationIdentifier` を iOS の本番アプリ ID（`ca-app-pub-…~…`）に |
| `android/app/src/main/AndroidManifest.xml` | `com.google.android.gms.ads.APPLICATION_ID` を Android の本番アプリ ID に |

- `isPlaceholder` が `true` のままリリースビルドを作ると、広告は出ません。テスト広告が本番で出ることはありません
- デバッグビルドでは、常に Google のテスト広告が出ます
- AdMob の「プライバシーとメッセージ」で、EEA・英国向けの同意メッセージ（GDPR）を作成・公開する。アプリは起動時に自動で表示し、設定に「広告のプライバシー設定」が出ます
- AdMob の「ブロックのコントロール」で、広告の最大コンテンツレーティングを G にする（アプリ側でも G に絞っています）
- `app-ads.txt` を、ストアに登録するデベロッパーのウェブサイトに置く

## 5. プライバシーの表示

広告SDK（Google Mobile Ads）が端末の識別子や広告の利用データを集めます。アプリ自体はサーバーに何も送りませんが、「収集なし」にはできません。

- **プライバシーポリシー**：`docs/PRIVACY.md` を公開し（GitHub Pages など）、その URL を両ストアに登録する。アプリ内の 設定 → プライバシーポリシー にも同じ文がある（`lib/ui/privacy_text.dart`。テストで一致を確かめている）
- **App Store のプライバシー**：Google の案内（[AdMob のデータ開示](https://developers.google.com/admob/ios/privacy/data-disclosure)）に沿って回答する。ATT は出さないので、「トラッキングに使用」は付けない
- **Google Play のデータセーフティ**：Google の案内（[Google Mobile Ads SDK のデータ開示](https://developers.google.com/admob/android/privacy/play-data-disclosure)）に沿って回答する。Android の `AD_ID` 権限は広告SDKが自動で追加するので「広告ID」も申告する
- **Google Play の権限の申告**：`POST_NOTIFICATIONS`（任意の通知）、`RECEIVE_BOOT_COMPLETED`（再起動後に通知とウィジェットの予約を戻す）。正確なアラームの権限は使っていない
- **輸出コンプライアンス**：独自の暗号化は使わない（`Info.plist` に `ITSAppUsesNonExemptEncryption = false` を入れてある）

## 6. 掲載情報

- 文：[store/listing_ja.md](../store/listing_ja.md)
- 画像：[store/](../store/)（アイコン、フィーチャーグラフィック、スクリーンショット）
- 年齢：App Store 4+、Google Play は IARC の質問に「暴力なし・ユーザー間の交流なし・広告あり・アプリ内購入あり」で答える
- 審査 4.3（類似アプリ）対策：自作の近接アプリ（メクマデ、ナゾノート、集印帳、ヨンクミ）とスクリーンショット・説明文を共有しない。ヨンクミと同時に提出せず、2週間以上あける（設計書）

## 7. 審査メモ（App Store、英語で書く）

- Daily puzzle: make 10 from the 4 digits of a ticket using + − × ÷ and parentheses. A new puzzle is chosen on-device from the date (JST); no server, no account.
- To test without waiting a day, open the Collection tab, tap any cell (or "番号を入れて探す"), and play that number as practice.
- Example answer for 1225: 5 × 2 × (2 − 1). Any correct answer is accepted.
- In-app purchases (non-consumable): "広告削除" removes the banner on the Collection screen; "硬券デザインパック" adds 4 ticket designs (Settings → 硬券のデザイン).
- Ads are a single banner on the Collection screen only. Non-personalized ads. No ATT prompt.

## 8. Google Play のクローズドテスト

個人のデベロッパーアカウントでは、製品版の前に **12人以上・14日間** のクローズドテストが要る（共通方針）。内部テストで購入と広告を確かめたあと、クローズドテストのトラックに上げ、14日後に製品版を申請する。

## 9. 実機で確かめること

- [ ] 初回起動：スプラッシュ → 今日の切符。通知の許可は出ない（設定でオンにしたときだけ）
- [ ] 今日の切符を解く → 入鋏・「あと◯通り」。切符の裏・共有画像（式を隠す／見せる、縦長／正方形）
- [ ] 共有：X と LINE と写真アプリに画像が渡る
- [ ] 0時をまたぐ：アプリを開いたまま次の番号に変わる。ウィジェットも開かずに変わる
- [ ] 通知：オン → 時刻を数分後にして待つ → 「今日は ◯◯◯◯」が出る。解いた日は出ない
- [ ] iOS：Sandbox アカウントで2つの商品を購入 → アプリを消して入れ直し →「購入を復元」で戻る
- [ ] Android：ライセンステスターで購入 → 入れ直し → 起動するだけで戻る
- [ ] 購入の途中でキャンセルしても、持ち物にならず、エラーも出ない
- [ ] 硬券デザインパックを持っていない状態で、桜鼠などを選ぶと購入の確認が出る。買うとそのデザインになる
- [ ] 広告：テスト広告のバナーが図鑑画面の下だけに出る。広告削除を買うと消える
- [ ] EEA の端末（または UMP のテスト設定）：起動時に同意フォームが出る。設定に「広告のプライバシー設定」が出る
- [ ] 機内モード：遊べる。購入済みのものはそのまま
- [ ] 古い iPhone を含む3機種で、共有画像の生成とウィジェットの更新（共通方針）
