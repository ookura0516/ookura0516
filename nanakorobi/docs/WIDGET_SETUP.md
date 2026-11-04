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

## iOS（ターゲットは追加済み）

- `ios/NanakorobiWidget/`：`NanakorobiWidget.swift`（WidgetKit）、`Info.plist`、`NanakorobiWidget.entitlements`（App Group `group.com.ookura.nanakorobi`）
- `ios/Runner.xcodeproj` には、ターゲット `NanakorobiWidgetExtension`（Bundle ID `com.ookura.nanakorobi.NanakorobiWidget`、iOS 17 以上）を `tool/add_ios_widget_target.py` で足してあります。Xcode の New Target → Widget Extension と同じ中身で、Runner には `Runner/Runner.entitlements`（同じ App Group）を設定します。2 回目以降は何もしません
- GitHub Actions（`.github/workflows/nanakorobi.yml` の `ios` ジョブ）が、署名なしでビルドして `.appex` がアプリに入っていることを確かめます

手元で Xcode を開くときは、Runner と NanakorobiWidgetExtension の **Signing & Capabilities** で Team を選ぶだけです（署名は自動。App Group は初めて署名するときに Apple Developer に作られます）。Deployment Target は NanakorobiWidgetExtension が iOS 17.0（`containerBackground` を使うため）、Runner は Flutter の既定のままです。

Flutter 側は起動時に `HomeWidget.setAppGroupId('group.com.ookura.nanakorobi')` を呼んでいます（`lib/services/widget_sync.dart`）。`HomeWidget.updateWidget(iOSName: 'NanakorobiWidget')` の名前は Swift の `kind` と同じにしてあります。

### 実機で確かめること

- [ ] アプリで記録 → ホーム画面のウィジェットが更新される
- [ ] 翌日の 0 時を過ぎると、アプリを開かずに「あと N 日」が 1 減る（Timeline の切り替え）
- [ ] ロック画面にも置ける（円形：残り日数、横長：本番の名前と日数）

### Timeline

`DarumaProvider.getTimeline` は、今日のエントリと今後 14 日分の 0 時のエントリを返します。各エントリの日数はその日の日付で計算するので、アプリを開かなくても進みます。アプリで記録すると Timeline を作り直します。
