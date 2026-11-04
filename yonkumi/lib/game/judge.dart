import '../core/puzzle.dart';

/// 選んだ4語の判定。
enum Verdict {
  /// どれかの組とぴったり同じ。
  correct,

  /// 3語が同じ組（「あと1つ」）。
  oneAway,

  /// それ以外。
  wrong,
}

class Judgement {
  const Judgement(this.verdict, [this.group]);

  final Verdict verdict;

  /// 正解した組。
  final PuzzleGroup? group;
}

/// [picked]（4語）を [candidates]（まだ当てていない組）と比べる。
Judgement judge(Iterable<String> picked, Iterable<PuzzleGroup> candidates) {
  final set = picked.toSet();
  if (set.length != 4) {
    throw ArgumentError('4語を選んでください（${set.length}語）');
  }
  var best = 0;
  for (final g in candidates) {
    final hit = g.words.where(set.contains).length;
    if (hit == 4) return Judgement(Verdict.correct, g);
    if (hit > best) best = hit;
  }
  return Judgement(best == 3 ? Verdict.oneAway : Verdict.wrong);
}
