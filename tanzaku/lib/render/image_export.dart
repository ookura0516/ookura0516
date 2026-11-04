import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';

/// [painter] を [size] の PNG にする。プレビューと同じ CustomPainter で描くので、見た目が一致する。
Future<Uint8List> renderPng(CustomPainter painter, Size size) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder, Offset.zero & size);
  painter.paint(canvas, size);
  final picture = recorder.endRecording();
  final image = await picture.toImage(size.width.round(), size.height.round());
  final data = await image.toByteData(format: ui.ImageByteFormat.png);
  image.dispose();
  picture.dispose();
  return data!.buffer.asUint8List();
}
