import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../core/countdown.dart';
import '../../core/entitlements.dart';
import '../../core/local_date.dart';
import '../../core/rest_tickets.dart';
import '../../core/review_policy.dart';
import '../../core/strokes.dart';
import '../../core/validation.dart';
import '../../model/models.dart';
import '../../state/daruma_actions.dart';
import '../../state/providers.dart';
import '../daruma/daruma_view.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../widgets/l10n_ext.dart';
import 'share_screen.dart';

/// ホーム。現役のだるまを大きく。今日の一歩、筆の数、起き上がり回数、残り日数。
/// 1画面で完結させ、詳細や棚は見たいときだけ開く。
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _asked = <String>{};

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final active = ref.watch(activeDarumasProvider);
    final loaded = ref.watch(bundlesProvider).hasValue;
    final hasPlus = ref.watch(hasPlusProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l.appName),
        actions: [
          IconButton(
            key: const Key('to-shelf'),
            tooltip: l.shelfTooltip,
            icon: const Icon(Icons.inventory_2_outlined),
            onPressed: () => context.push(Routes.shelf),
          ),
          IconButton(
            key: const Key('to-settings'),
            tooltip: l.settingsTooltip,
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push(Routes.settings),
          ),
        ],
      ),
      body: !loaded
          ? const SizedBox.shrink()
          : active.isEmpty
              ? _Empty(onCreate: () => context.push(Routes.newDaruma))
              : _Pager(active: active, asked: _asked),
      floatingActionButton: active.isEmpty || !loaded
          ? null
          : FloatingActionButton.small(
              key: const Key('add-daruma'),
              tooltip: l.addDaruma,
              backgroundColor: NanakorobiTheme.card,
              foregroundColor: NanakorobiTheme.ink,
              onPressed: () {
                if (Entitlements.canAddActive(activeCount: active.length, hasPlus: hasPlus)) {
                  context.push(Routes.newDaruma);
                } else {
                  // 購入導線の1つ目：2体目を作ろうとしたとき。
                  context.push(Routes.paywallFrom(PaywallEntry.secondDaruma.name));
                }
              },
              child: const Icon(Icons.add),
            ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.onCreate});

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l.homeEmptyTitle, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(l.homeEmptyBody, textAlign: TextAlign.center),
            const SizedBox(height: 20),
            FilledButton(key: const Key('home-create'), onPressed: onCreate, child: Text(l.homeCreate)),
          ],
        ),
      ),
    );
  }
}

class _Pager extends StatelessWidget {
  const _Pager({required this.active, required this.asked});

  final List<DarumaBundle> active;
  final Set<String> asked;

  @override
  Widget build(BuildContext context) {
    if (active.length == 1) return _DarumaPage(id: active.single.id, asked: asked);
    return PageView(
      children: [for (final b in active) _DarumaPage(id: b.id, asked: asked)],
    );
  }
}

class _DarumaPage extends ConsumerStatefulWidget {
  const _DarumaPage({required this.id, required this.asked});

  final String id;
  final Set<String> asked;

  @override
  ConsumerState<_DarumaPage> createState() => _DarumaPageState();
}

class _DarumaPageState extends ConsumerState<_DarumaPage> {
  StrokeMilestone? _justReached;

