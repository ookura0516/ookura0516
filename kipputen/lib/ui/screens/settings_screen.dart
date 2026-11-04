import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../monetize/products.dart';
import '../../monetize/purchase_service.dart';
import '../app_controller.dart';
import '../theme.dart';
import '../ticket_design.dart';
import 'how_to.dart';
import 'privacy_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppController>();
    final s = app.settings;
    final streak = app.streak;
    final avg = app.averageSeconds;
    return Scaffold(
      appBar: AppBar(title: const Text('設定')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('遊び方'),
            onTap: () => showHowTo(context),
          ),
          const _Header('成績'),
          ListTile(
            title: const Text('連続日数'),
            trailing: Text(
              '${streak.current} 日（最長 ${streak.best} 日）',
              key: const Key('stat-streak'),
            ),
          ),
          ListTile(
            title: const Text('解いた切符'),
            trailing: Text(
              '${app.solvedCount} 枚（日替わり ${app.dailyClearedCount} 日）',
            ),
          ),
          ListTile(
            title: const Text('平均タイム'),
            trailing: Text(avg == null ? '—' : '${avg ~/ 60}分${avg % 60}秒'),
          ),
          const _Header('遊び'),
          SwitchListTile(
            title: const Text('タイマーを出す'),
            subtitle: const Text('タイムは出さなくても記録します'),
            value: s.showTimer,
            onChanged: (v) => app.updateSettings((s) => s.showTimer = v),
          ),
          SwitchListTile(
            key: const Key('toggle-notify'),
            title: const Text('毎日の通知'),
            subtitle: const Text('1日1回、今日の4桁をお知らせします'),
            value: s.notify,
            onChanged: (v) async {
              final ok = await app.setNotify(v);
              if (!ok && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('通知が許可されていません。端末の設定で許可してください')),
                );
              }
            },
          ),
          if (s.notify)
            ListTile(
              key: const Key('notify-time'),
              title: const Text('通知の時刻（日本時間）'),
              trailing: Text(
                '${s.notifyMinutes ~/ 60}:${(s.notifyMinutes % 60).toString().padLeft(2, '0')}',
              ),
              onTap: () async {
                final t = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay(
                    hour: s.notifyMinutes ~/ 60,
                    minute: s.notifyMinutes % 60,
                  ),
                  helpText: '通知の時刻（日本時間）',
                );
                if (t != null) await app.setNotifyTime(t.hour * 60 + t.minute);
              },
            ),
          ListTile(
            title: const Text('誕生日'),
            subtitle: const Text('図鑑でその番号が金縁になります'),
            trailing: Text(
              s.birthday == null
                  ? '未設定'
                  : '${int.parse(s.birthday!.substring(0, 2))}月${int.parse(s.birthday!.substring(2))}日',
            ),
            onTap: () => _pickBirthday(context, app),
          ),
          const _Header('硬券のデザイン'),
          for (final d in TicketDesign.all) _DesignTile(design: d),
          const _Header('購入'),
          for (final p in Product.values) _ProductTile(product: p),
          ListTile(
            key: const Key('restore'),
            leading: const Icon(Icons.restore),
            title: const Text('購入を復元'),
            onTap: () => _restore(context, app),
          ),
          const _Header('このアプリについて'),
          const ListTile(
            title: Text('問題と記録は端末の中だけ'),
            subtitle: Text('問題は端末の中で日付から決まります。記録はサーバーに送りません。'),
          ),
          ListTile(
            key: const Key('open-privacy'),
            title: const Text('プライバシーポリシー'),
            onTap: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const PrivacyScreen())),
          ),
          if (app.showAds) const _AdPrivacyTile(),
          ListTile(
            title: const Text('ライセンス'),
            onTap: () =>
                showLicensePage(context: context, applicationName: 'キップテン'),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Future<void> _restore(BuildContext context, AppController app) async {
    final messenger = ScaffoldMessenger.of(context);
    await app.purchases.restore();
    // ストアの返事を少し待つ（復元は結果が遅れて届くことがある）。
    void report() {
      final msg = switch (app.purchases.status) {
        PurchaseStatus.restored => '購入を復元しました',
        PurchaseStatus.nothingToRestore => '復元できる購入はありませんでした',
        PurchaseStatus.unavailable => 'ストアに接続できません',
        PurchaseStatus.failed => '復元できませんでした',
        _ => null,
      };
      if (msg != null) {
        messenger.showSnackBar(SnackBar(content: Text(msg)));
        app.purchases.removeListener(report);
      }
    }

    if (app.purchases.status == PurchaseStatus.pending) {
      app.purchases.addListener(report);
    } else {
      report();
    }
  }

  Future<void> _pickBirthday(BuildContext context, AppController app) async {
    final now = DateTime(2000, 1, 1);
    final picked = await showDatePicker(
      context: context,
      initialDate: app.settings.birthday == null
          ? now
          : DateTime(
              2000,
              int.parse(app.settings.birthday!.substring(0, 2)),
              int.parse(app.settings.birthday!.substring(2)),
            ),
      firstDate: DateTime(2000, 1, 1),
      lastDate: DateTime(2000, 12, 31),
      helpText: '誕生日（年は使いません）',
    );
    if (picked == null) return;
    final mmdd =
        '${picked.month.toString().padLeft(2, '0')}${picked.day.toString().padLeft(2, '0')}';
    await app.updateSettings((s) => s.birthday = mmdd);
  }
}

