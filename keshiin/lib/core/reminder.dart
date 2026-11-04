/// リマインダー（設計書「拡散と継続の設計」：1日1回・初期オフ、文面は「今日の切手を貼る？」だけ）。
///
/// 毎日くり返す通知ではなく、この先 [reminderHorizonDays] 日ぶんを1日1件ずつ予約する。
/// すでに切手を貼った日は予約しないので、貼り終えた日に通知は来ない。
/// アプリを開いたときと、切手を貼った・消したときに予約し直す。
library;

import 'day_slots.dart';

const String reminderTitle = 'ケシイン';
const String reminderBody = '今日の切手を貼る？';

/// 何日先まで予約するか（iOS は予約できる通知が64件まで）。
const int reminderHorizonDays = 14;

/// 時刻（時・分）。
class ReminderTime {
  const ReminderTime(this.hour, this.minute)
    : assert(hour >= 0 && hour < 24),
      assert(minute >= 0 && minute < 60);

  static const defaultTime = ReminderTime(20, 0);

  final int hour;
  final int minute;

  /// '20:00'
  String get label => '$hour:${minute.toString().padLeft(2, '0')}';

  String encode() => label;

  static ReminderTime parse(String? s) {
    final m = RegExp(r'^(\d{1,2}):(\d{2})$').firstMatch(s ?? '');
    if (m == null) return defaultTime;
    final h = int.parse(m[1]!), mi = int.parse(m[2]!);
    if (h > 23 || mi > 59) return defaultTime;
    return ReminderTime(h, mi);
  }

  @override
  bool operator ==(Object other) =>
      other is ReminderTime && other.hour == hour && other.minute == minute;

  @override
  int get hashCode => Object.hash(hour, minute);
}

/// 予約する通知の日（端末の時刻で）。
///
/// [now] より後で、[filled] に入っていない日だけ。今日の時刻を過ぎていたら明日から。
List<({Day day, DateTime at})> reminderSchedule({
  required DateTime now,
  required ReminderTime time,
  required Set<Day> filled,
  int days = reminderHorizonDays,
}) {
  final today = Day.fromDateTime(now);
  final out = <({Day day, DateTime at})>[];
  for (var i = 0; i < days; i++) {
    final d = today.addDays(i);
    final at = DateTime(d.year, d.month, d.day, time.hour, time.minute);
    if (!at.isAfter(now)) continue;
    if (filled.contains(d)) continue;
    out.add((day: d, at: at));
  }
  return out;
}

/// 通知の id。日付から決めるので、予約し直しても重ならない。
int reminderId(Day d) => d.year * 10000 + d.month * 100 + d.day;
