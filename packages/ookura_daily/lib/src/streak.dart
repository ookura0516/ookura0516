/// 連続日数。
class StreakSummary {
  const StreakSummary({required this.current, required this.longest});

  /// いま続いている日数。今日まだ遊んでいなくても、昨日まで続いていれば数える
  /// （今日のうちに遊べば途切れないため）。
  final int current;

  /// これまでで最も長く続いた日数。
  final int longest;

  static const zero = StreakSummary(current: 0, longest: 0);

  @override
  bool operator ==(Object other) =>
      other is StreakSummary &&
      other.current == current &&
      other.longest == longest;

  @override
  int get hashCode => Object.hash(current, longest);

  @override
  String toString() => 'StreakSummary(current: $current, longest: $longest)';
}

/// 「遊んだ日」の通し番号の集まりから、連続日数を数える。
///
/// 何をもって「遊んだ日」とするか（正解したか、失敗も含めるか）は
/// 呼ぶ側が決めて [playedDays] に入れる。[today] より後の番号は無視する。
StreakSummary computeStreak(Iterable<int> playedDays, int today) {
  final days = playedDays.where((d) => d <= today).toSet().toList()..sort();
  if (days.isEmpty) return StreakSummary.zero;

  var longest = 1;
  var run = 1;
  for (var i = 1; i < days.length; i++) {
    run = days[i] == days[i - 1] + 1 ? run + 1 : 1;
    if (run > longest) longest = run;
  }

  final set = days.toSet();
  var end = today;
  if (!set.contains(end)) end = today - 1;
  var current = 0;
  while (set.contains(end - current)) {
    current++;
  }
  return StreakSummary(current: current, longest: longest);
}
