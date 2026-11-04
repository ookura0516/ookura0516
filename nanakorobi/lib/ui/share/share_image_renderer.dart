import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../core/entitlements.dart';
import '../../core/size_rank.dart';
import '../../model/models.dart';
import '../daruma/daruma_painter.dart';

/// 共有画像の縦横。1080×1350（4:5）と 1:1。
enum ShareAspect {
  portrait(1080, 1350),
  square(1080, 1080);

  const ShareAspect(this.width, this.height);

  final int width;
  final int height;
}

/// 共有画像に入れる文字。画面の言語で作って渡す。
class ShareTexts {
  const ShareTexts({
    required this.headline,
    required this.subline,
    this.dateLine,
    required this.appName,
  });

  /// 腹の文字の下の一行（例：「開眼から83日・起き上がり3回」）。
  final String headline;

  /// 二行目（例：本番までの残り日数や通過点）。空ならなし。
  final String subline;

  /// 満願の日付（満願のときだけ）。
  final String? dateLine;

  /// 小さなアプリ名。ストアリンクは入れない。
  final String appName;
}

/// 年末の棚ポスター（プラス）に入れる文字。
class PosterTexts {
  const PosterTexts({required this.title, required this.line, required this.appName});

  final String title;
  final String line;
  final String appName;
}

/// だるまと文字から PNG を作る。RepaintBoundary ではなく Canvas に直接描くので、
/// 画面に出していなくても作れる（テストでも同じ）。
class ShareImageRenderer {
  const ShareImageRenderer({this.brushFontFamily, this.textFontFamily});

  final String? brushFontFamily;

  /// 説明文のフォント。普段は null（端末のフォント）。ストア素材の撮影でだけ指定する。
  final String? textFontFamily;

  Future<Uint8List> renderPng({
    required DarumaLook look,
    required ShareTemplate template,
    required ShareAspect aspect,
    required ShareTexts texts,
  }) =>
      _toPng(aspect, (canvas, size) => paint(canvas, size, look: look, template: template, texts: texts));

  Future<Uint8List> renderPosterPng({
    required List<DarumaLook> looks,
    required ShareTemplate template,
    required ShareAspect aspect,
    required PosterTexts texts,
  }) =>
      _toPng(aspect, (canvas, size) => paintPoster(canvas, size, looks: looks, template: template, texts: texts));

  Future<Uint8List> _toPng(ShareAspect aspect, void Function(Canvas, Size) draw) async {
    final recorder = ui.PictureRecorder();
    final size = Size(aspect.width.toDouble(), aspect.height.toDouble());
    final canvas = Canvas(recorder, Offset.zero & size);
    draw(canvas, size);
    final picture = recorder.endRecording();
    final image = await picture.toImage(aspect.width, aspect.height);
    try {
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      return bytes!.buffer.asUint8List();
    } finally {
      image.dispose();
      picture.dispose();
    }
  }

  /// その年のだるまを棚に並べた1枚。
  void paintPoster(
    Canvas canvas,
    Size size, {
    required List<DarumaLook> looks,
    required ShareTemplate template,
    required PosterTexts texts,
  }) {
    final w = size.width;
    final h = size.height;
    final unit = w / 1080;
    _paintBackground(canvas, size, template, unit);
    final ink = template == ShareTemplate.bonfire ? const Color(0xFFF7EFDF) : const Color(0xFF2A2320);
    final dim = ink.withValues(alpha: 0.72);
    var y = _text(canvas, texts.title, w / 2, 70 * unit, 56 * unit, ink, FontWeight.w700, maxWidth: w * 0.86);
    y = _text(canvas, texts.line, w / 2, y + 8 * unit, 36 * unit, dim, FontWeight.w500, maxWidth: w * 0.86);

    // 棚：1段に最大4体、段数は必要なだけ（上限4段）。
    const perRow = 4;
    final rows = looks.isEmpty ? 1 : math.min(4, (looks.length + perRow - 1) ~/ perRow);
    final top = y + 30 * unit;
    final bottom = h - 110 * unit;
    final rowH = (bottom - top) / rows;
    final cellW = w * 0.86 / perRow;
    final shelfPaint = Paint()..color = const Color(0xFF7A5A3A);
    for (var r = 0; r < rows; r++) {
      final baseY = top + rowH * (r + 1) - 14 * unit;
      canvas.drawRect(Rect.fromLTWH(w * 0.07, baseY, w * 0.86, 12 * unit), shelfPaint);
      for (var c = 0; c < perRow; c++) {
        final i = r * perRow + c;
        if (i >= looks.length) break;
        final look = looks[i];
        final scale = SizeRank.fitScale(look.sizeRank);
        final dw = math.min(cellW * 0.9, (rowH - 30 * unit) * DarumaPainter.aspectRatio) * scale;
        final dh = dw / DarumaPainter.aspectRatio;
        final left = w * 0.07 + cellW * c + (cellW - dw) / 2;
        canvas.save();
        canvas.translate(left, baseY - dh + 4 * unit);
        DarumaPainter(look: look, brushFontFamily: brushFontFamily).paint(canvas, Size(dw, dh));
        canvas.restore();
      }
    }
    _text(canvas, texts.appName, w / 2, h - 70 * unit, 26 * unit, dim, FontWeight.w500, maxWidth: w * 0.8);
  }

