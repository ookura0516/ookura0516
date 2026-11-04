import 'dart:convert';

import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:tanzaku/core/japanese_date.dart';
import 'package:tanzaku/core/month_day.dart';
import 'package:tanzaku/core/review_policy.dart';
import 'package:tanzaku/core/streak.dart';
import 'package:tanzaku/render/style.dart';

void main() {
  group('連続日数', () {
    final today = DateTime(2026, 11, 4);
    DateTime d(int back) => DateTime(2026, 11, 4 - back);

    test('今日まで続いている', () {
      final s = computeStreak([d(0), d(1), d(2), d(5)], today);
      expect(s.days, 3);
      expect(s.composedToday, isTrue);
      expect(s.canRevive, isFalse);
    });

    test('今日まだでも昨日まで続いていれば数える', () {
      final s = computeStreak([d(1), d(2)], today);
      expect(s.days, 2);
      expect(s.composedToday, isFalse);
    });

    test('昨日が抜けたら0日。おとといまで続いていれば昨日の分で復活できる', () {
      final s = computeStreak([d(2), d(3)], today);
      expect(s.days, 0);
      expect(s.canRevive, isTrue);
      // 昨日の分を詠むと、また続く
      final s2 = computeStreak([d(1), d(2), d(3)], today);
      expect(s2.days, 3);
    });

    test('2日以上抜けたら復活できない', () {
      expect(computeStreak([d(3), d(4)], today).canRevive, isFalse);
      expect(computeStreak(const [], today).days, 0);
    });

    test('同じ日に何句詠んでも1日', () {
      expect(
        computeStreak([d(0), d(0), DateTime(2026, 11, 4, 22)], today).days,
        1,
      );
    });

    test('月をまたいでも数える', () {
      final s = computeStreak([
        DateTime(2026, 11, 1),
        DateTime(2026, 10, 31),
        DateTime(2026, 10, 30),
      ], DateTime(2026, 11, 1));
      expect(s.days, 3);
    });
  });

  group('漢数字と和暦', () {
    test('漢数字', () {
      expect(kanjiNumber(1), '一');
      expect(kanjiNumber(10), '十');
      expect(kanjiNumber(24), '二十四');
      expect(kanjiNumber(108), '百八');
      expect(kanjiNumber(2026), '二千二十六');
    });
    test('和暦の日付', () {
      expect(japaneseDate(DateTime(2026, 11, 4)), '令和八年十一月四日');
      expect(japaneseDate(DateTime(2019, 5, 1)), '令和元年五月一日');
      expect(wafuMonth(11), '霜月');
    });
  });

  group('月日', () {
    test('年をまたぐ期間', () {
      final s = MonthDay.parse('12-07'), e = MonthDay.parse('01-04');
      expect(MonthDay(12, 31).within(s, e), isTrue);
      expect(MonthDay(1, 4).within(s, e), isTrue);
      expect(MonthDay(1, 5).within(s, e), isFalse);
    });
    test('ありえない日付は読めない', () {
      expect(() => MonthDay.parse('02-30'), throwsFormatException);
      expect(() => MonthDay.parse('1-1'), throwsFormatException);
    });
  });

  group('評価依頼', () {
    final now = DateTime(2026, 11, 4);
    test('10句目・30句目・100句目だけ', () {
      for (final n in [1, 7, 9, 11, 29, 50]) {
        expect(
          shouldAskForReview(
            haikuCount: n,
            askedAt: const [],
            askedMilestones: const {},
            now: now,
          ),
          isFalse,
        );
      }
      for (final n in [10, 30, 100]) {
        expect(
          shouldAskForReview(
            haikuCount: n,
            askedAt: const [],
            askedMilestones: const {},
            now: now,
          ),
          isTrue,
        );
      }
    });
    test('同じ区切りでは2度出さず、365日に3回まで', () {
      expect(
        shouldAskForReview(
          haikuCount: 10,
          askedAt: [now],
          askedMilestones: {10},
          now: now,
        ),
        isFalse,
      );
      final three = [
        for (var i = 1; i <= 3; i++) now.subtract(Duration(days: i * 30)),
      ];
      expect(
        shouldAskForReview(
          haikuCount: 100,
          askedAt: three,
          askedMilestones: {10, 30},
          now: now,
        ),
        isFalse,
      );
      final old = [
        for (var i = 1; i <= 3; i++) now.subtract(Duration(days: 400 + i)),
      ];
      expect(
        shouldAskForReview(
          haikuCount: 100,
          askedAt: old,
          askedMilestones: {10, 30},
          now: now,
        ),
        isTrue,
      );
    });
  });

  group('短冊の見た目', () {
    test('有料の要素の判定と、無料の範囲への戻し', () {
      const free = TanzakuStyle();
      expect(free.premium, isFalse);
      final paid = free.copyWith(
        font: TanzakuFont.yuji,
        washi: Washi.ai,
        form: TanzakuForm.shikishi,
      );
      expect(paid.premium, isTrue);
      expect(paid.freeOnly, free);
      expect(
        free.copyWith(seal: const SealStyle(shape: SealShape.round)).premium,
        isTrue,
      );
      expect(free.copyWith(showDate: false, showSeal: false).premium, isFalse);
    });
    test('JSON に保存して戻せる', () {
      final s = const TanzakuStyle().copyWith(
        font: TanzakuFont.shippori,
        washi: Washi.kinsunago,
        seal: const SealStyle(
          carve: SealCarve.shubun,
          color: Color(0xFF2E3A5C),
        ),
        showDate: false,
      );
      expect(
        TanzakuStyle.fromJson(
          jsonDecode(jsonEncode(s.toJson())) as Map<String, Object?>,
        ),
        s,
      );
    });
  });
}
