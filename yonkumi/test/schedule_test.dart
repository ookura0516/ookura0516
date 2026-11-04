import 'package:flutter_test/flutter_test.dart';
import 'package:yonkumi/core/schedule.dart';

import 'fakes.dart';

void main() {
  group('日替わり（日本時間の0時）', () {
    test('第1問は第1日の0時から', () {
      expect(kClock.dayNumberAt(jst(2026, 11, 1, 0)), 1);
      expect(kClock.dayNumberAt(jst(2026, 10, 31, 23)), 0);
    });

    test('23時台は同じ問題、0時で次の問題', () {
      expect(kClock.dayNumberAt(jst(2026, 11, 4, 23)), 4);
      expect(kClock.dayNumberAt(jst(2026, 11, 5, 0)), 5);
    });

    test('次の切り替えは日本時間の0時（UTC 15時）', () {
      expect(
        kClock.nextSwitchAfter(jst(2026, 11, 4, 8)),
        DateTime.utc(2026, 11, 4, 15),
      );
    });
  });

  group('どの問題を出すか', () {
    const s = PuzzleSchedule(count: 30);

    test('問題があるうちは第N日に第N問', () {
      for (var d = 1; d <= 30; d++) {
        expect(s.puzzleFor(d), d);
        expect(s.isRerun(d), isFalse);
      }
      expect(s.puzzleFor(0), isNull);
    });

    test('尽きたら、それまでの問題から日付で決まる1問', () {
      for (var d = 31; d <= 400; d++) {
        final n = s.puzzleFor(d)!;
        expect(n, inInclusiveRange(1, 30));
        expect(s.isRerun(d), isTrue);
        // 同じ日はいつ聞いても同じ（全員が同じ問題）
        expect(s.puzzleFor(d), n);
        // 前の日と同じ問題は続かない
        expect(n, isNot(s.puzzleFor(d - 1)), reason: '第$d日');
      }
    });

    test('再出題はまんべんなく散る', () {
      final seen = {for (var d = 31; d <= 330; d++) s.puzzleFor(d)};
      expect(seen.length, greaterThan(25));
    });

    test('問題がなければ null', () {
      expect(const PuzzleSchedule(count: 0).puzzleFor(5), isNull);
      expect(const PuzzleSchedule(count: 1).puzzleFor(5), 1);
    });
  });
}
