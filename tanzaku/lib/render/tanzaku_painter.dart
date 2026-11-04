import 'dart:math';

import 'package:flutter/material.dart';

import '../core/japanese_date.dart';
import '../core/season.dart';
import '../core/vertical.dart';
import 'style.dart';
import 'washi.dart';

/// 短冊に載せる中身。
class TanzakuContent {
  const TanzakuContent({
    required this.lines,
    this.maegaki = '',
    this.gago = '',
    this.date,
    this.kigoRanges = const [],
    this.season,
    this.appName = 'タンザク',
  });

  /// 上五・中七・下五（空の行は詰める）。
  final List<String> lines;
  final String maegaki;

  /// 雅号。空なら落款を出さない。
  final String gago;
  final DateTime? date;

  /// `lines.join('\n')` の中での季語の位置（UTF-16 の [start, end)）。ごく薄く色を付ける。
  final List<(int, int)> kigoRanges;
  final Season? season;

  /// 画像に小さく入れるアプリ名。空なら入れない。
  final String appName;

  List<String> get nonEmptyLines => [
    for (final l in lines)
      if (l.trim().isNotEmpty) l.trim(),
  ];
}

/// 縦に並べる1文字と、季語かどうか。
class _Cell {
  _Cell(this.glyph, this.kigo);
  final VerticalGlyph glyph;
  final bool kigo;
}

/// 短冊・色紙を描く。プレビューと共有画像で同じものを使う。
class TanzakuPainter extends CustomPainter {
  TanzakuPainter({required this.content, required this.style});

  final TanzakuContent content;
  final TanzakuStyle style;

  @override
  void paint(Canvas canvas, Size size) {
    switch (style.form) {
      case TanzakuForm.tanzaku:
        _paintTanzaku(canvas, size);
      case TanzakuForm.shikishi:
        _paintShikishi(canvas, size);
    }
  }

  Color get _ink => style.washi.ink;

  Color get _kigoInk {
    final tint = SeasonPalette.of(content.season ?? Season.autumn).tint;
    // ごく薄く：墨に季節の色を少しだけ混ぜる。
    return Color.lerp(_ink, tint, style.washi.dark ? 0.35 : 0.42)!;
  }

  /// 行ごとの文字。季語の位置を付ける。
  List<List<_Cell>> _columns() {
    final cols = <List<_Cell>>[];
    var offset = 0;
    for (final raw in content.lines) {
      final line = raw;
      final cells = <_Cell>[];
      var pos = offset;
      for (final g in toVertical(line)) {
        final inKigo = content.kigoRanges.any((r) => pos >= r.$1 && pos < r.$2);
        if (g.text.trim().isNotEmpty) cells.add(_Cell(g, inKigo));
        pos += g.text.length;
      }
      offset += line.length + 1; // 改行の分
      if (cells.isNotEmpty) cols.add(cells);
    }
    return cols;
  }

  // ------------------------------------------------------------ 短冊

  void _paintTanzaku(Canvas canvas, Size size) {
    // 背景（床の間の壁の色を季節で少し変える）
    final wash = SeasonPalette.of(content.season ?? Season.autumn).wash;
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = Color.lerp(wash, const Color(0xFF8C7B68), 0.18)!,
    );

