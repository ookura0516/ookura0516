import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/rules.dart';
import '../../data/presets.dart';
import '../../l10n/app_localizations.dart';
import '../../state/providers.dart';
import '../share_flow.dart';
import '../theme.dart';

/// 試験日プリセット。同梱 JSON から、今日以降のものを近い順に。
class PresetsScreen extends ConsumerWidget {
  const PresetsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = L10n.of(context);
    final today = ref.watch(todayProvider);
    final async = ref.watch(presetsProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l.presetsTitle)),
      body: SafeArea(
        child: async.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('$e')),
          data: (presets) {
            final items = presets.upcoming(today);
            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
              children: [
                if (items.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Text(l.presetsEmpty, textAlign: TextAlign.center),
                  ),
                for (final p in items)
                  Card(
                    child: ListTile(
                      key: Key('preset-${p.id}'),
                      title: Text(p.name),
                      subtitle: Text('${p.category} ・ ${formatDate(p.date)}'),
                      trailing: Text(
                        l.presetsDaysLeft(Rules.daysLeft(p.date, today)),
                        style: const TextStyle(fontWeight: FontWeight.bold, color: NanakorobiTheme.red),
                      ),
                      onTap: () => context.pop<ExamPreset>(p),
                    ),
                  ),
                const SizedBox(height: 12),
                Text(
                  l.presetsUpdated(presets.updated),
                  style: const TextStyle(fontSize: 12, color: NanakorobiTheme.inkDim, height: 1.6),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
