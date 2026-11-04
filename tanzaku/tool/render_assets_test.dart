// アイコン・スプラッシュ・ストアのフィーチャーグラフィックを描いて書き出す。
//   flutter test tool/render_assets_test.dart --dart-define=WRITE=true
// そのあと:
//   dart run flutter_launcher_icons
//   dart run flutter_native_splash:create
import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tanzaku/render/image_export.dart';
import 'package:tanzaku/render/style.dart';
import 'package:tanzaku/render/tanzaku_painter.dart';
import 'package:tanzaku/render/washi.dart';

const shu = Color(0xFFA8322C); // アイコンの地（朱）。ひそかぎの紺と見分けがつくように
const shuDark = Color(0xFF7E211D);

Future<void> _font(String family, String path) async {
  final loader = FontLoader(family)
    ..addFont(Future.value(ByteData.sublistView(File(path).readAsBytesSync())));
  await loader.load();
}

/// 短冊1枚（紙・紐・字「句」・落款）。[center] に、高さ [h] で、[angle] 傾けて描く。
void paintStrip(
  Canvas canvas,
  Offset center,
  double h,
  double angle, {
  bool shadow = true,
}) {
  final w = h / 4.2;
  canvas.save();
  canvas.translate(center.dx, center.dy);
  canvas.rotate(angle);
  final paper = Rect.fromCenter(center: Offset.zero, width: w, height: h);
  // 紐
  final string = Paint()
    ..color = const Color(0xFFE2C26A)
    ..strokeWidth = w * 0.035
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round;
  final hole = Offset(0, paper.top + w * 0.16);
  canvas.drawPath(
    Path()
      ..moveTo(hole.dx, hole.dy)
      ..quadraticBezierTo(
        -w * 0.18,
        paper.top - w * 0.35,
        0,
        paper.top - w * 0.6,
      ),
    string,
  );
  if (shadow) {
    canvas.drawRect(
      paper.shift(Offset(w * 0.05, w * 0.07)),
      Paint()
        ..color = const Color(0x55000000)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, w * 0.06),
    );
  }
  canvas.save();
  canvas.clipRect(paper);
  paintWashi(canvas, paper, Washi.kinari);
  canvas.restore();
  canvas.drawCircle(hole, w * 0.04, Paint()..color = const Color(0xFF9C8B74));
  // 字
  final tp = TextPainter(
    text: TextSpan(
      text: '句',
      style: TextStyle(
        fontFamily: 'YujiSyuku',
        fontSize: w * 0.78,
        height: 1,
        color: const Color(0xFF231C17),
      ),
    ),
    textDirection: TextDirection.ltr,
  )..layout();
  tp.paint(canvas, Offset(-tp.width / 2, paper.top + h * 0.2));
  // 落款
  final s = w * 0.3;
  paintSeal(
    canvas,
    Rect.fromCenter(
      center: Offset(0, paper.bottom - h * 0.16),
      width: s,
      height: s,
    ),
    '',
    const SealStyle(),
    'NotoSerifJP',
  );
  canvas.restore();
}

class IconPainter extends CustomPainter {
  IconPainter({required this.background, this.scale = 1});
  final bool background;
  final double scale;

  @override
  void paint(Canvas canvas, Size size) {
    if (background) {
      final r = Offset.zero & size;
      canvas.drawRect(
        r,
        Paint()
          ..shader = ui.Gradient.radial(
            size.center(Offset.zero),
            size.width * 0.75,
            [shu, shuDark],
          ),
      );
      // 金の砂子をすこし
      final rnd = Random(7);
      for (var i = 0; i < 90; i++) {
        final p = Offset(
          rnd.nextDouble() * size.width,
          rnd.nextDouble() * size.height,
        );
        canvas.drawCircle(
          p,
          size.width * (0.002 + rnd.nextDouble() * 0.004),
          Paint()
            ..color = const Color(0xFFE2C26A)
                .withValues(alpha: 0.25 + rnd.nextDouble() * 0.35),
        );
      }
    }
    paintStrip(
      canvas,
      size.center(Offset(0, size.height * 0.04 * scale)),
      size.height * 0.78 * scale,
      -0.16,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class FeaturePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = ui.Gradient.linear(
          Offset.zero,
          Offset(size.width, size.height),
          [shu, shuDark],
        ),
    );
    paintStrip(
      canvas,
      Offset(size.width * 0.2, size.height * 0.53),
      size.height * 0.8,
      -0.16,
    );
    void text(
      String s,
      double f,
      Offset o, {
      Color color = const Color(0xFFFBF7F0),
      String family = 'NotoSerifJP',
    }) {
      final tp = TextPainter(
        text: TextSpan(
          text: s,
          style: TextStyle(
            fontFamily: family,
            fontSize: f,
            color: color,
            height: 1.2,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, o);
    }

    text(
      'タンザク',
      76,
      Offset(size.width * 0.38, size.height * 0.24),
      family: 'YujiSyuku',
    );
    text('詠んだ句が、そのまま短冊になる。', 34, Offset(size.width * 0.38, size.height * 0.52));
    text(
      '俳句の句帳と歳時記',
      26,
      Offset(size.width * 0.38, size.height * 0.68),
      color: const Color(0xFFE2C26A),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

void main() {
  test('アイコンとスプラッシュを書き出す', () async {
    if (!const bool.fromEnvironment('WRITE')) return;
    await _font('NotoSerifJP', 'assets/fonts/NotoSerifJP-Regular.ttf');
    await _font('YujiSyuku', 'assets/fonts/YujiSyuku-Regular.ttf');
    Future<void> write(String path, CustomPainter p, Size s) async =>
        File(path).writeAsBytesSync(await renderPng(p, s));
    const sq = Size(1024, 1024);
    await write('assets/icon/icon.png', IconPainter(background: true), sq);
    // Android のアダプティブアイコン（flutter_launcher_icons が周りに 16% の余白を付ける）
    await write(
      'assets/icon/icon_foreground.png',
      IconPainter(background: false, scale: 0.86),
      sq,
    );
    await write(
      'assets/splash/splash_icon.png',
      IconPainter(background: false, scale: 0.8),
      const Size(768, 768),
    );
    await write(
      'store/icon_512.png',
      IconPainter(background: true),
      const Size(512, 512),
    );
    await write(
      'store/feature_graphic.png',
      FeaturePainter(),
      const Size(1024, 500),
    );
  });
}
