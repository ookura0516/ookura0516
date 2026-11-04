/// 時差を持たない暦の日付（年・月・日）。
///
/// [DateTime] は時刻とタイムゾーンを持つので、日替わりの計算では
/// 「どの国の何日か」を取り違えやすい。日付だけを扱うときはこちらを使う。
class CivilDate implements Comparable<CivilDate> {
  const CivilDate(this.year, this.month, this.day);

  /// `2026-11-04` の形から作る。
  factory CivilDate.parse(String iso) {
    final m = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(iso);
    if (m == null) throw FormatException('日付の形が違います: $iso');
    final d = CivilDate._fromUtc(
      DateTime.utc(
        int.parse(m.group(1)!),
        int.parse(m.group(2)!),
        int.parse(m.group(3)!),
      ),
    );
    if (d.toIso() != iso) throw FormatException('ありえない日付です: $iso');
    return d;
  }

  factory CivilDate._fromUtc(DateTime utc) =>
      CivilDate(utc.year, utc.month, utc.day);

  final int year;
  final int month;
  final int day;

  DateTime get _utcMidnight => DateTime.utc(year, month, day);

  CivilDate addDays(int days) =>
      CivilDate._fromUtc(_utcMidnight.add(Duration(days: days)));

  /// [other] から何日後か（[other] のほうが後なら負）。
  int daysSince(CivilDate other) =>
      _utcMidnight.difference(other._utcMidnight).inDays;

  String toIso() =>
      '${year.toString().padLeft(4, '0')}-${month.toString().padLeft(2, '0')}'
      '-${day.toString().padLeft(2, '0')}';

  @override
  int compareTo(CivilDate other) => daysSince(other).sign;

  @override
  bool operator ==(Object other) =>
      other is CivilDate &&
      other.year == year &&
      other.month == month &&
      other.day == day;

  @override
  int get hashCode => Object.hash(year, month, day);

  @override
  String toString() => toIso();
}

/// 決まった時差の 0 時で日が替わる、通し番号つきの日めくり。
///
/// 第1日は [firstDay]。端末のタイムゾーンには関係なく、[utcOffset]（既定は
/// 日本時間の +9 時間）の 0 時に全員そろって次の番号に進む。日本には夏時間が
/// ないので、時差は固定の値で足りる。
class DailyClock {
  const DailyClock({
    required this.firstDay,
    this.utcOffset = const Duration(hours: 9),
  });

  /// 第1日の日付（[utcOffset] の地域での日付）。
  final CivilDate firstDay;

  final Duration utcOffset;

  /// [instant] の時点で、[utcOffset] の地域では何日か。
  CivilDate dateAt(DateTime instant) =>
      CivilDate._fromUtc(instant.toUtc().add(utcOffset));

  /// [instant] の時点の通し番号。第1日より前は 0 以下になる。
  int dayNumberAt(DateTime instant) => dateAt(instant).daysSince(firstDay) + 1;

  /// 通し番号 [dayNumber] の日付。
  CivilDate dateOf(int dayNumber) => firstDay.addDays(dayNumber - 1);

  /// 通し番号 [dayNumber] が始まる瞬間（UTC）。
  DateTime startOf(int dayNumber) =>
      dateOf(dayNumber)._utcMidnight.subtract(utcOffset);

  /// [instant] の次に日が替わる瞬間（UTC）。
  DateTime nextSwitchAfter(DateTime instant) =>
      startOf(dayNumberAt(instant) + 1);
}