  Future<void> _record() async {
    final l = context.l10n;
    final result = await ref.read(darumaActionsProvider).recordStep(widget.id);
    if (!mounted) return;
    if (result.rose) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.roseToast)));
    }
    if (result.milestone != null) {
      setState(() => _justReached = result.milestone);
      if (result.milestone == StrokeMilestone.day7) {
        // 評価依頼は7日目の節目と両目の直後だけ。
        await ref.read(darumaActionsProvider).maybeRequestReview(ReviewOccasion.milestone7);
      }
    }
  }

  Future<void> _undo() async {
    await ref.read(darumaActionsProvider).undoStep(widget.id);
    if (mounted) setState(() => _justReached = null);
  }

  Future<void> _memo(DarumaBundle b, LocalDate today) async {
    final l = context.l10n;
    final current = b.checkinOn(today)?.memo ?? '';
    final controller = TextEditingController(text: current);
    final text = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.fromLTRB(20, 8, 20, MediaQuery.viewInsetsOf(context).bottom + 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              key: const Key('memo-field'),
              controller: controller,
              autofocus: true,
              maxLength: Limits.memoMax,
              decoration: InputDecoration(hintText: l.memoHint),
            ),
            const SizedBox(height: 8),
            FilledButton(
              key: const Key('memo-save'),
              onPressed: () => Navigator.of(context).pop(controller.text),
              child: Text(l.save),
            ),
          ],
        ),
      ),
    );
    if (text != null) await ref.read(darumaActionsProvider).setMemo(widget.id, today, text);
  }

  Future<void> _rest(DarumaBundle b, LocalDate today) async {
    final l = context.l10n;
    final tomorrow = today.addDays(1);
    final existing = b.restDates.where((d) => d == tomorrow).isNotEmpty;
    if (existing) {
      await ref.read(darumaActionsProvider).cancelRest(widget.id, tomorrow);
      return;
    }
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l.restConfirmTitle),
        content: Text(l.restConfirmBody),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l.cancel)),
          FilledButton(key: const Key('rest-confirm'), onPressed: () => Navigator.pop(context, true), child: Text(l.ok)),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    final decision = await ref.read(darumaActionsProvider).declareRest(widget.id, tomorrow);
    if (!mounted) return;
    final message = switch (decision) {
      RestDecision.ok => l.restDeclared(context.formatShortDate(tomorrow)),
      RestDecision.tooLate => l.restTooLate,
      RestDecision.noTicketsLeft => l.restNoTickets,
      RestDecision.alreadyDeclared => l.restAlready,
      RestDecision.afterDeadline => l.restAfterDeadline,
    };
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _maybeAskDeadline(DarumaBundle b, DarumaLook look) {
    final d = b.daruma;
    if (look.daysLeft != 0 || d.askedAtDeadline || widget.asked.contains(d.id)) return;
    widget.asked.add(d.id);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final l = context.l10n;
      final yes = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l.deadlineAskTitle),
          content: Text(l.deadlineAskBody(d.deadlineName ?? '')),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l.deadlineAskNotYet)),
            FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(l.deadlineAskYes)),
          ],
        ),
      );
      await ref.read(darumaActionsProvider).markAskedAtDeadline(d.id);
      if (yes == true && mounted) context.push(Routes.complete(d.id));
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final b = ref.watch(bundleProvider(widget.id));
    final look = ref.watch(lookProvider(widget.id));
    final today = ref.watch(todayProvider);
    if (b == null || look == null) return const SizedBox.shrink();
    _maybeAskDeadline(b, look);

    final milestoneToday = look.recordedToday ? StrokeMilestone.reachedAt(look.strokes) : null;
    final reached = _justReached ?? milestoneToday;
    final tomorrow = today.addDays(1);
    final restTomorrow = b.restDates.contains(tomorrow);
    final ticketsLeft = RestTickets.remainingIn(restDates: b.restDates, year: tomorrow.year, month: tomorrow.month);
    final next = Countdown.upcoming(b.waypoints, today);
    final t = Theme.of(context).textTheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (look.fallen)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(color: NanakorobiTheme.paperDeep, borderRadius: BorderRadius.circular(12)),
              child: Text(l.fallenBanner, key: const Key('fallen-banner'), textAlign: TextAlign.center),
            ),
          GestureDetector(
            key: const Key('home-daruma'),
            onTap: () => context.push(Routes.daruma(widget.id)),
            child: Center(
              child: DarumaView(
                look: look,
                width: MediaQuery.sizeOf(context).width * 0.62,
                semanticsLabel:
                    '${l.darumaSemantics(look.text, look.strokes, look.riseCount)}${look.fallen ? l.darumaSemanticsFallen : ''}',
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              StatTile(label: l.strokesLabel, value: l.strokesCount(look.strokes)),
              StatTile(label: l.riseLabel, value: l.riseCount(look.riseCount)),
              if (look.daysLeft != null)
                StatTile(
                  label: b.daruma.deadlineName?.isNotEmpty == true ? b.daruma.deadlineName! : l.daysLeftLabel,
                  value: switch (look.daysLeft!) {
                    0 => l.daysLeftToday,
                    final n when n < 0 => l.daysLeftPassed(-n),
                    final n => l.daysLeft(n),
                  },
                  emphasis: true,
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            [
              l.sinceOpened(look.daysSinceOpened),
              if (look.streak > 0) l.streakSmall(look.streak),
              if (next.isNotEmpty) l.nextWaypoint(next.first.name, Countdown.daysLeft(next.first.date, today)),
            ].join('　'),
            textAlign: TextAlign.center,
            style: t.bodySmall?.copyWith(color: NanakorobiTheme.inkDim),
          ),
          const SizedBox(height: 16),
          if (reached != null)
            Card(
              key: const Key('milestone-card'),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    Text(l.milestoneTitle(reached.strokes), style: t.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    Text(switch (reached) {
                      StrokeMilestone.day7 => l.milestone7,
                      StrokeMilestone.day21 => l.milestone21,
                      StrokeMilestone.day50 => l.milestone50,
                      StrokeMilestone.day100 => l.milestone100,
                    }),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      key: const Key('milestone-share'),
                      onPressed: () => context.push(
                        Routes.shareFor(id: widget.id, occasion: ShareOccasion.milestone.name),
                      ),
                      icon: const Icon(Icons.ios_share),
                      label: Text(l.shareThis),
                    ),
                  ],
                ),
              ),
            ),
          if (!look.recordedToday)
            FilledButton(
              key: const Key('today-step'),
              style: FilledButton.styleFrom(minimumSize: const Size(0, 60)),
              onPressed: _record,
              child: Text(l.todayStep, style: const TextStyle(fontSize: 18)),
            )
          else ...[
            Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: NanakorobiTheme.card,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: NanakorobiTheme.paperDeep),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check, color: NanakorobiTheme.good),
                  const SizedBox(width: 8),
                  Text(l.todayStepDone, key: const Key('today-done')),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(key: const Key('today-memo'), onPressed: () => _memo(b, today), child: Text(l.todayStepMemo)),
                TextButton(key: const Key('today-undo'), onPressed: _undo, child: Text(l.todayStepUndo)),
              ],
            ),
          ],
          if (b.daruma.dailyAction != null)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                l.dailyActionHint(b.daruma.dailyAction!),
                textAlign: TextAlign.center,
                style: t.bodySmall?.copyWith(color: NanakorobiTheme.inkDim),
              ),
            ),
          const SizedBox(height: 10),
          TextButton(
            key: const Key('rest-tomorrow'),
            onPressed: () => _rest(b, today),
            child: Text(
              restTomorrow
                  ? '${l.restDeclared(context.formatShortDate(tomorrow))}　${l.restCancel}'
                  : '${l.restTomorrow}　${l.restTicketsLeft(ticketsLeft)}',
              style: const TextStyle(fontSize: 13, color: NanakorobiTheme.inkDim),
            ),
          ),
        ],
      ),
    );
  }
}
