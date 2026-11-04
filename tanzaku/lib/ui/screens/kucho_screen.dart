import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/season.dart';
import '../../data/database.dart';
import '../app_controller.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'haiku_detail_screen.dart';
import 'home_screen.dart';
import 'poster_screen.dart';

enum KuchoOrder { date, season, kigo }

/// 句帳。日付順・季節別・季語別、お気に入り、月の十句ポスター。
class KuchoScreen extends StatefulWidget {
  const KuchoScreen({super.key});

  @override
  State<KuchoScreen> createState() => _KuchoScreenState();
}

class _KuchoScreenState extends State<KuchoScreen> {
  KuchoOrder _order = KuchoOrder.date;
  bool _favoritesOnly = false;

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppController>();
    var list = app.haiku;
    if (_favoritesOnly) list = list.where((h) => h.favorite).toList();

    final groups = <String, List<HaikuRow>>{};
    for (final h in list) {
      final key = switch (_order) {
        KuchoOrder.date => '${h.composedOn.year}年${h.composedOn.month}月',
        KuchoOrder.season => h.season.isEmpty ? '無季' : h.season,
        KuchoOrder.kigo => app.dictionary.byId(h.kigoId)?.word ?? '季語なし',
      };
      groups.putIfAbsent(key, () => []).add(h);
    }
    var keys = groups.keys.toList();
    if (_order == KuchoOrder.season) {
      final order = [...Season.values.map((s) => s.label), '無季'];
      keys.sort((a, b) => order.indexOf(a).compareTo(order.indexOf(b)));
    } else if (_order == KuchoOrder.kigo) {
      keys.sort((a, b) {
        if (a == '季語なし') return 1;
        if (b == '季語なし') return -1;
        return groups[b]!.length != groups[a]!.length
            ? groups[b]!.length.compareTo(groups[a]!.length)
            : a.compareTo(b);
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('句帳'),
        actions: [
          IconButton(
            key: const Key('poster'),
            tooltip: '月の十句',
            icon: const Icon(Icons.view_week_outlined),
            onPressed: () async {
              final ok = await ensureSuzuri(
                context,
                reason: '月の十句ポスターはすずりで作れます。',
              );
              if (!ok) return;
              if (!context.mounted) return;
              final t = app.today;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PosterScreen(year: t.year, month: t.month),
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('kucho-compose'),
        onPressed: () => openCompose(context, theme: app.todayTheme),
        icon: const Icon(Icons.edit),
        label: const Text('詠む'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: SegmentedButton<KuchoOrder>(
                    segments: const [
                      ButtonSegment(value: KuchoOrder.date, label: Text('日付')),
                      ButtonSegment(
                        value: KuchoOrder.season,
                        label: Text('季節'),
                      ),
                      ButtonSegment(value: KuchoOrder.kigo, label: Text('季語')),
                    ],
                    selected: {_order},
                    onSelectionChanged: (s) => setState(() => _order = s.first),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  key: const Key('favorites-only'),
                  tooltip: 'お気に入りだけ',
                  isSelected: _favoritesOnly,
                  icon: const Icon(Icons.star_border),
                  selectedIcon: const Icon(Icons.star),
                  onPressed: () =>
                      setState(() => _favoritesOnly = !_favoritesOnly),
                ),
              ],
            ),
          ),
          Expanded(
            child: list.isEmpty
                ? Center(
                    child: Text(
                      _favoritesOnly ? 'お気に入りの句はまだありません' : 'まだ句がありません',
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
                    children: [
                      for (final k in keys) ...[
                        Padding(
                          padding: const EdgeInsets.only(top: 12, bottom: 4),
                          child: Text(
                            '$k（${groups[k]!.length}）',
                            style: const TextStyle(color: TanzakuTheme.inkDim),
                          ),
                        ),
                        for (final h in groups[k]!) _HaikuTile(haiku: h),
                      ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _HaikuTile extends StatelessWidget {
  const _HaikuTile({required this.haiku});
  final HaikuRow haiku;

  @override
  Widget build(BuildContext context) {
    final app = context.read<AppController>();
    final kigo = app.dictionary.byId(haiku.kigoId);
    return Card(
      child: ListTile(
        key: Key('haiku-${haiku.id}'),
        title: Text(
          haiku.body.replaceAll('\n', '　'),
          style: TanzakuTheme.haiku,
        ),
        subtitle: Text(
          [
            formatDate(haiku.composedOn),
            if (kigo != null) '${kigo.word}（${kigo.season.label}）',
            if (haiku.maegaki.isNotEmpty) haiku.maegaki,
          ].join('　'),
        ),
        trailing: IconButton(
          tooltip: haiku.favorite ? 'お気に入りから外す' : 'お気に入り',
          icon: Icon(haiku.favorite ? Icons.star : Icons.star_border),
          onPressed: () => app.toggleFavorite(haiku),
        ),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => HaikuDetailScreen(haikuId: haiku.id),
          ),
        ),
      ),
    );
  }
}
