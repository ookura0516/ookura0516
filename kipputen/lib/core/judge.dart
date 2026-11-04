import 'canonical.dart';
import 'expr.dart';
import 'fraction.dart';
import 'solution_book.dart';
import 'solver.dart';

enum Verdict {
  /// 10 になった。
  correct,

  /// 計算はできたが 10 ではない。
  notTen,

  /// 途中で 0 で割った。
  divByZero,

  /// 切符の4つの数字をちょうど1回ずつ使っていない。
  wrongDigits,
}

class Judgement {
  const Judgement(
    this.verdict, {
    this.value,
    this.key,
    this.display,
    this.matchIndex = -1,
  });

  final Verdict verdict;
  final Frac? value;

  /// 正解のときの正規形のキー。
  final String? key;

  /// 正解のときに画面へ出す式（事前計算の書き方。新しい解ならユーザーの入力のまま）。
  final String? display;

  /// 事前計算の何番目の解か。新しい解なら -1。
  final int matchIndex;

  bool get isCorrect => verdict == Verdict.correct;

  /// 正解だが、事前計算のどの解にも当たらなかった（正規化の取りこぼし）。
  bool get isNewSolution => isCorrect && matchIndex < 0;
}

/// [e] が [number] の正解かを分数で判定し、事前計算のどの解かを決める。
Judgement judge(SolutionBook book, String number, Expr e, {String? inputText}) {
  final want = number.split('').map(int.parse).toList()..sort();
  final got = [...e.digits]..sort();
  if (want.join() != got.join()) return const Judgement(Verdict.wrongDigits);

  final v = e.eval();
  if (v == null) return const Judgement(Verdict.divByZero);
  if (v != Frac(target)) return Judgement(Verdict.notTen, value: v);

  final key = canonicalKey(e);
  final idx = book.matchIndex(number, e);
  return Judgement(
    Verdict.correct,
    value: v,
    key: key,
    display: idx >= 0
        ? book.solutionsFor(number)[idx].display
        : (inputText ?? '$e'),
    matchIndex: idx,
  );
}
