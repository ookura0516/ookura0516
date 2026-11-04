import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../data/repository.dart';
import '../../render/pdf_export.dart';
import '../app_controller.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'font_license_screen.dart';

/// 設定。雅号、通知、書き出し・読み込み、購入、ライセンス。
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _editGago(BuildContext context, AppController app) async {
    final c = TextEditingController(text: app.gago);
    final v = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('雅号'),
        content: TextField(
          key: const Key('gago-field'),
          controller: c,
          autofocus: true,
          maxLength: 8,
          style: TanzakuTheme.input,
          decoration: const InputDecoration(
            hintText: '例：月庵',
            helperText: '落款（印）に最初の4字を彫ります',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('やめる'),
          ),
          TextButton(
            key: const Key('gago-save'),
            onPressed: () => Navigator.pop(ctx, c.text),
            child: const Text('保存'),
          ),
        ],
      ),
    );
    if (v != null) await app.setGago(v);
  }

  Future<void> _export(BuildContext context, AppController app) async {
    final json = await app.exportJson();
    final t = app.today;
    final name =
        'tanzaku_${t.year}${t.month.toString().padLeft(2, '0')}${t.day.toString().padLeft(2, '0')}.json';
    await app.share.shareFile(
      Uint8List.fromList(utf8.encode(json)),
      name,
      'application/json',
    );
  }

  Future<void> _import(BuildContext context, AppController app) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final text = await app.share.pickJsonText();
      if (text == null) return;
      final n = await app.importJson(text);
      messenger.showSnackBar(SnackBar(content: Text('$n句を読み込みました')));
    } on ImportException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  Future<void> _pdf(BuildContext context, AppController app) async {
    if (!await ensureSuzuri(context, reason: '縦書き PDF はすずりで書き出せます。')) return;
    final font = await rootBundle.load('assets/fonts/NotoSerifJP-Regular.ttf');
    final bytes = await buildHaikuPdf(
      haiku: [for (final h in app.haiku.reversed) (h.body, h.composedOn)],
      fontData: font,
      gago: app.gago,
    );
    await app.share.shareFile(bytes, 'tanzaku_kucho.pdf', 'application/pdf');
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppController>();
    final m = app.notifyMinutes;
    final time = '${m ~/ 60}:${(m % 60).toString().padLeft(2, '0')}';
    return Scaffold(
      appBar: AppBar(title: const Text('設定')),
      body: ListView(
        children: [
          ListTile(
            key: const Key('gago'),
            title: const Text('雅号'),
            subtitle: Text(app.gago.isEmpty ? '未設定（落款なし）' : app.gago),
            trailing: const Icon(Icons.edit),
            onTap: () => _editGago(context, app),
          ),
          const Divider(),
          SwitchListTile(
            key: const Key('notify'),
            title: const Text('兼題の通知'),
            subtitle: Text('1日1回 $time に今日の季語をお知らせ'),
            value: app.notifyEnabled,
            onChanged: (v) async {
              final ok = await app.setNotify(v);
              if (!ok && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('通知が許可されていません。端末の設定から許可してください')),
                );
              }
            },
          ),
          ListTile(
            title: const Text('通知の時刻'),
            subtitle: Text(time),
            enabled: app.notifyEnabled,
            onTap: () async {
              final t = await showTimePicker(
                context: context,
                initialTime: TimeOfDay(hour: m ~/ 60, minute: m % 60),
              );
              if (t != null) {
                await app.setNotify(true, minutes: t.hour * 60 + t.minute);
              }
            },
          ),
          const Divider(),
          ListTile(
            key: const Key('export'),
            leading: const Icon(Icons.upload_file),
            title: const Text('書き出し（JSON）'),
            subtitle: const Text('全句と推敲の履歴をファイルにします'),
            onTap: () => _export(context, app),
          ),
          ListTile(
            key: const Key('import'),
            leading: const Icon(Icons.download),
            title: const Text('読み込み（JSON）'),
            subtitle: const Text('書き出したファイルから句を戻します。同じ句は重ねません'),
            onTap: () => _import(context, app),
          ),
          ListTile(
            key: const Key('pdf'),
            leading: const Icon(Icons.picture_as_pdf_outlined),
            title: LockedLabel('縦書き PDF', locked: !app.hasSuzuri),
            subtitle: const Text('A4 に10句ずつ。句会の清記に'),
            onTap: () => _pdf(context, app),
          ),
          const Divider(),
          ListTile(
            key: const Key('purchase'),
            leading: const Icon(Icons.brush_outlined),
            title: Text(
              app.hasSuzuri
                  ? 'すずり（購入済み）'
                  : 'すずり（買い切り ${app.purchases.priceLabel}）',
            ),
            subtitle: const Text('書体・和紙・色紙・落款・十句ポスター・縦書き PDF'),
            onTap: () => ensureSuzuri(context),
          ),
          const Divider(),
          ListTile(
            key: const Key('font-licenses'),
            title: const Text('フォントのライセンス'),
            subtitle: const Text(
              'Noto Serif JP・しっぽり明朝・Yuji Syuku（SIL Open Font License 1.1）',
            ),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const FontLicenseScreen()),
            ),
          ),
          ListTile(
            title: const Text('そのほかのライセンス'),
            onTap: () =>
                showLicensePage(context: context, applicationName: 'タンザク'),
          ),
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'タンザクはサーバーもアカウントも使いません。句はこの端末の中だけにあります。機種変更の前に「書き出し」で保存してください。',
              style: TextStyle(color: TanzakuTheme.inkDim),
            ),
          ),
        ],
      ),
    );
  }
}
