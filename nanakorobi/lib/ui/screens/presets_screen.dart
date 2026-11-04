import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/countdown.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../model/models.dart';
import '../../state/providers.dart';
import '../theme.dart';
import '../widgets/l10n_ext.dart';

/// 試験日：共通テスト・公立高校入試・中学入試・資格の一覧と検索。選ぶと作成画面へ戻す。
class PresetsScreen extends ConsumerStatefulWidget {
  const PresetsScreen({super.key});

  @override
  ConsumerState<PresetsScreen> createState() => _PresetsScreenState();
}

class _PresetsScreenState extends ConsumerState<PresetsScreen> {
  var _query = '';
  String? _kind;

  static const kinds = ['university', 'highschool', 'juniorhigh', 'certification'];

  static String kindName(AppLocalizations l, String kind) => switch (kind) {
        'university' => l.presetsKindUniversity,
        'highschool' => l.presetsKindHighschool,
        'juniorhigh' => l.presetsKindJuniorhigh,
        _ => l.presetsKindCertification,
      };

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final today = ref.watch(todayProvider);
    final catalog = ref.watch(presetCatalogProvider);
    final t = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: Text(l.presetsTitle)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: TextField(
              key: const Key('presets-search'),
              decoration: InputDecoration(hintText: l.presetsSearchHint, prefixIcon: const Icon(Icons.search)),
              onChanged: (v) => setState(() => _query = v.trim()),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                for (final k in kinds)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      key: Key('kind-$k'),
                      label: Text(kindName(l, k)),
                      selected: _kind == k,
                      onSelected: (s) => setState(() => _kind = s ? k : null),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: catalog.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, _) => Center(child: Text(l.presetsEmpty)),
              data: (c) {
                final items = c.presets
                    .where((p) => p.date >= today)
                    .where((p) => _kind == null || p.kind == _kind)
                    .where((p) => _query.isEmpty || p.name.contains(_query) || (p.region?.contains(_query) ?? false))
                    .toList()
                  ..sort((a, b) => a.date.compareTo(b.date));
                if (items.isEmpty) return Center(child: Text(l.presetsEmpty));
                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 24),
                  itemCount: items.length + 1,
                  itemBuilder: (context, i) {
                    if (i == items.length) {
                      return Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          '${l.presetsUpdated(context.formatDate(c.updatedOn))}\n${l.presetsPastHidden}',
                          style: t.bodySmall?.copyWith(color: NanakorobiTheme.inkDim),
                        ),
                      );
                    }
                    final p = items[i];
                    return ListTile(
                      key: Key('preset-${p.id}'),
                      title: Text(p.name),
                      subtitle: Text(
                        '${context.formatDate(p.date)}　${kindName(l, p.kind)}${p.region == null ? '' : '　${p.region}'}\n${p.sourceOrg}',
                      ),
                      isThreeLine: true,
                      trailing: Text(l.presetsDaysLeft(Countdown.daysLeft(p.date, today)), style: t.labelLarge),
                      onTap: () => context.pop<ExamPreset>(p),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
