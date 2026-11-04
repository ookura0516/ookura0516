import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:kipputen/core/solution_book.dart';
import 'package:kipputen/core/solutions_json.dart';
import 'package:kipputen/core/solver.dart';

import 'helpers.dart';

void main() {
  group('全解の数（設計書の期待値）', () {
    test('数字の組み合わせは715通り', () {
      expect(allCombos().length, 715);
    });

    test('715通り中552通りに解がある', () {
      expect(loadBook().solvableComboCount, 552);
    });

    test('0000〜9999のうち8,147番号に解がある', () {
      expect(loadBook().solvableNumberCount, 8147);
    });

    test('分数を経由しないと解けない組み合わせは4通り', () {
      final book = loadBook();
      expect(book.fractionOnlyCombos, ['1158', '1199', '1337', '3478']);
      expect(book.solutionsFor('5811').single.display, '8 ÷ (1 − 1 ÷ 5)');
      expect(book.needsFraction('8743'), isTrue);
      expect(book.needsFraction('5839'), isFalse);
    });
  });

  test('アセットは、いま計算し直した結果と一致する（tool/ の出力が古くない）', () {
    final fresh = encodeSolutions([for (final c in allCombos()) solveCombo(c)]);
    expect(
      File('assets/solutions.json').readAsStringSync(),
      fresh,
      reason: 'dart run tool/generate_solutions.dart で作り直してください',
    );
  });

  test('解のない番号', () {
    final book = loadBook();
    expect(book.isSolvable('0000'), isFalse);
    expect(book.isSolvable('1111'), isFalse);
    expect(book.solutionsFor('0101'), isEmpty);
    expect(book.isSolvable('1225'), isTrue);
  });

  test('並び順の違う番号は同じ全解を引く', () {
    final book = loadBook();
    expect(
      book.solutionsFor('5839').map((s) => s.key),
      book.solutionsFor('9853').map((s) => s.key),
    );
  });

  test('formatNumber', () {
    expect(formatNumber(7), '0007');
    expect(formatNumber(1234), '1234');
  });
}
