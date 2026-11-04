import 'package:meta/meta.dart';

/// 端末のローカル日付。時刻とタイムゾーンを持たない。
///
/// 記録・休み券・本番の日はすべてこの型で扱う。DateTime の比較は
/// タイムゾーンや夏時間でずれるので、日数の差は [epochDay] の引き算で出す。
@immutable
class LocalDate implements Comparable<LocalDate> {
  const LocalDate(this.year, this.month, this.day);

  factory LocalDate.fromDateTime(DateTime t) => LocalDate(t.year, t.month, t.day);

  /// 'yyyy-MM-dd' を読む。
  factory LocalDate.parse(String s) {
    final d = tryParse(s);
    if (d == null) throw FormatException('LocalDate ではない: $s');
    return d;
  }

  factory LocalDate.fromJson(String s) => LocalDate.parse(s);

  /// 1970-01-01 を 0 とする通算日から作る。
  factory LocalDate.fromEpochDay(int epochDay) {
    final t = DateTime.utc(1970, 1, 1).add(Duration(days: epochDay));
    return LocalDate(t.year, t.month, t.day);
  }

  static LocalDate? tryParse(String? s) {
    if (s == null) return null;
    final m = RegExp(r'^(\d{4})-(\d{1,2})-(\d{1,2})$').firstMatch(s.trim());
    if (m == null) return null;
    final y = int.parse(m.group(1)!);
    final mo = int.parse(m.group(2)!);
    final d = int.parse(m.group(3)!);
    if (mo < 1 || mo > 12 || d < 1 || d > _daysInMonth(y, mo)) return null;
    return LocalDate(y, mo, d);
  }

  final int year;
  final int month;
  final int day;

  /// 1970-01-01 を 0 とする通算日。
  int get epochDay =>
      DateTime.utc(year, month, day).millisecondsSinceEpoch ~/ Duration.millisecondsPerDay;

  /// 端末ローカルの 0 時。
  DateTime toDateTime() => DateTime(year, month, day);

  LocalDate addDays(int n) => LocalDate.fromEpochDay(epochDay + n);

  /// this - other の日数。
  int difference(LocalDate other) => epochDay - other.epochDay;

  bool isBefore(LocalDate o) => compareTo(o) < 0;
  bool isAfter(LocalDate o) => compareTo(o) > 0;
  bool operator <(LocalDate o) => isBefore(o);
  bool operator >(LocalDate o) => isAfter(o);
  bool operator <=(LocalDate o) => compareTo(o) <= 0;
  bool operator >=(LocalDate o) => compareTo(o) >= 0;

  LocalDate get firstOfMonth => LocalDate(year, month, 1);
  int get daysInMonth => _daysInMonth(year, month);

  /// 月曜=1 … 日曜=7（DateTime と同じ）。
  int get weekday => DateTime.utc(year, month, day).weekday;

  bool sameMonth(LocalDate o) => year == o.year && month == o.month;

  static int _daysInMonth(int y, int m) {
    const days = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
    if (m == 2 && _isLeap(y)) return 29;
    return days[m - 1];
  }

  static bool _isLeap(int y) => (y % 4 == 0 && y % 100 != 0) || y % 400 == 0;

  String toJson() => toIso();

  String toIso() =>
      '${year.toString().padLeft(4, '0')}-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';

  @override
  int compareTo(LocalDate other) => epochDay.compareTo(other.epochDay);

  @override
  bool operator ==(Object other) =>
      other is LocalDate && other.year == year && other.month == month && other.day == day;

  @override
  int get hashCode => Object.hash(year, month, day);

  @override
  String toString() => toIso();
}

/// 1日の境界。
///
/// 仮置き：0〜3時の記録は当日扱い（[shiftHours] = 0）。前日扱いにするなら 3 にする。
@immutable
class DayBoundary {
  const DayBoundary({this.shiftHours = 0});

  /// 「0〜3時を前日扱い」にするときは 3。
  final int shiftHours;

  static const standard = DayBoundary();

  LocalDate dateOf(DateTime now) =>
      LocalDate.fromDateTime(now.subtract(Duration(hours: shiftHours)));

  /// 次に日付が切り替わる時刻（端末ローカル）。ウィジェットと通知の更新に使う。
  DateTime nextBoundary(DateTime now) {
    final today = dateOf(now);
    return today.addDays(1).toDateTime().add(Duration(hours: shiftHours));
  }
}
