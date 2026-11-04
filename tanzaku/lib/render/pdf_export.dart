import 'dart:math';
import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../core/japanese_date.dart';
import '../core/vertical.dart';

/// 縦書き PDF（A4 横置き、1ページ10句）。句会の清記用。
///
/// [fontData] は TrueType のフォント（Noto Serif JP）。
Future<Uint8List> buildHaikuPdf({
  required List<(String text, DateTime date)> haiku,
  required ByteData fontData,
  String title = '句帳',
  String gago = '',
}) async {
  final font = pw.Font.ttf(fontData);
  final doc = pw.Document(
    title: title,
    author: gago.isEmpty ? null : gago,
    creator: 'タンザク',
  );
  const perPage = 10;
  final pages = max(1, (haiku.length / perPage).ceil());
  for (var p = 0; p < pages; p++) {
    final items = haiku.skip(p * perPage).take(perPage).toList();
    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(36),
        build: (context) => pw.LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints!.maxWidth;
            final h = constraints.maxHeight;
            final children = <pw.Widget>[];
            const titleF = 16.0;
            children.addAll(
              _column(
                '$title${gago.isEmpty ? '' : '　$gago'}',
                w - titleF / 2,
                0,
                titleF,
                font,
                h,
              ),
            );
            final pitch = (w - titleF * 3) / perPage;
            for (var i = 0; i < items.length; i++) {
              final (text, date) = items[i];
              final joined = text
                  .split('\n')
                  .map((l) => l.trim())
                  .where((l) => l.isNotEmpty)
                  .join('　');
              final cx = w - titleF * 3 - pitch * (i + 0.5);
              final glyphs = toVertical(joined).length;
              final f = min(pitch * 0.5, (h * 0.8) / max(1, glyphs) / 1.06);
              children.addAll(_column(joined, cx, 0, f, font, h * 0.8));
              final d = japaneseDate(date);
              children.addAll(
                _column(d, cx, h * 0.82, min(7.0, f * 0.45), font, h * 0.18),
              );
            }
            children.add(
              pw.Positioned(
                left: 0,
                bottom: 0,
                child: pw.Text(
                  '${p + 1} / $pages',
                  style: pw.TextStyle(
                    font: font,
                    fontSize: 8,
                    color: PdfColors.grey600,
                  ),
                ),
              ),
            );
            return pw.SizedBox(
              width: w,
              height: h,
              child: pw.Stack(children: children),
            );
          },
        ),
      ),
    );
  }
  return doc.save();
}

List<pw.Widget> _column(
  String text,
  double cx,
  double top,
  double f,
  pw.Font font,
  double maxH,
) {
  final out = <pw.Widget>[];
  final glyphs = toVertical(text)
      .where((g) => g.text.trim().isNotEmpty || g.text == '　')
      .toList();
  final size = min(f, maxH / max(1, glyphs.length) / 1.06);
  var y = top;
  for (final g in glyphs) {
    pw.Widget child = pw.Text(
      g.text,
      style: pw.TextStyle(font: font, fontSize: size, lineSpacing: 0),
    );
    var dx = 0.0, dy = 0.0;
    switch (g.placement) {
      case VerticalPlacement.rotate:
        child = pw.Transform.rotate(angle: -pi / 2, child: child);
      case VerticalPlacement.smallKana:
        dx = size * 0.12;
        dy = -size * 0.12;
      case VerticalPlacement.punctuation:
        dx = size * 0.55;
        dy = -size * 0.5;
      case VerticalPlacement.upright:
        break;
    }
    out.add(
      pw.Positioned(
        left: cx - size / 2 + dx,
        top: y + dy,
        child: pw.SizedBox(
          width: size,
          height: size * 1.06,
          child: pw.Center(child: child),
        ),
      ),
    );
    y += size * 1.06;
  }
  return out;
}
