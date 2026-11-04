import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// 結果画像の大きさ。X・Instagram で切れない縦長と、正方形。
enum ResultImageSize {
  portrait(1080, 1350, '縦長'),
  square(1080, 1080, '正方形');

  const ResultImageSize(this.width, this.height, this.label);
  final int width;
  final int height;
  final String label;

  double get aspect => width / height;
}

/// RepaintBoundary の中身を PNG にする。[key] は RepaintBoundary に付けたもの。
/// 画面上の大きさによらず、幅が [size].width ピクセルになるよう拡大して描く。
Future<List<int>?> captureBoundary(GlobalKey key, ResultImageSize size) async {
  final obj = key.currentContext?.findRenderObject();
  if (obj is! RenderRepaintBoundary) return null;
  final ratio = size.width / obj.size.width;
  final image = await obj.toImage(pixelRatio: ratio);
  final data = await image.toByteData(format: ui.ImageByteFormat.png);
  image.dispose();
  return data?.buffer.asUint8List();
}
