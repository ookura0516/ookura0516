import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/app_state.dart';
import '../../core/day_slots.dart';
import '../../core/postmark_jitter.dart';
import '../theme.dart';
import '../widgets/stamp_view.dart';

/// 切手の詳細：拡大、消印の編集、共有、削除。
class StampDetailScreen extends StatefulWidget {
  const StampDetailScreen({super.key, required this.stampId});

  final int stampId;

  @override
  State<StampDetailScreen> createState() => _StampDetailScreenState();
}

class _StampDetailScreenState extends State<StampDetailScreen> {
  Future<StampEntry?>? _future;
  int _rev = -1;

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    if (_rev != app.revision || _future == null) {
      _rev = app.revision;
      _future = app.loadStamp(widget.stampId);
    }
    return FutureBuilder<StampEntry?>(
      future: _future,
      builder: (context, snap) {
        final e = snap.data;
        if (snap.connectionState != ConnectionState.done && e == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (e == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('この切手は削除されました')),
          );
        }
        final d = e.day;
        return Scaffold(
          appBar: AppBar(
            title: Text('${d.month}月${d.day}日　No.${e.serial}'),
            actions: [
              IconButton(
                key: const Key('delete-stamp'),
                tooltip: '削除',
                icon: const Icon(Icons.delete_outline),
                onPressed: () => _delete(e),
              ),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: InteractiveViewer(
                  maxScale: 5,
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: StampView(entry: e, full: true),
                  ),
                ),
              ),
              if (e.row.postmarkPlace.isNotEmpty ||
                  e.row.postmarkNote.isNotEmpty)
                Text(
                  [
                    e.row.postmarkPlace,
                    e.row.postmarkNote,
                  ].where((s) => s.isNotEmpty).join('　'),
                  key: const Key('detail-postmark-text'),
                ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        key: const Key('edit-postmark'),
                        onPressed: () => _editPostmark(e),
                        icon: const Icon(Icons.edit_outlined),
                        label: const Text('消印を直す'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.icon(
                        key: const Key('share-stamp'),
                        onPressed: () => _share(e),
                        icon: const Icon(Icons.ios_share),
                        label: const Text('共有'),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  kNotPostageNotice,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _delete(StampEntry e) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('この切手を削除しますか'),
        content: const Text('アプリ内にコピーした写真も消えます。写真ライブラリの元の写真は残ります。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('やめる'),
          ),
          FilledButton(
            key: const Key('confirm-delete'),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('削除'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    final app = context.read<AppState>();
    final nav = Navigator.of(context);
    await app.deleteStamp(e);
    nav.pop();
  }

  Future<void> _share(StampEntry e) async {
    final app = context.read<AppState>();
    final kind = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              key: const Key('share-tilted'),
              leading: const Icon(Icons.crop_portrait),
              title: const Text('紙の上に斜めに置いた画像'),
              subtitle: const Text('1080×1350'),
              onTap: () => Navigator.pop(ctx, 'tilted'),
            ),
            ListTile(
              key: const Key('share-tilted-dark'),
              leading: const Icon(Icons.dark_mode_outlined),
              title: const Text('黒い地に斜めに置いた画像'),
              onTap: () => Navigator.pop(ctx, 'dark'),
            ),
            ListTile(
              key: const Key('share-clear'),
              leading: const Icon(Icons.layers_clear_outlined),
              title: const Text('背景が透明な切手（PNG）'),
              subtitle: const Text('ストーリーズに貼る用'),
              onTap: () => Navigator.pop(ctx, 'clear'),
            ),
          ],
        ),
      ),
    );
    if (kind == null) return;
    final File f = switch (kind) {
      'clear' => await app.renderTransparent(e),
      'dark' => await app.renderTiltedShare(e, dark: true),
      _ => await app.renderTiltedShare(e),
    };
    await app.share(f);
  }

  Future<void> _editPostmark(StampEntry e) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) => _PostmarkEditor(entry: e),
    );
  }
}

class _PostmarkEditor extends StatefulWidget {
  const _PostmarkEditor({required this.entry});
  final StampEntry entry;

  @override
  State<_PostmarkEditor> createState() => _PostmarkEditorState();
}

class _PostmarkEditorState extends State<_PostmarkEditor> {
  late final _place = TextEditingController(
    text: widget.entry.row.postmarkPlace,
  );
  late final _note = TextEditingController(text: widget.entry.row.postmarkNote);
  late Day _date = Day.parse(widget.entry.row.postmarkDate);
  late int _seed = widget.entry.row.postmarkSeed;
  String? _error;

  @override
  void dispose() {
    _place.dispose();
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = context.read<AppState>();
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        0,
        20,
        20 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('消印を直す', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          TextField(
            key: const Key('edit-place'),
            controller: _place,
            maxLength: 12,
            decoration: const InputDecoration(labelText: '場所', counterText: ''),
          ),
          const SizedBox(height: 8),
          TextField(
            key: const Key('edit-note'),
            controller: _note,
            maxLength: 10,
            decoration: const InputDecoration(labelText: '一言', counterText: ''),
          ),
          Row(
            children: [
              TextButton(
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _date.toDateTime(),
                    firstDate: DateTime(2000),
                    lastDate: app.today.toDateTime(),
                  );
                  if (picked != null) {
                    setState(() => _date = Day.fromDateTime(picked));
                  }
                },
                child: Text('日付：${_date.dotted}'),
              ),
              const Spacer(),
              TextButton.icon(
                key: const Key('edit-reroll'),
                onPressed: () => setState(
                  () => _seed = newPostmarkSeed(DateTime.now()) ^ _seed,
                ),
                icon: const Icon(Icons.refresh),
                label: const Text('押し直す'),
              ),
            ],
          ),
          if (_error != null)
            Text(
              _error!,
              key: const Key('edit-error'),
              style: const TextStyle(color: KeshiinTheme.accent),
            ),
          const SizedBox(height: 8),
          FilledButton(
            key: const Key('save-postmark'),
            onPressed: () async {
              final nav = Navigator.of(context);
              final err = await app.updatePostmark(
                widget.entry,
                date: _date,
                place: _place.text,
                note: _note.text,
                seed: _seed,
              );
              if (err != null) {
                setState(() => _error = err);
              } else {
                nav.pop();
              }
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }
}
