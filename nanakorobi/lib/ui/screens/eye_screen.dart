import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../../model/models.dart';
import '../../state/actions.dart';
import '../../state/providers.dart';
import '../share_flow.dart';
import '../theme.dart';
import '../widgets/eye_trace.dart';

enum EyeMode {
  /// 開眼（最初の目）。
  open,

  /// 両目（満願）。
  complete,
}

/// 指でなぞって目を入れる画面。開眼と満願で共用。
class EyeScreen extends ConsumerStatefulWidget {
  const EyeScreen({super.key, required this.darumaId, required this.mode});

  final int darumaId;
  final EyeMode mode;

  @override
  ConsumerState<EyeScreen> createState() => _EyeScreenState();
}

class _EyeScreenState extends ConsumerState<EyeScreen> {
  bool _done = false;
  bool _reviewAsked = false;

  Future<void> _onPainted(DarumaDetail detail) async {
    setState(() => _done = true);
    final actions = ref.read(actionsProvider);
    if (widget.mode == EyeMode.open) {
      await actions.markOpened();
    } else {
      await actions.complete(detail);
      _maybeAskReview();
    }
  }

  /// 両目の直後は評価を頼んでよい場面（設計書「収益」）。1回だけ。
  Future<void> _maybeAskReview() async {
    final settings = ref.read(settingsProvider);
    if (settings.reviewRequested || _reviewAsked) return;
    _reviewAsked = true;
    await Future<void>.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    await ref.read(settingsProvider.notifier).markReviewRequested();
    await ref.read(settingsProvider.notifier).increment(Counters.reviewRequests);
    await ref.read(reviewProvider).requestReview();
  }

  @override
  Widget build(BuildContext context) {
    final l = L10n.of(context);
    final today = ref.watch(todayProvider);
    final async = ref.watch(darumaDetailProvider(widget.darumaId));
    final isOpen = widget.mode == EyeMode.open;
    return Scaffold(
      appBar: AppBar(
        title: Text(isOpen ? l.eyeTitle : l.completeTitle),
        automaticallyImplyLeading: !isOpen,
      ),
      body: SafeArea(
        child: async.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('$e')),
          data: (detail) {
            if (detail == null) return Center(child: Text(l.homeNoDaruma));
            final d = detail.daruma;
            final side = isOpen ? d.eyeSide : (d.eyeSide == EyeSide.left ? EyeSide.right : EyeSide.left);
            // 開眼前は目なし、満願前は片目。入れ終えたら EyeTrace が1つ足して描く。
            final before = detail.lookOn(today).copyWith(
                  fallen: false,
                  openedEyes: isOpen ? 0 : 1,
                );
            final instruction = isOpen
                ? (side == EyeSide.left ? l.eyeInstructionLeft : l.eyeInstructionRight)
                : l.completeInstruction;
            return Column(
              children: [
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Text(
                      _done ? (isOpen ? l.eyeDone : l.completeDone) : instruction,
                      key: ValueKey(_done),
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, height: 1.5),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: EyeTrace(
                      key: const Key('eye-trace'),
                      look: before,
                      side: side,
                      done: _done,
                      onPainted: () => _onPainted(detail),
                    ),
                  ),
                ),
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 400),
                  opacity: _done ? 1 : 0,
                  child: IgnorePointer(
                    ignoring: !_done,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  key: const Key('eye-share'),
                                  onPressed: () => shareDaruma(
                                    context,
                                    ref,
                                    detail,
                                    moment: isOpen ? ShareMoment.open : ShareMoment.complete,
                                  ),
                                  icon: const Icon(Icons.ios_share),
                                  label: Text(isOpen ? l.eyeShare : l.completeShare),
                                ),
                              ),
                              if (isOpen) ...[
                                const SizedBox(width: 10),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    key: const Key('eye-widget'),
                                    onPressed: () {
                                      ref.read(settingsProvider.notifier).increment(Counters.widgetHints);
                                      showWidgetHint(context);
                                    },
                                    icon: const Icon(Icons.widgets_outlined),
                                    label: Text(l.eyeWidgetHint),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              key: const Key('eye-start'),
                              onPressed: () => context.go(isOpen ? '/' : '/shelf'),
                              child: Text(isOpen ? l.eyeStart : l.toShelf),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (!_done)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 24),
                    child: Icon(Icons.touch_app_outlined, color: NanakorobiTheme.inkDim),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
