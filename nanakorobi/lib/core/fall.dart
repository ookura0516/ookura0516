import 'local_date.dart';

/// 転倒と起き上がりの判定。
///
/// - 記録のない日（step でも rest でもない日）が1日でもあると、翌日から転倒中
/// - 転倒中は模様が減らず、何日空いても1回の転びとして扱う
/// - 転倒中に step を記録すると起き上がる（Recovery を1件保存し、金の筋が1本増える）
/// - 休み券（rest）の日は空白にならないが、転んでいる状態を直しもしない
/// - 開眼日は記録のあった日とみなす（開眼日そのものは空白にならない）
class FallJudge {
  const FallJudge._();

  /// 最後に step を記録した日。なければ開眼日。
  static LocalDate lastStepDay({
    required LocalDate openedOn,
    required LocalDate today,
    required Iterable<LocalDate> stepDates,
  }) {
    var last = openedOn;
    for (final d in stepDates) {
      if (d > today) continue;
      if (d > last) last = d;
    }
    return last;
  }

  /// 開眼日の翌日から昨日までのうち、step も rest もない日。
  static List<LocalDate> gapDays({
    required LocalDate openedOn,
    required LocalDate today,
    required Iterable<LocalDate> stepDates,
    required Iterable<LocalDate> restDates,
  }) {
    final steps = stepDates.toSet();
    final rests = restDates.toSet();
    final result = <LocalDate>[];
    for (var d = openedOn.addDays(1); d < today; d = d.addDays(1)) {
      if (!steps.contains(d) && !rests.contains(d)) result.add(d);
    }
    return result;
  }

  /// 今日、転倒中か。
  ///
  /// 最後の step（なければ開眼日）より後で今日より前に、rest で埋まっていない日が
  /// あれば転倒中。今日 step を記録していれば立っている。
  static bool isFallen({
    required LocalDate openedOn,
    required LocalDate today,
    required Iterable<LocalDate> stepDates,
    required Iterable<LocalDate> restDates,
  }) {
    final steps = stepDates.toSet();
    if (steps.contains(today)) return false;
    final last = lastStepDay(openedOn: openedOn, today: today, stepDates: steps);
    final rests = restDates.toSet();
    for (var d = last.addDays(1); d < today; d = d.addDays(1)) {
      if (!rests.contains(d)) return true;
    }
    return false;
  }

  /// 今日 step を記録したら起き上がりになるか（＝今日の記録前に転倒中か）。
  static bool wouldRise({
    required LocalDate openedOn,
    required LocalDate today,
    required Iterable<LocalDate> stepDates,
    required Iterable<LocalDate> restDates,
  }) =>
      isFallen(openedOn: openedOn, today: today, stepDates: stepDates, restDates: restDates);

  /// 連続日数（小さく出すだけ。主役にしない）。
  ///
  /// 今日 step があれば今日から、なければ昨日から数える。rest の日は切れないが数えない。
  static int streak({
    required LocalDate today,
    required Iterable<LocalDate> stepDates,
    required Iterable<LocalDate> restDates,
  }) {
    final steps = stepDates.toSet();
    final rests = restDates.toSet();
    var d = steps.contains(today) ? today : today.addDays(-1);
    var count = 0;
    while (true) {
      if (steps.contains(d)) {
        count++;
      } else if (!rests.contains(d)) {
        break;
      }
      d = d.addDays(-1);
    }
    return count;
  }
}
