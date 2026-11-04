import 'package:flutter_test/flutter_test.dart';
import 'package:nanakorobi/core/strokes.dart';

void main() {
  group('筆の順番', () {
    test('眉→ひげ→腹の文字の縁→衣', () {
      expect(StrokePlan.zoneOf(1), StrokeZone.eyebrow);
      expect(StrokePlan.zoneOf(7), StrokeZone.eyebrow);
      expect(StrokePlan.zoneOf(8), StrokeZone.beard);
      expect(StrokePlan.zoneOf(21), StrokeZone.beard);
      expect(StrokePlan.zoneOf(22), StrokeZone.bellyOutline);
      expect(StrokePlan.zoneOf(50), StrokeZone.bellyOutline);
      expect(StrokePlan.zoneOf(51), StrokeZone.robe);
      expect(StrokePlan.zoneOf(100), StrokeZone.robe);
      expect(StrokePlan.zoneOf(300), StrokeZone.robe);
    });

    test('部位ごとの本数', () {
      expect(StrokePlan.eyebrowCount(0), 0);
      expect(StrokePlan.eyebrowCount(3), 3);
      expect(StrokePlan.eyebrowCount(30), 7);
      expect(StrokePlan.beardCount(7), 0);
      expect(StrokePlan.beardCount(10), 3);
      expect(StrokePlan.beardCount(99), 14);
      expect(StrokePlan.bellyCount(21), 0);
      expect(StrokePlan.bellyCount(50), 29);
      expect(StrokePlan.robeCount(50), 0);
      expect(StrokePlan.robeCount(100), 50);
      expect(StrokePlan.robeCount(130), 80);
    });
  });

  group('節目', () {
    test('ちょうど達した日だけ reachedAt が返る', () {
      expect(StrokeMilestone.reachedAt(6), isNull);
      expect(StrokeMilestone.reachedAt(7), StrokeMilestone.day7);
      expect(StrokeMilestone.reachedAt(8), isNull);
      expect(StrokeMilestone.reachedAt(21), StrokeMilestone.day21);
      expect(StrokeMilestone.reachedAt(50), StrokeMilestone.day50);
      expect(StrokeMilestone.reachedAt(100), StrokeMilestone.day100);
    });

    test('highest と next', () {
      expect(StrokeMilestone.highest(0), isNull);
      expect(StrokeMilestone.highest(7), StrokeMilestone.day7);
      expect(StrokeMilestone.highest(49), StrokeMilestone.day21);
      expect(StrokeMilestone.highest(500), StrokeMilestone.day100);
      expect(StrokeMilestone.next(0), StrokeMilestone.day7);
      expect(StrokeMilestone.next(7), StrokeMilestone.day21);
      expect(StrokeMilestone.next(100), isNull);
    });
  });
}
