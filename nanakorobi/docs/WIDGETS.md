# ウィジェットの実装手順（iOS WidgetKit・Android Glance）

Dart 側はできています。この環境では Xcode と Android Studio を動かせないので、ネイティブ側はここに手順と参考コードを残します。上から順に進めてください。

## 1. Dart 側がしていること

- 保存のたびに `DarumaActions.syncOutside()` が `WidgetSyncService.sync(WidgetSnapshot)` を呼ぶ（`lib/state/daruma_actions.dart`）
- `HomeWidgetSyncService`（`lib/services/widget_sync_service.dart`）が home_widget を使って、App Group `group.com.ookura.nanakorobi`（iOS）と `HomeWidgetPreferences`（Android）のキー `nanakorobi_snapshot` に次の JSON を書き、`NanakorobiWidget`（iOS）／`NanakorobiWidgetReceiver`（Android）の更新を要求する
- だるまがいないときは `nanakorobi_snapshot` を消す

```json
{
  "look": {
    "daruma_id": "…", "text": "合格", "color_id": 0, "seed": 123456,
    "strokes": 12, "gold_lines": 2, "first_eye": "left", "eyes": "one",
    "size_rank": 1, "fallen": false, "status": "active",
    "opened_on": "2027-01-01", "completed_on": null,
    "days_left": 15, "deadline_name": "共通テスト",
    "streak": 3, "recorded_today": true, "days_since_opened": 12
  },
  "name": "合格",
  "deadline_name": "共通テスト",
  "timeline": [
    {"date": "2027-01-01", "daysLeft": 15, "nextWaypointName": "模試", "nextWaypointDays": 4},
    {"date": "2027-01-02", "daysLeft": 14, "nextWaypointName": "模試", "nextWaypointDays": 3}
  ],
  "generated_at": "2027-01-01T20:00:00.000",
  "style": "paper"
}
```

- `timeline` は今日から14日分。各日の 0 時（端末のタイムゾーン）にその日のエントリへ切り替える。日数はアプリを開かなくても進む
- `look.recorded_today` は書いた時点の値。翌日以降のエントリでは「未記録」として薄い輪郭で描く
- ウィジェットからは記録しない。タップはアプリを開くだけ

## 2. iOS（WidgetKit）

ソースは置いてあります。残りは Xcode での作業です（この環境では Xcode を動かせないのでビルド未確認）。

- `ios/NanakorobiWidget/NanakorobiWidget.swift`：Provider（App Group の JSON を読んで 14 日分のタイムラインを作る）、小・中・ロック画面（円形・横長）の View、だるまの簡略描画（SwiftUI Canvas）
- `ios/NanakorobiWidget/Info.plist`：`com.apple.widgetkit-extension`
- `ios/NanakorobiWidget/NanakorobiWidget.entitlements` と `ios/Runner/Runner.entitlements`：App Group `group.com.ookura.nanakorobi`。Runner の `CODE_SIGN_ENTITLEMENTS` は project.pbxproj に設定済み
- `ios/Runner/Info.plist`：URL スキーム `nanakorobi`（ウィジェットのタップでアプリを開く）

Xcode での手順：

1. `ios/Runner.xcworkspace` を開き、File → New → Target → Widget Extension。Product Name `NanakorobiWidget`、Bundle Identifier `com.ookura.nanakorobi.NanakorobiWidget`、「Include Configuration App Intent」はオフ。Activate scheme は不要
2. 生成されたテンプレートのファイル（`NanakorobiWidget.swift`、`NanakorobiWidgetBundle.swift`、`Info.plist`、Assets）を削除し、`ios/NanakorobiWidget/` の `NanakorobiWidget.swift`・`Info.plist`・`NanakorobiWidget.entitlements` をそのターゲットに追加する（Copy items if needed はオフ）
3. NanakorobiWidget ターゲットの Build Settings：Deployment Target 16.0、Code Signing Entitlements に `NanakorobiWidget/NanakorobiWidget.entitlements`、Info.plist File に `NanakorobiWidget/Info.plist`
4. Runner と NanakorobiWidget の両方で Signing & Capabilities → App Groups に `group.com.ookura.nanakorobi` を付ける（Apple Developer で App Group を作っておく）
5. Runner の Build Phases → Embed Foundation Extensions に NanakorobiWidget.appex が入っていることを確認する
6. 実機で、アプリで記録 → ウィジェットの筆の数が増える、端末の時刻を翌日に進める → 残り日数が減る、を確認する

