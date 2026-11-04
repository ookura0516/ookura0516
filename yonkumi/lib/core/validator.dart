import 'axis.dart';
import 'dictionary.dart';
import 'kana.dart';
import 'puzzle.dart';

/// タイルに出せる最大の文字数。
const int kMaxWordLength = 7;

enum IssueLevel { error, warning }

/// 検証で見つかったこと。
class Issue {
  const Issue(this.level, this.puzzle, this.message);

  final IssueLevel level;

  /// 問題の番号。
  final int puzzle;
  final String message;

  bool get isError => level == IssueLevel.error;

  @override
  String toString() => '${isError ? 'エラー' : '注意'} 第$puzzle問: $message';
}

/// 作問の自動検証。
///
/// - 16語に重複がない、各組4語、難易度は1〜4が1組ずつ
/// - 各語は7文字以下、16語すべてに読みがある
/// - 各組の軸に当てはまる語が、ミスリード（decoys）を除いてちょうど4語
/// - 16語を4組に分ける分け方が1通りしかない
/// - 過去問と同じ軸で同じ語の組（3語以上の重なり）がない
class PuzzleValidator {
  const PuzzleValidator(this.dict);

  final WordDictionary dict;

  /// 1問を調べる。[previous] はそれより前の問題。
  List<Issue> validate(Puzzle p, {List<Puzzle> previous = const []}) {
    final issues = <Issue>[];
    void error(String m) => issues.add(Issue(IssueLevel.error, p.number, m));
    void warn(String m) => issues.add(Issue(IssueLevel.warning, p.number, m));

    // 形
    if (p.groups.length != 4) error('組が${p.groups.length}つあります（4つにする）');
    for (final g in p.groups) {
      if (g.words.length != 4) {
        error('「${g.title}」の語が${g.words.length}つです（4つにする）');
      }
      if (g.title.trim().isEmpty) error('軸の名前が空の組があります');
      if (g.note.trim().isEmpty) warn('「${g.title}」に解説がありません');
    }
    final diffs = [for (final g in p.groups) g.difficulty]..sort();
    if (diffs.join(',') != '1,2,3,4') {
      error('難易度は1〜4を1組ずつにする（いまは ${diffs.join(',')}）');
    }

    // 語
    final words = p.words;
    final seen = <String>{};
    for (final w in words) {
      if (!seen.add(w)) error('「$w」が2回出てきます');
      if (w.trim().isEmpty) error('空の語があります');
      if (displayLength(w) > kMaxWordLength) {
        error('「$w」は${displayLength(w)}文字です（$kMaxWordLength文字以下にする）');
      }
      final r = p.readings[w];
      if (r == null || r.isEmpty) {
        error('「$w」の読みがありません');
      } else if (!RegExp(r'^[ぁ-ゖー]+$').hasMatch(r)) {
        error('「$w」の読み「$r」はひらがなで書く');
      } else {
        final known = dict.readings[w];
        if (known != null && known != r) {
          warn('「$w」の読み「$r」が辞書（$known）と違います');
        }
      }
    }
    for (final w in p.readings.keys) {
      if (!seen.contains(w)) warn('読みだけあって問題にない語「$w」');
    }

    // ミスリード
    for (final d in p.decoys) {
      if (!seen.contains(d.word)) {
        error('ミスリード「${d.word}」が16語にありません');
        continue;
      }
      final m = d.axis.matches(d.word, p.readings[d.word] ?? '', dict);
      if (m == false) error('ミスリード「${d.word}」は「${d.title}」に当てはまりません');
      if (p.groupOf(d.word).axis == d.axis) {
        error('ミスリード「${d.word}」は自分の組の軸です');
      }
    }

    // 各軸に当てはまる語がちょうど4つ
    final candidates = <List<String>>[];
    for (final g in p.groups) {
      if (!g.axis.checkable) {
        warn('「${g.title}」は自動で確かめられない軸です（人が確かめる）');
        candidates.add(g.words);
        continue;
      }
      final hits = <String>[];
      var unknown = false;
      for (final w in words) {
        final m = g.axis.matches(w, p.readings[w] ?? '', dict);
        if (m == null) unknown = true;
        if (m == true) hits.add(w);
      }
      if (unknown) {
        error('「${g.title}」の軸 ${g.axis} を辞書で引けません');
        candidates.add(g.words);
        continue;
      }
      for (final w in g.words) {
        if (!hits.contains(w)) {
          error('「$w」が「${g.title}」（${g.axis}）に当てはまりません。辞書に足すか、軸を見直す');
        }
      }
      final declared = {
        for (final d in p.decoys)
          if (d.axis == g.axis) d.word,
      };
      final extra = [
        for (final w in hits)
          if (!g.words.contains(w) && !declared.contains(w)) w,
      ];
      if (extra.isNotEmpty) {
        error(
          '「${g.title}」にほかの語も当てはまります：${extra.join('・')}'
          '（ミスリードなら decoys に書く）',
        );
      }
      candidates.add(hits);
    }

    // 分け方は1通りだけ
    if (p.groups.length == 4 && issues.every((i) => !i.isError)) {
      final n = countPartitions(words, candidates);
      if (n != 1) error('16語の分け方が$n通りあります（1通りにする）');
    }

    // 過去問との重複
    for (final old in previous) {
      for (final g in p.groups) {
        for (final og in old.groups) {
          final shared = g.words.where(og.words.contains).length;
          if (shared == 4) {
            error('「${g.title}」の4語が第${old.number}問「${og.title}」と同じです');
          } else if (shared >= 3 && g.axis == og.axis) {
            error('「${g.title}」が第${old.number}問と同じ軸で$shared語重なります');
          }
        }
      }
      final oldWords = old.words.toSet();
      final overlap = words.where(oldWords.contains).length;
      if (overlap >= 8) warn('第${old.number}問と$overlap語が同じです');
    }
    return issues;
  }

