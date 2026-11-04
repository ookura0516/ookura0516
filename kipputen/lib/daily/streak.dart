import 'day.dart';

/// 連続日数。[cleared] は「その日の問題を解いた日」。
class Streak {
  const Streak({required this.current, required this.best});

  final int current;
  final int best;

  /// 今日まだ解いていなくても、昨日まで続いていれば途切れていない扱いにする
  /// （今日が終わるまでは記録を守る）。
  factory Streak.compute(Iterable<Day> cleared, Day today) {
    final days = cleared.toSet();
    var best = 0;
    final sorted = days.toList()..sort();
    var run = 0;
    Day? prev;
    for (final d in sorted) {
      run = (prev != null && d.daysSince(prev) == 1) ? run + 1 : 1;
      if (run > best) best = run;
      prev = d;
    }
    var cur = 0;
    var d = days.contains(today) ? today : today.addDays(-1);
    while (days.contains(d)) {
      cur++;
      d = d.addDays(-1);
    }
    return Streak(current: cur, best: best);
  }
}
