import 'package:flutter_test/flutter_test.dart';
import 'package:kipputen/core/difficulty.dart';
import 'package:kipputen/core/puzzle_picker.dart';
import 'package:kipputen/daily/daily.dart';

import 'helpers.dart';

void main() {
  final book = loadBook();
  PuzzlePicker picker() =>
      PuzzlePicker(book, anniversaries: loadAnniversaries());

  test('乱数は決定的（実装が変わったら気づけるよう値を固定）', () {
    final r = SeededRandom.fromString('kipputen:v1:20261104');
    final a = [for (var i = 0; i < 3; i++) r.nextUint32()];
    final r2 = SeededRandom.fromString('kipputen:v1:20261104');
    expect([for (var i = 0; i < 3; i++) r2.nextUint32()], a);
    // mulberry32 の参照実装（JavaScript）で種 1 の最初の値は 0.6270739405881613 = 2693262067 / 2^32。
    expect(SeededRandom(1).nextUint32(), 2693262067);
  });

  test('出題は決定的：別々に作っても、聞く順番が違っても同じ', () {
    final a = picker();
    final b = picker();
    final days = [
      for (var i = 0; i < 800; i++) PuzzlePicker.defaultEpoch.addDays(i),
    ];
    final fromA = [for (final d in days) a.forDay(d).number];
    final fromB = [
      for (final d in days.reversed) b.forDay(d).number,
    ].reversed.toList();
    expect(fromB, fromA);
  });

  test('出題の固定値（この表が変わると、配信済みの日の問題が変わってしまう）', () {
    final p = picker();
    expect(p.forDay(Day(2026, 11, 1)).number, '5045');
    expect(p.forDay(Day(2026, 11, 4)).number, '4027');
    expect(p.forDay(Day(2026, 11, 6)).number, '1199');
    expect(p.forDay(Day(2026, 11, 4)).serial, 4);
  });

  test('3年分：どの日も解があり、過去365日と同じ番号は出ない', () {
    final p = picker();
    final last = <String, int>{};
    for (var i = 0; i < 365 * 3; i++) {
      final d = PuzzlePicker.defaultEpoch.addDays(i);
      final q = p.forDay(d);
      expect(book.isSolvable(q.number), isTrue);
      expect(q.serial, i + 1);
      final prev = last[q.number];
      if (prev != null && q.anniversary == null) {
        expect(i - prev, greaterThan(365), reason: '${q.number} at $d');
      }
      last[q.number] = i;
    }
  });

  test('曜日で難易度帯が変わる：月曜は易しく、金曜は分数経由の難問', () {
    final p = picker();
    for (var i = 0; i < 365 * 2; i++) {
      final d = PuzzlePicker.defaultEpoch.addDays(i);
      final q = p.forDay(d);
      if (q.anniversary != null) continue;
      expect(q.band, Band.forWeekday(d.weekday), reason: '$d ${q.number}');
      if (d.weekday == DateTime.friday) {
        expect(book.needsFraction(q.number), isTrue);
      }
      if (d.weekday == DateTime.monday) {
        expect(book.solutionsFor(q.number).length, greaterThanOrEqualTo(7));
      }
    }
  });

  test('記念日は固定の表で出す', () {
    final p = picker();
    final xmas = p.forDay(Day(2026, 12, 25));
    expect(xmas.number, '1225');
    expect(xmas.anniversary, 'クリスマス');
    expect(p.forDay(Day(2027, 5, 5)).number, '0505');
    // 元日は 0101 に解がないので、西暦4桁を出す。
    expect(p.forDay(Day(2027, 1, 1)).number, '2027');
    expect(p.forDay(Day(2027, 1, 1)).anniversary, '元日');
    // 2030 には解がないので、ふつうの出題になる。
    final y2030 = p.forDay(Day(2030, 1, 1));
    expect(y2030.anniversary, isNull);
    expect(book.isSolvable(y2030.number), isTrue);
  });

  test('表の記念日はどれも（年号以外は）解がある', () {
    final t = loadAnniversaries();
    for (final mmdd in [
      '0214',
      '0229',
      '0429',
      '0505',
      '1123',
      '1225',
      '1231',
    ]) {
      final e = t.lookup(
        Day(
          2028,
          int.parse(mmdd.substring(0, 2)),
          int.parse(mmdd.substring(2)),
        ),
      );
      expect(e, isNotNull, reason: mmdd);
      expect(book.isSolvable(e!.number), isTrue, reason: mmdd);
    }
  });

  test('分数の難問は54番号', () {
    expect(picker().numbersIn(Band.fraction).length, 54);
  });
}
