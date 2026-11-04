import 'package:flutter_test/flutter_test.dart';
import 'package:tanzaku/core/vertical.dart';

void main() {
  List<VerticalPlacement> places(String s) => [
    for (final g in toVertical(s)) g.placement,
  ];

  test('漢字とかなは立てたまま', () {
    expect(places('古池や'), everyElement(VerticalPlacement.upright));
  });

  test('長音と括弧とダッシュは90度回す', () {
    for (final ch in [
      'ー',
      '「',
      '」',
      '『',
      '』',
      '（',
      '）',
      '(',
      ')',
      '〜',
      '～',
      '…',
      '―',
      '【',
      '】',
    ]) {
      expect(placementOf(ch), VerticalPlacement.rotate, reason: ch);
    }
    expect(places('ラーメン'), [
      VerticalPlacement.upright,
      VerticalPlacement.rotate,
      VerticalPlacement.upright,
      VerticalPlacement.upright,
    ]);
  });

  test('小書きのかなは右上に寄せる', () {
    for (final ch in ['っ', 'ゃ', 'ゅ', 'ょ', 'ぁ', 'ッ', 'ャ', 'ョ', 'ヶ', 'ㇷ']) {
      expect(placementOf(ch), VerticalPlacement.smallKana, reason: ch);
    }
    expect(places('きょう')[1], VerticalPlacement.smallKana);
  });

  test('句読点は右上に寄せる', () {
    expect(placementOf('、'), VerticalPlacement.punctuation);
    expect(placementOf('。'), VerticalPlacement.punctuation);
    expect(placementOf('，'), VerticalPlacement.punctuation);
  });

  test('英数字と絵文字は回さない', () {
    expect(places('SL3'), everyElement(VerticalPlacement.upright));
    // 肌の色付き・家族の絵文字も1文字として扱う
    final g = toVertical('👍🏽👨‍👩‍👧');
    expect(g.length, 2);
    expect(g.map((e) => e.placement), everyElement(VerticalPlacement.upright));
  });

  test('改行は並べない', () {
    expect(toVertical('あ\nい').map((g) => g.text), ['あ', 'い']);
  });

  test('変換表は約30文字の範囲に収まる', () {
    expect(rotatedChars.length, lessThan(60));
  });
}
