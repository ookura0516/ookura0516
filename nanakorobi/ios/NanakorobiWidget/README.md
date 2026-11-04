# NanakorobiWidget（iOS ウィジェット）

ホーム画面（小・中）とロック画面（円形・横長）のウィジェット。`ios/Runner.xcodeproj` に
ターゲット `NanakorobiWidgetExtension`（Bundle ID `com.ookura.nanakorobi.NanakorobiWidget`、iOS 17 以上）として入っています。
ターゲットは `tool/add_ios_widget_target.py` で足しました（Xcode の New Target → Widget Extension と同じ中身）。

| ファイル | 中身 |
| --- | --- |
| `NanakorobiWidget.swift` | WidgetKit のウィジェット。App Group の UserDefaults からだるまの絵と日付の元データを読み、今後 14 日分の 0 時のエントリを Timeline に入れる |
| `Info.plist` | 拡張の種類（`com.apple.widgetkit-extension`）とバージョン（アプリと同じ `FLUTTER_BUILD_NAME`・`FLUTTER_BUILD_NUMBER`） |
| `NanakorobiWidget.entitlements` | App Group `group.com.ookura.nanakorobi`（Runner 側は `Runner/Runner.entitlements`） |

署名は自動（Automatic）です。Xcode か GitHub Actions で初めて署名するときに、
Apple Developer に App Group とウィジェットの App ID が作られます。
