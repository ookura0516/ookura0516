import 'package:flutter_test/flutter_test.dart';
import 'package:nanakorobi/core/local_date.dart';
import 'package:nanakorobi/core/rules.dart';
import 'package:nanakorobi/model/models.dart';

void main() {
  group('LocalDate', () {
    test('日付の差は日単位で、時刻やタイムゾーンに左右されない', () {
      final a = LocalDate(2026, 11, 4);
      final b = LocalDate(2027, 1, 16);
      expect(b.difference(a), 73);
      expect(a.addDays(73), b);
      expect(LocalDate.fromDateTime(DateTime(2026, 11, 4, 23, 59)), a);
      expect(LocalDate.fromDateTime(DateTime(2026, 11, 5, 0, 0, 1)), a.addDays(1));
    });

    test('文字列と往復できる', () {
      expect(LocalDate.parse('2027-01-16').toIso(), '2027-01-16');
      expect(LocalDate.tryParse('2027-02-30'), isNull);
      expect(LocalDate.tryParse(null), isNull);
      expect(() => LocalDate.parse('2027/01/16'), throwsFormatException);
    });

    test('月末と曜日', () {
      expect(LocalDate(2028, 2, 1).daysInMonth, 29);
      expect(LocalDate(2027, 2, 1).daysInMonth, 28);
      expect(LocalDate(2026, 11, 4).weekday, DateTime.wednesday);
    });
  });

  group('Rules.isFallen', () {
    final opened = LocalDate(2026, 11, 10);

    test('開眼した日と翌日は記録がなくても転ばない', () {
      expect(Rules.isFallen(today: opened, createdOn: opened, lastStepOn: null), isFalse);
      expect(Rules.isFallen(today: opened.addDays(1), createdOn: opened, lastStepOn: null), isFalse);
    });

    test('記録のない日が1日あると翌日に転ぶ', () {
      expect(Rules.isFallen(today: opened.addDays(2), createdOn: opened, lastStepOn: null), isTrue);
      final last = opened.addDays(3);
      expect(Rules.isFallen(today: last.addDays(1), createdOn: opened, lastStepOn: last), isFalse);
      expect(Rules.isFallen(today: last.addDays(2), createdOn: opened, lastStepOn: last), isTrue);
      expect(Rules.missedDays(today: last.addDays(5), createdOn: opened, lastStepOn: last), 4);
    });

    test('転んでいるときの記録で起き上がる', () {
      final last = opened.addDays(3);
      expect(Rules.risesOnStep(today: last.addDays(1), createdOn: opened, lastStepOn: last), isFalse);
      expect(Rules.risesOnStep(today: last.addDays(9), createdOn: opened, lastStepOn: last), isTrue);
    });
  });

  group('Rules の数', () {
    test('残り日数と開眼からの日数', () {
      final today = LocalDate(2026, 11, 13);
      expect(Rules.daysLeft(LocalDate(2027, 1, 16), today), 64);
      expect(Rules.daysLeft(today, today), 0);
      expect(Rules.daysLeft(today.addDays(-1), today), -1);
      expect(Rules.daysSinceOpened(today, today), 1);
      expect(Rules.daysSinceOpened(today.addDays(-82), today), 83);
    });

    test('節目', () {
      expect(Rules.reachedMilestone(6), 0);
      expect(Rules.reachedMilestone(7), 7);
      expect(Rules.reachedMilestone(49), 21);
      expect(Rules.reachedMilestone(120), 100);
      expect(Rules.nextMilestone(0), 7);
      expect(Rules.nextMilestone(21), 50);
      expect(Rules.nextMilestone(100), isNull);
      expect(Rules.isMilestone(21), isTrue);
      expect(Rules.isMilestone(22), isFalse);
    });

    test('腹の文字は2〜6字', () {
      expect(Rules.isValidName('合格'), isTrue);
      expect(Rules.isValidName(' 合 '), isFalse);
      expect(Rules.isValidName('無病息災だよ'), isTrue);
      expect(Rules.isValidName('無病息災だよね'), isFalse);
    });
  });

  group('DarumaDetail', () {
    final opened = LocalDate(2026, 11, 10);
    final daruma = Daruma(
      id: 1,
      name: '合格',
      color: DarumaColor.red,
      eyeSide: EyeSide.left,
      createdOn: opened,
      deadline: LocalDate(2027, 1, 16),
      deadlineLabel: '共通テスト',
      seed: 3,
    );

    test('筆の数・起き上がり・最後の記録日', () {
      final d = DarumaDetail(
        daruma: daruma,
        checkins: [
          Checkin(id: 1, darumaId: 1, date: opened),
          Checkin(id: 2, darumaId: 1, date: opened.addDays(1)),
          Checkin(id: 3, darumaId: 1, date: opened.addDays(4)),
        ],
        recoveries: [
          Recovery(id: 1, darumaId: 1, fellAfter: opened.addDays(1), roseOn: opened.addDays(4)),
        ],
      );
      expect(d.brushCount, 3);
      expect(d.riseCount, 1);
      expect(d.lastStepOn, opened.addDays(4));
      expect(d.isFallenOn(opened.addDays(5)), isFalse);
      expect(d.isFallenOn(opened.addDays(6)), isTrue);
      expect(d.daysLeftOn(LocalDate(2026, 11, 13)), 64);
      final look = d.lookOn(opened.addDays(6));
      expect(look.brushCount, 3);
      expect(look.goldStripes, 1);
      expect(look.openedEyes, 1);
      expect(look.fallen, isTrue);
      expect(look.text, '合格');
    });

    test('満願は両目で、転ばない', () {
      final d = DarumaDetail(
        daruma: daruma.copyWith(status: DarumaStatus.completed, completedOn: opened.addDays(60)),
        checkins: const [],
        recoveries: const [],
      );
      final look = d.lookOn(opened.addDays(90));
      expect(look.openedEyes, 2);
      expect(look.fallen, isFalse);
    });
  });
}
