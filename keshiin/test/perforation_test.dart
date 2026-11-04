import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:keshiin/core/perforation.dart';

void main() {
  group('間隔の数', () {
    test('辺の長さを目安の間隔で割って丸める', () {
      expect(Perforation.intervalsFor(100, 10), 10);
      expect(Perforation.intervalsFor(104, 10), 10);
      expect(Perforation.intervalsFor(106, 10), 11);
    });

    test('短すぎる辺でも1以上', () {
      expect(Perforation.intervalsFor(3, 10), 1);
      expect(Perforation.intervalsFor(0, 10), 1);
    });
  });

  group('矩形の目打ち', () {
    const perf = Perforation(pitch: 9, radius: 3);
    const rect = Rect.fromLTWH(10, 20, 200, 260);

    test('穴の数は各辺の間隔の数の合計（角は1つずつ）', () {
      final nx = Perforation.intervalsFor(200, 9);
      final ny = Perforation.intervalsFor(260, 9);
      expect(perf.centersForRect(rect).length, 2 * nx + 2 * ny);
    });

    test('4つの角にちょうど穴がある', () {
      final c = perf.centersForRect(rect);
      for (final corner in [
        rect.topLeft,
        rect.topRight,
        rect.bottomRight,
        rect.bottomLeft,
      ]) {
        expect(
          c.where((p) => (p - corner).distance < 1e-9).length,
          1,
          reason: '$corner',
        );
      }
    });

    test('同じ辺の上では間隔がすべて等しい（角をまたいでも）', () {
      final c = perf.centersForRect(rect);
      final top = c.where((p) => (p.dy - rect.top).abs() < 1e-9).toList()
        ..add(rect.topRight)
        ..sort((a, b) => a.dx.compareTo(b.dx));
      final uniqueTop = <Offset>[];
      for (final p in top) {
        if (uniqueTop.isEmpty || (uniqueTop.last - p).distance > 1e-9) {
          uniqueTop.add(p);
        }
      }
      final gaps = [
        for (var i = 1; i < uniqueTop.length; i++)
          uniqueTop[i].dx - uniqueTop[i - 1].dx,
      ];
      for (final g in gaps) {
        expect(g, closeTo(200 / Perforation.intervalsFor(200, 9), 1e-9));
      }
    });

    test('実際の間隔は目安から半分以上ずれない', () {
      for (final len in [37.0, 64.0, 100.0, 333.3, 999.0]) {
        final pitches = actualPitches([
          const Offset(0, 0),
          Offset(len, 0),
          Offset(len, len * 1.3),
          Offset(0, len * 1.3),
        ], 9);
        for (final p in pitches) {
          expect(
            (p - 9).abs(),
            lessThanOrEqualTo(4.5 + 1e-9),
            reason: 'len=$len',
          );
        }
      }
    });

    test('穴の中心に重複がない', () {
      final c = perf.centersForRect(rect);
      for (var i = 0; i < c.length; i++) {
        for (var j = i + 1; j < c.length; j++) {
          expect((c[i] - c[j]).distance, greaterThan(1));
        }
      }
    });

    test('くり抜いたパス：穴の中は紙でなく、内側は紙', () {
      final path = perf.cutRect(rect);
      // 角の穴の中（矩形の内側に入った四分円の部分）
      expect(path.contains(rect.topLeft + const Offset(1, 1)), isFalse);
      // 辺の途中の穴の中
      final c = perf.centersForRect(rect)[3];
      expect(path.contains(c + const Offset(0, 1.5)), isFalse);
      // 穴と穴のあいだの縁は紙
      final c2 = perf.centersForRect(rect)[4];
      final mid = Offset((c.dx + c2.dx) / 2, rect.top + 0.5);
      expect(path.contains(mid), isTrue);
      // 中央は紙
      expect(path.contains(rect.center), isTrue);
      // 外は紙でない
      expect(path.contains(rect.topLeft - const Offset(2, 2)), isFalse);
    });
  });

  group('多角形の目打ち（三角・菱形）', () {
    test('正三角形でも各頂点に穴があり、辺ごとに等間隔', () {
      const perf = Perforation(pitch: 10, radius: 3);
      final h = 100 * math.sqrt(3) / 2;
      final tri = [const Offset(50, 0), Offset(100, h), Offset(0, h)];
      final c = perf.centersForPolygon(tri);
      for (final v in tri) {
        expect(c.any((p) => (p - v).distance < 1e-9), isTrue);
      }
      expect(c.length, 3 * Perforation.intervalsFor(100, 10));
      expect(actualPitches(tri, 10).toSet().length, 1);
    });
  });
}
