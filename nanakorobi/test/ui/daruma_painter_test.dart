import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nanakorobi/core/entitlements.dart';
import 'package:nanakorobi/core/local_date.dart';
import 'package:nanakorobi/model/models.dart';
import 'package:nanakorobi/ui/daruma/daruma_painter.dart';
import 'package:nanakorobi/ui/share/share_image_renderer.dart';

DarumaLook look({
  int strokes = 0,
  int goldLines = 0,
  EyeState eyes = EyeState.one,
  bool fallen = false,
  int colorId = 0,
  int seed = 1,
  int sizeRank = 1,
  String text = '合格',
}) =>
    DarumaLook(
      darumaId: 'd',
      text: text,
      colorId: colorId,
      seed: seed,
      strokes: strokes,
      goldLines: goldLines,
      firstEye: EyeSide.left,
      eyes: eyes,
      sizeRank: sizeRank,
      fallen: fallen,
      status: DarumaStatus.active,
      openedOn: const LocalDate(2027, 1, 1),
    );

Future<Uint8List> render(DarumaLook l, {double fall = 0, double stroke = 1}) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  DarumaPainter(look: l, fallProgress: fall, newStrokeProgress: stroke).paint(canvas, const Size(200, 250));
  final image = await recorder.endRecording().toImage(200, 250);
  final data = await image.toByteData();
  return data!.buffer.asUint8List();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('筆の数・金の筋・目・転倒で絵が変わる', () async {
    final base = await render(look());
    expect(base, isNot(equals(await render(look(strokes: 1)))));
    expect(base, isNot(equals(await render(look(goldLines: 1)))));
    expect(base, isNot(equals(await render(look(eyes: EyeState.both)))));
    expect(base, isNot(equals(await render(look(eyes: EyeState.none)))));
    expect(base, isNot(equals(await render(look(), fall: 1))));
    expect(base, isNot(equals(await render(look(colorId: 2)))));
    // テストのフォントは全部の字が同じ箱なので、字数の違いで比べる。
    expect(base, isNot(equals(await render(look(text: '無病息災')))));
  });

  test('同じだるまは同じ顔。種が違えば眉とひげが違う', () async {
    final a = await render(look(strokes: 21, seed: 10));
    final b = await render(look(strokes: 21, seed: 10));
    final c = await render(look(strokes: 21, seed: 11));
    expect(a, equals(b));
    expect(a, isNot(equals(c)));
  });

  test('節目で見た目が変わる（7・21・50・100）', () async {
    final s6 = await render(look(strokes: 6));
    final s7 = await render(look(strokes: 7));
    final s21 = await render(look(strokes: 21));
    final s50 = await render(look(strokes: 50));
    final s100 = await render(look(strokes: 100));
    expect(s6, isNot(equals(s7)));
    expect(s7, isNot(equals(s21)));
    expect(s21, isNot(equals(s50)));
    expect(s50, isNot(equals(s100)));
  });

  test('描き進みの途中と描き切りは違い、すべての段階で例外なく描ける', () async {
    final half = await render(look(strokes: 3), stroke: 0.5);
    final full = await render(look(strokes: 3), stroke: 1);
    expect(half, isNot(equals(full)));
    for (final strokes in [0, 1, 7, 8, 21, 22, 50, 51, 100, 101, 400]) {
      for (final fallen in [0.0, 0.5, 1.0]) {
        await render(look(strokes: strokes, goldLines: strokes ~/ 10, text: '無病息災'), fall: fallen);
      }
    }
    for (final color in [0, 1, 2, 5, 8, 11]) {
      await render(look(colorId: color, sizeRank: 5, text: '一二三四五六'));
    }
  });

  test('共有画像は 1080×1350 と 1:1 の PNG になる', () async {
    const renderer = ShareImageRenderer();
    const texts = ShareTexts(headline: '開眼から83日・起き上がり3回', subline: '共通テストまで 7日', appName: 'ナナコロビ');
    for (final aspect in ShareAspect.values) {
      for (final template in ShareTemplate.values) {
        final png = await renderer.renderPng(
          look: look(strokes: 83, goldLines: 3),
          template: template,
          aspect: aspect,
          texts: texts,
        );
        // PNG の署名と IHDR の幅・高さ。
        expect(png.sublist(0, 8), [137, 80, 78, 71, 13, 10, 26, 10]);
        final bd = ByteData.sublistView(png);
        expect(bd.getUint32(16), aspect.width);
        expect(bd.getUint32(20), aspect.height);
      }
    }
  });
}
