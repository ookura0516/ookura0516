# ヨンクミ

16語を4組に分けろ。間違えは4回まで。

日替わりの言葉パズルです。毎日、日本時間の0時に1問だけ替わります。仕分けの軸は「同じ読み」「同じ漢字」「季語の季節」「隠れた県名」「ことわざの穴」「数え方」「カタカナ語の元」「前に「お」で別の言葉」など、日本語ならではのひねりにしています。サーバーもアカウントも使いません。

- 設計：[docs/DESIGN.md](docs/DESIGN.md)
- 元の企画：「人気ジャンル分析から作るアプリ4案 設計書（第2弾）」の案3と「共通の技術方針」
- 共通部品：[../packages/ookura_daily](../packages/ookura_daily)（日替わり・連続日数・結果画像・ウィジェット用データ。キップテンとタンザクでも使う）

## できたこと

| 項目 | 状態 |
| --- | --- |
| 今日の問題（4×4タイル、間違い4回まで、「あと1つ！」、シャッフル、選択解除、解きかけの保存） | できた。画面のテスト済み |
| 結果（4色グリッド、回数、連続日数、全組の解説とひっかけ、失敗でも答えを見せる） | できた。画面のテスト済み |
| 共有：画像（1080×1350・1080×1080）と文字（絵文字の四角） | できた。画像の大きさと文字の中身をテスト済み。答えは入れない |
| アーカイブ（直近7日は無料、それより前は全問パック、解いた日はサムネイル） | できた。画面のテスト済み |
| 設定（遊び方、成績、色名の表示、通知、全問パック） | できた。画面のテスト済み |
| 初回のチュートリアル問 | できた。成績と連続日数には数えない |
| 判定・日替わり（日本時間の0時）・連続日数（失敗しても途切れない）・成績の集計 | できた。ユニットテスト済み |
| 問題データの簡易暗号（日付で鍵を作る XOR）と、尽きたあとの再出題 | できた。ユニットテスト済み |
| 作問 CLI（候補出し・自動検証・書き出し） | できた。検証の各項目をテスト済み |
| 問題 30問（2026-11-01〜11-30 分、全問にミスリード） | できた。30問すべて自動検証を通る |
| 共通部品 `packages/ookura_daily` | できた。テスト済み |
| ウィジェット（第N問・未解決／解決済み・連続日数、0時に翌日分へ） | Dart 側とネイティブのコードはできた。実機での確認はまだ |
| 通知（1日1回・初期オフ・「第N問が出ました」だけ） | できた。予約の中身をテスト済み。実機での確認はまだ |
| 広告（結果画面の下のバナーだけ）と全問パック ¥600 | 差し替えられる仮の実装。広告 ID とストアの商品は入れていない |
| `flutter analyze` と `flutter test` | 通る（アプリ 69件、共通部品 19件） |

## まだのこと

