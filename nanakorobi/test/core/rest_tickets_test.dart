import 'package:flutter_test/flutter_test.dart';
import 'package:nanakorobi/core/local_date.dart';
import 'package:nanakorobi/core/rest_tickets.dart';

void main() {
  const today = LocalDate(2027, 1, 10);

  test('前日までの宣言だけ。当日と事後には使えない', () {
    expect(
      RestTickets.canDeclare(today: today, forDate: const LocalDate(2027, 1, 11), restDates: const []),
      RestDecision.ok,
    );
    expect(
      RestTickets.canDeclare(today: today, forDate: today, restDates: const []),
      RestDecision.tooLate,
    );
    expect(
      RestTickets.canDeclare(today: today, forDate: const LocalDate(2027, 1, 9), restDates: const []),
      RestDecision.tooLate,
    );
  });

  test('月に2枚。枚数は休む日の月で数える', () {
    final used = [const LocalDate(2027, 1, 3), const LocalDate(2027, 1, 5)];
    expect(RestTickets.remainingIn(restDates: used, year: 2027, month: 1), 0);
    expect(
      RestTickets.canDeclare(today: today, forDate: const LocalDate(2027, 1, 20), restDates: used),
      RestDecision.noTicketsLeft,
    );
    // 翌月の分はまだ使える
    expect(
      RestTickets.canDeclare(today: today, forDate: const LocalDate(2027, 2, 1), restDates: used),
      RestDecision.ok,
    );
    expect(RestTickets.remainingIn(restDates: used, year: 2027, month: 2), 2);
  });

  test('同じ日は二重に宣言できない。本番の日より後は使えない', () {
    const tomorrow = LocalDate(2027, 1, 11);
    expect(
      RestTickets.canDeclare(today: today, forDate: tomorrow, restDates: const [tomorrow]),
      RestDecision.alreadyDeclared,
    );
    expect(
      RestTickets.canDeclare(
        today: today,
        forDate: const LocalDate(2027, 1, 20),
        restDates: const [],
        deadline: const LocalDate(2027, 1, 16),
      ),
      RestDecision.afterDeadline,
    );
  });

  test('その日が来る前なら取り消せる', () {
    expect(RestTickets.canCancel(today: today, forDate: const LocalDate(2027, 1, 11)), isTrue);
    expect(RestTickets.canCancel(today: today, forDate: today), isFalse);
  });
}
