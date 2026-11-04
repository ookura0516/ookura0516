import 'package:flutter_test/flutter_test.dart';
import 'package:kipputen/core/entry.dart';
import 'package:kipputen/core/expr.dart';
import 'package:kipputen/core/fraction.dart';

Frac? ev(String s) => parse(tokenize(s)).eval();

void main() {
  group('分数', () {
    test('約分して、符号は分子に寄せる', () {
      expect(Frac(2, 4), Frac(1, 2));
      expect(Frac(3, -6).toString(), '-1/2');
      expect(Frac(10, 1).isInteger, isTrue);
    });

    test('四則', () {
      expect(Frac(1, 3) + Frac(1, 6), Frac(1, 2));
      expect(Frac(1, 3) - Frac(1, 2), Frac(-1, 6));
      expect(Frac(2, 3) * Frac(3, 4), Frac(1, 2));
      expect(Frac(1).div(Frac(3)), Frac(1, 3));
      expect(Frac(1).div(Frac.zero), isNull);
    });

    test('浮動小数点では誤差の出る計算もぴったり', () {
      // 0.1 を10回足すと浮動小数点では 1 にならない。
      var x = Frac.zero;
      for (var i = 0; i < 10; i++) {
        x = x + Frac(1, 10);
      }
      expect(x, Frac(1));
    });
  });

  group('式の評価', () {
    test('× ÷ が先、同じ強さは左から', () {
      expect(ev('1 + 2 × 3'), Frac(7));
      expect(ev('8 − 3 − 2'), Frac(3));
      expect(ev('8 ÷ 4 ÷ 2'), Frac(1));
      expect(ev('(1 + 2) × 3'), Frac(9));
    });

    test('分数を経由して 10', () {
      expect(ev('8 ÷ (1 − 1 ÷ 5)'), Frac(10));
      expect(ev('9 × (1 + 1 ÷ 9)'), Frac(10));
      expect(ev('8 × (3 − 7 ÷ 4)'), Frac(10));
      expect(parse(tokenize('8 ÷ (1 − 1 ÷ 5)')).usesFraction(), isTrue);
      expect(parse(tokenize('(1 + 4) × 2 + 0')).usesFraction(), isFalse);
    });

    test('0 で割ると null', () {
      expect(ev('5 ÷ (2 − 2)'), isNull);
      expect(parse(tokenize('5 ÷ (2 − 2)')).usesFraction(), isNull);
    });

    test('数字の連結・単項のマイナス・閉じない括弧は読めない', () {
      expect(() => parse(tokenize('12 + 3')), throwsA(isA<ParseError>()));
      expect(() => parse(tokenize('− 3 + 13')), throwsA(isA<ParseError>()));
      expect(() => parse(tokenize('(1 + 2')), throwsA(isA<ParseError>()));
      expect(() => parse(tokenize('1 + 2)')), throwsA(isA<ParseError>()));
      expect(() => tokenize('2 ^ 3'), throwsFormatException);
    });

    test('ASCII の記号も読める', () {
      expect(ev('8/(1-1/5)'), Frac(10));
      expect(ev('2*5'), Frac(10));
    });
  });

  group('入力', () {
    test('数字の直後に数字は押せない（連結できない）', () {
      final e = Entry('1158')..addDigit(0);
      expect(e.canDigit(1), isFalse);
      e.addDigit(1);
      expect(e.tokens.length, 1);
    });

    test('最初に演算子は押せない、使った数字は押せない', () {
      final e = Entry('1158');
      expect(e.canOp, isFalse);
      e
        ..addDigit(2)
        ..addOp(Op.add);
      expect(e.canDigit(2), isFalse);
      expect(e.canDigit(0), isTrue);
    });

    test('閉じ括弧は開いている数だけ', () {
      final e = Entry('1234')
        ..open()
        ..addDigit(0);
      expect(e.canClose, isTrue);
      e.close();
      expect(e.canClose, isFalse);
    });

    test('途中結果：末尾の演算子は無視し、開いた括弧は閉じて計算', () {
      final e = Entry('1158')
        ..addDigit(3) // 8
        ..addOp(Op.div)
        ..open()
        ..addDigit(0) // 1
        ..addOp(Op.sub)
        ..addDigit(1) // 1
        ..addOp(Op.div);
      // 8 ÷ (1 − 1) → 0 で割っている
      expect(e.preview.divByZero, isTrue);
      e.addDigit(2); // 5
      expect(e.preview.value, Frac(10)); // 8 ÷ (1 − 1 ÷ 5)
      expect(e.isComplete, isFalse); // 括弧が閉じていない
      e.close();
      expect(e.isComplete, isTrue);
      expect(e.expr!.eval(), Frac(10));
      expect(e.text, '8 ÷ (1 − 1 ÷ 5)');
    });

    test('1つ消す・全部消す', () {
      final e = Entry('1234')
        ..addDigit(0)
        ..addOp(Op.add);
      e.backspace();
      expect(e.tokens.length, 1);
      e.clear();
      expect(e.isEmpty, isTrue);
      expect(e.preview.value, isNull);
    });
  });
}
