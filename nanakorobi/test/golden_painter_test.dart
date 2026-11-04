// だるまの描画を目で確かめるためのゴールデン。
//   flutter test --update-goldens test/golden_painter_test.dart
// で test/goldens/*.png が書き出される。
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nanakorobi/model/models.dart';
import 'package:nanakorobi/paint/daruma_painter.dart';

Future<void> _loadFont() async {
  final loader = FontLoader('YujiSyuku')
    ..addFont(rootBundle.load('assets/fonts/YujiSyuku-Regular.ttf'));
  await loader.load();
}

Widget _grid(List<DarumaLook> looks) {
  return Directionality(
    textDirection: TextDirection.ltr,
    child: Container(
      color: const Color(0xFFF3ECDF),
      child: Wrap(
        children: [
          for (final l in looks)
            SizedBox(
              width: 240,
              height: 304,
              child: CustomPaint(painter: DarumaPainter(l)),
            ),
        ],
      ),
    ),
  );
}

void main() {
  setUpAll(_loadFont);

  testWidgets('筆の数で模様が増える', (tester) async {
    tester.view.physicalSize = const Size(1200, 920);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final looks = [
      for (final n in [0, 3, 7, 12, 21, 35, 50, 75, 100, 130])
        DarumaLook(color: DarumaColor.red, text: '合格', brushCount: n, goldStripes: n ~/ 10, seed: 7),
    ];
    await tester.pumpWidget(_grid(looks));
    await expectLater(find.byType(Wrap), matchesGoldenFile('goldens/brush_progression.png'));
  });

  testWidgets('色・目・転倒・文字数', (tester) async {
    tester.view.physicalSize = const Size(1200, 920);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final looks = [
      const DarumaLook(color: DarumaColor.red, text: '合格', brushCount: 12, goldStripes: 2, openedEyes: 0, seed: 1),
      const DarumaLook(color: DarumaColor.red, text: '合格', brushCount: 12, goldStripes: 2, openedEyes: 2, seed: 1),
      const DarumaLook(color: DarumaColor.red, text: '合格', brushCount: 12, goldStripes: 2, fallen: true, seed: 1),
      const DarumaLook(color: DarumaColor.white, text: '必勝', brushCount: 25, goldStripes: 5, seed: 2),
      const DarumaLook(color: DarumaColor.black, text: '家内安全', brushCount: 60, goldStripes: 14, seed: 3),
      const DarumaLook(color: DarumaColor.red, text: '毎日英語', brushCount: 7, eyeSide: EyeSide.right, seed: 4),
      const DarumaLook(color: DarumaColor.red, text: '無病息災だ', brushCount: 0, seed: 5),
      const DarumaLook(color: DarumaColor.white, text: '走る', brushCount: 3, fallen: true, seed: 6),
      const DarumaLook(color: DarumaColor.black, text: '禁酒九十日', brushCount: 101, goldStripes: 1, seed: 8),
      const DarumaLook(color: DarumaColor.red, text: '貯金', brushCount: 49, seed: 9),
    ];
    await tester.pumpWidget(_grid(looks));
    await expectLater(find.byType(Wrap), matchesGoldenFile('goldens/variants.png'));
  });
}
