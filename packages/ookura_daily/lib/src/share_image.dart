import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// 共有画像の大きさ。
enum ShareImageFormat {
  /// X・Instagram のタイムラインで切れない縦長。
  portrait(1080, 1350),

  /// 正方形。
  square(1080, 1080);

  const ShareImageFormat(this.width, this.height);

  /// 出来上がる画像のピクセル数。
  final int width;
  final int height;

  /// 画像を組むときの論理サイズ。[pixelRatio] 倍して [width]×[height] になる。
  Size get logicalSize => Size(width / pixelRatio, height / pixelRatio);

  static const double pixelRatio = 3;
}

/// [child] を画面に出さずに組んで、PNG にする。
///
/// 画面上のツリーとは別の RepaintBoundary に描くので、表示中の画面の
/// 大きさや向きに左右されず、いつも [format] の大きさになる。
/// フォントや画像は、呼ぶ前に読み込んでおく（ここでは待たない）。
Future<Uint8List> renderShareImage(
  Widget child, {
  ShareImageFormat format = ShareImageFormat.portrait,
}) {
  return renderWidgetToPng(
    child,
    logicalSize: format.logicalSize,
    pixelRatio: ShareImageFormat.pixelRatio,
  );
}

/// [child] を [logicalSize]×[pixelRatio] の PNG にする。
Future<Uint8List> renderWidgetToPng(
  Widget child, {
  required Size logicalSize,
  double pixelRatio = 3,
}) async {
  final boundary = RenderRepaintBoundary();
  final view =
      WidgetsBinding.instance.platformDispatcher.implicitView ??
      WidgetsBinding.instance.platformDispatcher.views.first;
  final renderView = RenderView(
    view: view,
    child: RenderPositionedBox(alignment: Alignment.center, child: boundary),
    configuration: ViewConfiguration(
      logicalConstraints: BoxConstraints.tight(logicalSize),
      physicalConstraints: BoxConstraints.tight(logicalSize * pixelRatio),
      devicePixelRatio: pixelRatio,
    ),
  );
  final pipelineOwner = PipelineOwner()..rootNode = renderView;
  renderView.prepareInitialFrame();

  final buildOwner = BuildOwner(focusManager: FocusManager());
  final root = RenderObjectToWidgetAdapter<RenderBox>(
    container: boundary,
    child: MediaQuery(
      data: MediaQueryData(size: logicalSize, devicePixelRatio: pixelRatio),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: SizedBox.fromSize(size: logicalSize, child: child),
      ),
    ),
  ).attachToRenderTree(buildOwner);

  try {
    buildOwner
      ..buildScope(root)
      ..finalizeTree();
    pipelineOwner
      ..flushLayout()
      ..flushCompositingBits()
      ..flushPaint();

    final image = await boundary.toImage(pixelRatio: pixelRatio);
    try {
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      if (data == null) throw StateError('PNG にできませんでした');
      return data.buffer.asUint8List();
    } finally {
      image.dispose();
    }
  } finally {
    // 組んだツリーを外して、後片付けする。
    RenderObjectToWidgetAdapter<RenderBox>(
      container: boundary,
    ).attachToRenderTree(buildOwner, root);
    buildOwner.finalizeTree();
  }
}
