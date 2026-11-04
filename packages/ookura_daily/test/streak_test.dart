import 'package:flutter_test/flutter_test.dart';
import 'package:ookura_daily/ookura_daily.dart';

void main() {
  test('記録がなければ0', () {
    expect(computeStreak([], 10), StreakSummary.zero);
  });

  test('今日まで続いている', () {
    expect(
      computeStreak([8, 9, 10], 10),
      const StreakSummary(current: 3, longest: 3),
    );
  });

  test('今日まだでも昨日まで続いていれば途切れない', () {
    expect(computeStreak([7, 8, 9], 10).current, 3);
  });

  test('一昨日で止まっていたら0', () {
    expect(computeStreak([7, 8], 10).current, 0);
  });

  test('最長は途中の山を数える', () {
    expect(
      computeStreak([1, 2, 3, 4, 6, 9, 10], 10),
      const StreakSummary(current: 2, longest: 4),
    );
  });

  test('重複と未来の番号は無視する', () {
    expect(
      computeStreak([5, 5, 6, 12], 6),
      const StreakSummary(current: 2, longest: 2),
    );
  });
}
