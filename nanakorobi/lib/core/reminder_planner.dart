import 'countdown.dart';
import 'local_date.dart';

/// リマインド通知の予定。
///
/// 1日1回、指定時刻。通知文の残り日数は配信時に正しくなるよう、日ごとに前もって
/// 計算した本文で [days] 日分を予約する（首位アプリの「残り288日のまま」を避ける）。
/// アプリを開くたびに予約し直す。
class ReminderEntry {
  const ReminderEntry({required this.date, required this.at, this.daysLeft});

  final LocalDate date;

  /// 配信する時刻（端末ローカル）。
  final DateTime at;

  /// その日の残り日数（本番がなければ null）。
  final int? daysLeft;

  /// 通知 id。日付から決める（同じ日に二重に予約しない）。
  int get notificationId => 100000 + date.epochDay % 100000;

  @override
  bool operator ==(Object other) =>
      other is ReminderEntry && other.date == date && other.at == at && other.daysLeft == daysLeft;

  @override
  int get hashCode => Object.hash(date, at, daysLeft);
}

class ReminderPlanner {
  const ReminderPlanner._();

  static List<ReminderEntry> plan({
    required DateTime now,
    required LocalDate today,
    required int minuteOfDay,
    LocalDate? deadline,
    int days = 14,
  }) {
    final result = <ReminderEntry>[];
    for (var i = 0; i < days; i++) {
      final d = today.addDays(i);
      final at = d.toDateTime().add(Duration(minutes: minuteOfDay));
      if (!at.isAfter(now)) continue;
      if (deadline != null && d > deadline) break;
      result.add(
        ReminderEntry(
          date: d,
          at: at,
          daysLeft: deadline == null ? null : Countdown.daysLeft(deadline, d),
        ),
      );
    }
    return result;
  }
}
