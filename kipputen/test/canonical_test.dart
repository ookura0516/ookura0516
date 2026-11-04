import 'package:flutter_test/flutter_test.dart';
import 'package:kipputen/core/canonical.dart';
import 'package:kipputen/core/expr.dart';

import 'helpers.dart';

String key(String s) => canonicalKey(parse(tokenize(s)));

void main() {
  group('正規化：交換法則と結合法則で同じ式は1つ', () {
    test('交換法則', () {
      expect(key('3 + 7'), key('7 + 3'));
      expect(key('2 × 5'), key('5 × 2'));
      expect(key('(1 + 4) × 2'), key('2 × (4 + 1)'));
    });

    test('結合法則', () {
      expect(key('(1 + 2) + 7'), key('1 + (2 + 7)'));
      expect(key('(1 × 2) × 5'), key('1 × (2 × 5)'));
    });

    test('引き算・割り算の連なりも並べ替える', () {
      expect(key('9 − (3 − 4)'), key('9 + 4 − 3'));
      expect(key('9 − 3 + 4'), key('9 + 4 − 3'));
      expect(key('8 ÷ (4 ÷ 5)'), key('8 × 5 ÷ 4'));
      expect(key('8 ÷ 4 × 5'), key('5 × 8 ÷ 4'));
      expect(key('(9 − 1) − 3'), key('9 − (1 + 3)'));
    });

    test('分配法則ではまとめない（別の解）', () {
      expect(key('2 × (3 + 2)'), isNot(key('2 × 3 + 2 × 2')));
      expect(key('2 × (5 − 1) + 2'), isNot(key('2 × (5 + 1) − 2')));
    });

    test('値が同じでも形が違えば別', () {
      expect(key('5 × 2 + 0'), isNot(key('5 × 2 − 0')));
      expect(key('9 + 1 + 0 × 0'), isNot(key('9 + 1 + 0 + 0')));
    });
  });

  test('事前計算の式を読み直すと、同じ正規形・同じ表示に戻る', () {
    final book = loadBook();
    for (final n in book.solvableNumbers.where((n) => n == comboOrder(n))) {
      for (final s in book.solutionsFor(n)) {
        final e = parse(tokenize(s.display));
        expect(e.eval()!.toString(), '10', reason: s.display);
        expect(canonicalKey(e), s.key, reason: s.display);
        expect(render(canonicalize(e)), s.display, reason: s.display);
      }
    }
  });

  test('事前計算の同じ組み合わせの中に、同じ正規形は2つない', () {
    final book = loadBook();
    for (final n in book.solvableNumbers.where((n) => n == comboOrder(n))) {
      final keys = book.solutionsFor(n).map((s) => s.key).toList();
      expect(keys.toSet().length, keys.length, reason: n);
    }
  });
}

String comboOrder(String n) => (n.split('')..sort()).join();
