import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../game/stats.dart';
import '../../monetize/purchase_service.dart';
import '../app_controller.dart';
import '../theme.dart';
import 'how_to_screen.dart';
import 'purchase_sheet.dart';
import 'puzzle_screen.dart';

/// 設定：遊び方、成績、色名表示、通知、購入。
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppController>();
    final stats = app.stats;
    return Scaffold(
      appBar: AppBar(title: const Text('設定')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('遊び方'),
            onTap: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const HowToScreen())),
          ),
          ListTile(
            leading: const Icon(Icons.school_outlined),
            title: const Text('遊び方の問題をもう一度'),
            onTap: () {
              app.resetTutorial();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => PuzzleScreen(entry: app.tutorial),
                ),
              );
            },
          ),
          const _Header('成績'),
          _StatsView(stats: stats, detailed: app.purchases.owned),
          const _Header('表示'),
          SwitchListTile(
            key: const Key('color-names'),
            title: const Text('色名を表示する'),
            subtitle: const Text('帯と結果に「柿・紅・栗・墨」を文字でも出す'),
            value: app.settings.colorNames,
            onChanged: app.setColorNames,
          ),
          const _Header('通知'),
          SwitchListTile(
            key: const Key('notify'),
            title: const Text('新しい問題を知らせる'),
            subtitle: const Text('1日1回。「第N問が出ました」だけ'),
            value: app.settings.notify,
            onChanged: (v) async {
              final ok = await app.setNotify(v);
              if (!ok && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('通知が許可されていません。端末の設定から許可してください')),
                );
              }
            },
          ),
          if (app.settings.notify)
            ListTile(
              title: const Text('通知の時刻'),
              trailing: DropdownButton<int>(
                value: app.settings.notifyHour,
                items: [
                  for (var h = 6; h <= 22; h++)
                    DropdownMenuItem(value: h, child: Text('$h:00')),
                ],
                onChanged: (h) {
                  if (h != null) app.setNotifyHour(h);
                },
              ),
            ),
          const _Header(kFullPackName),
          ListTile(
            leading: Icon(
              app.purchases.owned
                  ? Icons.check_circle_outline
                  : Icons.lock_open_outlined,
            ),
            title: Text(
              app.purchases.owned
                  ? '購入済み'
                  : '広告を消して、過去問をすべて遊ぶ（${app.purchases.priceLabel}）',
            ),
            onTap: () => showPurchaseSheet(context),
          ),
          const _Header('このアプリについて'),
          const ListTile(
            title: Text('ヨンクミ'),
            subtitle: Text(
              '16語を4組に分ける、日替わりの言葉パズル。'
              '記録はこの端末の中だけに残り、どこにも送りません。',
            ),
          ),
        ],
      ),
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
        color: YonkumiTheme.accent,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}

class _StatsView extends StatelessWidget {
  const _StatsView({required this.stats, required this.detailed});

  final PlayStats stats;

  /// 軸別分析（全問パック）を見せるか。
  final bool detailed;

  @override
  Widget build(BuildContext context) {
    String pct(double v) => '${(v * 100).round()}%';
    final rows = <(String, String)>[
      ('遊んだ問題', '${stats.played}問'),
      ('クリア', '${stats.cleared}問（${pct(stats.clearRate)}）'),
      ('パーフェクト', '${stats.perfect}回'),
      ('平均の間違い', '${stats.averageMistakes.toStringAsFixed(1)}回'),
      ('連続日数', '${stats.streak.current}日'),
      ('最長の連続', '${stats.streak.longest}日'),
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          for (final (k, v) in rows)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Expanded(child: Text(k)),
                  Text(v, style: const TextStyle(fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          const SizedBox(height: 8),
          if (!detailed)
            const Text(
              '軸ごとの正解率（「季語に弱い」など）は全問パックで見られます',
              style: TextStyle(color: YonkumiTheme.inkDim, fontSize: 13),
            )
          else if (stats.byAxis.isEmpty)
            const Text(
              'まだ記録がありません',
              style: TextStyle(color: YonkumiTheme.inkDim),
            )
          else
            for (final e in stats.byAxis.entries)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  children: [
                    SizedBox(width: 110, child: Text(e.key.label)),
                    Expanded(
                      child: LinearProgressIndicator(
                        value: e.value.rate,
                        minHeight: 8,
                        color: YonkumiTheme.ink,
                        backgroundColor: YonkumiTheme.tile,
                      ),
                    ),
                    SizedBox(
                      width: 64,
                      child: Text(
                        '${e.value.solved}/${e.value.total}',
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
              ),
        ],
      ),
    );
  }
}
