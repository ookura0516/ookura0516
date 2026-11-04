import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../core/entitlements.dart';
import '../../core/look_builder.dart';
import '../../model/models.dart';
import '../../state/providers.dart';
import '../daruma/daruma_view.dart';
import '../theme.dart';
import '../widgets/l10n_ext.dart';
import 'share_screen.dart';

/// 棚：現役・満願・納めの3段、年で絞り込み、年末ポスター（プラス）。
class ShelfScreen extends ConsumerStatefulWidget {
  const ShelfScreen({super.key});

  @override
  ConsumerState<ShelfScreen> createState() => _ShelfScreenState();
}

class _ShelfScreenState extends ConsumerState<ShelfScreen> {
  int? _year;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final shelfAll = ref.watch(shelfProvider);
    final shelf = shelfAll.ofYear(_year);
    final today = ref.watch(todayProvider);
    final hasPlus = ref.watch(hasPlusProvider);
    final posterYear = _year ?? today.year;

    return Scaffold(
      appBar: AppBar(title: Text(l.shelfTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
        children: [
          if (shelfAll.years.length > 1)
            Wrap(
              spacing: 8,
              children: [
                ChoiceChip(label: Text(l.yearAll), selected: _year == null, onSelected: (_) => setState(() => _year = null)),
                for (final y in shelfAll.years)
                  ChoiceChip(
                    key: Key('year-$y'),
                    label: Text(l.yearLabel(y)),
                    selected: _year == y,
                    onSelected: (_) => setState(() => _year = y),
                  ),
              ],
            ),
          _Row(title: l.shelfActive, items: shelf.active, today: today),
          _Row(title: l.shelfCompleted, items: shelf.completed, today: today),
          _Row(title: l.shelfRetired, items: shelf.retired, today: today),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            key: const Key('shelf-poster'),
            onPressed: () => hasPlus
                ? context.push(Routes.shareFor(occasion: ShareOccasion.year.name, year: posterYear))
                : context.push(Routes.paywallFrom(PaywallEntry.settings.name)),
            icon: Icon(hasPlus ? Icons.image_outlined : Icons.lock_outline),
            label: Text(l.posterButton),
          ),
          if (!hasPlus)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(l.posterPlus, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: NanakorobiTheme.inkDim)),
            ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.title, required this.items, required this.today});

  final String title;
  final List<DarumaBundle> items;
  final dynamic today;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 16, 4, 6),
          child: Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(8, 10, 8, 0),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Color(0xFF7A5A3A), width: 6)),
          ),
          child: items.isEmpty
              ? Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(l.shelfEmpty, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: NanakorobiTheme.inkDim)),
                )
              : SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      for (final b in items)
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: InkWell(
                            key: Key('shelf-${b.id}'),
                            onTap: () => context.push(Routes.daruma(b.id)),
                            child: SizedBox(
                              width: 96,
                              height: 120,
                              child: Align(
                                alignment: Alignment.bottomCenter,
                                child: DarumaView(
                                  look: buildLookFromBundle(b, today).copyWith(fallen: false),
                                  fitRank: true,
                                  semanticsLabel: b.daruma.name,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
        ),
      ],
    );
  }
}
