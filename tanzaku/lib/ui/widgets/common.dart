import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/kigo.dart';
import '../../data/database.dart';
import '../../render/style.dart';
import '../../render/tanzaku_painter.dart';
import '../../services/purchase_service.dart';
import '../app_controller.dart';
import '../theme.dart';

/// 小さな短冊（ホームの「最近の句」など）。
class TanzakuThumb extends StatelessWidget {
  const TanzakuThumb({
    super.key,
    required this.haiku,
    this.width = 88,
    this.onTap,
  });

  final HaikuRow haiku;
  final double width;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final app = context.read<AppController>();
    final a = app.analyzeBody(haiku.body);
    final style = app.lastStyle.copyWith(form: TanzakuForm.tanzaku);
    return Semantics(
      button: onTap != null,
      label: haiku.body.replaceAll('\n', ' '),
      child: GestureDetector(
        onTap: onTap,
        child: SizedBox(
          width: width,
          height: width * 1350 / 1080,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CustomPaint(
              painter: TanzakuPainter(
                style: style,
                content: TanzakuContent(
                  lines: splitLines(haiku.body),
                  kigoRanges: a.kigoRanges,
                  season: app.dictionary.byId(haiku.kigoId)?.season,
                  appName: '',
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 季語と季節のチップ。
class KigoChip extends StatelessWidget {
  const KigoChip({super.key, required this.kigo, this.onTap});
  final Kigo kigo;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final p = SeasonPalette.of(kigo.season);
    return ActionChip(
      onPressed: onTap,
      backgroundColor: p.wash,
      side: BorderSide(color: p.accent.withValues(alpha: 0.4)),
      label: Text(
        '${kigo.word}　${kigo.season.label}・${kigo.category}',
        style: TextStyle(
          color: TanzakuTheme.ink,
          fontFamily: TanzakuTheme.haikuFont,
        ),
      ),
    );
  }
}

/// 有料の項目を選んだときに出す購入の案内。買えたら true。
Future<bool> ensureSuzuri(BuildContext context, {String reason = ''}) async {
  final app = context.read<AppController>();
  if (app.hasSuzuri) return true;
  final bought = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => ChangeNotifierProvider.value(
      value: app,
      child: PurchaseSheet(reason: reason),
    ),
  );
  return bought ?? app.hasSuzuri;
}

class PurchaseSheet extends StatelessWidget {
  const PurchaseSheet({super.key, this.reason = ''});
  final String reason;

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppController>();
    final p = app.purchases;
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'すずり（買い切り ${p.priceLabel}）',
              style: Theme.of(context).textTheme.titleLarge
                  ?.copyWith(fontFamily: TanzakuTheme.haikuFont),
            ),
            if (reason.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(reason, style: const TextStyle(color: TanzakuTheme.inkDim)),
            ],
            const SizedBox(height: 12),
            for (final f in suzuriFeatures)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('・'),
                    Expanded(child: Text(f)),
                  ],
                ),
              ),
            const SizedBox(height: 8),
            const Text(
              '一度買えばずっと使えます。広告はありません。句帳・歳時記・兼題・短冊（書体1種・和紙1種）・共有は無料のままです。',
              style: TextStyle(color: TanzakuTheme.inkDim),
            ),
            const SizedBox(height: 16),
            if (app.hasSuzuri)
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('すずりを使えます'),
              )
            else ...[
              FilledButton(
                key: const Key('buy-suzuri'),
                onPressed: p.status == PurchaseStatus.pending
                    ? null
                    : () async {
                        await p.buy();
                        if (context.mounted && p.hasSuzuri) {
                          Navigator.pop(context, true);
                        }
                      },
                child: Text('${p.priceLabel}で買う'),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () async {
                  await p.restore();
                  if (!context.mounted) return;
                  if (p.hasSuzuri) {
                    Navigator.pop(context, true);
                  } else if (p.status == PurchaseStatus.nothingToRestore) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('購入の記録が見つかりませんでした')),
                    );
                  }
                },
                child: const Text('購入を復元'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// 鍵の印付きの選択肢。
class LockedLabel extends StatelessWidget {
  const LockedLabel(this.text, {super.key, required this.locked});
  final String text;
  final bool locked;

  @override
  Widget build(BuildContext context) {
    if (!locked) return Text(text);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(text),
        const SizedBox(width: 4),
        const Icon(Icons.lock_outline, size: 14, semanticLabel: 'すずり'),
      ],
    );
  }
}

String formatDate(DateTime d) => '${d.year}年${d.month}月${d.day}日';