  /// 問題の並び全体を調べる。番号は1からの連番にする。
  List<Issue> validateAll(List<Puzzle> puzzles) {
    final issues = <Issue>[];
    for (var i = 0; i < puzzles.length; i++) {
      final p = puzzles[i];
      if (p.number != i + 1) {
        issues.add(
          Issue(IssueLevel.error, p.number, '番号が飛んでいます（${i + 1} のはず）'),
        );
      }
      issues.addAll(validate(p, previous: puzzles.sublist(0, i)));
    }
    return issues;
  }
}

/// [words] を、[candidates]（組ごとに当てはまる語の候補）から4語ずつ選んで
/// 分ける分け方の数。2 を超えたら数えるのをやめる。
int countPartitions(List<String> words, List<List<String>> candidates) {
  final all = words.toSet();
  var count = 0;
  void go(int i, Set<String> used) {
    if (count > 2) return;
    if (i == candidates.length) {
      if (used.length == all.length) count++;
      return;
    }
    final pool = [
      for (final w in candidates[i])
        if (!used.contains(w)) w,
    ];
    for (final combo in _combinations(pool, 4)) {
      go(i + 1, {...used, ...combo});
    }
  }

  go(0, {});
  return count;
}

Iterable<List<T>> _combinations<T>(List<T> items, int k) sync* {
  if (k == 0) {
    yield [];
    return;
  }
  for (var i = 0; i <= items.length - k; i++) {
    for (final rest in _combinations(items.sublist(i + 1), k - 1)) {
      yield [items[i], ...rest];
    }
  }
}

/// 辞書の語から、軸の候補（当てはまる語が4つ以上ある軸）を出す。
class AxisCandidates {
  const AxisCandidates(this.dict);

  final WordDictionary dict;

  /// 軸 → 当てはまる語。[minSize] 語以上のものだけ。
  Map<AxisSpec, List<String>> generate(AxisType type, {int minSize = 4}) {
    final out = <AxisSpec, List<String>>{};
    void add(AxisSpec a, String w) => (out[a] ??= []).add(w);
    switch (type) {
      case AxisType.reading:
        for (final e in dict.readings.entries) {
          add(AxisSpec(type, e.value), e.key);
        }
      case AxisType.kanji:
        for (final w in dict.readings.keys) {
          for (final c in w.runes.toSet()) {
            final ch = String.fromCharCode(c);
            if (RegExp(r'^[一-龯々]$').hasMatch(ch)) add(AxisSpec(type, ch), w);
          }
        }
      case AxisType.season:
        for (final e in dict.kigo.entries) {
          add(AxisSpec(type, e.value), e.key);
        }
      case AxisType.counter:
        for (final e in dict.counters.entries) {
          for (final c in e.value) {
            add(AxisSpec(type, c), e.key);
          }
        }
      case AxisType.origin:
        for (final e in dict.origins.entries) {
          add(AxisSpec(type, e.value), e.key);
        }
      case AxisType.hidden:
        for (final list in dict.hidden.entries) {
          for (final e in dict.readings.entries) {
            if (list.value.any((h) => e.value.contains(h) && e.value != h)) {
              add(AxisSpec(type, list.key), e.key);
            }
          }
        }
      case AxisType.proverb:
        for (final p in dict.proverbs) {
          add(AxisSpec(AxisType.proverb, p.theme), p.answer);
        }
      case AxisType.oPrefix:
        for (final w in dict.oWords) {
          add(const AxisSpec(AxisType.oPrefix), w);
        }
      case AxisType.palindrome:
        const a = AxisSpec(AxisType.palindrome);
        for (final e in dict.readings.entries) {
          if (a.matches(e.key, e.value, dict) == true) add(a, e.key);
        }
      case AxisType.list:
        for (final e in dict.lists.entries) {
          for (final w in e.value) {
            add(AxisSpec(type, e.key), w);
          }
        }
      case AxisType.manual:
        break;
    }
    out.removeWhere((_, v) => v.toSet().length < minSize);
    return {for (final e in out.entries) e.key: e.value.toSet().toList()};
  }

  /// [word] が当てはまる軸をすべて（ミスリードを組むとき用）。
  List<AxisSpec> axesOf(String word) {
    final reading = dict.readings[word] ?? '';
    final out = <AxisSpec>[];
    for (final t in AxisType.values) {
      for (final a in generate(t, minSize: 1).keys) {
        if (a.matches(word, reading, dict) == true) out.add(a);
      }
    }
    return out;
  }
}
