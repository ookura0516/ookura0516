import 'package:flutter/material.dart';

import '../../game/band.dart';
import '../theme.dart';

/// 結果グリッド：決定ごとに1行、4マス。色は語の組の難易度。
class ResultGrid extends StatelessWidget {
  const ResultGrid({
    super.key,
    required this.rows,
    this.cell = 36,
    this.gap = 6,
    this.colorNames = false,
  });

  final List<List<int>> rows;
  final double cell;
  final double gap;
  final bool colorNames;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label:
          '結果：${rows.length}回決定。'
          '${rows.map((r) => r.map((d) => Band.of(d).name).join('')).join('、')}',
      excludeSemantics: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final r in rows)
            Padding(
              padding: EdgeInsets.only(bottom: gap),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var i = 0; i < r.length; i++)
                    Container(
                      width: cell,
                      height: cell,
                      margin: EdgeInsets.only(left: i == 0 ? 0 : gap),
                      decoration: BoxDecoration(
                        color: YonkumiTheme.band(r[i]),
                        borderRadius: BorderRadius.circular(cell * 0.16),
                      ),
                      alignment: Alignment.center,
                      child: colorNames
                          ? Text(
                              Band.of(r[i]).name,
                              style: TextStyle(
                                fontSize: cell * 0.45,
                                fontWeight: FontWeight.w700,
                                color: YonkumiTheme.onBand(r[i]),
                              ),
                            )
                          : null,
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
