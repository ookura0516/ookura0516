/// 日付とシートのマスの対応。
///
/// 月のシートは5列×6行の30マス。1日〜30日はマスに順に入り、
/// 31日目（と、1日に2枚目以降の切手）は欄外に置く（設計書「主要機能と画面構成」）。
library;

const int sheetColumns = 5;
const int sheetRows = 6;
const int sheetCells = sheetColumns * sheetRows;

/// 日付だけを持つ値。時刻とタイムゾーンを持たないので、日の境目でずれない。
class Day implements Comparable<Day> {
  const Day(this.year, this.month, this.day);

  factory Day.fromDateTime(DateTime t) => Day(t.year, t.month, t.day);

  /// 'YYYY-MM-DD'
  factory Day.parse(String s) {
    final p = s.split('-');
    return Day(int.parse(p[0]), int.parse(p[1]), int.parse(p[2]));
  }

  final int year;
  final int month;
  final int day;

  DateTime toDateTime() => DateTime(year, month, day);

  Day addDays(int n) => Day.fromDateTime(DateTime(year, month, day + n));

  String get iso =>
      '${year.toString().padLeft(4, '0')}-${_pad2(month)}-${_pad2(day)}';

  /// 消印用の表記「2026.11.04」
  String get dotted => '$year.${_pad2(month)}.${_pad2(day)}';

  bool sameMonth(Day o) => year == o.year && month == o.month;

  @override
  int compareTo(Day o) => year != o.year
      ? year - o.year
      : month != o.month
      ? month - o.month
      : day - o.day;

  bool operator <(Day o) => compareTo(o) < 0;
  bool operator >(Day o) => compareTo(o) > 0;
  bool operator <=(Day o) => compareTo(o) <= 0;

  @override
  bool operator ==(Object other) =>
      other is Day &&
      other.year == year &&
      other.month == month &&
      other.day == day;

  @override
  int get hashCode => Object.hash(year, month, day);

  @override
  String toString() => iso;
}

String _pad2(int n) => n.toString().padLeft(2, '0');

int daysInMonth(int year, int month) => DateTime(year, month + 1, 0).day;

/// その日が入るマスの番号（0〜29）。31日は欄外なので null。
int? cellIndexForDay(int day) {
  if (day < 1 || day > 31) throw RangeError.range(day, 1, 31, 'day');
  return day <= sheetCells ? day - 1 : null;
}

/// マスの番号から行・列。
({int row, int col}) cellPosition(int index) {
  RangeError.checkValueInInterval(index, 0, sheetCells - 1, 'index');
  return (row: index ~/ sheetColumns, col: index % sheetColumns);
}

/// マスの番号に対応する日。その月に無い日（2月の29〜30日など）は null。
int? dayForCell(int index, int year, int month) {
  final d = index + 1;
  return d <= daysInMonth(year, month) ? d : null;
}

/// シートに貼った切手の置き場所。
sealed class Placement {
  const Placement();
}

/// マスの中（その日の1枚目）。
class InCell extends Placement {
  const InCell(this.index);
  final int index;
  @override
  bool operator ==(Object other) => other is InCell && other.index == index;
  @override
  int get hashCode => index.hashCode;
  @override
  String toString() => 'InCell($index)';
}

/// 欄外（31日目、または同じ日の2枚目以降）。
class Margin extends Placement {
  const Margin();
  @override
  bool operator ==(Object other) => other is Margin;
  @override
  int get hashCode => 0;
  @override
  String toString() => 'Margin';
}

/// 月の切手（日付と作った順）を、マスと欄外に分ける。
///
/// [entries] は (日, 並び順のキー)。同じ日の中では並び順のキーが小さいものを
/// マスに入れ、残りは欄外にする。戻り値は入力と同じ順番。
List<Placement> placeInMonth(List<({Day day, int order})> entries) {
  final firstOfDay = <int, int>{}; // day -> 最小の order
  for (final e in entries) {
    final cur = firstOfDay[e.day.day];
    if (cur == null || e.order < cur) firstOfDay[e.day.day] = e.order;
  }
  return [
    for (final e in entries)
      if (firstOfDay[e.day.day] == e.order &&
          cellIndexForDay(e.day.day) != null)
        InCell(cellIndexForDay(e.day.day)!)
      else
        const Margin(),
  ];
}

/// 写真をまとめて貼るときの振り分け。
///
/// 写真ごとに撮影日（無ければ [fallback]）の日に貼る。すでに切手がある日は
/// [allowMultiple] が偽なら飛ばす（失敗にはせず、飛ばした理由を返す）。
/// [today] より未来の日付は今日に寄せる（時計のずれたカメラ対策）。
class Assignment {
  const Assignment(
    this.photoIndex,
    this.day, {
    this.skipped = false,
    this.fromCaptureDate = true,
  });
  final int photoIndex;
  final Day day;
  final bool skipped;

  /// 撮影日から決めたか（偽なら [fallback] を使った）。
  final bool fromCaptureDate;

  @override
  String toString() => 'Assignment($photoIndex, $day, skipped: $skipped)';
}

List<Assignment> assignPhotosToDays({
  required List<DateTime?> captureDates,
  required Set<Day> occupied,
  required Day today,
  required Day fallback,
  bool allowMultiple = false,
}) {
  final taken = {...occupied};
  final out = <Assignment>[];
  for (var i = 0; i < captureDates.length; i++) {
    final t = captureDates[i];
    var day = t == null ? fallback : Day.fromDateTime(t);
    if (day > today) day = today;
    final skip = !allowMultiple && taken.contains(day);
    if (!skip) taken.add(day);
    out.add(Assignment(i, day, skipped: skip, fromCaptureDate: t != null));
  }
  return out;
}

/// 月の埋まり具合。分母は「その月のマスの数」（日数、ただし最大30）。
/// 31日は欄外なので数に入れない。
({int filled, int total}) fillCount(Set<int> filledDays, int year, int month) {
  final total = daysInMonth(year, month).clamp(0, sheetCells);
  final filled = filledDays.where((d) => d >= 1 && d <= total).length;
  return (filled: filled, total: total);
}

/// 全マスが埋まったか（31日は欄外なので問わない）。
bool isMonthComplete(Set<int> filledDays, int year, int month) {
  final c = fillCount(filledDays, year, month);
  return c.filled == c.total;
}
