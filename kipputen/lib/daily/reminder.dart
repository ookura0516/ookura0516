import 'day.dart';

/// 日替わりの通知1回分。
class Reminder {
  const Reminder({required this.at, required this.title, required this.body});

  /// 出す時刻（UTC）。
  final DateTime at;
  final String title;
  final String body;

  /// 同じ日には同じ ID（「20261104」の数字）。予約し直しても重ならない。
  static int idFor(Day day) => int.parse(day.key);
}

/// 通知を出す窓口。実装は flutter_local_notifications。テストでは記録するだけのものに差し替える。
abstract class ReminderService {
  Future<void> init();

  /// 通知の許可を求める。許可されたら true。
  Future<bool> requestPermission();

  /// 予約を全部消して、[reminders] だけを予約し直す。
  Future<void> replaceAll(Map<int, Reminder> reminders);
}

class NoReminderService implements ReminderService {
  const NoReminderService();
  @override
  Future<void> init() async {}
  @override
  Future<bool> requestPermission() async => false;
  @override
  Future<void> replaceAll(Map<int, Reminder> reminders) async {}
}