    // 短冊の紙（縦横比 およそ 1:4.4）
    final h = size.height * 0.9;
    final w = min(h / 4.4, size.width * 0.5);
    final paper = Rect.fromCenter(
      center: Offset(size.width / 2, size.height * 0.48),
      width: w,
      height: h,
    );
    canvas.drawRect(
      paper.shift(Offset(w * 0.03, w * 0.04)),
      Paint()
        ..color = const Color(0x33000000)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, w * 0.04),
    );
    canvas.save();
    canvas.clipRect(paper);
    paintWashi(canvas, paper, style.washi);
    canvas.restore();
    // 掛け紐の穴
    canvas.drawCircle(
      Offset(paper.center.dx, paper.top + w * 0.09),
      w * 0.025,
      Paint()..color = Color.lerp(style.washi.paper, _ink, 0.25)!,
    );

    final cols = _columns();
    // 1行書き：3つの句を少しずつ間を空けて1列に並べる。
    const gap = 0.6; // 句と句の間（字の高さに対する割合）
    final glyphs = cols.fold<int>(0, (s, c) => s + c.length);
    final gaps = max(0, cols.length - 1) * gap;
    final textTop = paper.top + w * 0.2;
    final bottomReserve = (content.gago.isNotEmpty && style.showSeal)
        ? w * 0.95
        : w * 0.35;
    final avail = paper.bottom - bottomReserve - textTop;
    final fontSize = glyphs == 0
        ? w * 0.4
        : min(w * 0.42, avail / ((glyphs + gaps) * _advance));

    final x = paper.center.dx + (content.maegaki.isNotEmpty ? w * 0.06 : 0);
    var y = textTop;
    for (var i = 0; i < cols.length; i++) {
      y = _drawColumn(canvas, cols[i], x, y, fontSize);
      y += fontSize * gap * _advance;
    }

    // 前書き：右に小さく
    if (content.maegaki.isNotEmpty) {
      final mf = min(fontSize * 0.42, w * 0.13);
      _drawPlain(
        canvas,
        content.maegaki,
        x + fontSize * 0.5 + mf * 0.9,
        textTop,
        mf,
        maxBottom: paper.bottom - bottomReserve,
      );
    }

    // 日付：左上に小さく
    if (style.showDate && content.date != null) {
      final df = w * 0.08;
      _drawPlain(
        canvas,
        japaneseDate(content.date!),
        paper.left + w * 0.16,
        textTop + fontSize * 1.5,
        df,
        maxBottom: paper.bottom - bottomReserve,
        color: _ink.withValues(alpha: 0.75),
      );
    }

    // 雅号と落款：左下
    final sealBottom = _drawSignature(
      canvas,
      right: paper.center.dx - w * 0.02 + w * 0.12,
      bottom: paper.bottom - w * 0.22,
      unit: w,
    );
    _drawAppName(
      canvas,
      Offset(
        paper.center.dx,
        max(sealBottom, paper.bottom) + size.height * 0.025,
      ),
      size.width * 0.022,
      onPaper: false,
    );
  }

  // ------------------------------------------------------------ 色紙

  void _paintShikishi(Canvas canvas, Size size) {
    final s = min(size.width, size.height);
    final outer = Rect.fromCenter(
      center: size.center(Offset.zero),
      width: s,
      height: s,
    );
    // 金の縁
    canvas.drawRect(outer, Paint()..color = const Color(0xFFC9A44C));
    final paper = outer.deflate(s * 0.022);
    canvas.save();
    canvas.clipRect(paper);
    paintWashi(canvas, paper, style.washi);
    canvas.restore();

    final cols = _columns();
    final margin = s * 0.12;
    final top = paper.top + margin;
    final bottom = paper.bottom - margin * 1.1;
    // 散らし書き：右から左へ、1列ずつ少し下げて始める。
    const stagger = 1.2; // 字の高さに対する割合
    final maxLen = cols.fold<int>(0, (m, c) => max(m, c.length + 0));
    final n = max(1, cols.length);
    final byHeight = (bottom - top) / ((maxLen + stagger * (n - 1)) * _advance);
    final byWidth =
        (paper.width - margin * 2.4) /
        (n * 1.7 + (content.maegaki.isNotEmpty ? 1 : 0));
    final fontSize = min(min(byHeight, byWidth), s * 0.12);
    final pitch = fontSize * 1.7;
    final blockWidth = pitch * (n - 1);
    final rightX =
        paper.center.dx +
        blockWidth / 2 +
        (content.maegaki.isNotEmpty ? fontSize * 0.4 : 0);
    for (var i = 0; i < cols.length; i++) {
      _drawColumn(
        canvas,
        cols[i],
        rightX - i * pitch,
        top + i * fontSize * stagger * _advance * 0.6,
        fontSize,
      );
    }
    if (content.maegaki.isNotEmpty) {
      final mf = fontSize * 0.42;
      _drawPlain(
        canvas,
        content.maegaki,
        rightX + fontSize * 1.1,
        top,
        mf,
        maxBottom: bottom,
      );
    }
    final leftX = rightX - blockWidth - pitch * 0.85;
    if (style.showDate && content.date != null) {
      _drawPlain(
        canvas,
        japaneseDate(content.date!),
        leftX,
        top + fontSize * 0.5,
        fontSize * 0.34,
        maxBottom: bottom,
        color: _ink.withValues(alpha: 0.75),
      );
    }
    _drawSignature(
      canvas,
      right: leftX + fontSize * 0.25,
      bottom: paper.bottom - margin * 0.6,
      unit: s * 0.24,
    );
    _drawAppName(
      canvas,
      Offset(paper.right - s * 0.08, paper.bottom - s * 0.035),
      s * 0.02,
      onPaper: true,
    );
  }

  // ------------------------------------------------------------ 共通

  /// 字の送り（字の高さに対する割合）。
  static const _advance = 1.06;

  TextPainter _tp(String text, double fontSize, Color color) => TextPainter(
    text: TextSpan(
      text: text,
      style: TextStyle(
        fontFamily: style.font.family,
        fontFamilyFallback: const ['NotoSerifJP'],
        fontSize: fontSize,
        height: 1.0,
        color: color,
      ),
    ),
    textDirection: TextDirection.ltr,
    textScaler: TextScaler.noScaling,
  )..layout();

  /// 1列を上から描く。描き終えた下端を返す。
  double _drawColumn(
    Canvas canvas,
    List<_Cell> cells,
    double cx,
    double top,
    double fontSize,
  ) {
    var y = top;
    for (final c in cells) {
      _drawGlyph(
        canvas,
        c.glyph,
        Offset(cx, y + fontSize * _advance / 2),
        fontSize,
        c.kigo ? _kigoInk : _ink,
      );
      y += fontSize * _advance;
    }
    return y;
  }

  void _drawGlyph(
    Canvas canvas,
    VerticalGlyph g,
    Offset center,
    double fontSize,
    Color color,
  ) {
    final tp = _tp(g.text, fontSize, color);
    final half = Offset(tp.width / 2, tp.height / 2);
    switch (g.placement) {
      case VerticalPlacement.upright:
        tp.paint(canvas, center - half);
      case VerticalPlacement.rotate:
        canvas.save();
        canvas.translate(center.dx, center.dy);
        canvas.rotate(pi / 2);
        tp.paint(canvas, -half);
        canvas.restore();
      case VerticalPlacement.smallKana:
        // 小書きは右上に寄せる。
        tp.paint(
          canvas,
          center - half + Offset(fontSize * 0.12, -fontSize * 0.12),
        );
      case VerticalPlacement.punctuation:
        // 句読点は右上に寄せる（横書きでは左下にあるので、ほぼ対角に動かす）。
        tp.paint(
          canvas,
          center - half + Offset(fontSize * 0.58, -fontSize * 0.55),
        );
    }
  }

  /// 前書き・日付などの小さな縦書き。[maxBottom] を超えるなら字を小さくする。
  void _drawPlain(
    Canvas canvas,
    String text,
    double cx,
    double top,
    double fontSize, {
    required double maxBottom,
    Color? color,
  }) {
    final glyphs = toVertical(text)
        .where((g) => g.text.trim().isNotEmpty)
        .toList();
    if (glyphs.isEmpty) return;
    final fit = (maxBottom - top) / (glyphs.length * _advance);
    final f = min(fontSize, fit);
    var y = top;
    for (final g in glyphs) {
      _drawGlyph(
        canvas,
        g,
        Offset(cx, y + f * _advance / 2),
        f,
        color ?? _ink.withValues(alpha: 0.85),
      );
      y += f * _advance;
    }
  }

  /// 雅号（縦書き）と落款。右端 [right]、下端 [bottom] に置く。描いた下端を返す。
  double _drawSignature(
    Canvas canvas, {
    required double right,
    required double bottom,
    required double unit,
  }) {
    final gago = content.gago.trim();
    if (gago.isEmpty || !style.showSeal) return bottom;
    final sealSize = unit * 0.24;
    final sealRect = Rect.fromLTWH(
      right - sealSize,
      bottom - sealSize,
      sealSize,
      sealSize,
    );
    // 雅号の文字（落款の上）
    final nameFont = unit * 0.11;
    final chars = toVertical(gago).take(6).toList();
    var y = sealRect.top - unit * 0.04 - chars.length * nameFont * _advance;
    for (final g in chars) {
      _drawGlyph(
        canvas,
        g,
        Offset(sealRect.center.dx, y + nameFont * _advance / 2),
        nameFont,
        _ink,
      );
      y += nameFont * _advance;
    }
    paintSeal(canvas, sealRect, gago, style.seal, style.font.family);
    return sealRect.bottom;
  }

  void _drawAppName(
    Canvas canvas,
    Offset center,
    double fontSize, {
    required bool onPaper,
  }) {
    if (content.appName.isEmpty) return;
    final color = onPaper
        ? _ink.withValues(alpha: 0.45)
        : const Color(0x99332A20);
    final tp = TextPainter(
      text: TextSpan(
        text: content.appName,
        style: TextStyle(
          fontFamily: 'NotoSerifJP',
          fontSize: fontSize,
          color: color,
          letterSpacing: fontSize * 0.3,
          height: 1,
        ),
      ),
      textDirection: TextDirection.ltr,
      textScaler: TextScaler.noScaling,
    )..layout();
    tp.paint(canvas, center - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(TanzakuPainter old) =>
      old.style != style ||
      old.content.lines.join('\n') != content.lines.join('\n') ||
      old.content.maegaki != content.maegaki ||
      old.content.gago != content.gago ||
      old.content.date != content.date ||
      old.content.season != content.season ||
      old.content.kigoRanges.length != content.kigoRanges.length;
}

/// 落款（雅号の印）を描く。字は最大4字を2列に組む。
void paintSeal(
  Canvas canvas,
  Rect rect,
  String gago,
  SealStyle seal,
  String family,
) {
  final chars = gago.characters
      .where((c) => c.trim().isNotEmpty)
      .take(4)
      .toList();
  final round = seal.shape == SealShape.round;
  final rrect = RRect.fromRectAndRadius(
    rect,
    Radius.circular(round ? rect.width / 2 : rect.width * 0.08),
  );
  final fill = seal.carve == SealCarve.hakubun;
  if (fill) {
    canvas.drawRRect(
      rrect,
      Paint()..color = seal.color.withValues(alpha: 0.92),
    );
  } else {
    canvas.drawRRect(
      rrect.deflate(rect.width * 0.04),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = rect.width * 0.07
        ..color = seal.color.withValues(alpha: 0.92),
    );
  }
  if (chars.isEmpty) return;
  final color = fill ? const Color(0xFFF8F1E6) : seal.color;
  // 印は右の列から読む。1〜2字は1列、3〜4字は2列。
  final cols = chars.length <= 2
      ? [chars]
      : [chars.sublist(0, 2), chars.sublist(2)];
  final inner = rect.deflate(rect.width * (round ? 0.2 : 0.14));
  final colW = inner.width / cols.length;
  final rows = cols.fold<int>(0, (m, c) => max(m, c.length));
  final f = min(colW * 0.95, inner.height / rows * 0.95);
  for (var i = 0; i < cols.length; i++) {
    final cx = inner.right - colW * (i + 0.5);
    final col = cols[i];
    final cellH = inner.height / col.length;
    for (var j = 0; j < col.length; j++) {
      final tp = TextPainter(
        text: TextSpan(
          text: col[j],
          style: TextStyle(
            fontFamily: family,
            fontFamilyFallback: const ['NotoSerifJP'],
            fontSize: f,
            height: 1,
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
        textDirection: TextDirection.ltr,
        textScaler: TextScaler.noScaling,
      )..layout();
      tp.paint(
        canvas,
        Offset(
          cx - tp.width / 2,
          inner.top + cellH * (j + 0.5) - tp.height / 2,
        ),
      );
    }
  }
}
