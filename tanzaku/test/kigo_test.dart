import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:tanzaku/core/kana.dart';
import 'package:tanzaku/core/kigo.dart';
import 'package:tanzaku/core/season.dart';

import 'helpers.dart';

void main() {
  group('歳時記データ', () {
    final entries = dictionary.entries;

    test('150語あり、id と語が重ならない', () {
      expect(entries.length, 150);
      expect(entries.map((k) => k.id).toSet().length, entries.length);
      expect(entries.map((k) => k.word).toSet().length, entries.length);
    });

    test('すべての季節がある', () {
      expect(entries.map((k) => k.season).toSet(), Season.values.toSet());
    });

    test('項目がそろっている', () {
      for (final k in entries) {
        expect(kigoCategories, contains(k.category), reason: k.word);
        expect(k.reading, isNotEmpty, reason: k.word);
        expect(
          k.reading.runes.every((c) => isHiragana(c) || c == 0x30FC),
          isTrue,
          reason: '読みはひらがな: ${k.word}',
        );
        expect(k.description, isNotEmpty, reason: k.word);
        expect(
          k.description.length,
          lessThanOrEqualTo(80),
          reason: '説明は短く: ${k.word}',
        );
        expect(k.period, isNotEmpty);
        expect(
          k.aliases.every((a) => a.isNotEmpty && a != k.word),
          isTrue,
          reason: k.word,
        );
      }
    });

    test('例句は芭蕉・蕪村・一茶・子規だけ', () {
      const allowed = {'松尾芭蕉', '与謝蕪村', '小林一茶', '正岡子規'};
      final examples = entries.expand((k) => k.examples).toList();
      expect(examples, isNotEmpty);
      for (final e in examples) {
        expect(allowed, contains(e.author), reason: e.text);
      }
    });

    test('例句は、その季語1つだけが見つかる（季重なりにならない）', () {
      for (final k in entries) {
        for (final e in k.examples) {
          final d = dictionary.detect(e.text);
          expect(d.primary?.id, k.id, reason: '${e.text} → ${d.kigo}');
          expect(d.kigasanari, isFalse, reason: '${e.text} → ${d.kigo}');
        }
      }
    });

    test('JSON の形は600語まで増やせる（id は数、季節・時期は文字列）', () {
      final data = jsonDecode(kigoJson) as Map<String, Object?>;
      expect(data['schema'], 1);
      expect(data['version'], isA<int>());
      // 600語に増やしても読めることを確かめる。
      final list = data['kigo'] as List;
      final big = [
        for (var i = 0; i < 600; i++)
          {...(list[i % list.length] as Map), 'id': i + 1, 'word': '語$i'},
      ];
      final d = KigoDictionary.fromJsonString(
        jsonEncode({...data, 'kigo': big}),
      );
      expect(d.entries.length, 600);
    });

    test('JSON に書き戻しても同じ', () {
      for (final k in entries) {
        final again = Kigo.fromJson(
          jsonDecode(jsonEncode(k.toJson())) as Map<String, Object?>,
        );
        expect(again.toJson(), k.toJson());
      }
    });
  });

  group('季語の検出', () {
    test('古池や蛙飛びこむ水の音 → 蛙（春）', () {
      final d = dictionary.detect('古池や\n蛙飛びこむ\n水の音');
      expect(d.kigo.map((k) => k.word), ['蛙']);
      expect(d.primary!.season, Season.spring);
      expect(d.kigasanari, isFalse);
    });

    test('最長一致：名月は月より優先', () {
      final d = dictionary.detect('名月や池をめぐりて夜もすがら');
      expect(d.kigo.map((k) => k.word), ['名月']);
    });

    test('最長一致：秋の暮は秋より優先、春の海は春より優先', () {
      expect(dictionary.detect('此道や行人なしに秋の暮').kigo.single.word, '秋の暮');
      expect(dictionary.detect('春の海終日のたりのたり哉').kigo.single.word, '春の海');
    });

    test('別表記とかな書きで見つかる', () {
      expect(dictionary.detect('こがらしや').primary!.word, '木枯');
      expect(dictionary.detect('凩の果てはありけり').primary!.word, '木枯');
      expect(dictionary.detect('ほととぎす鳴く').primary!.word, '時鳥');
    });

    test('行をまたいでも見つかる', () {
      final d = dictionary.detect('朝の\n雪\n解の音');
      expect(d.primary!.word, '雪解');
    });

    test('季語が2つなら季重なり', () {
      final d = dictionary.detect('菜の花や\n月は東に\n日は西に');
      expect(d.kigo.map((k) => k.word), ['菜の花', '月']);
      expect(d.kigasanari, isTrue);
    });

    test('同じ季語が2回でも季重なりではない', () {
      final d = dictionary.detect('雪の朝雪の夕べの雪のこと');
      expect(d.hits.length, 3);
      expect(d.kigasanari, isFalse);
    });

    test('季語がなければ空（無季）', () {
      final d = dictionary.detect('電車の窓に映る顔');
      expect(d.isEmpty, isTrue);
      expect(d.primary, isNull);
    });

    test('位置は元の文字列の位置', () {
      const text = '古池や\n蛙飛びこむ';
      final h = dictionary.detect(text).hits.single;
      expect(text.substring(h.start, h.end), '蛙');
    });
  });

  group('検索', () {
    test('読みで前方一致', () {
      expect(dictionary.search('こが').first.word, '木枯');
    });
    test('季節で絞る', () {
      final r = dictionary.search('', season: Season.newYear);
      expect(r, isNotEmpty);
      expect(r.every((k) => k.season == Season.newYear), isTrue);
    });
    test('カタカナでもひらがなの読みに当たる', () {
      expect(dictionary.search('ユキ').map((k) => k.word), contains('雪'));
    });
  });
}
