import 'package:flutter/material.dart';

import '../theme.dart';

class HowToScreen extends StatelessWidget {
  const HowToScreen({super.key});

  static const _steps = [
    ('ひとりが部屋をつくる', '「部屋をつくる」でシナリオを選ぶと、6けたの部屋番号が出ます。'),
    ('相棒が部屋にはいる', '相棒は自分のスマホで「部屋にはいる」を開き、同じ番号を入れます。ふたりには、ちがう役が割り当てられます。'),
    ('見えたものを、声で伝える', 'ふたりの画面には、ちがう手がかりが出ます。相手の画面は見ずに、言葉で伝え合ってください。'),
    ('解いたら、合言葉を渡す', '答えを入れる人は、ステージごとに決まっています。正解すると合言葉が出るので、相棒に伝えてください。相棒が合言葉を入れると、次のステージに進みます。'),
    ('手帳を見返す', 'あなたが解いた答えは、手帳に残ります。最後のステージでは、ふたりの手帳が役に立ちます。'),
  ];

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('遊びかた')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          for (var i = 0; i < _steps.length; i++)
            Card(
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: CircleAvatar(
                  backgroundColor: HisokagiTheme.surfaceHi,
                  foregroundColor: HisokagiTheme.star,
                  child: Text('${i + 1}'),
                ),
                title: Text(_steps[i].$1, style: text.titleMedium),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(_steps[i].$2, style: const TextStyle(height: 1.6)),
                ),
              ),
            ),
          const SizedBox(height: 12),
          Text(
            'スマホが1台しかないときは「1台で遊ぶ」を選んでください。役を切り替えながら遊べます。切り替えのときは、相手の役の画面を見ないようにしましょう。\n\n'
            '通信は使いません。機内モードでも遊べます。',
            style: text.bodyMedium?.copyWith(color: HisokagiTheme.textDim, height: 1.7),
          ),
        ],
      ),
    );
  }
}
