import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/database.dart';
import '../app_controller.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'compose_screen.dart';
import 'kigo_detail_screen.dart';
import 'tanzaku_screen.dart';

/// 1句の詳細。推敲の履歴、メモ、お気に入り。
class HaikuDetailScreen extends StatefulWidget {
  const HaikuDetailScreen({super.key, required this.haikuId});
  final int haikuId;

  @override
  State<HaikuDetailScreen> createState() => _HaikuDetailScreenState();
}

class _HaikuDetailScreenState extends State<HaikuDetailScreen> {
  List<HaikuRevisionRow> _revisions = const [];
  late final TextEditingController _memo;

  @override
  void initState() {
    super.initState();
    final app = context.read<AppController>();
    _memo = TextEditingController(
      text: app.haikuById(widget.haikuId)?.memo ?? '',
    );
    _loadRevisions();
  }

  @override
  void dispose() {
    _memo.dispose();
    super.dispose();
  }

  Future<void> _loadRevisions() async {
    final r = await context.read<AppController>().repo.revisions(
      widget.haikuId,
    );
    if (mounted) setState(() => _revisions = r);
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppController>();
    final h = app.haikuById(widget.haikuId);
    if (h == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('この句は削除されました')),
      );
    }
    final kigo = app.dictionary.byId(h.kigoId);

    return Scaffold(
      appBar: AppBar(
        title: Text(formatDate(h.composedOn)),
        actions: [
          IconButton(
            key: const Key('detail-favorite'),
            tooltip: h.favorite ? 'お気に入りから外す' : 'お気に入り',
            icon: Icon(h.favorite ? Icons.star : Icons.star_border),
            onPressed: () => app.toggleFavorite(h),
          ),
          IconButton(
            tooltip: '削除',
            icon: const Icon(Icons.delete_outline),
            onPressed: () async {
              final ok = await showDialog<bool>(
                context: context,
                builder: (c) => AlertDialog(
                  title: const Text('この句を削除しますか'),
                  content: const Text('推敲の履歴も消えます。元に戻せません。'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(c, false),
                      child: const Text('やめる'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(c, true),
                      child: const Text('削除'),
                    ),
                  ],
                ),
              );
              if (ok == true && context.mounted) {
                Navigator.pop(context);
                await app.delete(h.id);
              }
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          if (h.maegaki.isNotEmpty)
            Text(
              h.maegaki,
              style: const TextStyle(
                color: TanzakuTheme.inkDim,
                fontFamily: TanzakuTheme.haikuFont,
              ),
            ),
          Text(
            h.body,
            key: const Key('detail-body'),
            style: TanzakuTheme.haiku.copyWith(fontSize: 24),
          ),
          const SizedBox(height: 8),
          if (kigo != null)
            Align(
              alignment: Alignment.centerLeft,
              child: KigoChip(
                kigo: kigo,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => KigoDetailScreen(kigo: kigo),
                  ),
                ),
              ),
            ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  key: const Key('revise'),
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ComposeScreen(editing: h),
                      ),
                    );
                    await _loadRevisions();
                  },
                  child: const Text('推敲する'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  key: const Key('open-tanzaku'),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TanzakuScreen(haikuId: h.id),
                    ),
                  ),
                  child: const Text('短冊にする'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          TextField(
            key: const Key('memo'),
            controller: _memo,
            style: TanzakuTheme.inputSmall,
            maxLines: null,
            decoration: const InputDecoration(labelText: 'メモ'),
            onChanged: (v) => app.setMemo(h.id, v),
          ),
          const SizedBox(height: 20),
          Text(
            '推敲の履歴（${_revisions.length}）',
            style: const TextStyle(color: TanzakuTheme.inkDim),
          ),
          if (_revisions.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 6),
              child: Text('まだありません。推敲すると、前の版がここに残ります（20件まで）。'),
            ),
          for (final r in _revisions)
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                r.body.replaceAll('\n', '　'),
                style: TanzakuTheme.haiku,
              ),
              subtitle: Text(formatDate(r.savedAt)),
            ),
        ],
      ),
    );
  }
}
