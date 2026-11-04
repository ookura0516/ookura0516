import 'package:flutter_test/flutter_test.dart';
import 'package:nanakorobi/core/local_date.dart';

void main() {
  group('LocalDate', () {
    test('日数の差と加算は月またぎ・うるう年で正しい', () {
      expect(const LocalDate(2027, 3, 1).difference(const LocalDate(2027, 2, 28)), 1);
      expect(const LocalDate(2028, 3, 1).difference(const LocalDate(2028, 2, 28)), 2);
      expect(const LocalDate(2026, 12, 31).addDays(1), const LocalDate(2027, 1, 1));
      expect(const LocalDate(2027, 1, 1).addDays(-1), const LocalDate(2026, 12, 31));
      expect(const LocalDate(2027, 1, 16).difference(const LocalDate(2026, 11, 4)), 73);
    });

    test('parse と toIso', () {
      expect(LocalDate.parse('2027-01-16'), const LocalDate(2027, 1, 16));
      expect(const LocalDate(2027, 1, 6).toIso(), '2027-01-06');
      expect(LocalDate.tryParse('2027-02-30'), isNull);
      expect(LocalDate.tryParse('abc'), isNull);
      expect(() => LocalDate.parse('x'), throwsFormatException);
    });

    test('比較', () {
      const a = LocalDate(2027, 1, 1);
      const b = LocalDate(2027, 1, 2);
      expect(a < b, isTrue);
      expect(b > a, isTrue);
      expect(a <= a, isTrue);
      expect(a == const LocalDate(2027, 1, 1), isTrue);
      expect(a.weekday, 5); // 2027-01-01 は金曜
      expect(const LocalDate(2027, 2, 1).daysInMonth, 28);
      expect(const LocalDate(2028, 2, 1).daysInMonth, 29);
    });
  });

  group('DayBoundary', () {
    test('仮置き：0〜3時の記録は当日扱い', () {
      const b = DayBoundary.standard;
      expect(b.dateOf(DateTime(2027, 1, 16, 1, 30)), const LocalDate(2027, 1, 16));
      expect(b.dateOf(DateTime(2027, 1, 16, 23, 59)), const LocalDate(2027, 1, 16));
      expect(b.nextBoundary(DateTime(2027, 1, 16, 1, 30)), DateTime(2027, 1, 17));
    });

    test('前日扱いにするなら shiftHours=3', () {
      const b = DayBoundary(shiftHours: 3);
      expect(b.dateOf(DateTime(2027, 1, 16, 2, 59)), const LocalDate(2027, 1, 15));
      expect(b.dateOf(DateTime(2027, 1, 16, 3, 0)), const LocalDate(2027, 1, 16));
      expect(b.nextBoundary(DateTime(2027, 1, 16, 2, 0)), DateTime(2027, 1, 16, 3));
      expect(b.nextBoundary(DateTime(2027, 1, 16, 12, 0)), DateTime(2027, 1, 17, 3));
    });
  });
}
