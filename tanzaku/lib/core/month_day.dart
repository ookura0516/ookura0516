/// 年をまたぐ「MM-DD〜MM-DD」の期間。季語の時期に使う。
class MonthDay implements Comparable<MonthDay> {
  const MonthDay(this.month, this.day);

  /// "11-07" の形から作る。
  factory MonthDay.parse(String s) {
    final m = RegExp(r'^(\d{2})-(\d{2})$').firstMatch(s);
    if (m == null) throw FormatException('MM-DD の形ではありません: $s');
    final month = int.parse(m.group(1)!);
    final day = int.parse(m.group(2)!);
    const days = [31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
    if (month < 1 || month > 12 || day < 1 || day > days[month - 1]) {
      throw FormatException('ありえない日付です: $s');
    }
    return MonthDay(month, day);
  }

  /// 4桁の数（1107）から作る。データベースではこの形で持つ。
  factory MonthDay.fromKey(int key) => MonthDay(key ~/ 100, key % 100);

  factory MonthDay.of(DateTime d) => MonthDay(d.month, d.day);

  final int month;
  final int day;

  int get key => month * 100 + day;

  @override
  int compareTo(MonthDay other) => key.compareTo(other.key);

  @override
  bool operator ==(Object other) => other is MonthDay && other.key == key;

  @override
  int get hashCode => key;

  @override
  String toString() =>
      '${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';

  /// [start]〜[end]（両端を含む）に入るか。start > end なら年をまたぐ。
  bool within(MonthDay start, MonthDay end) {
    if (start.key <= end.key) return start.key <= key && key <= end.key;
    return key >= start.key || key <= end.key;
  }
}
