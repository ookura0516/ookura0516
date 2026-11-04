import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';

import '../core/day_slots.dart';
import '../core/frames.dart';
import 'stamp_painter.dart';

const Color sheetPaper = Color(0xFFF4EFE4);
const Color sheetInk = Color(0xFF4A4238);
const Color sheetFaint = Color(0xFFCFC6B5);

/// 月のシート1枚分。
class MonthSheetVisual {
  const MonthSheetVisual({
    required this.year,
    required this.month,
    required this.title,
    required this.cells,
    required this.margin,
    required this.completed,
    this.today,
  });

  final int year;
  final int month;
  final String title;

  /// 30マス。空欄は null。
  final List<StampVisual?> cells;

  /// 欄外（31日、同じ日の2枚目以降）。
  final List<StampVisual> margin;
  final bool completed;

  /// 今日がこの月にあれば、そのマスを点線で強調する。
  final Day? today;
}

/// 旅の小型シート。
class TripSheetVisual {
  const TripSheetVisual({
    required this.title,
    required this.from,
    required this.to,
    required this.stamps,
  });

  final String title;
  final Day from;
  final Day to;
  final List<StampVisual> stamps;
}

TextPainter _text(
  String s,
  double size, {
  Color color = sheetInk,
  FontWeight weight = FontWeight.w600,
  double? maxWidth,
}) {
  return TextPainter(
    text: TextSpan(
      text: s,
      style: TextStyle(
        fontSize: size,
        color: color,
        fontWeight: weight,
        height: 1.2,
        fontFamily: postmarkFonts.first.families.first,
        fontFamilyFallback: postmarkFonts.first.families.skip(1).toList(),
      ),
    ),
    textDirection: TextDirection.ltr,
    maxLines: 1,
    ellipsis: '…',
  )..layout(maxWidth: maxWidth ?? double.infinity);
}

void _paperBackground(Canvas canvas, Rect r) {
  canvas.drawRect(r, Paint()..color = sheetPaper);
  // 紙の目：ごく薄い横線
  final grain = Paint()
    ..color = const Color(0x08000000)
    ..strokeWidth = 1;
  for (var y = r.top; y < r.bottom; y += r.height / 180) {
    canvas.drawLine(Offset(r.left, y), Offset(r.right, y), grain);
  }
}

/// シート上の点線の目打ち（マスの区切り）。
void _dottedLine(Canvas canvas, Offset a, Offset b, double dot) {
  final p = Paint()..color = sheetFaint;
  final len = (b - a).distance;
  final n = math.max(1, (len / (dot * 3)).round());
  for (var i = 0; i <= n; i++) {
    canvas.drawCircle(a + (b - a) * (i / n), dot / 2, p);
  }
}

/// 「完」の印。
void _completeSeal(Canvas canvas, Offset c, double r) {
  final red = const Color(0xFFB8432F).withValues(alpha: 0.85);
  canvas.drawCircle(
    c,
    r,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.12
      ..color = red,
  );
  final tp = _text('完', r * 1.05, color: red, weight: FontWeight.w800);
  tp.paint(canvas, c - Offset(tp.width / 2, tp.height / 2));
}

