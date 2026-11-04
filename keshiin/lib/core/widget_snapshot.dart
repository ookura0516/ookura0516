import 'day_slots.dart';

/// ホーム画面のウィジェットに渡す1日分の内容。
///
/// 日付が変わる0時に古い内容が残らないよう、今日の分と明日の分を両方書いておき、
/// ウィジェット側が端末の日付に合うほうを選ぶ（共通の技術方針）。
class WidgetSnapshot {
  const WidgetSnapshot({
    required this.date,
    required this.filled,
    required this.total,
    required this.todayEmpty,
    required this.grid,
  });

  final Day date;
  final int filled;
  final int total;
  final bool todayEmpty;

  /// 5文字×6行。■＝貼った日、□＝空欄、◇＝今日の空欄、・＝その月に無い日。
  final String grid;

  String get countLabel => '$filled／$total';

  String get monthLabel => '${date.month}月のシート';

  Map<String, Object> toMap(String prefix) => {
    '${prefix}date': date.iso,
    '${prefix}filled': filled,
    '${prefix}total': total,
    '${prefix}todayEmpty': todayEmpty,
    '${prefix}count': countLabel,
    '${prefix}month': monthLabel,
    '${prefix}grid': grid,
    '${prefix}status': todayEmpty ? '今日のマスは空欄' : '今日の切手は貼りました',
  };
}

/// [day] の時点のウィジェットの内容。[filledDays] はその月に切手がある日。
WidgetSnapshot snapshotFor(Day day, Set<int> filledDays) {
  final c = fillCount(filledDays, day.year, day.month);
  final days = daysInMonth(day.year, day.month);
  final b = StringBuffer();
  for (var i = 0; i < sheetCells; i++) {
    final d = i + 1;
    if (i > 0 && i % sheetColumns == 0) b.write('\n');
    if (d > days) {
      b.write('・');
    } else if (filledDays.contains(d)) {
      b.write('■');
    } else if (d == day.day) {
      b.write('◇');
    } else {
      b.write('□');
    }
  }
  return WidgetSnapshot(
    date: day,
    filled: c.filled,
    total: c.total,
    todayEmpty: !filledDays.contains(day.day),
    grid: b.toString(),
  );
}
