import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../core/entitlements.dart';
import '../../core/look_builder.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../model/models.dart';
import '../../services/settings_store.dart';
import '../../state/app_deps.dart';
import '../../state/daruma_actions.dart';
import '../../state/providers.dart';
import '../share/share_image_renderer.dart';
import '../theme.dart';
import '../widgets/l10n_ext.dart';

/// 共有を促す4つの山：開眼、節目、両目、年末の棚。
enum ShareOccasion {
  eye,
  milestone,
  complete,
  year;

  static ShareOccasion parse(String? s) =>
      values.firstWhere((v) => v.name == s, orElse: () => ShareOccasion.milestone);
}

/// 共有：テンプレ選択、プレビュー、共有シート。ストアリンクは画像にも本文にも入れない。
class ShareScreen extends ConsumerStatefulWidget {
  const ShareScreen({super.key, this.darumaId, required this.occasion, this.year});

  final String? darumaId;
  final ShareOccasion occasion;
  final int? year;

  @override
  ConsumerState<ShareScreen> createState() => _ShareScreenState();
}

class _ShareScreenState extends ConsumerState<ShareScreen> {
  ShareTemplate _template = ShareTemplate.plain;
  ShareAspect _aspect = ShareAspect.portrait;
  var _busy = false;

  ShareTexts _texts(AppLocalizations l, DarumaLook look, DarumaBundle b) {
    final deadline = b.daruma.deadline;
    final daysLeft = look.daysLeft;
    return ShareTexts(
      headline: l.shareHeadline(look.daysSinceOpened, look.riseCount),
      subline: deadline != null && daysLeft != null && daysLeft >= 0
          ? l.shareDeadlineLine(b.daruma.deadlineName ?? '', daysLeft)
          : '',
      dateLine: look.completedOn == null ? null : l.shareCompletedLine(context.formatDate(look.completedOn!)),
      appName: l.appName,
    );
  }

  String _shareText(AppLocalizations l, {int strokes = 0, int rises = 0, int total = 0}) =>
      switch (widget.occasion) {
        ShareOccasion.eye => l.shareTextEye,
        ShareOccasion.milestone => l.shareTextMilestone(strokes, rises),
        ShareOccasion.complete => l.shareTextComplete,
        ShareOccasion.year => l.shareTextYear(total),
      };

