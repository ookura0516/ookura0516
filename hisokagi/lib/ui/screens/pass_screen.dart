import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../monetize/purchase_service.dart';
import '../app_controller.dart';
import '../theme.dart';

/// 「ひそかぎパス」の購入・復元と、広告のプライバシー設定。
class PassScreen extends StatefulWidget {
  const PassScreen({super.key});

  @override
  State<PassScreen> createState() => _PassScreenState();
}

class _PassScreenState extends State<PassScreen> {
  PassStatus? _lastShown;
  bool _privacyRequired = false;

  @override
  void initState() {
    super.initState();
    context.read<AppController>().ads.privacyOptionsRequired().then((v) {
      if (mounted) setState(() => _privacyRequired = v);
    });
  }

  static String? _message(PassStatus s) => switch (s) {
        PassStatus.purchased => 'ありがとうございます。ひそかぎパスが有効になりました。',
        PassStatus.restored => '購入を復元しました。',
        PassStatus.nothingToRestore => 'このストアのアカウントでは、購入の記録が見つかりませんでした。',
        PassStatus.failed => '購入できませんでした。時間をおいて、もう一度お試しください。',
        PassStatus.unavailable => 'ストアにつながりません。通信できる場所で、もう一度お試しください。',
        PassStatus.idle || PassStatus.pending => null,
      };

  void _showStatus(PassStatus s) {
    if (s == _lastShown) return;
    _lastShown = s;
    final m = _message(s);
    if (m == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(m)));
    });
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppController>();
    final p = app.purchases;
    final text = Theme.of(context).textTheme;
    _showStatus(p.status);
    final busy = p.status == PassStatus.pending;

    final benefits = [
      '広告が出なくなります',
      'ヒント2と答えが、広告を見ずにすぐ開きます',
      if (app.hasPaidScenarios) '有料シナリオの部屋をつくれます（相棒は無料で参加できます）',
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('ひそかぎパス')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(app.hasPass ? 'パスは有効です' : '買い切り　${p.priceLabel}',
                      key: const Key('pass-headline'),
                      style: text.titleLarge
                          ?.copyWith(color: HisokagiTheme.star)),
                  const SizedBox(height: 12),
                  for (final b in benefits)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(top: 2, right: 8),
                            child: Icon(Icons.check, size: 18,
                                color: HisokagiTheme.good),
                          ),
                          Expanded(
                              child: Text(b, style: const TextStyle(height: 1.5))),
                        ],
                      ),
                    ),
                  const SizedBox(height: 8),
                  Text('一度買えば、ずっと使えます。月額の料金はありません。',
                      style: text.bodySmall
                          ?.copyWith(color: HisokagiTheme.textDim)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (!app.hasPass)
            FilledButton(
              key: const Key('buy-pass'),
              onPressed: busy ? null : p.buyPass,
              child: busy
                  ? const SizedBox(
                      width: 22, height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2.5))
                  : Text('${p.priceLabel}で買う'),
            ),
          const SizedBox(height: 8),
          TextButton(
            key: const Key('restore-pass'),
            onPressed: busy ? null : p.restore,
            child: const Text('購入を復元する'),
          ),
          if (_privacyRequired)
            TextButton(
              onPressed: app.ads.showPrivacyOptions,
              child: const Text('広告のプライバシー設定'),
            ),
          const SizedBox(height: 16),
          Text(
            '広告は、あなたに合わせて選ばれるもの（パーソナライズ広告）を使いません。'
            'プレイ中と謎の途中には広告を出しません。',
            style: text.bodySmall?.copyWith(color: HisokagiTheme.textDim, height: 1.6),
          ),
        ],
      ),
    );
  }
}
