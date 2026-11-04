import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/app_state.dart';
import '../../core/frames.dart';
import '../../monetize/purchase_service.dart';
import '../theme.dart';
import '../widgets/paywall.dart';

/// 設定：シート名、消印の書体、書き出し、購入、注意書き。
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final _title = TextEditingController(
    text: context.read<AppState>().settings.sheetTitle,
  );
  String? _titleError;
  String? _titleSaved;
  bool _exporting = false;

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final p = app.purchases;
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('設定')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('シート名', style: text.titleMedium),
            const SizedBox(height: 4),
            const Text('シートの上と、切手の右下に小さく入ります（「2026 日常」など）。'),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextField(
                    key: const Key('sheet-title-field'),
                    controller: _title,
                    maxLength: 16,
                    decoration: InputDecoration(
                      errorText: _titleError,
                      helperText: _titleSaved,
                    ),
                    onChanged: (_) => setState(() {
                      _titleError = null;
                      _titleSaved = null;
                    }),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  key: const Key('sheet-title-save'),
                  onPressed: () async {
                    final err = await app.setSheetTitle(_title.text);
                    setState(() {
                      _titleError = err;
                      _titleSaved = err == null ? '保存しました' : null;
                    });
                  },
                  child: const Text('保存'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text('消印の書体', style: text.titleMedium),
            RadioGroup<String>(
              groupValue: app.fontId,
              onChanged: (id) async {
                if (id == null) return;
                final f = postmarkFontById(id);
                if (f.premium &&
                    !await showPaywall(context, Premium.extraFonts)) {
                  return;
                }
                await app.setFont(id);
              },
              child: Column(
                children: [
                  for (final f in postmarkFonts)
                    RadioListTile<String>(
                      key: Key('font-${f.id}'),
                      value: f.id,
                      title: Text(f.name),
                      subtitle: f.premium && !app.unlocked(Premium.extraFonts)
                          ? const Text('記念')
                          : null,
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text('書き出し', style: text.titleMedium),
            const SizedBox(height: 4),
            const Text('切手のデータと元の写真を、年ごとの ZIP にして共有シートに渡します。「ファイル」に保存できます。'),
            const SizedBox(height: 8),
            FutureBuilder<int>(
              future: app.photoStore.totalBytes(),
              builder: (context, snap) => Text('写真の容量：${_mb(snap.data ?? 0)}'),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              key: const Key('export-zip'),
              onPressed: _exporting
                  ? null
                  : () async {
                      setState(() => _exporting = true);
                      final messenger = ScaffoldMessenger.of(context);
                      try {
                        final files = await app.exportZip();
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text(
                              files.isEmpty
                                  ? '書き出す切手がありません'
                                  : '${files.length}個の ZIP を作りました',
                            ),
                          ),
                        );
                      } catch (_) {
                        messenger.showSnackBar(
                          const SnackBar(content: Text('書き出せませんでした')),
                        );
                      } finally {
                        if (mounted) setState(() => _exporting = false);
                      }
                    },
              icon: const Icon(Icons.archive_outlined),
              label: const Text('ZIP で書き出す'),
            ),
            const SizedBox(height: 24),
            Text('記念（買い切り ${p.priceLabel}）', style: text.titleMedium),
            const SizedBox(height: 4),
            Text(Premium.values.map((f) => f.label).join('、')),
            const SizedBox(height: 8),
            if (p.hasKinen)
              const ListTile(
                leading: Icon(Icons.verified_outlined),
                title: Text('購入済みです。ありがとうございます。'),
              )
            else
              FilledButton(
                key: const Key('settings-buy'),
                onPressed: () => showPaywall(context, Premium.extraFrames),
                child: const Text('記念について'),
              ),
            TextButton(onPressed: p.restore, child: const Text('購入を復元')),
            if (p.isProvisional)
              Text('いまの購入は仮の実装です（ストアの商品が未登録）。', style: text.bodySmall),
            if (kDebugMode && p is ProvisionalPurchaseService && p.hasKinen)
              TextButton(
                onPressed: p.reset,
                child: const Text('仮の購入を取り消す（開発用）'),
              ),
            const SizedBox(height: 24),
            Text('このアプリについて', style: text.titleMedium),
            const SizedBox(height: 4),
            const Text(kNotPostageNotice, key: Key('notice')),
            const SizedBox(height: 4),
            const Text('額面や通貨記号は入りません。シートや消印には、郵便を思わせる言葉は使えません。'),
            const SizedBox(height: 12),
            Text(
              '写真は端末の中だけに保存し、どこにも送りません。場所は写真の位置情報から市区町村まで読みます。'
              '端末の現在地や写真ライブラリ全体へのアクセスは求めません。海外の写真の地名だけ、通信できるときに OS の機能で調べます。',
              style: text.bodySmall,
            ),
            const SizedBox(height: 12),
            Text(
              '市区町村の代表座標：Geolonia 住所データ（CC BY 4.0、国土交通省「位置参照情報」ほかをもとに加工）から作成。',
              style: text.bodySmall,
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  static String _mb(int bytes) =>
      '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
}
