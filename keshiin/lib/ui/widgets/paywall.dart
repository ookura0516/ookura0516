import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/app_state.dart';
import '../../monetize/purchase_service.dart';

/// 「記念」の案内。有料の機能を使おうとしたときにだけ出す（設計書「収益化」）。
Future<bool> showPaywall(BuildContext context, Premium reason) async {
  final app = context.read<AppState>();
  if (app.unlocked(reason)) return true;
  final ok = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (ctx) => _Paywall(reason: reason),
  );
  return ok == true && app.unlocked(reason);
}

class _Paywall extends StatelessWidget {
  const _Paywall({required this.reason});
  final Premium reason;

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AppState>().purchases;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '「${reason.label}」は「記念」で使えます',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            const Text('買い切り・広告なし。一度買えばずっと使えます。'),
            const SizedBox(height: 8),
            for (final f in Premium.values)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    const Icon(Icons.check, size: 18),
                    const SizedBox(width: 8),
                    Text(f.label),
                  ],
                ),
              ),
            if (p.isProvisional) ...[
              const SizedBox(height: 8),
              Text(
                'いまは仮の購入です（ストア未接続）。お金はかかりません。',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            const SizedBox(height: 16),
            FilledButton(
              key: const Key('buy-kinen'),
              onPressed: p.status == KinenStatus.pending
                  ? null
                  : () async {
                      await p.buy();
                      if (context.mounted && p.hasKinen) {
                        Navigator.pop(context, true);
                      }
                    },
              child: Text('記念を買う ${p.priceLabel}'),
            ),
            TextButton(onPressed: p.restore, child: const Text('購入を復元')),
            if (p.status == KinenStatus.unavailable)
              const Text('ストアに接続できませんでした。通信を確かめてください。'),
            if (p.status == KinenStatus.nothingToRestore)
              const Text('復元できる購入はありませんでした。'),
          ],
        ),
      ),
    );
  }
}