  Future<void> _share(Future<Uint8List> Function() render, String text) async {
    setState(() => _busy = true);
    try {
      final png = await render();
      await ref.read(appDepsProvider).share.sharePng(png, fileName: 'nanakorobi.png', text: text);
      await ref.read(darumaActionsProvider).count(MetricKeys.shared);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.sharedToast)));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  static String _templateName(AppLocalizations l, ShareTemplate t) => switch (t) {
        ShareTemplate.plain => l.templatePlain,
        ShareTemplate.framed => l.templateFramed,
        ShareTemplate.goldScreen => l.templateGoldScreen,
        ShareTemplate.sakura => l.templateSakura,
        ShareTemplate.bonfire => l.templateBonfire,
      };

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final hasPlus = ref.watch(hasPlusProvider);
    final today = ref.watch(todayProvider);
    final renderer = ShareImageRenderer(
      brushFontFamily: NanakorobiTheme.brushFontFamily,
      textFontFamily: ref.watch(appDepsProvider).uiFontFamily,
    );
    final t = Theme.of(context).textTheme;

    final Widget preview;
    final Future<Uint8List> Function() render;
    final String text;

    if (widget.occasion == ShareOccasion.year) {
      final year = widget.year ?? today.year;
      final shelf = ref.watch(shelfProvider).ofYear(year);
      final bundles = [...shelf.completed, ...shelf.retired, ...shelf.active];
      final looks = [for (final b in bundles) buildLookFromBundle(b, today).copyWith(fallen: false)];
      final total = bundles.fold<int>(0, (s, b) => s + b.recoveries.length);
      final texts = PosterTexts(
        title: l.yearPosterTitle(year),
        line: l.yearPosterLine(bundles.length, total),
        appName: l.appName,
      );
      preview = _Preview(
        aspect: _aspect,
        painter: (canvas, size) =>
            renderer.paintPoster(canvas, size, looks: looks, template: _template, texts: texts),
      );
      render = () => renderer.renderPosterPng(looks: looks, template: _template, aspect: _aspect, texts: texts);
      text = _shareText(l, total: total);
    } else {
      final id = widget.darumaId;
      final b = id == null ? null : ref.watch(bundleProvider(id));
      final look = id == null ? null : ref.watch(lookProvider(id));
      if (b == null || look == null) return Scaffold(appBar: AppBar(title: Text(l.shareTitle)));
      final shown = look.copyWith(fallen: false);
      final texts = _texts(l, shown, b);
      preview = _Preview(
        aspect: _aspect,
        painter: (canvas, size) => renderer.paint(canvas, size, look: shown, template: _template, texts: texts),
      );
      render = () => renderer.renderPng(look: shown, template: _template, aspect: _aspect, texts: texts);
      text = _shareText(l, strokes: shown.strokes, rises: shown.riseCount);
    }

    return Scaffold(
      appBar: AppBar(title: Text(l.shareTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          Center(child: SizedBox(width: MediaQuery.sizeOf(context).width * 0.7, child: preview)),
          const SizedBox(height: 12),
          SegmentedButton<ShareAspect>(
            segments: [
              ButtonSegment(value: ShareAspect.portrait, label: Text(l.shareAspectPortrait)),
              ButtonSegment(value: ShareAspect.square, label: Text(l.shareAspectSquare)),
            ],
            selected: {_aspect},
            onSelectionChanged: (s) => setState(() => _aspect = s.first),
          ),
          const SizedBox(height: 12),
          Text(l.shareTemplateLabel, style: t.titleSmall),
          Wrap(
            spacing: 8,
            children: [
              for (final tpl in ShareTemplate.values)
                ChoiceChip(
                  key: Key('template-${tpl.name}'),
                  label: Text(_templateName(l, tpl)),
                  avatar: Entitlements.templateAllowed(template: tpl, hasPlus: hasPlus)
                      ? null
                      : const Icon(Icons.lock_outline, size: 16),
                  selected: _template == tpl,
                  onSelected: (_) {
                    if (Entitlements.templateAllowed(template: tpl, hasPlus: hasPlus)) {
                      setState(() => _template = tpl);
                    } else {
                      // 購入導線の2つ目：初めての節目の共有画面。
                      context.push(Routes.paywallFrom(PaywallEntry.firstMilestoneShare.name));
                    }
                  },
                ),
            ],
          ),
          if (!hasPlus) Text(l.shareLockedTemplate, style: t.bodySmall?.copyWith(color: NanakorobiTheme.inkDim)),
          const SizedBox(height: 8),
          Text(text, style: t.bodyMedium),
          Text(l.shareNoLink, style: t.bodySmall?.copyWith(color: NanakorobiTheme.inkDim)),
          const SizedBox(height: 16),
          FilledButton.icon(
            key: const Key('share-button'),
            onPressed: _busy ? null : () => _share(render, text),
            icon: const Icon(Icons.ios_share),
            label: Text(l.shareButton),
          ),
        ],
      ),
    );
  }
}

class _Preview extends StatelessWidget {
  const _Preview({required this.aspect, required this.painter});

  final ShareAspect aspect;
  final void Function(Canvas canvas, Size size) painter;

  @override
  Widget build(BuildContext context) => AspectRatio(
        aspectRatio: aspect.width / aspect.height,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: CustomPaint(painter: _ScaledPainter(aspect, painter)),
        ),
      );
}

/// 1080 基準で描いたものを、プレビューの大きさに縮めて描く。
class _ScaledPainter extends CustomPainter {
  _ScaledPainter(this.aspect, this.painter);

  final ShareAspect aspect;
  final void Function(Canvas canvas, Size size) painter;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / aspect.width;
    canvas.save();
    canvas.scale(s);
    painter(canvas, Size(aspect.width.toDouble(), aspect.height.toDouble()));
    canvas.restore();
  }

  @override
  bool shouldRepaint(_ScaledPainter old) => true;
}
