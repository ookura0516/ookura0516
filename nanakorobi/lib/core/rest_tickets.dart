import 'local_date.dart';

/// 休み券の決まり（ookura_streak の代わり。README「共有パッケージの差し替え」）。
///
/// - 月に2枚。枚数は「休む日」の月で数える
/// - 前日までの宣言制。当日と事後には使えない
/// - 宣言した休みは、その日が来る前なら取り消せる
enum RestDecision {
  ok,

  /// 当日・事後（前日までにしか宣言できない）。
  tooLate,

  /// その月の券を使い切った。
  noTicketsLeft,

  /// 同じ日にもう宣言している。
  alreadyDeclared,

  /// 本番の日より後。
  afterDeadline,
}

class RestTickets {
  const RestTickets._();

  static const perMonth = 2;

  static int usedIn({required Iterable<LocalDate> restDates, required int year, required int month}) =>
      restDates.where((d) => d.year == year && d.month == month).length;

  static int remainingIn({required Iterable<LocalDate> restDates, required int year, required int month}) =>
      (perMonth - usedIn(restDates: restDates, year: year, month: month)).clamp(0, perMonth);

  static RestDecision canDeclare({
    required LocalDate today,
    required LocalDate forDate,
    required Iterable<LocalDate> restDates,
    LocalDate? deadline,
  }) {
    if (forDate <= today) return RestDecision.tooLate;
    if (deadline != null && forDate > deadline) return RestDecision.afterDeadline;
    if (restDates.contains(forDate)) return RestDecision.alreadyDeclared;
    if (remainingIn(restDates: restDates, year: forDate.year, month: forDate.month) <= 0) {
      return RestDecision.noTicketsLeft;
    }
    return RestDecision.ok;
  }

  static bool canCancel({required LocalDate today, required LocalDate forDate}) => forDate > today;
}
