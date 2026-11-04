import 'dart:math';

import '../core/puzzle.dart';
import 'judge.dart';

/// 決定を押したときの結果。
enum SubmitResult {
  correct,

  /// 間違い。3語は同じ組だった。
  oneAway,
  wrong,

  /// 前にも同じ4語で決定した（間違いに数えない）。
  alreadyTried,
}

/// 1問を解いている途中の状態。
///
/// 決定した4語の並び（[guesses]）だけを保存すれば、いつでも同じ状態に戻せる。
class GameSession {
  GameSession(
    this.puzzle, {
    Iterable<List<String>> guesses = const [],
    int? seed,
  }) : _random = Random(seed ?? puzzle.number) {
    _board = [...puzzle.words]..shuffle(_random);
    for (final g in guesses) {
      _selected
        ..clear()
        ..addAll(g);
      submit();
    }
  }

  static const int maxMistakes = 4;

  final Puzzle puzzle;
  final Random _random;
  late List<String> _board;
  final Set<String> _selected = {};
  final List<List<String>> _guesses = [];
  final List<PuzzleGroup> _solved = [];
  int _mistakes = 0;

  /// まだ帯になっていない語（表示の順）。
  List<String> get board => List.unmodifiable(_board);

  /// 選んでいる語。
  Set<String> get selected => Set.unmodifiable(_selected);

  /// 決定した4語の並び（決定した順）。
  List<List<String>> get guesses => List.unmodifiable(_guesses);

  /// 当てた組（当てた順）。
  List<PuzzleGroup> get solved => List.unmodifiable(_solved);

  int get mistakes => _mistakes;
  int get mistakesLeft => maxMistakes - _mistakes;

  bool get cleared => _solved.length == puzzle.groups.length;
  bool get failed => _mistakes >= maxMistakes;
  bool get finished => cleared || failed;

  /// 当てられなかった組（失敗したときに答えとして見せる）。
  List<PuzzleGroup> get unsolved => [
    for (final g in puzzle.groups)
      if (!_solved.contains(g)) g,
  ];

  bool get canSubmit => !finished && _selected.length == 4;

  /// 語を選ぶ・外す。4語まで。
  void toggle(String word) {
    if (finished || !_board.contains(word)) return;
    if (!_selected.remove(word) && _selected.length < 4) _selected.add(word);
  }

  void deselectAll() => _selected.clear();

  void shuffle() => _board.shuffle(_random);

  SubmitResult submit() {
    if (!canSubmit) throw StateError('4語を選んでから決定してください');
    final picked = _board.where(_selected.contains).toList();
    final key = picked.toSet();
    if (_guesses.any((g) => g.toSet().containsAll(key))) {
      return SubmitResult.alreadyTried;
    }
    _guesses.add(picked);
    final j = judge(picked, unsolved);
    if (j.verdict == Verdict.correct) {
      _solved.add(j.group!);
      _board.removeWhere(key.contains);
      _selected.clear();
      return SubmitResult.correct;
    }
    _mistakes++;
    if (failed) _selected.clear();
    return j.verdict == Verdict.oneAway
        ? SubmitResult.oneAway
        : SubmitResult.wrong;
  }

  /// 結果グリッド：決定ごとに、4語それぞれの組の難易度（1〜4）。
  List<List<int>> get gridRows => resultGrid(puzzle, _guesses);
}

/// 決定の並びから結果グリッドを作る（記録から作り直すときにも使う）。
List<List<int>> resultGrid(Puzzle puzzle, Iterable<List<String>> guesses) => [
  for (final g in guesses) [for (final w in g) puzzle.groupOf(w).difficulty],
];
