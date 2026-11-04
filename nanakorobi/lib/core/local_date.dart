/// 端末のローカル日付。時刻を持たない。
///
/// 記録・転倒・残り日数はすべてこの日付で数える（設計書「データモデル」）。
/// 日数の差は UTC の epoch day で取り、夏時間やタイムゾーンの影響を受けない。
class LocalDate implements Comparable<LocalDate> {
  const LocalDate(this.year, this.month, this.day);

  factory LocalDate.fromDateTime(DateTime t) => LocalDate(t.year, t.month, t.day);

  /// 1970-01-01 からの日数から作る。
  factory LocalDate.fromEpochDay(int epochDay) {
    final t = DateTime.utc(1970, 1, 1).add(Duration(days: epochDay));
    return LocalDate(t.year, t.month, t.day);
  }

  /// 'YYYY-MM-DD' を読む。形が違えば [FormatException]。
  factory LocalDate.parse(String s) {
    final m = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(s.trim());
    if (m == null) throw FormatException('LocalDate: $s');
    final d = LocalDate(
      int.parse(m[1]!),
      int.parse(m[2]!),
      int.parse(m[3]!),
    );
    if (!d.isValid) throw FormatException('LocalDate: $s');
    return d;
  }

  static LocalDate? tryParse(String? s) {
    if (s == null) return null;
    try {
      return LocalDate.parse(s);
    } on FormatException {
      return null;
    }
  }

  final int year;
  final int month;
  final int day;

  bool get isValid {
    if (month < 1 || month > 12 || day < 1) return false;
    final t = DateTime.utc(year, month, day);
    return t.year == year && t.month == month && t.day == day;
  }

  /// 1970-01-01 からの日数。
  int get epochDay =>
      DateTime.utc(year, month, day).millisecondsSinceEpoch ~/ Duration.millisecondsPerDay;

  LocalDate addDays(int n) => LocalDate.fromEpochDay(epochDay + n);

  /// this − other の日数。
  int difference(LocalDate other) => epochDay - other.epochDay;

  /// 1=月曜 … 7=日曜。
  int get weekday => DateTime.utc(year, month, day).weekday;

  /// その月の日数。
  int get daysInMonth => DateTime.utc(year, month + 1, 0).day;

  LocalDate get firstOfMonth => LocalDate(year, month, 1);

  /// 'YYYY-MM-DD'
  String toIso() => '${year.toString().padLeft(4, '0')}-'
      '${month.toString().padLeft(2, '0')}-'
      '${day.toString().padLeft(2, '0')}';

  /// 端末のローカル時刻での 0 時。
  DateTime toLocalDateTime() => DateTime(year, month, day);

  bool isBefore(LocalDate o) => compareTo(o) < 0;
  bool isAfter(LocalDate o) => compareTo(o) > 0;

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
