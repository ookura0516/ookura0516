import 'package:flutter_test/flutter_test.dart';
import 'package:kipputen/core/special_numbers.dart';
import 'package:kipputen/daily/daily.dart';

void main() {
  group('日替わりの切り替え（JST 0時）', () {
    test('UTC 14:59 はまだ前の日、15:00 で次の日', () {
      expect(
        DailyClock.fixed(DateTime.utc(2026, 11, 4, 14, 59)).today,
        Day(2026, 11, 4),
      );
      expect(
        DailyClock.fixed(DateTime.utc(2026, 11, 4, 15, 0)).today,
        Day(2026, 11, 5),
      );
    });

    test('次の切り替え時刻', () {
      final c = DailyClock.fixed(DateTime.utc(2026, 11, 4, 3));
      expect(c.nextSwitch, DateTime.utc(2026, 11, 4, 15));
    });

    test('Day の書式', () {
      final d = Day(2026, 1, 5);
      expect(d.key, '20260105');
      expect(d.mmdd, '0105');
      expect(d.dotted, '2026.01.05');
      expect(Day.parse('20260105'), d);
      expect(Day(2026, 3, 1).addDays(-1), Day(2026, 2, 28));
    });
  });

  group('連続日数', () {
    final today = Day(2026, 11, 10);
    test('今日まで続いている', () {
      final s = Streak.compute([
        today,
        today.addDays(-1),
        today.addDays(-2),
        today.addDays(-5),
      ], today);
      expect(s.current, 3);
      expect(s.best, 3);
    });

    test('今日まだでも、昨日まで続いていれば途切れない', () {
      final s = Streak.compute([today.addDays(-1), today.addDays(-2)], today);
      expect(s.current, 2);
    });

    test('一昨日で止まっていたら 0', () {
      final s = Streak.compute([today.addDays(-2), today.addDays(-3)], today);
      expect(s.current, 0);
      expect(s.best, 2);
    });
  });

  test('ウィジェット用データは今日と翌日の分', () {
    final m = WidgetExporter.encode([
      WidgetDay(day: Day(2026, 11, 4), title: '4027', done: true),
      WidgetDay(day: Day(2026, 11, 5), title: '7168', done: false),
    ]);
    expect(m['days'], '20261104,20261105');
    expect(m['day_20261104_title'], '4027');
    expect(m['day_20261104_done'], '1');
    expect(m['day_20261105_done'], '0');
  });

  test('評価依頼は初日に出さず、365日に3回まで', () {
    const p = ReviewPolicy();
    final now = DateTime.utc(2026, 11, 4);
    expect(p.shouldAsk(pastAsks: [], now: now, isFirstUseDay: true), isFalse);
    expect(p.shouldAsk(pastAsks: [], now: now, isFirstUseDay: false), isTrue);
    final three = [
      for (var i = 1; i <= 3; i++) now.subtract(Duration(days: i * 30)),
    ];
    expect(
      p.shouldAsk(pastAsks: three, now: now, isFirstUseDay: false),
      isFalse,
    );
    final old = [
      for (var i = 1; i <= 3; i++) now.subtract(Duration(days: 300 + i * 30)),
    ];
    expect(p.shouldAsk(pastAsks: old, now: now, isFirstUseDay: false), isTrue);
  });

  group('特別な番号（金縁）', () {
    test('ゾロ目・連番・回文・誕生日', () {
      expect(specialKinds('7777'), {SpecialKind.zorome});
      expect(specialKinds('1234'), {SpecialKind.sequence});
      expect(specialKinds('9876'), {SpecialKind.sequence});
      expect(specialKinds('1221'), {SpecialKind.palindrome});
      expect(specialKinds('0516', birthday: '0516'), {SpecialKind.birthday});
      expect(specialKinds('5839'), isEmpty);
      expect(specialKinds('1357'), isEmpty);
    });
  });
}
