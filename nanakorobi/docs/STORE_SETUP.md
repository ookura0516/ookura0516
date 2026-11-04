# ストアの設定手順

コードは組み込み済みです。ここに書いてあるのは、ストアの管理画面と Xcode で人がやる作業です。広告はありません。外部 SDK は各ストアの IAP だけです。

## 1. プラスの商品を作る

### App Store Connect

1. アプリ「ナナコロビ」（Bundle ID `com.ookura.nanakorobi`）を作る
2. 「App内課金」で **非消耗型** を追加する
   - 製品ID：`nanakorobi_plus`（`lib/services/plus_service.dart` の `plusProductId` と完全に一致させる）
   - 参照名：ナナコロビ プラス
   - 価格：¥600（仮置き。¥480〜730 で未決）
   - 表示名：ナナコロビ プラス
   - 説明：現役のだるまを何体でも、全12色、年末の棚ポスター、共有テンプレ全種、JSON の書き出し・読み込み
3. 審査用のスクリーンショットに、プラスの画面（設定 →「プラスについて」）を使う
4. 最初の審査は、アプリ本体と一緒に App内課金 を提出する

### Google Play Console

1. アプリ「ナナコロビ」（パッケージ名 `com.ookura.nanakorobi`）を作る
2. 「収益化 → アプリ内アイテム」で **アイテム** を追加する
   - アイテムID：`nanakorobi_plus`
   - 名前・説明・価格は App Store と同じ
3. 内部テストのトラックにアップロードしてから、ライセンステスターで購入を試す

## 2. iOS の設定

- App Groups：`group.com.ookura.nanakorobi` を Runner と Widget Extension の両方に付ける（docs/WIDGETS.md）
- 通知：`flutter_local_notifications` の iOS 設定（`AppDelegate` で `UNUserNotificationCenter.current().delegate` を設定）。許可は設定画面でオンにしたときだけ求める
- `Info.plist` の `CFBundleDisplayName` は「ナナコロビ」。「高崎だるま」など地域団体商標の名前は使わない

## 3. Android の設定

- `AndroidManifest.xml`：`POST_NOTIFICATIONS`（Android 13 以降の通知）、`RECEIVE_BOOT_COMPLETED`（0時更新の再登録）は設定済み。`SCHEDULE_EXACT_ALARM` は使わない（通知もウィジェットも inexact で予約している）
- ウィジェットの receiver は設定済み（docs/WIDGETS.md）
- 署名：`android/key.properties`（Git には入れない）を置くと `build.gradle.kts` がリリース鍵で署名する。なければデバッグ鍵

```
storePassword=＜キーストアのパスワード＞
keyPassword=＜鍵のパスワード＞
keyAlias=upload
storeFile=/絶対パス/upload-keystore.jks
```

```bash
keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

```bash
flutter build appbundle --release
```

- Play Console の「アプリのコンテンツ」で、`POST_NOTIFICATIONS` の用途（リマインド通知）を申告する

## 4. プライバシーの表示

このアプリはサーバーを持たず、広告 SDK も入れていません。集めるデータはありません。

- **App Store のプライバシー**：「データを収集しない」。購入情報はストアが扱う
- **Google Play のデータセーフティ**：「ユーザーデータを収集・共有しない」
- 試験日プリセットの更新で jsDelivr（CDN）に JSON を1つ取りに行く。個人情報は送らない。プライバシーポリシーにこの通信を書く
- 端末内の計測は設定画面で見せ、ユーザーが自分で共有シートに出したときだけ外に出る
- プライバシーポリシーの本文は `store/privacy_policy.md`。両ストアとも URL が要るので、GitHub Pages などに公開してその URL を登録する

## 5. 審査メモ（App Store）

次の内容を英語で書いておくと、確認が速くなります。

- 1つの目標に1体の「だるま」を作り、指で片目をなぞって始め、毎日の記録で模様が増える目標帳。達成でもう片方の目を入れる
- 試験日までの残り日数はウィジェットに出すが、主機能は目標の記録。配信中の「メクマデ 日めくりカウントダウン」とは画面も文言も別物（4.3 対策）
- 有料部分の解放は IAP のみ（非消耗型 `nanakorobi_plus`）。復元ボタンあり
- 縁起物としての風習の説明はするが、ご利益や効能はうたわない
- 通信はストアと試験日プリセットの更新（CDN）だけ。アカウントなし

## 6. 提出に使うもの

- 掲載文：`store/listing_ja.md`（アプリ名・サブタイトル・説明・キーワード・審査メモ）
- アイコン：App Store は Xcode の Assets（`flutter_launcher_icons` が生成済み）、Google Play は `store/icon_512.png`
- フィーチャーグラフィック：`store/feature_graphic.png`
- スクリーンショット：`store/screens/ios/`（6.9インチ、1320×2868）、`store/screens/android/`（1080×1920）。作り直しは `store/README.md`
- iOS の暗号の申告：`Info.plist` に `ITSAppUsesNonExemptEncryption = false` を設定済み

## 7. 実機で確かめること

- [ ] iOS：Sandbox アカウントで購入 → アプリを消して入れ直し →「購入を復元する」でプラスが戻る
- [ ] Android：ライセンステスターで購入 → アプリを消して入れ直し → 起動するだけでプラスが戻る
- [ ] 購入の途中でキャンセルしても、プラスにならず、エラーも出ない
- [ ] 機内モード：プラスを持っていれば、購入済みのまま。試験日は同梱版で出る
- [ ] 通知：オンにして時刻を設定 → 翌日その時刻に通知が来て、残り日数が合っている
- [ ] ウィジェット：docs/WIDGETS.md の確認項目
- [ ] 低価格端末で、だるまの描画と開眼のなぞりにフレーム落ちがない
