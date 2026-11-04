# ホーム画面ウィジェットの組み込み

Flutter 側は `lib/services/widget_sync.dart` が、記録のたびに home_widget で次を書き出します。

| キー | 中身 |
| --- | --- |
| `nk_has` | だるまがいるか |
| `nk_name` / `nk_label` | 腹の文字、本番の名前 |
| `nk_deadline` / `nk_created` / `nk_last_step` | 本番の日・開眼日・最後に記録した日（epoch day。なければ -1） |
| `nk_brush` / `nk_rises` / `nk_eyes` | 筆の数、起き上がり回数、入っている目の数 |
| `nk_img_up` / `nk_img_fallen` | だるまの絵（通常・転倒）の PNG のパス（600×760） |

残り日数と「転んでいるか」は、ウィジェット側が **その日の日付** で計算します（`lib/core/rules.dart` と同じ決まり）。だから Flutter を起動しなくても 0 時に進みます。記録はアプリ内でだけ行い、ウィジェットからは記録しません（タップでアプリが開く）。

## Android（組み込み済み）

- `android/app/src/main/kotlin/com/ookura/nanakorobi/NanakorobiWidgetProvider.kt`：描画と日数の計算
- `android/app/src/main/res/layout/nanakorobi_widget.xml`、`res/xml/nanakorobi_widget_info.xml`：2×2 の小ウィジェット（広げられる）
- 0 時の更新：Flutter 側が home_widget の `scheduleWidgetUpdates` で **14 日分の 0 時 5 秒** を予約する（AlarmManager）。`AndroidManifest.xml` に `HomeWidgetScheduledUpdateReceiver` を登録してあり、再起動・アプリ更新後に予約を組み直す。保険として `updatePeriodMillis`（30 分）でも更新する
- 正確なアラーム（`SCHEDULE_EXACT_ALARM`）は宣言していない。Android 12 以降の Doze では 0 時の更新が数分遅れることがある。遅れても表示は日付から計算するので、次の更新で正しい日数になる

### 実機で確かめること

- [ ] ウィジェットを置き、アプリで記録すると絵と日数が変わる
- [ ] 端末の日付を翌日にして数分待つと、アプリを開かずに「あと N 日」が 1 減る（または転倒の絵に変わる）
- [ ] 再起動後も翌日の 0 時に進む
- [ ] ウィジェットをタップするとアプリが開く

## iOS（Xcode で Widget Extension を足す）

ファイルは `ios/NanakorobiWidget/` に置いてあります。この環境には Xcode がないので、手元で次の手順で組み込みます。

1. Xcode で `ios/Runner.xcworkspace` を開く
2. File → New → Target → **Widget Extension**。Product Name は `NanakorobiWidget`、Bundle Identifier は `com.ookura.nanakorobi.NanakorobiWidget`。"Include Configuration App Intent" はオフ。Activate する
3. Xcode が作った `NanakorobiWidget/` の Swift ファイルを消し、`ios/NanakorobiWidget/NanakorobiWidget.swift`・`Info.plist`・`ja.lproj`・`en.lproj` をターゲットに加える（Target Membership は NanakorobiWidget だけ）
4. **Signing & Capabilities** で、Runner と NanakorobiWidget の両方に **App Groups** を足し、`group.com.ookura.nanakorobi` を有効にする（`ios/Runner/Runner.entitlements`、`ios/NanakorobiWidget/NanakorobiWidget.entitlements` と同じ）
5. NanakorobiWidget の Deployment Target を **iOS 17.0** にする（`containerBackground` を使っている）。Runner は Flutter の既定のまま
6. Runner の Build Phases → Embed Foundation Extensions に NanakorobiWidget が入っていることを確かめる
7. 実機で、アプリで記録 → ウィジェットが更新されることを確かめる。ロック画面にも置ける（円形：残り日数、横長：本番の名前と日数）

Flutter 側は起動時に `HomeWidget.setAppGroupId('group.com.ookura.nanakorobi')` を呼んでいます（`lib/services/widget_sync.dart`）。`HomeWidget.updateWidget(iOSName: 'NanakorobiWidget')` の名前は Swift の `kind` と同じにしてあります。

### Timeline

`DarumaProvider.getTimeline` は、今日のエントリと今後 14 日分の 0 時のエントリを返します。各エントリの日数はその日の日付で計算するので、アプリを開かなくても進みます。アプリで記録すると Timeline を作り直します。
