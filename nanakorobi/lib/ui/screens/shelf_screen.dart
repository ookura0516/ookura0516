import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../../model/models.dart';
import '../../state/providers.dart';
import '../share_flow.dart';
import '../theme.dart';
import '../widgets/daruma_view.dart';

/// 棚：現役・満願・納めの3段。納めたら消えず、ここに残る。
class ShelfScreen extends ConsumerWidget {
  const ShelfScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = L10n.of(context);
    final async = ref.watch(shelfProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l.shelfTitle)),
      body: SafeArea(
        child: async.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('$e')),
          data: (all) {
            final hasActive = all.any((d) => d.isActive);
            final sections = [
              (l.shelfActive, all.where((d) => d.status == DarumaStatus.active).toList()),
              (l.shelfCompleted, all.where((d) => d.status == DarumaStatus.completed).toList().reversed.toList()),
              (l.shelfRetired, all.where((d) => d.status == DarumaStatus.retired).toList().reversed.toList()),
            ];
            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
              children: [
                if (all.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Text(l.shelfEmpty, textAlign: TextAlign.center),
                  ),
                for (final (title, items) in sections)
                  if (items.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.only(top: 12, bottom: 4),
                      child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                    for (final d in items) _ShelfTile(daruma: d, canRetry: !hasActive),
                  ],
                if (!hasActive) ...[
                  const SizedBox(height: 20),
                  FilledButton(
                    key: const Key('shelf-new'),
                    onPressed: () => context.push('/new'),
                    child: Text(l.shelfNew),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ShelfTile extends ConsumerWidget {
  const _ShelfTile({required this.daruma, required this.canRetry});

  final Daruma daruma;
  final bool canRetry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = L10n.of(context);
    final today = ref.watch(todayProvider);
    final detail = ref.watch(darumaDetailProvider(daruma.id)).value;
    final look = detail?.lookOn(today) ??
        DarumaLook(color: daruma.color, text: daruma.name, eyeSide: daruma.eyeSide, seed: daruma.seed);
    final date = switch (daruma.status) {
      DarumaStatus.active => l.shelfOpenedOn(formatDate(daruma.createdOn)),
      DarumaStatus.completed => l.shelfCompletedOn(formatDate(daruma.completedOn ?? daruma.createdOn)),
      DarumaStatus.retired => l.shelfRetiredOn(formatDate(daruma.retiredOn ?? daruma.createdOn)),
    };
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => context.push('/daruma/${daruma.id}'),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              SizedBox(
                width: 72 + 10.0 * (daruma.sizeRank - 1),
                height: 92 + 12.0 * (daruma.sizeRank - 1),
                child: DarumaView(look.copyWith(fallen: false), animate: false),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(daruma.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    Text(date, style: const TextStyle(color: NanakorobiTheme.inkDim, fontSize: 13)),
                    if (detail != null)
                      Text(
                        '${l.homeBrushes(detail.brushCount)} ・ ${l.homeRises(detail.riseCount)}',
                        style: const TextStyle(color: NanakorobiTheme.inkDim, fontSize: 13),
                      ),
                    if (canRetry && !daruma.isActive)
                      TextButton(
                        key: Key('shelf-retry-${daruma.id}'),
                        style: TextButton.styleFrom(padding: EdgeInsets.zero, foregroundColor: NanakorobiTheme.red),
                        onPressed: () => context.push(
                          '/new?parent=${daruma.id}&size=${daruma.sizeRank + 1}&name=${Uri.encodeQueryComponent(daruma.name)}',
                        ),
                        child: Text(l.shelfBigger),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
