import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/app_state.dart';
import '../../render/sheet_painter.dart';
import '../../render/stamp_painter.dart';

/// 保存済みの切手1枚。写真は縮小版を読み込んでから描く。
class StampView extends StatefulWidget {
  const StampView({super.key, required this.entry, this.full = false});

  final StampEntry entry;
  final bool full;

  @override
  State<StampView> createState() => _StampViewState();
}

class _StampViewState extends State<StampView> {
  Future<ui.Image?>? _future;
  String? _key;

  @override
  Widget build(BuildContext context) {
    final key = '${widget.entry.row.imagePath}|${widget.full}';
    if (_key != key) {
      _key = key;
      _future = context.read<AppState>().photoLoader.load(
        widget.entry.row.imagePath,
        full: widget.full,
      );
    }
    final fontId = context.select<AppState, String>((a) => a.fontId);
    return FutureBuilder<ui.Image?>(
      future: _future,
      builder: (context, snap) => CustomPaint(
        painter: StampPainter(widget.entry.visual(snap.data, fontId)),
        child: const SizedBox.expand(),
      ),
    );
  }
}

/// 月のシート全体（共有画像と同じ描き方）を画面に出す。
class MonthSheetPicture extends StatefulWidget {
  const MonthSheetPicture({super.key, required this.data});

  final MonthData data;

  @override
  State<MonthSheetPicture> createState() => _MonthSheetPictureState();
}

class _MonthSheetPictureState extends State<MonthSheetPicture> {
  late Future<MonthSheetVisual> _future = context.read<AppState>().monthVisual(
    widget.data,
  );

  @override
  void didUpdateWidget(MonthSheetPicture old) {
    super.didUpdateWidget(old);
    if (old.data != widget.data) {
      _future = context.read<AppState>().monthVisual(widget.data);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1080 / 1350,
      child: FutureBuilder<MonthSheetVisual>(
        future: _future,
        builder: (context, snap) {
          final v = snap.data;
          if (v == null) return const ColoredBox(color: sheetPaper);
          return CustomPaint(
            painter: _MonthPainter(v),
            child: const SizedBox.expand(),
          );
        },
      ),
    );
  }
}

class _MonthPainter extends CustomPainter {
  _MonthPainter(this.v);
  final MonthSheetVisual v;
  @override
  void paint(Canvas canvas, Size size) => paintMonthSheet(canvas, size, v);
  @override
  bool shouldRepaint(_MonthPainter old) => old.v != v;
}

/// 任意の描画関数を置く。
class PicturePainter extends CustomPainter {
  PicturePainter(this.draw);
  final void Function(Canvas, Size) draw;
  @override
  void paint(Canvas canvas, Size size) => draw(canvas, size);
  @override
  bool shouldRepaint(PicturePainter old) => old.draw != draw;
}
