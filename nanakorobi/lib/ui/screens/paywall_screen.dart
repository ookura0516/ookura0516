import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/entitlements.dart';
import '../../services/plus_service.dart';
import '../../services/settings_store.dart';
import '../../state/daruma_actions.dart';
import '../../state/providers.dart';
import '../theme.dart';
import '../widgets/l10n_ext.dart';

/// プラス購入：特典一覧、¥600（仮置き）。購入導線は3回だけ（2体目、7日目の共有、両目の直後）。
class PaywallScreen extends ConsumerStatefulWidget {
  const PaywallScreen({super.key, this.entry});

  final String? entry;

  @override
  ConsumerState<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends ConsumerState<PaywallScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(darumaActionsProvider).count(MetricKeys.paywallShown));
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final plus = ref.watch(plusProvider);
    final t = Theme.of(context).textTheme;
    final entry = PaywallEntry.values.where((e) => e.name == widget.entry).firstOrNull;
    final entryText = switch (entry) {
      PaywallEntry.secondDaruma => l.paywallEntrySecond,
      PaywallEntry.firstMilestoneShare => l.paywallEntryMilestone,
      PaywallEntry.afterCompletion => l.paywallEntryCompletion,
      _ => null,
    };
    final status = switch (plus.status) {
      PlusStatus.pending => l.paywallPending,
      PlusStatus.purchased => l.paywallPurchased,
      PlusStatus.restored => l.paywallRestored,
      PlusStatus.nothingToRestore => l.paywallNothingToRestore,
      PlusStatus.failed => l.paywallFailed,
      PlusStatus.unavailable => l.paywallUnavailable,
      PlusStatus.idle => null,
    };

    return Scaffold(
      appBar: AppBar(title: Text(l.paywallTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          if (entryText != null) Text(entryText, style: t.bodyMedium?.copyWith(color: NanakorobiTheme.inkDim)),
          const SizedBox(height: 8),
          Text(l.paywallPrice(plus.priceLabel), style: t.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          for (final b in [l.paywallBenefit1, l.paywallBenefit2, l.paywallBenefit3, l.paywallBenefit4, l.paywallBenefit5])
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.check_circle_outline, color: NanakorobiTheme.gold),
              title: Text(b),
            ),
          const SizedBox(height: 12),
          if (plus.hasPlus)
            Text(l.plusActive, key: const Key('plus-active'), style: t.titleMedium)
          else
            FilledButton(
              key: const Key('buy-plus'),
              onPressed: plus.status == PlusStatus.pending ? null : () => ref.read(plusProvider.notifier).buy(),
              child: Text(l.paywallBuy),
            ),
          const SizedBox(height: 8),
          OutlinedButton(
            key: const Key('restore-plus'),
            onPressed: plus.status == PlusStatus.pending ? null : () => ref.read(plusProvider.notifier).restore(),
            child: Text(l.paywallRestore),
          ),
          if (status != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(status, key: const Key('plus-status'), textAlign: TextAlign.center),
            ),
          const SizedBox(height: 12),
          Text(l.paywallNote, style: t.bodySmall?.copyWith(color: NanakorobiTheme.inkDim)),
        ],
      ),
    );
  }
}
