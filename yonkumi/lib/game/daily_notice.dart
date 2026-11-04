import 'package:ookura_daily/ookura_daily.dart';

/// 予約する通知1件。
class ScheduledNotice {
  const ScheduledNotice({
    required this.id,
    required this.at,
    required this.body,
  });

  final int id;

  /// 出す瞬間（UTC）。
  final DateTime at;
  final String body;

  @override
  String toString() => 'ScheduledNotice($id, $at, $body)';
}

/// これから [days] 日分の通知を決める。文面は「第N問が出ました」だけ。
///
/// 毎日同じ時刻の繰り返し通知では番号を変えられないので、1日ずつ予約する
/// （アプリを開くたびに予約し直す）。今日の分は、もう解いた・時刻を過ぎた
/// なら出さない。
List<ScheduledNotice> planNotices({
  required DailyClock clock,
  required DateTime now,
  required int hour,
  required bool todayDone,
  int days = 7,
}) {
  final today = clock.dayNumberAt(now);
  final out = <ScheduledNotice>[];
  for (var d = today; d < today + days; d++) {
    if (d < 1) continue;
    final at = clock.startOf(d).add(Duration(hours: hour));
    if (!at.isAfter(now)) continue;
    if (d == today && todayDone) continue;
    out.add(ScheduledNotice(id: d, at: at, body: '第$d問が出ました'));
  }
  return out;
}

/// 通知の窓口。テストでは差し替える。
abstract class NotificationService {
  Future<void> init();

  /// 通知の許可を求める。許可されたら true。
  Future<bool> requestPermission();

  /// 予約をすべて消して、[notices] を予約し直す。
  Future<void> replaceAll(List<ScheduledNotice> notices);
}

class NoNotificationService implements NotificationService {
  const NoNotificationService();

  @override
  Future<void> init() async {}

  @override
  Future<bool> requestPermission() async => false;

  @override
  Future<void> replaceAll(List<ScheduledNotice> notices) async {}
}
