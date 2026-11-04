# KeshiinWidget（iOS ウィジェット）

このフォルダの Swift は、まだ Xcode のターゲットに入っていません（この開発環境に Xcode がないため）。
Mac で次の手順を行ってください。

1. Xcode で `ios/Runner.xcworkspace` を開く
2. File → New → Target → Widget Extension、名前は `KeshiinWidget`（Live Activity と Configuration は外す）
3. 自動で作られた Swift を消し、このフォルダの `KeshiinWidget.swift` をターゲットに入れる
4. Runner には App Group の entitlements（`Runner/Runner.entitlements`、`group.com.ookura.keshiin`）を設定済み。KeshiinWidget の Signing & Capabilities で App Groups を足し、同じ `group.com.ookura.keshiin` を選ぶ（このフォルダの `KeshiinWidget.entitlements` を使ってよい）
5. KeshiinWidget の Deployment Target を iOS 17 以上にする（`containerBackground` を使うため）
