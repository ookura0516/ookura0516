import 'package:flutter/material.dart';
import 'package:ookura_daily/ookura_daily_flutter.dart';

import '../../game/share_text.dart';
import '../theme.dart';
import 'result_grid.dart';

/// 共有画像の中身。答え（語と軸）は入れない。アプリ名は小さく、ストアのリンクは入れない。
class ShareCard extends StatelessWidget {
  const ShareCard({
    super.key,
    required this.format,
    required this.day,
    required this.date,
    required this.grid,
    required this.cleared,
    required this.mistakes,
    required this.streak,
    this.colorNames = false,
  });

  final ShareImageFormat format;
  final int day;
  final CivilDate date;
  final List<List<int>> grid;
  final bool cleared;
  final int mistakes;
  final int streak;
  final bool colorNames;

  @override
  Widget build(BuildContext context) {
    final size = format.logicalSize;
    // 行が多いときも収まるように、マスの大きさを決める。
    final maxGridH =
        size.height - (format == ShareImageFormat.square ? 150 : 200);
    final rows = grid.isEmpty ? 1 : grid.length;
    final cell = ((maxGridH / rows) - 6).clamp(16.0, 46.0);
    final verdict = cleared
        ? (mistakes == 0 ? 'パーフェクト' : 'クリア・間違い$mistakes回')
        : '間違い4回で終了';
    const ink = YonkumiTheme.ink;
    return DefaultTextStyle.merge(
      style: const TextStyle(color: ink),
      child: Container(
        color: YonkumiTheme.paper,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          children: [
            Text(
              '第$day問',
              style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w800),
            ),
            Text(
              '${date.year}年${date.month}月${date.day}日',
              style: const TextStyle(fontSize: 14, color: YonkumiTheme.inkDim),
            ),
            const SizedBox(height: 14),
            // 行が多くても枠に収める。
            Expanded(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: ResultGrid(
                  rows: grid,
                  cell: cell,
                  colorNames: colorNames,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              verdict,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            Text(
              '連続$streak日',
              style: const TextStyle(fontSize: 14, color: YonkumiTheme.inkDim),
            ),
            const SizedBox(height: 10),
            const Text(
              'ヨンクミ  $kHashtag',
              style: TextStyle(fontSize: 11, color: YonkumiTheme.inkDim),
            ),
          ],
        ),
      ),
    );
  }
}
