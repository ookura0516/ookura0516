import 'dart:convert';

import 'package:ookura_daily/ookura_daily.dart';

import 'puzzle.dart';
import 'puzzle_cipher.dart';

/// アセット（assets/puzzles.json）の中身。1問ずつ、その問題の日付で暗号化してある。
///
/// ```json
/// {"version": 1, "firstDay": "2026-11-01", "items": {"1": "<base64>", ...}}
/// ```
class PuzzleBundle {
  PuzzleBundle({required this.clock, required Map<int, String> items})
    : _items = items;

  static const int version = 1;

  final DailyClock clock;
  final Map<int, String> _items;
  final Map<int, Puzzle> _opened = {};

  /// 収録した問題の数（番号は1からの連番）。
  int get count => _items.length;

  /// アセットの文字列を読む。第1日がアプリの [clock] と違えば
  /// （作り直し忘れ）、鍵が合わないので [FormatException]。
  factory PuzzleBundle.parse(String source, DailyClock clock) {
    final j = jsonDecode(source) as Map<String, dynamic>;
    if (j['version'] != version) {
      throw const FormatException('問題データの版が違います');
    }
    if (j['firstDay'] != clock.firstDay.toIso()) {
      throw FormatException(
        '問題データの第1日（${j['firstDay']}）がアプリ（${clock.firstDay}）と違います',
      );
    }
    final items = {
      for (final e in (j['items'] as Map<String, dynamic>).entries)
        int.parse(e.key): e.value as String,
    };
    for (var n = 1; n <= items.length; n++) {
      if (!items.containsKey(n)) throw FormatException('第$n問がありません');
    }
    return PuzzleBundle(clock: clock, items: items);
  }

  /// 問題を暗号化してアセットの文字列にする（作問 CLI が使う）。
  static String encode(List<Puzzle> puzzles, DailyClock clock) {
    final items = <String, String>{};
    for (final p in puzzles) {
      final plain = jsonEncode(p.toJson());
      items['${p.number}'] = PuzzleCipher.encrypt(
        plain,
        clock.dateOf(p.number),
      );
    }
    return const JsonEncoder.withIndent(' ').convert({
      'version': version,
      'firstDay': clock.firstDay.toIso(),
      'items': items,
    });
  }

  /// 第 [number] 問を開く。[today]（第何日か）より先の問題は開かない。
  Puzzle open(int number, {required int today}) {
    if (number > today) {
      throw StateError('第$number問はまだ公開前です');
    }
    final cached = _opened[number];
    if (cached != null) return cached;
    final cipher = _items[number];
    if (cipher == null) throw RangeError('第$number問は収録されていません');
    final plain = PuzzleCipher.decrypt(cipher, clock.dateOf(number));
    return _opened[number] = Puzzle.fromJson(
      jsonDecode(plain) as Map<String, dynamic>,
    );
  }
}
