import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/kigo.dart';
import '../../core/season.dart';
import '../app_controller.dart';
import '../theme.dart';
import 'kigo_detail_screen.dart';

/// 歳時記。検索と「今の季節」。
class SaijikiScreen extends StatefulWidget {
  const SaijikiScreen({super.key});

  @override
  State<SaijikiScreen> createState() => _SaijikiScreenState();
}

class _SaijikiScreenState extends State<SaijikiScreen> {
  final _query = TextEditingController();

  /// null は「すべて」。
  Season? _season;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _season = context.read<AppController>().season;
      _initialized = true;
    }
  }

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppController>();
    final now = app.season;
    final results = app.dictionary.search(_query.text, season: _season);
    final byCategory = <String, List<Kigo>>{};
    for (final k in results) {
      byCategory.putIfAbsent(k.category, () => []).add(k);
    }
    final searching = _query.text.trim().isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: const Text('歳時記')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
            child: TextField(
              key: const Key('saijiki-search'),
              controller: _query,
              style: TanzakuTheme.inputSmall,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: '季語・読みで探す',
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                ChoiceChip(
                  key: const Key('season-now'),
                  label: Text('今の季節（${now.label}）'),
                  selected: _season == now,
                  onSelected: (_) => setState(() => _season = now),
                ),
                const SizedBox(width: 6),
                for (final s in Season.values)
                  if (s != now)
                    Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: ChoiceChip(
                        label: Text(s.label),
                        selected: _season == s,
                        onSelected: (_) => setState(() => _season = s),
                      ),
                    ),
                ChoiceChip(
                  key: const Key('season-all'),
                  label: const Text('すべて'),
                  selected: _season == null,
                  onSelected: (_) => setState(() => _season = null),
                ),
              ],
            ),
          ),
          Expanded(
            child: results.isEmpty
                ? const Center(child: Text('見つかりませんでした'))
                : ListView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                    children: [
                      if (searching)
                        for (final k in results) _KigoTile(kigo: k)
                      else
                        for (final c in kigoCategories)
                          if (byCategory[c] != null) ...[
                            Padding(
                              padding: const EdgeInsets.only(
                                top: 12,
                                bottom: 4,
                              ),
                              child: Text(
                                '$c（${byCategory[c]!.length}）',
                                style: const TextStyle(
                                  color: TanzakuTheme.inkDim,
                                ),
                              ),
                            ),
                            for (final k in byCategory[c]!) _KigoTile(kigo: k),
                          ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _KigoTile extends StatelessWidget {
  const _KigoTile({required this.kigo});
  final Kigo kigo;

  @override
  Widget build(BuildContext context) => ListTile(
    key: Key('kigo-tile-${kigo.id}'),
    contentPadding: EdgeInsets.zero,
    title: Text(kigo.word, style: TanzakuTheme.haiku),
    subtitle: Text(
      '${kigo.reading}　${kigo.season.label}・${kigo.category}',
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    ),
    trailing: const Icon(Icons.chevron_right),
    onTap: () => Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => KigoDetailScreen(kigo: kigo)),
    ),
  );
}
