import 'package:ookura_daily/ookura_daily.dart';

import '../core/axis.dart';
import '../core/puzzle.dart';
import 'play_log.dart';

/// 軸ごとの正解率。
class AxisRate {
  const AxisRate(this.solved, this.total);

  final int solved;
  final int total;

  double get rate => total == 0 ? 0 : solved / total;
}

/// 成績。遊んだ記録から毎回集計する（集計結果は保存しない）。
class PlayStats {
  const PlayStats({
    required this.played,
    required this.cleared,
    required this.perfect,
    required this.averageMistakes,
    required this.streak,
    required this.byAxis,
  });

  final int played;
  final int cleared;

  /// 間違いなしでクリアした回数。
  final int perfect;

  /// 1問あたりの平均の間違い回数。
  final double averageMistakes;
  final StreakSummary streak;

  /// 軸の種類ごとに、当てた組の数と出た組の数。
  final Map<AxisType, AxisRate> byAxis;

  double get clearRate => played == 0 ? 0 : cleared / played;

  static PlayStats compute(
    Iterable<PlayRecord> records, {
    required int today,
    required Puzzle? Function(PlayRecord record) puzzleOf,
  }) {
    final list = records.toList();
    final solvedByAxis = <AxisType, int>{};
    final totalByAxis = <AxisType, int>{};
    for (final r in list) {
      final p = puzzleOf(r);
      if (p == null) continue;
      for (final g in p.groups) {
        totalByAxis[g.tag] = (totalByAxis[g.tag] ?? 0) + 1;
        final hit = r.guesses.any(
          (guess) => guess.length == 4 && guess.every(g.words.contains),
        );
        if (hit) solvedByAxis[g.tag] = (solvedByAxis[g.tag] ?? 0) + 1;
      }
    }
    return PlayStats(
      played: list.length,
      cleared: list.where((r) => r.cleared).length,
      perfect: list.where((r) => r.perfect).length,
      averageMistakes: list.isEmpty
          ? 0
          : list.fold<int>(0, (s, r) => s + r.mistakes) / list.length,
      streak: computeStreak([
        for (final r in list)
          if (r.countsForStreak) r.day,
      ], today),
      byAxis: {
        for (final t in AxisType.values)
          if (totalByAxis.containsKey(t))
            t: AxisRate(solvedByAxis[t] ?? 0, totalByAxis[t]!),
      },
    );
  }
}
