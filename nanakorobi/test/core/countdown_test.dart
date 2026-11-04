import 'package:flutter_test/flutter_test.dart';
import 'package:nanakorobi/core/countdown.dart';
import 'package:nanakorobi/core/local_date.dart';
import 'package:nanakorobi/core/reminder_planner.dart';
import 'package:nanakorobi/core/size_rank.dart';

void main() {
  const exam = LocalDate(2027, 1, 16);

  group('残り日数', () {
    test('本番の日の0時と今日の0時の差。当日は0、過ぎると負', () {
      expect(Countdown.daysLeft(exam, const LocalDate(2026, 11, 4)), 73);
      expect(Countdown.daysLeft(exam, const LocalDate(2027, 1, 15)), 1);
      expect(Countdown.daysLeft(exam, exam), 0);
      expect(Countdown.daysLeft(exam, const LocalDate(2027, 1, 17)), -1);
    });
  });

  group('ウィジェットのタイムライン', () {
    test('14日分を前もって作り、1日ずつ減る', () {
      final t = Countdown.timeline(from: const LocalDate(2027, 1, 1), deadline: exam);
      expect(t.length, 14);
      expect(t.first.date, const LocalDate(2027, 1, 1));
      expect(t.first.daysLeft, 15);
      expect(t.last.date, const LocalDate(2027, 1, 14));
      expect(t.last.daysLeft, 2);
    });

    test('次の通過点は日付順で、過ぎたら次へ進む', () {
      const mock = Waypoint(name: '模試', date: LocalDate(2027, 1, 5));
      const apply = Waypoint(name: '出願', date: LocalDate(2027, 1, 10));
      final t = Countdown.timeline(
        from: const LocalDate(2027, 1, 4),
        days: 8,
        waypoints: [apply, mock],
      );
      expect(t[0].nextWaypointName, '模試');
      expect(t[0].nextWaypointDays, 1);
      expect(t[1].nextWaypointName, '模試'); // 当日も含む
      expect(t[1].nextWaypointDays, 0);
      expect(t[2].nextWaypointName, '出願');
      expect(t[7].nextWaypointName, isNull);
      expect(t[0].daysLeft, isNull);
    });

    test('JSON に往復できる', () {
      const e = TimelineEntry(
        date: LocalDate(2027, 1, 1),
        daysLeft: 15,
        nextWaypointName: '模試',
        nextWaypointDays: 4,
      );
      expect(TimelineEntry.fromJson(e.toJson()), e);
    });
  });

  group('リマインドの予定', () {
    test('今日の時刻を過ぎていれば明日から。本番の日を越えては予約しない', () {
      final plan = ReminderPlanner.plan(
        now: DateTime(2027, 1, 10, 21, 0),
        today: const LocalDate(2027, 1, 10),
        minuteOfDay: 20 * 60,
        deadline: exam,
      );
      expect(plan.first.date, const LocalDate(2027, 1, 11));
      expect(plan.first.at, DateTime(2027, 1, 11, 20, 0));
      expect(plan.first.daysLeft, 5);
      expect(plan.last.date, exam);
      expect(plan.last.daysLeft, 0);
      expect(plan.length, 6);
    });

    test('本番がなければ14日分', () {
      final plan = ReminderPlanner.plan(
        now: DateTime(2027, 1, 10, 8, 0),
        today: const LocalDate(2027, 1, 10),
        minuteOfDay: 20 * 60,
      );
      expect(plan.length, 14);
      expect(plan.first.date, const LocalDate(2027, 1, 10));
      expect(plan.first.daysLeft, isNull);
      expect(plan.map((e) => e.notificationId).toSet().length, 14);
    });
  });

  group('ひと回り大きいだるま', () {
    test('段階は1つ上がり、5で打ち止め', () {
      expect(SizeRank.next(1), 2);
      expect(SizeRank.next(5), 5);
      expect(SizeRank.relativeScale(1), 1.0);
      expect(SizeRank.relativeScale(5), closeTo(1.48, 1e-9));
      expect(SizeRank.fitScale(5), 1.0);
      expect(SizeRank.fitScale(1), lessThan(1.0));
    });
  });
}
