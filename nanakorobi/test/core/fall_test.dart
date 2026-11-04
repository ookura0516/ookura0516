import 'package:flutter_test/flutter_test.dart';
import 'package:nanakorobi/core/fall.dart';
import 'package:nanakorobi/core/local_date.dart';

LocalDate d(int day) => LocalDate(2027, 1, day);

void main() {
  const opened = LocalDate(2027, 1, 1);

  bool fallen({required int today, List<int> steps = const [], List<int> rests = const []}) =>
      FallJudge.isFallen(
        openedOn: opened,
        today: d(today),
        stepDates: steps.map(d),
        restDates: rests.map(d),
      );

  group('転倒判定', () {
    test('開眼日とその翌日は転ばない', () {
      expect(fallen(today: 1), isFalse);
      expect(fallen(today: 2), isFalse);
    });

    test('記録のない日が1日あると、翌日から転倒中', () {
      // 1日：開眼、2日：空白、3日：横倒し
      expect(fallen(today: 3), isTrue);
      // 1日：開眼、2日：記録、3日：記録、4日：空白、5日：転倒
      expect(fallen(today: 4, steps: [2, 3]), isFalse);
      expect(fallen(today: 5, steps: [2, 3]), isTrue);
    });

    test('何日空いても1回の転び。今日記録すれば立つ', () {
      expect(fallen(today: 10, steps: [2]), isTrue);
      expect(fallen(today: 10, steps: [2, 10]), isFalse);
      expect(
        FallJudge.wouldRise(openedOn: opened, today: d(10), stepDates: [d(2)], restDates: const []),
        isTrue,
      );
      expect(
        FallJudge.wouldRise(openedOn: opened, today: d(3), stepDates: [d(2)], restDates: const []),
        isFalse,
      );
    });

    test('休み券の日は空白にならない', () {
      // 2日：記録、3日：休み、4日：今日 → 立っている
      expect(fallen(today: 4, steps: [2], rests: [3]), isFalse);
      // 3日と4日が休み（月2枚）、5日：今日 → 立っている
      expect(fallen(today: 5, steps: [2], rests: [3, 4]), isFalse);
      // 3日：休み、4日：空白、5日：今日 → 転倒
      expect(fallen(today: 5, steps: [2], rests: [3]), isTrue);
    });

    test('休み券は転んだ状態を直さない', () {
      // 2日：記録、3日：空白（転ぶ）、4日：休み、5日：今日 → まだ転倒中
      expect(fallen(today: 5, steps: [2], rests: [4]), isTrue);
    });

    test('未来の日付の記録は無視する', () {
      expect(fallen(today: 5, steps: [2, 9]), isTrue);
      expect(
        FallJudge.lastStepDay(openedOn: opened, today: d(5), stepDates: [d(2), d(9)]),
        d(2),
      );
    });

    test('空白の日の一覧（カレンダーの「転んだ日」）', () {
      final gaps = FallJudge.gapDays(
        openedOn: opened,
        today: d(8),
        stepDates: [d(2), d(5)],
        restDates: [d(3)],
      );
      expect(gaps, [d(4), d(6), d(7)]);
    });
  });

  group('連続日数', () {
    int streak(int today, List<int> steps, [List<int> rests = const []]) =>
        FallJudge.streak(today: d(today), stepDates: steps.map(d), restDates: rests.map(d));

    test('今日の記録があれば今日から、なければ昨日から数える', () {
      expect(streak(5, [3, 4, 5]), 3);
      expect(streak(5, [3, 4]), 2);
      expect(streak(5, [2, 3]), 0);
    });

    test('休みの日は切れないが数えない', () {
      expect(streak(6, [3, 4, 6], [5]), 3);
    });
  });
}