設計のメモ：

- `WidgetSnapshot` の JSON を `UserDefaults(suiteName: "group.com.ookura.nanakorobi")` の `nanakorobi_snapshot` から読む（home_widget はこのキー名のまま保存する）
- Timeline は `timeline` の各日について「その日の 0 時」をエントリの日時にし、`.atEnd` で切り替える。14日目の末尾で再要求される
- だるまの絵は SwiftUI Canvas の Path で簡略に描く（体の色、顔、目の状態、眉の本数 ≤7、ひげの本数 ≤14、腹の文字、台座の金の筋）。アプリと同じ `DarumaLook` から描くので筆の数が合う
- 複数のだるま（プラス）：初版は「設定 → ウィジェットに出すだるま」でアプリ側が選んだ1体を書く。AppIntent による設定は次版

（Swift のソースは `ios/NanakorobiWidget/NanakorobiWidget.swift`）


確認すること：

- [ ] 0 時をまたいで、アプリを開かずに残り日数が1減る（端末の時刻を進めて確認）
- [ ] 記録のある日とない日で、だるまの濃さが変わる
- [ ] ロック画面の円形と横長が出る（iOS 16 以降）
- [ ] だるまを納めたあと、「だるまを作る」の表示になる

## 3. Android（Glance）

実装済みです（この環境には Android SDK がなく、ビルドは未確認。最初に `flutter build apk --debug` を通してください）。

- `android/app/src/main/kotlin/com/ookura/nanakorobi/NanakorobiWidgetReceiver.kt`：home_widget の `HomeWidgetGlanceWidgetReceiver`
- `.../NanakorobiWidget.kt`：Glance の本体。小（2×2）と中（4×2）を `SizeMode.Responsive` で切り替える。JSON（`nanakorobi_snapshot`）の `timeline` から「今日」の行を選ぶので、描き直しが遅れても日数は狂わない
- `.../DarumaBitmap.kt`：だるまを android.graphics で描く（腹の文字は Flutter アセットの Yuji Syuku）
- `res/xml/nanakorobi_widget_info.xml`、`res/values/strings.xml`、`AndroidManifest.xml` の receiver 2 つ（ウィジェット本体と、0 時更新用の `HomeWidgetScheduledUpdateReceiver`）
- `android/app/build.gradle.kts`：Compose コンパイラ（`org.jetbrains.kotlin.plugin.compose`）と `androidx.glance:glance-appwidget:1.2.0`
- 0 時更新：Dart 側の `HomeWidgetSyncService` が `HomeWidget.scheduleWidgetUpdates` で 14 日分の 0 時（端末のタイムゾーン）を予約する。再起動とアプリ更新後の予約し直しは home_widget の receiver が行う。`SCHEDULE_EXACT_ALARM` は使わない（inexact でよい。表示は日付で行を選ぶので遅れても狂わない）

（Kotlin のソースは上のファイル）

確認すること：

- [ ] アプリで記録すると、数秒以内にウィジェットの筆の数が増える
- [ ] 0 時をまたいで残り日数が減る。Doze 中でも、次に画面を見たとき日付が合っている
- [ ] 再起動後も 0 時の更新が続く
- [ ] だるまがいないとき「だるまを作る」になる

## 4. ウィジェットから記録しない理由

記録はアプリ内だけで行う。「ウィジェットで便利になりすぎて開かれないアプリ」を避け、評価依頼（7日目と両目の直後）と購入導線（2体目、7日目の共有、両目の直後）の機会を残すため。ウィジェットのタップはアプリを開くだけにする。