/// 月のシートを [size] に描く。アプリ名は右下に小さく入れる。
void paintMonthSheet(Canvas canvas, Size size, MonthSheetVisual v) {
  final r = Offset.zero & size;
  _paperBackground(canvas, r);
  final pad = size.width * 0.06;
  final u = size.width / 100; // 基準の単位

  // 見出し
  final head = _text('${v.year}年${v.month}月', u * 5.2);
  head.paint(canvas, Offset(pad, pad));
  if (v.title.isNotEmpty) {
    final t = _text(
      v.title,
      u * 3.6,
      weight: FontWeight.w500,
      maxWidth: size.width * 0.5,
    );
    t.paint(
      canvas,
      Offset(size.width - pad - t.width, pad + head.height - t.height),
    );
  }
  final gridTop = pad + head.height + u * 3;

  // 欄外の高さ（ある時だけ）
  final marginH = v.margin.isEmpty ? 0.0 : size.height * 0.13;
  final footer = u * 5;
  final gridH = size.height - gridTop - pad - marginH - footer;
  final gridW = size.width - pad * 2;
  final cellW = gridW / sheetColumns;
  final cellH = math.min(gridH / sheetRows, cellW * 1.3);
  final gridRect = Rect.fromLTWH(pad, gridTop, gridW, cellH * sheetRows);

  // マスの区切り
  final dot = u * 0.45;
  for (var c = 1; c < sheetColumns; c++) {
    final x = gridRect.left + cellW * c;
    _dottedLine(
      canvas,
      Offset(x, gridRect.top),
      Offset(x, gridRect.bottom),
      dot,
    );
  }
  for (var rr = 1; rr < sheetRows; rr++) {
    final y = gridRect.top + cellH * rr;
    _dottedLine(
      canvas,
      Offset(gridRect.left, y),
      Offset(gridRect.right, y),
      dot,
    );
  }

  final days = daysInMonth(v.year, v.month);
  for (var i = 0; i < sheetCells; i++) {
    final pos = cellPosition(i);
    final cell = Rect.fromLTWH(
      gridRect.left + pos.col * cellW,
      gridRect.top + pos.row * cellH,
      cellW,
      cellH,
    );
    final day = i + 1;
    final stamp = i < v.cells.length ? v.cells[i] : null;
    if (day > days) {
      // その月に無い日：薄い斜線
      final hatch = Paint()
        ..color = const Color(0x14000000)
        ..strokeWidth = 1;
      canvas.save();
      canvas.clipRect(cell.deflate(u));
      for (var x = cell.left - cell.height; x < cell.right; x += u * 2) {
        canvas.drawLine(
          Offset(x, cell.bottom),
          Offset(x + cell.height, cell.top),
          hatch,
        );
      }
      canvas.restore();
      continue;
    }
    if (stamp != null) {
      canvas.save();
      canvas.clipRect(cell);
      paintStamp(canvas, cell.deflate(u * 1.2), stamp);
      canvas.restore();
    } else {
      final num = _text(
        '$day',
        u * 3,
        color: sheetFaint,
        weight: FontWeight.w500,
      );
      num.paint(canvas, cell.center - Offset(num.width / 2, num.height / 2));
      if (v.today != null &&
          v.today!.day == day &&
          v.today!.sameMonth(Day(v.year, v.month, 1))) {
        _dashedRect(
          canvas,
          cell.deflate(u * 1.6),
          sheetInk.withValues(alpha: 0.5),
          u * 0.4,
        );
      }
    }
  }

  // 欄外
  if (v.margin.isNotEmpty) {
    final top = gridRect.bottom + u * 2.5;
    final label = _text('欄外', u * 2.6, weight: FontWeight.w500);
    label.paint(canvas, Offset(pad, top));
    final h = marginH - label.height - u;
    final w = h * 0.8;
    var x = pad;
    for (final s in v.margin.take(((gridW) / (w + u)).floor())) {
      paintStamp(
        canvas,
        Rect.fromLTWH(x, top + label.height + u * 0.5, w, h),
        s,
      );
      x += w + u;
    }
  }

  if (v.completed) {
    _completeSeal(
      canvas,
      Offset(size.width - pad - u * 7, pad + u * 3.5),
      u * 5,
    );
  }
  _appMark(canvas, size, u);
}

void _dashedRect(Canvas canvas, Rect r, Color color, double w) {
  final p = Paint()
    ..color = color
    ..strokeWidth = w
    ..style = PaintingStyle.stroke;
  final dash = w * 5;
  void line(Offset a, Offset b) {
    final len = (b - a).distance;
    final n = (len / (dash * 2)).floor();
    for (var i = 0; i < n; i++) {
      canvas.drawLine(
        a + (b - a) * (i * 2 * dash / len),
        a + (b - a) * ((i * 2 + 1) * dash / len),
        p,
      );
    }
  }

  line(r.topLeft, r.topRight);
  line(r.topRight, r.bottomRight);
  line(r.bottomRight, r.bottomLeft);
  line(r.bottomLeft, r.topLeft);
}

void _appMark(Canvas canvas, Size size, double u) {
  final mark = _text(
    'ケシイン',
    u * 2.2,
    color: sheetInk.withValues(alpha: 0.55),
    weight: FontWeight.w500,
  );
  mark.paint(
    canvas,
    Offset(size.width - mark.width - u * 4, size.height - mark.height - u * 3),
  );
}

/// 旅の小型シート。切手を3列で並べる（最大12枚）。
void paintTripSheet(Canvas canvas, Size size, TripSheetVisual v) {
  final r = Offset.zero & size;
  _paperBackground(canvas, r);
  final u = size.width / 100;
  final pad = u * 7;
  // 外枠：小型シートらしい二重線
  final frame = Paint()
    ..style = PaintingStyle.stroke
    ..color = sheetInk.withValues(alpha: 0.6)
    ..strokeWidth = u * 0.35;
  canvas.drawRect(r.deflate(u * 3), frame);
  canvas.drawRect(r.deflate(u * 4.2), frame..strokeWidth = u * 0.15);

  final title = _text(
    v.title.isEmpty ? '旅のシート' : v.title,
    u * 5.5,
    maxWidth: size.width - pad * 2,
  );
  title.paint(canvas, Offset((size.width - title.width) / 2, pad));
  final range = _text(
    '${v.from.dotted} – ${v.to.dotted}',
    u * 3,
    weight: FontWeight.w500,
  );
  range.paint(
    canvas,
    Offset((size.width - range.width) / 2, pad + title.height + u),
  );

  final stamps = v.stamps.take(12).toList();
  final cols = stamps.length <= 4 ? 2 : 3;
  final rows = math.max(1, (stamps.length / cols).ceil());
  final top = pad + title.height + range.height + u * 5;
  final gridW = size.width - pad * 2;
  final gridH = size.height - top - pad - u * 4;
  final cw = gridW / cols;
  final ch = math.min(gridH / rows, cw * 1.3);
  final offsetY = top + (gridH - ch * rows) / 2;
  for (var i = 0; i < stamps.length; i++) {
    final cell = Rect.fromLTWH(
      pad + (i % cols) * cw,
      offsetY + (i ~/ cols) * ch,
      cw,
      ch,
    );
    canvas.save();
    canvas.clipRect(cell);
    paintStamp(canvas, cell.deflate(u * 1.5), stamps[i]);
    canvas.restore();
  }
  _appMark(canvas, size, u);
}

