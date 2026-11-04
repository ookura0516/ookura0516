import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../model/models.dart';
import '../paint/daruma_painter.dart';

/// 共有画像の文言（表示言語に合わせて呼び出し側が渡す）。
class ShareCardStrings {
  const ShareCardStrings({
    required this.appName,
    required this.progress,
    this.completed,
  });

  /// 小さなアプリ名。
  final String appName;

  /// 「開眼から83日・起き上がり3回」
  final String progress;

  /// 満願なら「満願 2027.01.16」。
  final String? completed;
}

/// 共有画像（1080×1350）。だるま、腹の文字、開眼からの日数と起き上がり回数、満願の日付、
/// 小さなアプリ名。ストアリンクは入れない。
Future<Uint8List> renderShareCard(DarumaLook look, ShareCardStrings s) async {
  const w = 1080.0;
  const h = 1350.0;
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);

  // 和紙のような背景。
  canvas.drawRect(
    const Rect.fromLTWH(0, 0, w, h),
    Paint()
      ..shader = ui.Gradient.radial(
        const Offset(540, 520),
        900,
        const [Color(0xFFF8F1E4), Color(0xFFEFE4CF), Color(0xFFE6D8BF)],
        const [0.0, 0.7, 1.0],
      ),
  );

  // だるま（台座つき）。
  canvas.save();
  canvas.translate(190, 110);
  DarumaPainter(look.copyWith(fallen: false)).paint(canvas, const Size(700, 887));
  canvas.restore();

  // 文。
  final ink = const Color(0xFF2A221C);
  final muted = const Color(0xFF6B5A4A);
  final progress = _text(s.progress, 46, ink, bold: true);
  progress.paint(canvas, Offset((w - progress.width) / 2, 1060));
  if (s.completed != null) {
    final done = _text(s.completed!, 54, const Color(0xFFC3262A), bold: true);
    done.paint(canvas, Offset((w - done.width) / 2, 1130));
  }
  final name = _text(s.appName, 30, muted);
  name.paint(canvas, Offset(w - name.width - 56, h - 80));

  final picture = recorder.endRecording();
  final image = await picture.toImage(w.toInt(), h.toInt());
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  return bytes!.buffer.asUint8List();
}

TextPainter _text(String text, double size, Color color, {bool bold = false}) {
  return TextPainter(
    text: TextSpan(
      text: text,
      style: TextStyle(
        color: color,
        fontSize: size,
        fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
        letterSpacing: 1,
      ),
    ),
    textDirection: TextDirection.ltr,
  )..layout();
}
