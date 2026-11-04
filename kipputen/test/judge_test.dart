import 'package:flutter_test/flutter_test.dart';
import 'package:kipputen/core/expr.dart';
import 'package:kipputen/core/judge.dart';
import 'package:kipputen/core/solution_book.dart';

import 'helpers.dart';

Judgement j(SolutionBook book, String number, String expr) =>
    judge(book, number, parse(tokenize(expr)), inputText: expr);

void main() {
  final book = loadBook();

  test('正解すると、事前計算のどの解かが決まる', () {
    final r = j(book, '1158', '8 ÷ (1 − 1 ÷ 5)');
    expect(r.verdict, Verdict.correct);
    expect(r.matchIndex, 0);
    expect(r.isNewSolution, isFalse);
  });

  test('並べ替えた書き方でも同じ解に当たる', () {
    final sols = book.solutionsFor('5839');
    final a = j(book, '5839', '5 + 8 − 9 ÷ 3');
    final b = j(book, '5839', '8 − 9 ÷ 3 + 5');
    final c = j(book, '5839', '(8 + 5) − (9 ÷ 3)');
    expect(a.matchIndex, greaterThanOrEqualTo(0));
    expect(b.matchIndex, a.matchIndex);
    expect(c.matchIndex, a.matchIndex);
    expect(a.display, sols[a.matchIndex].display);
  });

  test('すべての番号・すべての解で、数字の並びを入れ替えた式も当たる', () {
    // 各解の式の数字を、番号の並びに関係なく読み直しても当たることを確かめる。
    for (final n in ['5839', '1234', '0019', '2468', '7777', '1199']) {
      if (!book.isSolvable(n)) continue;
      final sols = book.solutionsFor(n);
      for (var i = 0; i < sols.length; i++) {
        expect(
          j(book, n, sols[i].display).matchIndex,
          i,
          reason: '$n ${sols[i].display}',
        );
      }
    }
  });

  test('10 にならない・0 で割る・数字が違う', () {
    expect(j(book, '1158', '1 + 1 + 5 + 8').verdict, Verdict.notTen);
    expect(j(book, '1158', '1 + 1 + 5 + 8').value.toString(), '15');
    expect(j(book, '1225', '5 × 2 ÷ (2 − 2)').verdict, Verdict.wrongDigits);
    expect(j(book, '1225', '1 × 2 + 2 − 5').verdict, Verdict.notTen);
    expect(j(book, '2256', '5 ÷ (2 − 2) + 6').verdict, Verdict.divByZero);
    expect(j(book, '1158', '8 + 1 + 1').verdict, Verdict.wrongDigits);
  });

  test('事前計算に当たらない正解は「新しい解」として認める', () {
    // 1158 の解を抜いた本を作る。
    final partial = SolutionBook.fromJson(
      '{"version":1,"target":10,"combos":{"1158":{"f":1,"s":[]}}}',
    );
    final r = j(partial, '1158', '8 ÷ (1 − 1 ÷ 5)');
    expect(r.isCorrect, isTrue);
    expect(r.isNewSolution, isTrue);
    expect(r.display, '8 ÷ (1 − 1 ÷ 5)');
  });
}
