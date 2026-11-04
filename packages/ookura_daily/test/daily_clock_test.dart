import 'package:flutter_test/flutter_test.dart';
import 'package:ookura_daily/ookura_daily.dart';

void main() {
  const clock = DailyClock(firstDay: CivilDate(2026, 11, 1));

  group('CivilDate', () {
    test('文字列との行き来', () {
      expect(CivilDate.parse('2026-02-28').toIso(), '2026-02-28');
      expect(() => CivilDate.parse('2026-02-30'), throwsFormatException);
      expect(() => CivilDate.parse('2026/02/01'), throwsFormatException);
    });

    test('日数の足し引きは月と年をまたぐ', () {
      expect(
        const CivilDate(2026, 12, 31).addDays(1),
        const CivilDate(2027, 1, 1),
      );
      expect(
        const CivilDate(2028, 3, 1).addDays(-1),
        const CivilDate(2028, 2, 29),
      );
      expect(
        const CivilDate(2027, 1, 1).daysSince(const CivilDate(2026, 11, 1)),
        61,
      );
      expect(
        const CivilDate(2026, 1, 1).compareTo(const CivilDate(2026, 1, 2)),
        -1,
      );
    });
  });

  group('DailyClock（日本時間の0時で替わる）', () {
    test('第1日の0時ちょうどに第1日になる', () {
      // 2026-11-01 00:00 JST = 2026-10-31 15:00 UTC
      expect(clock.dayNumberAt(DateTime.utc(2026, 10, 31, 15)), 1);
      expect(clock.dayNumberAt(DateTime.utc(2026, 10, 31, 14, 59, 59)), 0);
    });

    test('日本時間の23:59までは同じ番号、0:00で次へ', () {
      expect(clock.dayNumberAt(DateTime.utc(2026, 11, 4, 14, 59)), 4);
      expect(clock.dayNumberAt(DateTime.utc(2026, 11, 4, 15, 0)), 5);
    });

    test('端末のタイムゾーンに関係なく同じ番号', () {
      final instant = DateTime.utc(2026, 11, 4, 20); // JST 11/5 05:00
      // 同じ瞬間を、ニューヨーク（-5時間）の地方時として書いた値。
      final asLocalNY = DateTime.utc(
        2026,
        11,
        4,
        15,
      ).add(const Duration(hours: 5));
      expect(clock.dayNumberAt(instant), 5);
      expect(clock.dayNumberAt(asLocalNY), 5);
      expect(clock.dateAt(instant), const CivilDate(2026, 11, 5));
    });

    test('番号から日付と開始時刻', () {
      expect(clock.dateOf(1), const CivilDate(2026, 11, 1));
      expect(clock.dateOf(62), const CivilDate(2027, 1, 1));
      expect(clock.startOf(5), DateTime.utc(2026, 11, 4, 15));
    });

    test('次の切り替え', () {
      expect(
        clock.nextSwitchAfter(DateTime.utc(2026, 11, 4, 3)),
        DateTime.utc(2026, 11, 4, 15),
      );
      // ちょうど切り替えの瞬間なら、その次。
      expect(
        clock.nextSwitchAfter(DateTime.utc(2026, 11, 4, 15)),
        DateTime.utc(2026, 11, 5, 15),
      );
    });

    test('時差を変えれば別の地域でも使える', () {
      const utc = DailyClock(
        firstDay: CivilDate(2026, 11, 1),
        utcOffset: Duration.zero,
      );
      expect(utc.dayNumberAt(DateTime.utc(2026, 11, 4, 23)), 4);
    });
  });
}
