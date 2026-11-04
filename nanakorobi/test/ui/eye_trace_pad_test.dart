import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nanakorobi/core/local_date.dart';
import 'package:nanakorobi/model/models.dart';
import 'package:nanakorobi/ui/daruma/daruma_painter.dart';
import 'package:nanakorobi/ui/widgets/eye_trace_pad.dart';

const look = DarumaLook(
  darumaId: 'd',
  text: '合格',
  colorId: 0,
  seed: 1,
  strokes: 0,
  goldLines: 0,
  firstEye: EyeSide.left,
  eyes: EyeState.none,
  sizeRank: 1,
  fallen: false,
  status: DarumaStatus.active,
  openedOn: LocalDate(2027, 1, 1),
);

Future<void> sweep(WidgetTester tester, Offset center, double r, {required bool inside}) async {
  final start = inside ? center + Offset(-r * 0.7, 0) : center + Offset(0, r * 3);
  final g = await tester.startGesture(start);
  for (var i = 1; i <= 7; i++) {
    await g.moveBy(Offset(r * 0.2, 0));
    await tester.pump(const Duration(milliseconds: 16));
  }
  for (var i = 1; i <= 7; i++) {
    await g.moveBy(Offset(-r * 0.2, 0));
    await tester.pump(const Duration(milliseconds: 16));
  }
  await g.up();
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('目の中をなぞると onTraced、外をなぞっても呼ばれない', (tester) async {
    var traced = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ListView(
            children: [
              Center(
                child: SizedBox(
                  width: 300,
                  child: EyeTracePad(
                    key: const Key('pad'),
                    look: look,
                    targetEye: EyeSide.left,
                    onTraced: () => traced++,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    final rect = tester.getRect(find.byKey(const Key('pad')));
    final scale = math.min(rect.width / DarumaPainter.boxWidth, rect.height / DarumaPainter.boxHeight);
    final origin = Offset(
      rect.left + (rect.width - DarumaPainter.boxWidth * scale) / 2,
      rect.top + (rect.height - DarumaPainter.boxHeight * scale) / 2,
    );
    final center = DarumaPainter.eyeCenter(EyeSide.left) * scale + origin;
    final r = DarumaPainter.eyeRadius * scale;

    await sweep(tester, center, r, inside: false);
    expect(traced, 0);
    await sweep(tester, center, r, inside: true);
    expect(traced, 1);
    // 右目をなぞっても左目は開かない
    final other = DarumaPainter.eyeCenter(EyeSide.right) * scale + origin;
    await sweep(tester, other, r, inside: true);
    expect(traced, 1);
  });
}
