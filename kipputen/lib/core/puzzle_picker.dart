import 'dart:convert';

import '../daily/day.dart';
import '../daily/seeded_random.dart';
import 'difficulty.dart';
import 'solution_book.dart';
import 'solver.dart';

/// その日の切符。
class DailyPuzzle {
  const DailyPuzzle({
    required this.day,
    required this.number,
    required this.serial,
    required this.band,
    this.anniversary,
  });

  final Day day;

  /// 4桁の番号（「5839」）。
  final String number;

  /// 通し番号（初日が 1）。切符の「No.」欄。
  final int serial;

  final Band band;

  /// 記念日の名前（「元日」など）。ふつうの日は null。
  final String? anniversary;
}

/// 記念日の固定出題の表（assets/anniversaries.json）。
class AnniversaryTable {
  const AnniversaryTable(this._entries);

  factory AnniversaryTable.fromJson(String json) {
    final m = jsonDecode(json) as Map<String, dynamic>;
    return AnniversaryTable({
      for (final e in m.entries)
        if (!e.key.startsWith('_'))
          e.key: (
            name: (e.value as Map)['name'] as String,
            number: (e.value as Map)['number'] as String,
          ),
    });
  }

  static const assetPath = 'assets/anniversaries.json';
  static const empty = AnniversaryTable({});

  final Map<String, ({String name, String number})> _entries;

  /// [day] が記念日なら（名前, 番号）。番号は "year" を西暦に置き換えたもの。
  ({String name, String number})? lookup(Day day) {
    final e = _entries[day.mmdd];
    if (e == null) return null;
    final n = e.number == 'year'
        ? (day.year % 10000).toString().padLeft(4, '0')
        : e.number;
    return (name: e.name, number: n);
  }
}

/// 日付から、その日の番号を決める。サーバーを使わず、どの端末でも同じ結果になる。
///
/// - 曜日で難易度帯を選び（[Band.forWeekday]）、帯の中から日付を種にした乱数で選ぶ
/// - 過去365日に出た番号は避ける。そのため [epoch] から1日ずつ順に決めていく
///   （決めた結果は覚えておくので、2回目からは速い）
/// - なるべく、同じ数字の組み合わせ（7168 と 6781 など）も [comboGapDays] 日は空ける
///   （分数の難問は4組み合わせしかないので、空けられないときは空けない）
/// - 記念日は表の番号に固定する（解がある場合だけ）
class PuzzlePicker {
  PuzzlePicker(
    this.book, {
    this.anniversaries = AnniversaryTable.empty,
    Day? epoch,
  }) : epoch = epoch ?? defaultEpoch {
    for (final n in book.solvableNumbers) {
      (_bands[Band.of(book, n)] ??= []).add(n);
    }
  }

  /// 通し番号 No.1 の日。これより前の日を聞かれたら、この日として扱う。
  static final Day defaultEpoch = Day(2026, 11, 1);

  /// 同じ番号を出さない期間（日）。
  static const noRepeatDays = 365;

  /// 同じ組み合わせをなるべく出さない期間（日）。
  static const comboGapDays = 30;

  static const _salt = 'kipputen:v1:';

  final SolutionBook book;
  final AnniversaryTable anniversaries;
  final Day epoch;

  final Map<Band, List<String>> _bands = {};
  final List<DailyPuzzle> _history = [];
  final Map<String, int> _lastUsed = {};
  final Map<String, int> _lastCombo = {};

  List<String> numbersIn(Band band) => List.unmodifiable(_bands[band] ?? []);

  DailyPuzzle forDay(Day day) {
    if (day < epoch) day = epoch;
    final index = day.daysSince(epoch);
    while (_history.length <= index) {
      _history.add(_pick(epoch.addDays(_history.length), _history.length));
    }
    return _history[index];
  }

  DailyPuzzle _pick(Day day, int index) {
    final serial = index + 1;
    final anni = anniversaries.lookup(day);
    if (anni != null && book.isSolvable(anni.number)) {
      return _use(
        DailyPuzzle(
          day: day,
          number: anni.number,
          serial: serial,
          band: Band.of(book, anni.number),
          anniversary: anni.name,
        ),
        index,
      );
    }

    final rng = SeededRandom.fromString('$_salt${day.key}');
    final want = Band.forWeekday(day.weekday);
    for (final band in [want, ...want.fallbacks]) {
      final pool = _bands[band] ?? const [];
      if (pool.isEmpty) continue;
      // 乱数で始点と歩幅を決め、まだ出ていない番号が見つかるまで歩く。
      // 歩幅を帯の大きさと互いに素にすると、帯の全部をちょうど1回ずつ見る。
      final start = rng.nextInt(pool.length);
      var step = 1 + rng.nextInt(pool.length);
      while (_gcd(step, pool.length) != 1) {
        step = step % pool.length + 1;
      }
      for (final spreadCombos in [true, false]) {
        for (var k = 0; k < pool.length; k++) {
          final n = pool[(start + k * step) % pool.length];
          if (_recentlyUsed(n, index)) continue;
          if (spreadCombos && _comboRecentlyUsed(n, index)) continue;
          return _use(
            DailyPuzzle(day: day, number: n, serial: serial, band: band),
            index,
          );
        }
      }
    }
    // ここには来ない（帯の合計 8,147 番号 > 365）。
    throw StateError('出題できる番号がない: $day');
  }

  bool _recentlyUsed(String n, int index) {
    final last = _lastUsed[n];
    return last != null && index - last <= noRepeatDays;
  }

  bool _comboRecentlyUsed(String n, int index) {
    final last = _lastCombo[comboKeyOf(n)];
    return last != null && index - last < comboGapDays;
  }

  DailyPuzzle _use(DailyPuzzle p, int index) {
    _lastUsed[p.number] = index;
    _lastCombo[comboKeyOf(p.number)] = index;
    return p;
  }

  static int _gcd(int a, int b) => b == 0 ? a : _gcd(b, a % b);
}
