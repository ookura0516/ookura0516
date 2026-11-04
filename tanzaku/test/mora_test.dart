import 'package:flutter_test/flutter_test.dart';
import 'package:tanzaku/core/mora.dart';

import 'helpers.dart';

void main() {
  group('かなのモーラ', () {
    test('拗音は1つ', () {
      expect(kanaMora('きょう'), 2);
      expect(kanaMora('しゃしん'), 3);
      expect(kanaMora('チョコ'), 2);
    });
    test('促音・長音・撥音も1つ', () {
      expect(kanaMora('がっこう'), 4);
      expect(kanaMora('ラーメン'), 4);
      expect(kanaMora('コーヒー'), 4);
      expect(kanaMora('さんぽ'), 3);
    });
    test('記号は数えない', () {
      expect(kanaMora('ア・イ'), 2);
    });
  });

  group('句の音数', () {
    final c = moraCounter;
    test('ひらがなだけの句', () {
      expect(c.countLines(['ふるいけや', 'かわずとびこむ', 'みずのおと']).map((m) => m.count), [
        5,
        7,
        5,
      ]);
      expect(c.count('ふるいけや').estimated, isFalse);
    });

    test('辞書の読みがある漢字はその読みで数える', () {
      final m = c.countLines(['古池や', '蛙飛びこむ', '水の音']);
      expect(m.map((e) => e.count), [5, 7, 5]);
      expect(m.every((e) => !e.estimated), isTrue);
    });

    test('季語の読みを使う（木枯＝こがらし）', () {
      final m = c.count('木枯や');
      expect(m.count, 5);
      expect(m.estimated, isFalse);
    });

    test('読みの分からない漢字は1字2音の目安', () {
      final m = c.count('鬱々と');
      expect(m.count, 5); // 鬱2 + 々2 + と1
      expect(m.estimated, isTrue);
      expect(m.label, '約5音');
    });

    test('英数字は1字1音の目安、記号と絵文字は数えない', () {
      final m = c.count('SL走る🚂、');
      expect(m.estimated, isTrue);
      expect(m.count, 2 + 2 + 1);
    });

    test('空でもエラーにしない', () {
      expect(c.count('').count, 0);
      expect(c.count('　 ').count, 0);
    });

    test('字余り・字足らずは目安として言う', () {
      expect(moraNote(c.countLines(['ふるいけや', 'かわずとびこむ', 'みずのおと'])), '五七五');
      expect(
        moraNote(c.countLines(['ふるいけやああ', 'かわずとびこむ', 'みずのおと'])),
        '字余り（目安）',
      );
      expect(moraNote(c.countLines(['ふるいけ', 'かわずとびこむ', 'みずのおと'])), '字足らず（目安）');
      expect(moraNote(c.countLines(['', '', ''])), '');
    });
  });
}
