import 'package:flutter_test/flutter_test.dart';
import 'package:keshiin/core/banned_words.dart';
import 'package:keshiin/core/frames.dart';
import 'package:keshiin/core/places.dart';

import 'fakes.dart';

void main() {
  group('シート名の禁止語', () {
    for (final ng in [
      'NIPPON',
      'nippon 2026',
      'Ｎｉｐｐｏｎ',
      'N I P P O N',
      'N.I.P.P.O.N',
      'ニッポンの夏',
      '日本郵便',
      '郵便',
      '郵便切手',
      'ゆうびん',
      'ﾕｳﾋﾞﾝ',
      'JAPAN POST',
      'POSTAGE',
      '〒',
      '¥84',
      '￥120',
      r'$1',
      '€2',
      '84円',
      '１２０円',
      '百円',
      '84yen',
      '120 JPY',
    ]) {
      test('弾く：$ng', () => expect(checkSheetTitle(ng).ok, isFalse));
    }

    for (final ok in [
      '2026 日常',
      '旅の記録',
      '円山公園',
      '元町',
      '秋の京都',
      '',
      'おうち',
      'Japan trip',
    ]) {
      test('通す：「$ok」', () => expect(checkSheetTitle(ok).ok, isTrue));
    }

    test('理由を返す', () {
      expect(checkSheetTitle('NIPPON').reason, contains('NIPPON'));
      expect(checkSheetTitle('¥').reason, contains('通貨記号'));
    });
  });

  group('消印の場所', () {
    test('「○○郵便局」の形は使えない', () {
      expect(checkPostmarkPlace('中央郵便局').ok, isFalse);
      expect(checkPostmarkPlace('東京中央局').ok, isFalse);
      expect(checkPostmarkPlace('札幌市中央区').ok, isTrue);
      expect(checkPostmarkPlace('家').ok, isTrue);
      expect(checkPostmarkPlace('Paris').ok, isTrue);
    });

    test('一言にも禁止語', () {
      expect(checkPostmarkNote('NIPPON').ok, isFalse);
      expect(checkPostmarkNote('いい天気').ok, isTrue);
    });
  });

  test('内蔵の市区町村名・フレーム名・書体名に禁止語は無く、「○○局」の形もない', () {
    final idx = loadMunicipalities();
    for (final m in idx.items) {
      expect(
        checkPostmarkPlace(postmarkPlaceName(m)).ok,
        isTrue,
        reason: m.city,
      );
    }
    for (final f in allFrames) {
      expect(checkSheetTitle(f.name).ok, isTrue, reason: f.name);
    }
    for (final f in postmarkFonts) {
      expect(checkSheetTitle(f.name).ok, isTrue, reason: f.name);
    }
  });
}
