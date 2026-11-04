/// 暦の1日（時刻なし）。日替わりの単位。
class Day implements Comparable<Day> {
  Day(int year, int month, int day) : _utc = DateTime.utc(year, month, day);
  Day._(this._utc);

  /// 「20261104」から。
  factory Day.parse(String key) => Day(
    int.parse(key.substring(0, 4)),
    int.parse(key.substring(4, 6)),
    int.parse(key.substring(6, 8)),
  );

  final DateTime _utc;

  int get year => _utc.year;
  int get month => _utc.month;
  int get day => _utc.day;

  /// 1 = 月曜 … 7 = 日曜（DateTime と同じ）。
  int get weekday => _utc.weekday;

  Day addDays(int n) => Day._(_utc.add(Duration(days: n)));

  int daysSince(Day other) => _utc.difference(other._utc).inDays;

  /// 「20261104」。保存のキーと乱数の種に使う。
  String get key =>
      '${year.toString().padLeft(4, '0')}${_two(month)}${_two(day)}';

  /// 「1104」。記念日の表と誕生日に使う。
  String get mmdd => '${_two(month)}${_two(day)}';

  /// 「2026.11.04」。切符の日付欄。
  String get dotted => '$year.${_two(month)}.${_two(day)}';

  static String _two(int n) => n.toString().padLeft(2, '0');

  @override
  bool operator ==(Object other) => other is Day && other._utc == _utc;
  @override
  int get hashCode => _utc.hashCode;
  @override
  int compareTo(Day o) => _utc.compareTo(o._utc);
  bool operator <(Day o) => compareTo(o) < 0;
  bool operator >(Day o) => compareTo(o) > 0;
  @override
  String toString() => key;
}
