import 'package:flutter/material.dart';

/// プライバシーポリシー（アプリ内）。docs/PRIVACY.md と同じ内容。
class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  static const sections = <(String, String)>[
    (
      '集める情報',
      'ケシインは、利用者の情報を集めません。運営者に届く情報はありません。アカウントはなく、サーバーもありません。'
          '広告も、利用状況の解析（アナリティクス）も入っていません。通信するのは、下の「写真と位置情報」に書いた海外の地名を調べるときと、購入のときだけです。',
    ),
    (
      '端末の中に保存するもの',
      '選んだ写真のコピー（長辺2400pxに縮小したもの）、切手とシートの記録、消印の場所の履歴、設定、購入の状態。'
          'これらは端末の中だけにあり、アプリを削除すると消えます。',
    ),
    (
      '写真と位置情報',
      '写真は、OS の写真ピッカーで選んだものだけを読みます。写真ライブラリ全体へのアクセスは求めません。'
          '写真に位置情報があれば、消印の場所（市区町村）を決めるためだけに使います。'
          '国内の写真は、アプリに入っている市区町村の表で調べ、通信しません。'
          '海外の写真だけ、地名を調べるために OS の機能（Apple または Google の逆ジオコーディング）に緯度・経度を渡します。'
          '端末の現在地は使いません。',
    ),
    ('通知', 'リマインダーをオンにしたときだけ、端末の中で通知を予約します。通知のための通信はしません。'),
    (
      '購入',
      '買い切り「記念」の支払いは、App Store または Google Play が処理します。'
          'アプリが受け取るのは、購入したかどうかだけです。',
    ),
    (
      '共有と書き出し',
      '共有や ZIP の書き出しは、利用者が操作したときだけ、OS の共有シートに画像やファイルを渡します。'
          'どこに送るかは利用者が選びます。',
    ),
    ('お問い合わせ', 'ストアの掲載ページにあるサポート用のメールアドレスまで。'),
  ];

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('プライバシーポリシー')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          for (final (title, body) in sections) ...[
            Text(title, style: t.titleMedium),
            const SizedBox(height: 6),
            Text(body),
            const SizedBox(height: 20),
          ],
          Text('2026年11月 制定', style: t.bodySmall),
        ],
      ),
    );
  }
}