/// EEA などで必要なときだけ出す、広告のプライバシー設定（UMP）。
class _AdPrivacyTile extends StatefulWidget {
  const _AdPrivacyTile();

  @override
  State<_AdPrivacyTile> createState() => _AdPrivacyTileState();
}

class _AdPrivacyTileState extends State<_AdPrivacyTile> {
  bool _required = false;

  @override
  void initState() {
    super.initState();
    context.read<AppController>().ads.privacyOptionsRequired().then((v) {
      if (mounted) setState(() => _required = v);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_required) return const SizedBox.shrink();
    return ListTile(
      title: const Text('広告のプライバシー設定'),
      onTap: () => context.read<AppController>().ads.showPrivacyOptions(),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
    child: Text(
      text,
      style: const TextStyle(
        color: KipTheme.accent,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}

class _DesignTile extends StatelessWidget {
  const _DesignTile({required this.design});
  final TicketDesign design;

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppController>();
    final locked = design.pack && !app.owns(Product.designPack);
    final selected = app.design.id == design.id;
    return ListTile(
      key: Key('design-${design.id}'),
      leading: Container(
        width: 40,
        height: 24,
        decoration: BoxDecoration(
          color: design.paper,
          border: Border.all(color: design.ink.withValues(alpha: 0.5)),
          borderRadius: BorderRadius.circular(3),
        ),
        alignment: Alignment.center,
        child: Text(
          '10',
          style: TextStyle(
            color: design.ink,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      title: Text(design.name),
      subtitle: design.pack ? const Text('デザインパック') : null,
      trailing: locked
          ? const Icon(Icons.lock_outline)
          : selected
          ? const Icon(Icons.check, color: KipTheme.accent)
          : null,
      onTap: () async {
        // 購入の入口は「デザインを変えようとした時」（設計書）。
        // 先に選んでおき、パックが届いた時点でこのデザインになる。
        await app.updateSettings((s) => s.design = design.id);
        if (locked && context.mounted) {
          await _confirmBuy(context, Product.designPack);
        }
      },
    );
  }
}

class _ProductTile extends StatelessWidget {
  const _ProductTile({required this.product});
  final Product product;

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppController>();
    final owned = app.owns(product);
    return ListTile(
      key: Key('buy-${product.name}'),
      title: Text(product.title),
      subtitle: Text(switch (product) {
        Product.removeAds => '図鑑画面の下のバナーを消します',
        Product.designPack => '硬券の地色・書体・入鋏の形が4種増えます。共有画像にも反映',
      }),
      trailing: owned
          ? const Text('購入済み', style: TextStyle(color: KipTheme.accent))
          : FilledButton.tonal(
              onPressed: () => _confirmBuy(context, product),
              child: Text(app.purchases.priceOf(product)),
            ),
    );
  }
}

Future<void> _confirmBuy(BuildContext context, Product p) async {
  final app = context.read<AppController>();
  final ok = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(p.title),
      content: Text('${app.purchases.priceOf(p)} で購入しますか？（買い切り）'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('やめる'),
        ),
        FilledButton(
          key: const Key('confirm-buy'),
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('購入する'),
        ),
      ],
    ),
  );
  if (ok != true || !context.mounted) return;
  final messenger = ScaffoldMessenger.of(context);
  await app.purchases.buy(p);
  // ストアの購入は、結果があとから届く。届いたら一言出す。
  void report() {
    final msg = switch (app.purchases.status) {
      PurchaseStatus.purchased ||
      PurchaseStatus.restored => app.owns(p) ? '購入しました' : null,
      PurchaseStatus.unavailable => 'ストアに接続できません',
      PurchaseStatus.failed => '購入できませんでした',
      PurchaseStatus.idle => '購入をやめました',
      _ => null,
    };
    if (msg != null) {
      messenger.showSnackBar(SnackBar(content: Text(msg)));
      app.purchases.removeListener(report);
    }
  }

  if (app.purchases.status == PurchaseStatus.pending) {
    app.purchases.addListener(report);
  } else {
    report();
  }
}
