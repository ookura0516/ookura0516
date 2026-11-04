import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_controller.dart';
import '../theme.dart';

/// 切符の裏。見つけた解が並び、全解で「完」の印が付く。
class SolutionsScreen extends StatelessWidget {
  const SolutionsScreen({super.key, required this.number});

  final String number;

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppController>();
    final found = app.foundDisplays(number);
    final goal = app.goalFor(number);
    final total = app.solutionsFor(number).length;
    final done = app.recordOf(number)?.allFound ?? false;
    return Scaffold(
      appBar: AppBar(title: Text('切符の裏 $number')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: app.design.paper,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: app.design.ink.withValues(alpha: 0.4)),
            ),
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      total > solutionCap
                          ? '本質的に違う解は $total 通り。$solutionCap つ見つければ完'
                          : '本質的に違う解は $total 通り',
                      style: TextStyle(color: app.design.ink, fontSize: 13),
                    ),
                    const SizedBox(height: 12),
                    for (var i = 0; i < goal; i++)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 28,
                              child: Text(
                                '${i + 1}.',
                                style: TextStyle(color: app.design.ink),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                i < found.length ? '${found[i]} = 10' : '？？？',
                                key: Key('solution-$i'),
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: i < found.length
                                      ? app.design.ink
                                      : app.design.ink.withValues(alpha: 0.35),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (found.length > goal)
                      for (final extra in found.skip(goal))
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Text(
                            '＋ $extra = 10',
                            style: TextStyle(color: app.design.ink),
                          ),
                        ),
                  ],
                ),
                if (done)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Transform.rotate(
                      angle: -0.25,
                      child: Container(
                        key: const Key('kan-stamp'),
                        width: 64,
                        height: 64,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: KipTheme.punch, width: 3),
                        ),
                        child: const Text(
                          '完',
                          style: TextStyle(
                            color: KipTheme.punch,
                            fontSize: 30,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (!done)
            const Text(
              '切符の画面に戻って、ほかの解き方を入れてみましょう。',
              style: TextStyle(color: KipTheme.inkDim),
            ),
        ],
      ),
    );
  }
}
