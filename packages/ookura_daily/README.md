# ookura_daily

日替わりアプリの共通部品。ヨンクミで作り、キップテンとタンザクでも使う前提で、アプリ固有の言葉を持たない。

| 読み込み | 中身 |
| --- | --- |
| `package:ookura_daily/ookura_daily.dart` | Flutter に依存しない部分（Dart の CLI からも使える）：`CivilDate`、`DailyClock`（決まった時差の0時で替わる通し番号）、`computeStreak`（連続日数）、`DailyWidgetSnapshot`（ウィジェットに書く今日と翌日の2日分）、`emojiGrid` |
| `package:ookura_daily/ookura_daily_flutter.dart` | 上に加えて：`renderShareImage`（画面に出さずに PNG、1080×1350 と 1080×1080）、`ShareSheet`（share_plus）、`DailyWidgetSink`・`HomeWidgetSink`（home_widget への書き出しと、切り替え時刻の更新予約） |

## 使い方

```dart
const clock = DailyClock(firstDay: CivilDate(2026, 11, 1)); // 日本時間
final today = clock.dayNumberAt(DateTime.now());            // 第何日
final streak = computeStreak(playedDays, today);            // current / longest
final png = await renderShareImage(MyCard(), format: ShareImageFormat.square);
```

ウィジェットのネイティブ側は、`ookura_daily.today.*` と `ookura_daily.tomorrow.*`（`title`・`status`・`done`・`streak`）、`ookura_daily.switch_at`（UTC のエポックミリ秒）を読み、切り替え時刻を過ぎていれば翌日分を出す。ヨンクミの `android/.../YonkumiWidgetProvider.kt` と `ios/YonkumiWidget/YonkumiWidget.swift` が例。

## テスト

```bash
flutter test
```
