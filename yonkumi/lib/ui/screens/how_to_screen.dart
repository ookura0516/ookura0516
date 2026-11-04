import 'package:flutter/material.dart';

import '../../core/axis.dart';
import '../../game/band.dart';
import '../theme.dart';

/// 遊び方。
class HowToScreen extends StatelessWidget {
  const HowToScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('遊び方')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('16語を4組に分ける', style: t.titleMedium),
          const SizedBox(height: 8),
          const Text(
            '同じ仲間の4語を選んで「決定」。正解すると、その4語が帯になって上に並び、'
            '仲間の名前（軸）が出ます。4組すべて当てればクリア。\n'
            '間違えられるのは4回まで。3語が合っているときは「あと1つ！」と出ます。\n'
            '問題は毎日、日本時間の0時に1問だけ替わります。',
            style: TextStyle(height: 1.6),
          ),
          const SizedBox(height: 20),
          Text('帯の色と難しさ', style: t.titleMedium),
          const SizedBox(height: 8),
          for (final b in Band.all)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: YonkumiTheme.band(b.difficulty),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      b.name,
                      style: TextStyle(
                        color: YonkumiTheme.onBand(b.difficulty),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text('${b.name}・${b.label}'),
                ],
              ),
            ),
          const SizedBox(height: 20),
          Text('仲間の分け方（軸）', style: t.titleMedium),
          const SizedBox(height: 8),
          const Text(
            '読みが同じ、同じ漢字を含む、季語の季節、県名が隠れている、ことわざの穴、'
            '数え方、カタカナ語の元の言葉、前に「お」を付けると別の言葉、など。'
            '1語が2つの仲間に見えるように作ってあります。',
            style: TextStyle(height: 1.6),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final a in AxisType.values)
                if (a != AxisType.manual) Chip(label: Text(a.label)),
            ],
          ),
          const SizedBox(height: 20),
          Text('連続日数', style: t.titleMedium),
          const SizedBox(height: 8),
          const Text(
            'その日の問題をその日のうちに解き終えると1日。'
            '間違いが4回になって終わっても、連続は途切れません。',
            style: TextStyle(height: 1.6),
          ),
        ],
      ),
    );
  }
}
