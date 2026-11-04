import 'day.dart';

/// 日替わりの切り替え。端末のタイムゾーンによらず、日本時間（JST）の0時で次の日になる。
///
/// 海外から遊んでも全員が同じ日に同じ問題になるよう、JST に固定する。
class DailyClock {
  DailyClock({DateTime Function()? now}) : _now = now ?? DateTime.now;

  /// テスト用：いつ聞いても [instant]（UTC の時刻）を返す。
  DailyClock.fixed(DateTime instant) : _now = (() => instant);

  final DateTime Function() _now;

  static const jstOffset = Duration(hours: 9);

  DateTime get nowUtc => _now().toUtc();

  /// 今日（JST）。
  Day get today {
    final j = nowUtc.add(jstOffset);
    return Day(j.year, j.month, j.day);
  }

  /// [day] の JST 0時を UTC の時刻で。
  static DateTime startOf(Day day) =>
      DateTime.utc(day.year, day.month, day.day).subtract(jstOffset);

  /// 次に日が替わる時刻（UTC）。
  DateTime get nextSwitch => startOf(today.addDays(1));
}
