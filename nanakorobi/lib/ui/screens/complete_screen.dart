import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../core/entitlements.dart';
import '../../core/review_policy.dart';
import '../../model/models.dart';
import '../../state/daruma_actions.dart';
import '../../state/providers.dart';
import '../daruma/daruma_view.dart';
import '../theme.dart';
import '../widgets/eye_trace_pad.dart';
import '../widgets/l10n_ext.dart';
import 'share_screen.dart';

/// 両目：もう片方の目を入れる1筆、満願の演出、共有。
class CompleteScreen extends ConsumerStatefulWidget {
  const CompleteScreen({super.key, required this.id});

  final String id;

  @override
  ConsumerState<CompleteScreen> createState() => _CompleteScreenState();
}

class _CompleteScreenState extends ConsumerState<CompleteScreen> {
  var _done = false;
  var _busy = false;

  Future<void> _onTraced() async {
    if (_busy || _done) return;
    setState(() => _busy = true);
    final actions = ref.read(darumaActionsProvider);
    await actions.complete(widget.id);
    if (!mounted) return;
    setState(() {
      _done = true;
      _busy = false;
    });
    // 評価依頼は両目の直後に（365日3回まで）。
    await actions.maybeRequestReview(ReviewOccasion.completed);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final b = ref.watch(bundleProvider(widget.id));
    final look = ref.watch(lookProvider(widget.id));
    final hasPlus = ref.watch(hasPlusProvider);
    final t = Theme.of(context).textTheme;
    if (b == null || look == null) return Scaffold(appBar: AppBar(title: Text(l.completeTitle)));
    final other = look.firstEye == EyeSide.left ? EyeSide.right : EyeSide.left;
    final done = _done || look.eyes == EyeState.both;

    return PopScope(
      canPop: !done,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) context.go(Routes.home);
      },
      child: Scaffold(
        appBar: AppBar(title: Text(done ? l.completeDone : l.completeTitle), automaticallyImplyLeading: !done),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            Text(
              done ? l.completeDoneBody(context.formatDate(b.daruma.completedOn ?? ref.read(todayProvider))) : l.eyeInstructionSecond,
              textAlign: TextAlign.center,
              style: t.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Center(
              child: SizedBox(
                width: MediaQuery.sizeOf(context).width * 0.78,
                child: done
                    ? DarumaView(key: const Key('complete-view'), look: look, semanticsLabel: l.completeDone)
                    : EyeTracePad(
                        key: const Key('complete-pad'),
                        look: look.copyWith(fallen: false),
                        targetEye: other,
                        enabled: !_busy,
                        onTraced: _onTraced,
                        semanticsLabel: l.eyeInstructionSecond,
                      ),
              ),
            ),
            const SizedBox(height: 16),
            if (done) ...[
              OutlinedButton.icon(
                key: const Key('complete-share'),
                onPressed: () => context.push(Routes.shareFor(id: widget.id, occasion: ShareOccasion.complete.name)),
                icon: const Icon(Icons.ios_share),
                label: Text(l.completeShare),
              ),
              const SizedBox(height: 8),
              if (!hasPlus)
                TextButton(
                  key: const Key('complete-paywall'),
                  onPressed: () => context.push(Routes.paywallFrom(PaywallEntry.afterCompletion.name)),
                  child: Text(l.paywallEntryCompletion, style: const TextStyle(color: NanakorobiTheme.inkDim)),
                ),
              FilledButton(key: const Key('complete-home'), onPressed: () => context.go(Routes.home), child: Text(l.goHome)),
            ],
          ],
        ),
      ),
    );
  }
}
