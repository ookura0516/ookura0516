import 'package:flutter_test/flutter_test.dart';
import 'package:tanzaku/core/season.dart';
import 'package:tanzaku/core/theme_picker.dart';

import 'helpers.dart';

void main() {
  group('二十四節気', () {
    test('2026年の主な節気', () {
      final t = {
        for (final s in solarTermsOf(2026)) s.name: '${s.month}/${s.day}',
      };
      expect(t['立春'], '2/4');
      expect(t['春分'], '3/20');
      expect(t['立夏'], '5/5');
      expect(t['夏至'], '6/21');
      expect(t['立秋'], '8/7');
      expect(t['秋分'], '9/23');
      expect(t['立冬'], '11/7');
      expect(t['冬至'], '12/22');
      expect(solarTermsOf(2026).length, 24);
    });

    test('ほかの年もおおむね合う', () {
      String of(int y, String n) {
        final s = solarTermsOf(y).firstWhere((e) => e.name == n);
        return '${s.month}/${s.day}';
      }

      expect(of(2025, '立春'), '2/3');
      expect(of(2027, '立春'), '2/4');
      expect(of(2024, '夏至'), '6/21');
    });

    test('今の節気', () {
      expect(currentSolarTerm(DateTime(2026, 11, 4)).name, '霜降');
      expect(currentSolarTerm(DateTime(2026, 11, 7)).name, '立冬');
      expect(currentSolarTerm(DateTime(2026, 1, 2)).name, '冬至');
    });
  });

  group('今の季節', () {
    test('二十四節気で切り替わる', () {
      expect(seasonOf(DateTime(2026, 11, 4)), Season.autumn);
      expect(seasonOf(DateTime(2026, 11, 6)), Season.autumn);
      expect(seasonOf(DateTime(2026, 11, 7)), Season.winter);
      expect(seasonOf(DateTime(2026, 2, 3)), Season.winter);
      expect(seasonOf(DateTime(2026, 2, 4)), Season.spring);
      expect(seasonOf(DateTime(2026, 5, 4)), Season.spring);
      expect(seasonOf(DateTime(2026, 5, 5)), Season.summer);
      expect(seasonOf(DateTime(2026, 8, 7)), Season.autumn);
    });

    test('新年は1月1日〜7日', () {
      expect(seasonOf(DateTime(2027, 1, 1)), Season.newYear);
      expect(seasonOf(DateTime(2027, 1, 7)), Season.newYear);
      expect(seasonOf(DateTime(2027, 1, 8)), Season.winter);
    });

    test('次の季節の変わり目', () {
      final (t, at) = nextSeasonChange(DateTime(2026, 11, 4));
      expect(t.name, '立冬');
      expect(at, DateTime(2026, 11, 7));
      final (t2, at2) = nextSeasonChange(DateTime(2026, 12, 1));
      expect(t2.name, '立春');
      expect(at2.year, 2027);
    });
  });

  group('日替わり兼題', () {
    final all = dictionary.entries;

    test('同じ日には同じ季語（端末によらない）', () {
      final d = DateTime(2026, 11, 4);
      expect(
        pickDailyTheme(d, all)!.id,
        pickDailyTheme(d, List.of(all.reversed))!.id,
      );
    });

    test('1年を通して、その日の季節で時期の合う季語が選ばれる', () {
      var day = DateTime(2026, 1, 1);
      while (day.year == 2026) {
        final k = pickDailyTheme(day, all)!;
        expect(k.season, seasonOf(day), reason: '$day ${k.word}');
        expect(k.inSeasonOn(day), isTrue, reason: '$day ${k.word}');
        day = DateTime(day.year, day.month, day.day + 1);
      }
    });

    test('その日だけの季語を優先する', () {
      expect([
        '元日',
        '初日の出',
      ], contains(pickDailyTheme(DateTime(2027, 1, 1), all)!.word));
      expect([
        '大晦日',
        '除夜の鐘',
      ], contains(pickDailyTheme(DateTime(2026, 12, 31), all)!.word));
    });

    test('立冬の日の前後で、秋から冬の季語に変わる', () {
      expect(pickDailyTheme(DateTime(2026, 11, 6), all)!.season, Season.autumn);
      expect(pickDailyTheme(DateTime(2026, 11, 7), all)!.season, Season.winter);
    });

    test('続く7日間はおおむね違う季語になる', () {
      var day = DateTime(2026, 10, 10);
      final seen = <int>{};
      for (var i = 0; i < 7; i++) {
        seen.add(pickDailyTheme(day, all)!.id);
        day = DateTime(day.year, day.month, day.day + 1);
      }
      expect(seen.length, 7);
    });

    test('日本時間の0時で日付が変わる', () {
      expect(
        jstToday(DateTime.utc(2026, 11, 4, 14, 59)),
        DateTime(2026, 11, 4),
      );
      expect(jstToday(DateTime.utc(2026, 11, 4, 15, 0)), DateTime(2026, 11, 5));
    });

    test('空の歳時記なら null', () {
      expect(pickDailyTheme(DateTime(2026, 1, 1), const []), isNull);
    });
  });
}
