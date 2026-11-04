import 'package:flutter_test/flutter_test.dart';
import 'package:yonkumi/core/axis.dart';
import 'package:yonkumi/core/dictionary.dart';
import 'package:yonkumi/core/puzzle.dart';
import 'package:yonkumi/core/validator.dart';

import '../tool/src/files.dart';

/// 小さな辞書と問題で、検証の各項目を確かめる。
const dict = WordDictionary(
  kigo: {'金魚': '夏', '風鈴': '夏', '蛍': '夏', '夕立': '夏', '蚊': '夏'},
  counters: {
    '牛': ['頭'],
    '象': ['頭'],
    '蝶': ['頭', '匹'],
    '鯨': ['頭'],
  },
  hidden: {
    '県名': ['ちば', 'なら'],
  },
);

PuzzleGroup g(AxisType t, String v, int d, List<String> words) => PuzzleGroup(
  title: '$t$v',
  axis: AxisSpec(t, v),
  words: words,
  difficulty: d,
  note: '解説',
);

Puzzle base({
  int number = 1,
  List<PuzzleGroup>? groups,
  Map<String, String>? readings,
  List<Decoy> decoys = const [
    Decoy(word: '金魚', title: '金', axis: AxisSpec(AxisType.kanji, '金')),
  ],
}) {
  final gs =
      groups ??
      [
        g(AxisType.reading, 'はし', 1, ['橋', '箸', '端', '嘴']),
        g(AxisType.kanji, '金', 2, ['金曜', '貯金', '針金', '金庫']),
        g(AxisType.season, '夏', 3, ['金魚', '風鈴', '蛍', '夕立']),
        g(AxisType.counter, '頭', 4, ['牛', '象', '蝶', '鯨']),
      ];
  return Puzzle(
    number: number,
    groups: gs,
    decoys: decoys,
    readings:
        readings ??
              {
                '橋': 'はし',
                '箸': 'はし',
                '端': 'はし',
                '嘴': 'はし',
                '金曜': 'きんよう',
                '貯金': 'ちょきん',
                '針金': 'はりがね',
                '金庫': 'きんこ',
                '金魚': 'きんぎょ',
                '風鈴': 'ふうりん',
                '蛍': 'ほたる',
                '夕立': 'ゆうだち',
                '牛': 'うし',
                '象': 'ぞう',
                '蝶': 'ちょう',
                '鯨': 'くじら',
                '蚊': 'か',
                '金星': 'きんせい',
                'ちばなれ': 'ちばなれ',
              }
          ..removeWhere((k, _) => !gs.expand((g) => g.words).contains(k)),
  );
}

List<String> errors(Puzzle p, {List<Puzzle> previous = const []}) => [
  for (final i in const PuzzleValidator(dict).validate(p, previous: previous))
    if (i.isError) i.message,
];

PuzzleGroup replaceWord(PuzzleGroup x, String from, String to) => PuzzleGroup(
  title: x.title,
  axis: x.axis,
  words: [for (final w in x.words) w == from ? to : w],
  difficulty: x.difficulty,
  note: x.note,
);

