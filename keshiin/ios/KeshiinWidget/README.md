# KeshiinWidget（iOS ウィジェット）

ホーム画面（小・中）とロック画面のウィジェット。`ios/Runner.xcodeproj` に
ターゲット `KeshiinWidgetExtension`（Bundle ID `com.ookura.keshiin.KeshiinWidget`、iOS 17 以上）として入っています。
ターゲットは `tool/add_ios_widget_target.py` で足しました（Xcode の New Target → Widget Extension と同じ中身）。

| ファイル | 中身 |
| --- | --- |
| `KeshiinWidget.swift` | WidgetKit のウィジェット。App Group の UserDefaults から今日と明日の分を読み、0時に切り替える |
| `Info.plist` | 拡張の種類（`com.apple.widgetkit-extension`）とバージョン（アプリと同じ `FLUTTER_BUILD_NAME`・`FLUTTER_BUILD_NUMBER`） |
| `KeshiinWidget.entitlements` | App Group `group.com.ookura.keshiin` |

署名は自動（Automatic）です。Xcode か GitHub Actions で初めて署名するときに、
Apple Developer に App Group とウィジェットの App ID が作られます。
