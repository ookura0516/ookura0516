import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../monetize/purchase_service.dart';
import '../app_controller.dart';

/// 全問パックの説明と購入。アーカイブの8日より前、または「広告を消す」から開く。
Future<void> showPurchaseSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (_) => ChangeNotifierProvider.value(
      value: context.read<AppController>(),
      child: const _PurchaseSheet(),
    ),
  );
}

class _PurchaseSheet extends StatelessWidget {
  const _PurchaseSheet();

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppController>();
    final p = app.purchases;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '$kFullPackName（買い切り ${p.priceLabel}）',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            const Text(
              '・結果画面の広告を消す\n'
              '・過去の問題をすべて遊べる（無料は直近$kFreeArchiveDays日分）\n'
              '・成績の軸別分析（どの軸に強いか・弱いか）',
            ),
            const SizedBox(height: 16),
            if (p.owned)
              const Text('購入済みです。ありがとうございます。', textAlign: TextAlign.center)
            else ...[
              FilledButton(
                key: const Key('buy'),
                onPressed: p.status == PurchaseStatus.pending ? null : p.buy,
                child: Text('${p.priceLabel}で購入'),
              ),
              TextButton(onPressed: p.restore, child: const Text('購入を復元')),
            ],
            if (_statusText(p.status) case final t?)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(t, textAlign: TextAlign.center),
              ),
          ],
        ),
      ),
    );
  }

  String? _statusText(PurchaseStatus s) => switch (s) {
    PurchaseStatus.unavailable => 'いまは購入できません（ストアの準備中です）',
    PurchaseStatus.failed => '購入できませんでした。時間をおいて試してください',
    PurchaseStatus.nothingToRestore => '復元できる購入がありませんでした',
    PurchaseStatus.restored => '購入を復元しました',
    _ => null,
  };
}