void main() {
  test('正しい問題はエラーなし', () {
    expect(errors(base()), isEmpty);
  });

  test('16語の重複', () {
    final gs = base().groups.toList();
    gs[0] = replaceWord(gs[0], '嘴', '金庫');
    expect(errors(base(groups: gs)), contains(contains('「金庫」が2回')));
  });

  test('7文字より長い語', () {
    final gs = base().groups.toList();
    gs[0] = replaceWord(gs[0], '嘴', 'はしはしはしはし');
    final p = base(
      groups: gs,
      readings: {...base().readings, 'はしはしはしはし': 'はし'},
    );
    expect(errors(p), contains(contains('8文字')));
  });

  test('読みがない語', () {
    final r = {...base().readings}..remove('蛍');
    expect(errors(base(readings: r)), contains(contains('「蛍」の読みがありません')));
  });

  test('難易度は1〜4を1組ずつ', () {
    final gs = base().groups.toList();
    gs[3] = g(AxisType.counter, '頭', 3, ['牛', '象', '蝶', '鯨']);
    expect(errors(base(groups: gs)), contains(contains('難易度')));
  });

  test('軸にほかの語も当てはまるのに、ミスリードに書いていない', () {
    expect(
      errors(base(decoys: const [])),
      contains(contains('ほかの語も当てはまります：金魚')),
    );
  });

  test('組の語が軸に当てはまらない（辞書にない）', () {
    final gs = base().groups.toList();
    gs[2] = replaceWord(gs[2], '夕立', '氷');
    final p = base(groups: gs, readings: {...base().readings, '氷': 'こおり'});
    expect(errors(p), contains(contains('「氷」が')));
  });

  test('ミスリードに書いた語が、その軸に当てはまらない', () {
    final p = base(
      decoys: const [
        Decoy(word: '金魚', title: '金', axis: AxisSpec(AxisType.kanji, '金')),
        Decoy(word: '蛍', title: '金', axis: AxisSpec(AxisType.kanji, '金')),
      ],
    );
    expect(errors(p), contains(contains('ミスリード「蛍」')));
  });

  test('分け方が2通り以上あればエラー', () {
    // 金庫も夏の季語だとすると、金魚と金庫を入れ替えても成り立つ。
    const d2 = WordDictionary(
      kigo: {'金魚': '夏', '風鈴': '夏', '蛍': '夏', '夕立': '夏', '金庫': '夏'},
      counters: {
        '牛': ['頭'],
        '象': ['頭'],
        '蝶': ['頭'],
        '鯨': ['頭'],
      },
    );
    final p = base(
      decoys: const [
        Decoy(word: '金魚', title: '金', axis: AxisSpec(AxisType.kanji, '金')),
        Decoy(word: '金庫', title: '夏', axis: AxisSpec(AxisType.season, '夏')),
      ],
    );
    final issues = const PuzzleValidator(d2).validate(p);
    expect(
      issues.where((i) => i.isError).map((i) => i.message),
      contains('16語の分け方が2通りあります（1通りにする）'),
    );
  });

  test('過去問と同じ組・同じ軸で3語重なる', () {
    final old = base();
    final gs = base().groups.toList();
    gs[1] = replaceWord(gs[1], '金庫', '金星');
    final p = base(
      number: 2,
      groups: gs,
      readings: {...base().readings, '金星': 'きんせい'},
    );
    final e = errors(p, previous: [old]);
    expect(e, contains(contains('3語重なります')));
    expect(e, contains(contains('4語が第1問')));
  });

  group('軸の当てはまり', () {
    test('隠れた県名は読みで見る', () {
      const a = AxisSpec(AxisType.hidden, '県名');
      expect(a.matches('ちばなれ', 'ちばなれ', dict), isTrue);
      expect(a.matches('さよなら', 'さよなら', dict), isTrue);
      expect(a.matches('橋', 'はし', dict), isFalse);
    });

    test('回文は3文字以上', () {
      const a = AxisSpec(AxisType.palindrome);
      expect(a.matches('新聞紙', 'しんぶんし', dict), isTrue);
      expect(a.matches('トマト', 'とまと', dict), isTrue);
      expect(a.matches('もも', 'もも', dict), isFalse);
    });

    test('カタカナの読みはひらがなにそろえる', () {
      const a = AxisSpec(AxisType.reading, 'はし');
      expect(a.matches('ハシ', 'ハシ', dict), isTrue);
    });

    test('辞書にないリストは確かめられない', () {
      expect(
        const AxisSpec(AxisType.list, 'ない').matches('x', 'x', dict),
        isNull,
      );
      expect(const AxisSpec(AxisType.manual).checkable, isFalse);
    });
  });

  test('分け方の数を数える', () {
    final w = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h'];
    expect(countPartitions(w, [w.sublist(0, 4), w.sublist(4)]), 1);
    expect(countPartitions(w, [w, w]), greaterThan(1));
    expect(countPartitions(w, [w.sublist(0, 3), w.sublist(3)]), 0);
  });

  group('収録した問題（tool/puzzles/puzzles.json）', () {
    final paths = ToolPaths.find();
    final dictionary = loadDictionary(paths);
    final puzzles = loadPuzzles(paths.puzzles);

    test('30問以上あり、すべての検証を通る', () {
      expect(puzzles.length, greaterThanOrEqualTo(30));
      final issues = PuzzleValidator(dictionary).validateAll(puzzles);
      expect([
        for (final i in issues)
          if (i.isError) '$i',
      ], isEmpty);
    });

    test('どの問題にもミスリードがある', () {
      for (final p in puzzles) {
        expect(p.decoys, isNotEmpty, reason: '第${p.number}問');
      }
    });

    test('設計書の軸をすべて使っている', () {
      final used = {for (final p in puzzles) ...p.tags};
      for (final t in [
        AxisType.reading,
        AxisType.kanji,
        AxisType.season,
        AxisType.hidden,
        AxisType.proverb,
        AxisType.counter,
        AxisType.origin,
        AxisType.oPrefix,
      ]) {
        expect(used, contains(t));
      }
    });

    test('辞書から軸の候補が出る', () {
      final c = AxisCandidates(dictionary);
      final readings = c.generate(AxisType.reading);
      expect(readings.keys, contains(const AxisSpec(AxisType.reading, 'はし')));
      expect(
        c.generate(AxisType.season).keys,
        contains(const AxisSpec(AxisType.season, '冬')),
      );
      expect(c.axesOf('金魚'), contains(const AxisSpec(AxisType.season, '夏')));
      expect(c.axesOf('金魚'), contains(const AxisSpec(AxisType.kanji, '金')));
    });
  });
}
