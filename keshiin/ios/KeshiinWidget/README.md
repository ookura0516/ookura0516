# KeshiinWidget（iOS ウィジェット）

このフォルダの Swift は、まだ Xcode のターゲットに入っていません（この開発環境に Xcode がないため）。
Mac で次の手順を行ってください。

1. Xcode で `ios/Runner.xcworkspace` を開く
2. File → New → Target → Widget Extension、名前は `KeshiinWidget`（Live Activity と Configuration は外す）
3. 自動で作られた Swift を消し、このフォルダの `KeshiinWidget.swift` をターゲットに入れる
4. Runner と KeshiinWidget の両方に App Groups の Capability を付け、`group.com.ookura.keshiin` を選ぶ
5. KeshiinWidget の Deployment Target を iOS 17 以上にする（`containerBackground` を使うため）
