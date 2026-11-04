import 'axis.dart';

/// 1組（4語）。
class PuzzleGroup {
  const PuzzleGroup({
    required this.title,
    required this.axis,
    required this.words,
    required this.difficulty,
    required this.note,
  });

  /// 軸の名前。正解したとき帯に出す（例：「「はし」と読む」）。
  final String title;

  /// 仕分けの軸。作問の検証と、成績の軸別集計に使う。
  final AxisSpec axis;

  final List<String> words;

  /// 1（やさしい）〜4（むずかしい）。帯の色になる。
  final int difficulty;

  /// 解説1行。
  final String note;

  /// 成績の軸別集計に使う種類。
  AxisType get tag => axis.type;

  factory PuzzleGroup.fromJson(Map<String, dynamic> j) => PuzzleGroup(
    title: j['title'] as String,
    axis: AxisSpec.fromJson(j['axis'] as Map<String, dynamic>),
    words: List<String>.from(j['words'] as List),
    difficulty: j['difficulty'] as int,
    note: j['note'] as String? ?? '',
  );

  Map<String, dynamic> toJson() => {
    'title': title,
    'axis': axis.toJson(),
    'words': words,
    'difficulty': difficulty,
    'note': note,
  };
}

/// ミスリード：別の組の軸にも当てはまる語（解説に出す）。
class Decoy {
  const Decoy({required this.word, required this.title, required this.axis});

  final String word;

  /// 何に見えるか（例：「夏の季語」）。
  final String title;

  /// 当てはまる軸。組の軸と同じなら、その組の「ちょうど4語」の数から外す。
  final AxisSpec axis;

  factory Decoy.fromJson(Map<String, dynamic> j) => Decoy(
    word: j['word'] as String,
    title: j['title'] as String,
    axis: AxisSpec.fromJson(j['axis'] as Map<String, dynamic>),
  );

  Map<String, dynamic> toJson() => {
    'word': word,
    'title': title,
    'axis': axis.toJson(),
  };
}

/// 1問。
class Puzzle {
  const Puzzle({
    required this.number,
    required this.groups,
    required this.readings,
    this.decoys = const [],
  });

  /// 通し番号。チュートリアルは 0。
  final int number;

  /// 難易度の順（1〜4）に並べておく。
  final List<PuzzleGroup> groups;

  /// 16語すべての読み（ひらがな）。同じ読み・隠れた語の判定に使う。
  final Map<String, String> readings;

  final List<Decoy> decoys;

  /// 16語（組の順）。
  List<String> get words => [for (final g in groups) ...g.words];

  /// [word] の入っている組。
  PuzzleGroup groupOf(String word) =>
      groups.firstWhere((g) => g.words.contains(word));

  /// 軸の種類（成績の軸別分析用）。
  List<AxisType> get tags => [for (final g in groups) g.tag];

  factory Puzzle.fromJson(Map<String, dynamic> j) {
    final groups = [
      for (final g in j['groups'] as List)
        PuzzleGroup.fromJson(g as Map<String, dynamic>),
    ]..sort((a, b) => a.difficulty.compareTo(b.difficulty));
    return Puzzle(
      number: j['number'] as int,
      groups: groups,
      readings: Map<String, String>.from(j['readings'] as Map? ?? const {}),
      decoys: [
        for (final d in j['decoys'] as List? ?? const [])
          Decoy.fromJson(d as Map<String, dynamic>),
      ],
    );
  }

  Map<String, dynamic> toJson() => {
    'number': number,
    'groups': [for (final g in groups) g.toJson()],
    'readings': readings,
    'decoys': [for (final d in decoys) d.toJson()],
    'tags': [for (final t in tags) t.name],
  };
}
