import 'package:flutter_test/flutter_test.dart';
import 'package:nanakorobi/core/daruma_colors.dart';
import 'package:nanakorobi/core/entitlements.dart';
import 'package:nanakorobi/core/local_date.dart';
import 'package:nanakorobi/core/review_policy.dart';
import 'package:nanakorobi/core/rng.dart';
import 'package:nanakorobi/core/validation.dart';

void main() {
  group('無料とプラス', () {
    test('無料は現役1体、色は赤・白・黒', () {
      expect(Entitlements.canAddActive(activeCount: 0, hasPlus: false), isTrue);
      expect(Entitlements.canAddActive(activeCount: 1, hasPlus: false), isFalse);
      expect(Entitlements.canAddActive(activeCount: 5, hasPlus: true), isTrue);
      expect(Entitlements.colorAllowed(colorId: DarumaColor.red.id, hasPlus: false), isTrue);
      expect(Entitlements.colorAllowed(colorId: DarumaColor.white.id, hasPlus: false), isTrue);
      expect(Entitlements.colorAllowed(colorId: DarumaColor.black.id, hasPlus: false), isTrue);
      expect(Entitlements.colorAllowed(colorId: DarumaColor.gold.id, hasPlus: false), isFalse);
      expect(Entitlements.colorAllowed(colorId: DarumaColor.gold.id, hasPlus: true), isTrue);
      expect(DarumaColor.values.length, Entitlements.colorCount);
    });

    test('共有テンプレは無料2種、プラス全種', () {
      expect(Entitlements.templates(false).length, 2);
      expect(Entitlements.templates(true).length, ShareTemplate.values.length);
      expect(Entitlements.canExport(false), isFalse);
      expect(Entitlements.canPoster(true), isTrue);
    });
  });

  group('評価依頼', () {
    test('365日に3回まで', () {
      const today = LocalDate(2027, 3, 1);
      expect(
        ReviewPromptPolicy.shouldPrompt(
          occasion: ReviewOccasion.milestone7,
          today: today,
          promptedOn: const [],
        ),
        isTrue,
      );
      final three = [
        const LocalDate(2026, 6, 1),
        const LocalDate(2026, 9, 1),
        const LocalDate(2027, 1, 1),
      ];
      expect(
        ReviewPromptPolicy.shouldPrompt(occasion: ReviewOccasion.completed, today: today, promptedOn: three),
        isFalse,
      );
      // 1年以上前の分は数えない
      final old = [const LocalDate(2026, 2, 1), ...three.skip(1)];
      expect(
        ReviewPromptPolicy.shouldPrompt(occasion: ReviewOccasion.completed, today: today, promptedOn: old),
        isTrue,
      );
    });
  });

  group('決定的な乱数', () {
    test('同じ種なら同じ列、違う種なら違う列', () {
      final a = DeterministicRng(123);
      final b = DeterministicRng(123);
      final c = DeterministicRng(124);
      final la = List.generate(5, (_) => a.nextInt32());
      final lb = List.generate(5, (_) => b.nextInt32());
      final lc = List.generate(5, (_) => c.nextInt32());
      expect(la, lb);
      expect(la, isNot(lc));
      expect(DeterministicRng(0).nextInt32(), isNot(0));
      for (var i = 0; i < 100; i++) {
        final v = a.nextDouble();
        expect(v, inInclusiveRange(0.0, 0.999999999));
      }
    });
  });

  group('入力の決まり', () {
    test('腹の文字は2〜6字、空白なし', () {
      expect(Limits.nameOk('合格'), isTrue);
      expect(Limits.nameOk('無病息災'), isTrue);
      expect(Limits.nameOk('一二三四五六'), isTrue);
      expect(Limits.nameOk('一'), isFalse);
      expect(Limits.nameOk('一二三四五六七'), isFalse);
      expect(Limits.nameOk('合 格'), isFalse);
      expect(Limits.memoOk('あ' * 30), isTrue);
      expect(Limits.memoOk('あ' * 31), isFalse);
    });
  });
}
