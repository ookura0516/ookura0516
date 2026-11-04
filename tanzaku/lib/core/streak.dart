/// 連続日数。
class StreakInfo {
  const StreakInfo({
    required this.days,
    required this.composedToday,
    required this.canRevive,
  });

  /// 今日まで（今日まだ詠んでいなければ昨日まで）続いている日数。
  final int days;
  final bool composedToday;

  /// 昨日が抜けていて、おとといまで続いていた。「昨日の分を詠む」で復活できる。
  /// 復活できるのは昨日の1日分だけ。
  final bool canRevive;
}

DateTime _d(DateTime t) => DateTime(t.year, t.month, t.day);

StreakInfo computeStreak(Iterable<DateTime> composedDays, DateTime today) {
  final days = {for (final d in composedDays) _d(d)};
  final t = _d(today);
  DateTime back(int n) => DateTime(t.year, t.month, t.day - n);

  int run(DateTime from) {
    var n = 0;
    var cur = from;
    while (days.contains(cur)) {
      n++;
      cur = DateTime(cur.year, cur.month, cur.day - 1);
    }
    return n;
  }

  final composedToday = days.contains(t);
  if (composedToday) {
    return StreakInfo(days: run(t), composedToday: true, canRevive: false);
  }
  final yesterday = back(1);
  if (days.contains(yesterday)) {
    return StreakInfo(
      days: run(yesterday),
      composedToday: false,
      canRevive: false,
    );
  }
  final before = run(back(2));
  return StreakInfo(days: 0, composedToday: false, canRevive: before > 0);
}
