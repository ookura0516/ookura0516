import 'package:ookura_daily/ookura_daily.dart';

/// ホーム画面ウィジェットに出す「第N問」「未解決／解決済み」「連続日数」。
/// 語はネタバレになるので出さない。
DailyWidgetSnapshot widgetSnapshot({
  required DailyClock clock,
  required DateTime now,
  required Iterable<int> streakDays,
}) {
  final today = clock.dayNumberAt(now);
  final days = streakDays.toSet();
  final doneToday = days.contains(today);
  return DailyWidgetSnapshot(
    today: DailyWidgetEntry(
      title: '第$today問',
      status: doneToday ? '解決済み' : '未解決',
      done: doneToday,
      streak: computeStreak(days, today).current,
    ),
    // 翌日分。今日を解いていなければ、日付が替わった時点で連続は0になる。
    tomorrow: DailyWidgetEntry(
      title: '第${today + 1}問',
      status: '未解決',
      done: false,
      streak: computeStreak(days, today + 1).current,
    ),
    switchAt: clock.nextSwitchAfter(now),
  );
}
