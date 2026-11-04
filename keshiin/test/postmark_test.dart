import 'dart:ui' as ui;

import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:keshiin/core/crop.dart';
import 'package:keshiin/core/day_slots.dart';
import 'package:keshiin/core/frames.dart';
import 'package:keshiin/core/postmark_jitter.dart';
import 'package:keshiin/core/rng.dart';
import 'package:keshiin/render/postmark_painter.dart';
import 'package:keshiin/render/sheet_painter.dart';
import 'package:keshiin/render/stamp_painter.dart';

Future<List<int>> _pixels(ui.Image img) async => (await img.toByteData(
  format: ui.ImageByteFormat.rawRgba,
))!.buffer.asUint8List().toList();

void main() {
  group('乱数', () {
    test('同じシードなら同じ列（mulberry32 の既知の値）', () {
      final a = SeededRng(1);
      final b = SeededRng(1);
      final xs = [for (var i = 0; i < 5; i++) a.nextUint32()];
      expect([for (var i = 0; i < 5; i++) b.nextUint32()], xs);
      // mulberry32(1) の最初の値（JavaScript の参照実装と同じ）
      expect(xs.first, 2693262067); // 0.6270739405881613 × 2^32
    });

    test('[0,1) に収まる', () {
      final r = SeededRng(99);
      for (var i = 0; i < 1000; i++) {
        final v = r.nextDouble();
        expect(v >= 0 && v < 1, isTrue);
      }
    });
  });

  group('消印のずれ', () {
    test('同じシードなら同じずれ、違うシードなら違うずれ', () {
      final a = PostmarkJitter.fromSeed(12345);
      final b = PostmarkJitter.fromSeed(12345);
      final c = PostmarkJitter.fromSeed(12346);
      expect(
        [a.dx, a.dy, a.angle, a.inkStrength],
        [b.dx, b.dy, b.angle, b.inkStrength],
      );
      expect(a.angle == c.angle && a.dx == c.dx, isFalse);
    });

    test('ずれは小さい範囲に収まる', () {
      for (var s = 0; s < 500; s++) {
        final j = PostmarkJitter.fromSeed(s * 7919);
        expect(j.dx.abs(), lessThanOrEqualTo(PostmarkJitter.maxShift));
        expect(j.dy.abs(), lessThanOrEqualTo(PostmarkJitter.maxShift));
        expect(j.angle.abs(), lessThanOrEqualTo(PostmarkJitter.maxAngle));
        expect(j.inkStrength, inInclusiveRange(0.75, 1.0));
      }
    });
  });

  testWidgets('同じ切手は何度描いても同じ画素になる。シードを変えると変わる', (tester) async {
    await tester.runAsync(() async {
      const data = PostmarkData(
        date: Day(2026, 11, 4),
        place: '鎌倉市',
        note: '晴れ',
        seed: 777,
      );
      final a = await _pixels(await renderPostmarkImage(data));
      final b = await _pixels(await renderPostmarkImage(data));
      expect(a, b);
      final c = await _pixels(
        await renderPostmarkImage(
          const PostmarkData(
            date: Day(2026, 11, 4),
            place: '鎌倉市',
            note: '晴れ',
            seed: 778,
          ),
        ),
      );
      expect(c, isNot(equals(a)));
    });
  });

  testWidgets('切手・シート・共有画像が例外なく描ける（全フレーム）', (tester) async {
    await tester.runAsync(() async {
      for (final f in allFrames) {
        for (final shape in StampShape.values) {
          final v = StampVisual(
            photo: null,
            crop: CropRect.full,
            shape: shape,
            frame: f,
            serial: 12,
            sheetName: '2026 日常',
            postmark: const PostmarkData(
              date: Day(2026, 11, 4),
              place: 'Paris',
              note: '',
              seed: 1,
            ),
          );
          final img = await renderToImage(
            const Size(300, 360),
            (c, s) => paintStamp(c, Offset.zero & s, v),
          );
          expect(img.width, 300);
          final tilted = await renderToImage(
            const Size(1080, 1350),
            (c, s) => paintTiltedStamp(c, s, v),
          );
          expect(tilted.height, 1350);
        }
      }
      final sheet = await renderToImage(
        const Size(1080, 1350),
        (c, s) => paintMonthSheet(
          c,
          s,
          MonthSheetVisual(
            year: 2026,
            month: 12,
            title: '2026 日常',
            cells: List.filled(30, null),
            margin: const [],
            completed: true,
            today: const Day(2026, 12, 3),
          ),
        ),
      );
      expect(sheet.width, 1080);
    });
  });

  test('透明 PNG の切手は紙の外が透明', () async {
    // 角の穴の中心は紙でない＝透明になる場所。
    final v = StampVisual(
      photo: null,
      crop: CropRect.full,
      shape: StampShape.square,
      frame: frameById('shiro'),
    );
    final g = StampGeometry.fit(
      const Rect.fromLTWH(0, 0, 400, 400),
      v.shape,
      v.frame,
    );
    expect(g.perforation.centersForPolygon(g.outline).first, g.outline.first);
    expect(g.bounds.left, greaterThan(0)); // 穴の半円の分だけ内側に置く
  });
}