  /// プレビューにも使えるよう、描く部分は分けておく。
  void paint(
    Canvas canvas,
    Size size, {
    required DarumaLook look,
    required ShareTemplate template,
    required ShareTexts texts,
  }) {
    final w = size.width;
    final h = size.height;
    final unit = w / 1080;

    _paintBackground(canvas, size, template, unit);

    // だるま：上 62% に収める。
    final darumaH = h * 0.60;
    final darumaW = math.min(w * 0.72, darumaH * DarumaPainter.aspectRatio);
    final darumaRect = Rect.fromCenter(
      center: Offset(w / 2, h * 0.08 + darumaH / 2),
      width: darumaW,
      height: darumaW / DarumaPainter.aspectRatio,
    );
    canvas.save();
    canvas.translate(darumaRect.left, darumaRect.top);
    DarumaPainter(look: look, brushFontFamily: brushFontFamily).paint(canvas, darumaRect.size);
    canvas.restore();

    final ink = template == ShareTemplate.bonfire ? const Color(0xFFF7EFDF) : const Color(0xFF2A2320);
    final dim = ink.withValues(alpha: 0.72);
    var y = darumaRect.bottom + 36 * unit;
    y = _text(canvas, texts.headline, w / 2, y, 52 * unit, ink, FontWeight.w700, maxWidth: w * 0.86);
    if (texts.subline.isNotEmpty) {
      y = _text(canvas, texts.subline, w / 2, y + 10 * unit, 38 * unit, dim, FontWeight.w500, maxWidth: w * 0.86);
    }
    final date = texts.dateLine;
    if (date != null) {
      _text(canvas, date, w / 2, y + 14 * unit, 40 * unit, const Color(0xFFC9A227), FontWeight.w700, maxWidth: w * 0.86);
    }
    _text(canvas, texts.appName, w / 2, h - 70 * unit, 26 * unit, dim, FontWeight.w500, maxWidth: w * 0.8);
  }

  double _text(
    Canvas canvas,
    String text,
    double cx,
    double top,
    double fontSize,
    Color color,
    FontWeight weight, {
    required double maxWidth,
  }) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(fontFamily: textFontFamily, fontSize: fontSize, color: color, fontWeight: weight, height: 1.3),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
      maxLines: 2,
      ellipsis: '…',
    )..layout(maxWidth: maxWidth);
    tp.paint(canvas, Offset(cx - tp.width / 2, top));
    return top + tp.height;
  }

  void _paintBackground(Canvas canvas, Size size, ShareTemplate template, double unit) {
    final rect = Offset.zero & size;
    switch (template) {
      case ShareTemplate.plain:
        canvas.drawRect(rect, Paint()..color = const Color(0xFFF7F1E6));
        _paperGrain(canvas, size, unit);
      case ShareTemplate.framed:
        canvas.drawRect(rect, Paint()..color = const Color(0xFFF7F1E6));
        _paperGrain(canvas, size, unit);
        final inset = 36 * unit;
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect.deflate(inset), Radius.circular(28 * unit)),
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 8 * unit
            ..color = const Color(0xFFC73E2E),
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect.deflate(inset + 16 * unit), Radius.circular(20 * unit)),
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2 * unit
            ..color = const Color(0xFFC9A227),
        );
      case ShareTemplate.goldScreen:
        canvas.drawRect(
          rect,
          Paint()
            ..shader = ui.Gradient.linear(
              rect.topLeft,
              rect.bottomRight,
              const [Color(0xFFF2D77A), Color(0xFFE2B94A), Color(0xFFF6E3A1)],
              const [0, 0.5, 1],
            ),
        );
        // 屏風の折り目。
        final fold = Paint()
          ..color = const Color(0xFF9C7A1F).withValues(alpha: 0.25)
          ..strokeWidth = 3 * unit;
        for (var i = 1; i < 4; i++) {
          final x = size.width * i / 4;
          canvas.drawLine(Offset(x, 0), Offset(x, size.height), fold);
        }
      case ShareTemplate.sakura:
        canvas.drawRect(rect, Paint()..color = const Color(0xFFFDF1F3));
        final petal = Paint()..color = const Color(0xFFF3B6C6).withValues(alpha: 0.7);
        for (var i = 0; i < 28; i++) {
          final x = (i * 157) % 1080 * unit;
          final y = ((i * 311) % 1350) * (size.height / 1350);
          canvas.save();
          canvas.translate(x, y);
          canvas.rotate(i * 0.7);
          canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: 44 * unit, height: 26 * unit), petal);
          canvas.restore();
        }
      case ShareTemplate.bonfire:
        canvas.drawRect(
          rect,
          Paint()
            ..shader = ui.Gradient.linear(
              rect.topCenter,
              rect.bottomCenter,
              const [Color(0xFF1B1412), Color(0xFF4A2314), Color(0xFF8A3A16)],
              const [0, 0.65, 1],
            ),
        );
        final ember = Paint()..color = const Color(0xFFFFB347).withValues(alpha: 0.8);
        for (var i = 0; i < 40; i++) {
          final x = (i * 233) % 1080 * unit;
          final y = size.height * (0.45 + ((i * 97) % 100) / 180);
          canvas.drawCircle(Offset(x, y), (3 + i % 4) * unit, ember);
        }
    }
  }

  void _paperGrain(Canvas canvas, Size size, double unit) {
    final p = Paint()..color = const Color(0xFFE6DBC6).withValues(alpha: 0.35);
    for (var i = 0; i < 60; i++) {
      final y = size.height * ((i * 53) % 100) / 100;
      final x = size.width * ((i * 29) % 100) / 100;
      canvas.drawCircle(Offset(x, y), (6 + i % 5) * unit, p);
    }
  }
}
