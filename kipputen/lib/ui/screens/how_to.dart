import 'package:flutter/material.dart';

const howToText = '''切符の4つの数字を全部1回ずつ使って、10 を作ります。

・使えるのは ＋ − × ÷ と括弧だけ
・数字の順番は入れ替えてよい
・数字をつなげる（1 と 2 で 12）、累乗、平方根、階乗はできません
・途中で分数になってもかまいません（例：8 ÷ (1 − 1 ÷ 5)）
・負の数は途中に出てきてもよいですが、式の頭に − は付けられません

1つ解けたら、ほかの解き方も探せます。並べ替えただけの式（3 + 7 と 7 + 3、(1 + 2) + 3 と 1 + (2 + 3) など）は同じ解として数えます。解が多い日は5つ見つければ「完」です。

毎日 0 時（日本時間）に新しい切符が出ます。月曜はやさしく、金曜は分数を使う難問です。''';

Future<void> showHowTo(BuildContext context) => showDialog<void>(
  context: context,
  builder: (context) => AlertDialog(
    title: const Text('遊び方'),
    content: const SingleChildScrollView(child: Text(howToText)),
    actions: [
      TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: const Text('閉じる'),
      ),
    ],
  ),
);