| 項目 | メモ |
| --- | --- |
| 問題を200問にする | いまは30問（11月分）。`tool/` の CLI で足す（[作問の流れ](docs/DESIGN.md#作問の流れ)） |
| 第1日の決定 | `lib/core/schedule.dart` の `kFirstDay` はいま 2026-11-01（仮）。リリース日に変えて `build` し直す |
| AdMob の組み込み | `AdService` を実装したクラスに差し替える（下の「広告と購入の差し替え」） |
| ストアの商品と購入 | `PurchaseService` を in_app_purchase で実装する |
| ookura_consent（ATT・UMP） | 広告を本物にするときに必須。非公開パッケージなので、この環境では未対応 |
| ookura_design・ookura_a11y・ookura_meta | 非公開パッケージなので未対応（ひそかぎと同じ） |
| iOS のウィジェットと App Group を Xcode に組み込む | ファイルは `ios/YonkumiWidget/` にある。下の「iOS のウィジェット」 |
| 実機での確認 | Android SDK と Xcode がない環境で作ったので、ビルドと実機（画像生成・ウィジェットの0時更新・通知）はまだ |
| 評価の依頼（in_app_review） | 設計書では「パーフェクトでクリアした直後」。まだ |
| 記録の書き出し（JSON のファイル） | まだ |
| ウィジェットの「未解決ならタイルを点滅」 | いまは色を変えるだけ |
| 配色テーマ（全問パックの特典） | まだ |
| アイコン・スプラッシュ・ストア素材 | まだ |

## 動かし方

Flutter 3.41 以上（Dart 3.11 以上）。yonkumi/ で：

```bash
flutter pub get
```

```bash
flutter test
```

```bash
flutter analyze
```

```bash
flutter run
```

共通部品のテストは packages/ookura_daily/ で `flutter test`。

### 作問 CLI

```bash
dart run tool/yonkumi.dart validate
```

```bash
dart run tool/yonkumi.dart candidates reading
```

```bash
dart run tool/yonkumi.dart axes 金魚 蚊帳
```

```bash
dart run tool/yonkumi.dart check 下書き.json
```

```bash
dart run tool/yonkumi.dart build
```

`tool/puzzles/puzzles.json` を直したら、必ず `build` で `assets/puzzles.json` を作り直す（テストが元の問題とアセットの一致を確かめる）。

### 広告と購入の差し替え

`lib/main.dart` で、仮の実装を本物に替える。

- 広告：`AdService`（`lib/monetize/ad_service.dart`）を google_mobile_ads のアンカーアダプティブバナーで実装し、`PlaceholderAdService` の代わりに渡す。ひそかぎの `AdUnitIds` と同じく、本番 ID が未設定のリリースビルドでは出さないようにする。AndroidManifest.xml と Info.plist に AdMob のアプリ ID を足す
- 購入：`PurchaseService`（`lib/monetize/purchase_service.dart`）を in_app_purchase で実装する。形はひそかぎの `StorePurchaseService` と同じ（非消耗型1つ、Android は起動時に復元、iOS は「復元」ボタン）。App Store Connect と Play Console に非消耗型の商品（¥600）を作る

### iOS のウィジェット

1. Xcode で `ios/Runner.xcworkspace` を開き、Widget Extension のターゲットを「YonkumiWidget」の名前で足す
2. できたひな形の Swift を `ios/YonkumiWidget/YonkumiWidget.swift` に、Info.plist を `ios/YonkumiWidget/Info.plist` に置き換える
3. Runner と YonkumiWidget の両方に App Groups の capability を付け、`group.com.ookura.yonkumi` を選ぶ（`Runner/Runner.entitlements` と `YonkumiWidget/YonkumiWidget.entitlements` に同じ値を書いてある）

Android のウィジェット（`YonkumiWidgetProvider`）と通知の受け口は AndroidManifest.xml に登録済み。

## 設計書と変えたところ

| 設計書 | このアプリ | 理由 |
| --- | --- | --- |
| 帯の色は黄→緑→青→紫 | 柿→紅→栗→墨 | 依頼の「NYTと別の色」に合わせた。明るい色から暗い色へ並べ、色が見分けにくくても明るさで順が分かるようにした。文字の結果も 🟧🟥🟫⬛ で、NYT の 🟨🟩🟦🟪 を使わない |
| 永続化は drift（SQLite） | shared_preferences に JSON | 依頼の「hisokagi のパッケージの選び方に合わせる」に従った。記録は1日1件・数百件で、検索もしないので SQLite は要らない。コード生成（build_runner）もなくせる |
| 初版に200問 | 30問 | 依頼の範囲（最低30問、200問は後から） |
| 問題形式の `decoys` は「語と軸の対応表」 | `{word, title, axis}` の並び。各組に `axis`（種類と値）、問題に `readings`（16語の読み）を足した | 「各軸に当てはまる語がちょうど4つ」と「分け方が1通り」を機械で確かめるには、軸を辞書で引ける形にする必要があった。`tags` は `axis` から作る |
| ことわざの穴（例：○に入る語） | 同じ形のことわざの集まり（「猫に〇〇」型、「花より〇〇」型など）ごとの軸 | どの語もどこかのことわざの穴には入るので、集まりで絞らないと別解だらけになる |
| 前に「お」が付く（例：寿司・頼み…） | 前に「お」を付けると**別の言葉になる**語（化け→お化け、萩→おはぎ） | お茶・お金のような丁寧の「お」まで数えると、ほとんどの名詞が当てはまり、問題が成り立たない |
| 県名が隠れている（例：おかやま・とっとり…） | 語の読みの中に県名が隠れている語（みえっぱり＝三重、ちばしる＝千葉） | 例は県名そのものだったので、軸の名前の「隠れている」に合わせた |
| 作問ツールはタンザクの歳時記データを流用 | 自前の小さな季語辞書（約220語） | タンザクがまだない。できたら差し替える |
| 連続日数は「解いた日」 | その日の問題をその日のうちに解き終えた日。アーカイブで後から解いた日は数えない | 後から過去問を解いて連続を埋められないようにした。失敗でも途切れないのは設計書どおり |
| （記載なし） | 前と同じ4語の決定は間違いに数えない | うっかり同じ組を2回出して1回減るのは理不尽なため |
| 通知は1日1回・初期オフ | それに加えて時刻を選べる（6〜22時、初期8時） | 番号入りの文面にするため、繰り返し通知ではなく1日ずつ予約する。そのついでに時刻を選べるようにした |
| 共通基盤（ookura_design ほか） | 使っていない | 非公開パッケージで、この環境から取れない（ひそかぎと同じ） |
| 依頼文の「hisokagi の PlaceholderAdService」 | `PlaceholderAdService` を新しく作った | hisokagi にあるのは広告を出さない `NoAdService` と AdMob の実装で、同名のクラスはなかった。考え方（差し替えられる窓口と、ID なしの仮の実装）に合わせた |