/// 年間ポスター：12か月を4列×3行に縮小して並べる。
void paintYearPoster(
  Canvas canvas,
  Size size,
  int year,
  List<MonthSheetVisual?> months,
) {
  final r = Offset.zero & size;
  _paperBackground(canvas, r);
  final u = size.width / 100;
  final pad = u * 5;
  final head = _text('$year', u * 8, weight: FontWeight.w700);
  head.paint(canvas, Offset(pad, pad));
  final top = pad + head.height + u * 3;
  const cols = 3, rows = 4;
  final cw = (size.width - pad * 2) / cols;
  final ch = (size.height - top - pad - u * 4) / rows;
  for (var m = 1; m <= 12; m++) {
    final i = m - 1;
    final cell = Rect.fromLTWH(
      pad + (i % cols) * cw,
      top + (i ~/ cols) * ch,
      cw,
      ch,
    ).deflate(u);
    final label = _text('$m月', u * 2.6);
    label.paint(canvas, cell.topLeft);
    final grid = Rect.fromLTRB(
      cell.left,
      cell.top + label.height + u * 0.5,
      cell.right,
      cell.bottom,
    );
    final mw = grid.width / sheetColumns;
    final mh = math.min(grid.height / sheetRows, mw * 1.25);
    final v = months[i];
    for (var k = 0; k < sheetCells; k++) {
      final pos = cellPosition(k);
      final c = Rect.fromLTWH(
        grid.left + pos.col * mw,
        grid.top + pos.row * mh,
        mw,
        mh,
      );
      final s = v == null || k >= v.cells.length ? null : v.cells[k];
      if (s != null) {
        paintStamp(
          canvas,
          c.deflate(u * 0.2),
          s,
          withPostmark: false,
          shadow: false,
        );
      } else if (k < daysInMonth(year, m)) {
        canvas.drawRect(
          c.deflate(u * 0.6),
          Paint()..color = const Color(0x0F000000),
        );
      }
    }
  }
  _appMark(canvas, size, u);
}

/// 共有用：切手1枚を斜めに置く（1080×1350 を [scale] 倍）。
void paintTiltedStamp(
  Canvas canvas,
  Size size,
  StampVisual v, {
  bool dark = false,
}) {
  final r = Offset.zero & size;
  if (dark) {
    canvas.drawRect(r, Paint()..color = const Color(0xFF1C1B1A));
  } else {
    _paperBackground(canvas, r);
  }
  final u = size.width / 100;
  canvas.save();
  canvas.translate(size.width / 2, size.height * 0.47);
  canvas.rotate(-0.07 + (v.postmark?.seed ?? 0) % 7 * 0.012);
  final w = size.width * 0.72;
  final h = w / v.shape.aspect;
  final area = Rect.fromCenter(
    center: Offset.zero,
    width: w,
    height: math.min(h, size.height * 0.72),
  );
  paintStamp(canvas, area, v);
  canvas.restore();
  final mark = _text(
    'ケシイン',
    u * 2.6,
    color: (dark ? const Color(0xFFEDE6D8) : sheetInk).withValues(alpha: 0.6),
    weight: FontWeight.w500,
  );
  mark.paint(
    canvas,
    Offset(size.width - mark.width - u * 5, size.height - mark.height - u * 4),
  );
}

/// 背景が透明な切手単体。消印のはみ出し分の余白を取る。
void paintTransparentStamp(Canvas canvas, Size size, StampVisual v) {
  paintStamp(canvas, Rect.fromLTWH(0, 0, size.width * 0.78, size.height), v);
}

/// 描画関数を画像にして PNG のバイト列にする。
Future<ui.Image> renderToImage(
  Size size,
  void Function(Canvas c, Size s) draw,
) async {
  final rec = ui.PictureRecorder();
  final canvas = Canvas(rec, Offset.zero & size);
  draw(canvas, size);
  final pic = rec.endRecording();
  final img = await pic.toImage(size.width.round(), size.height.round());
  pic.dispose();
  return img;
}
