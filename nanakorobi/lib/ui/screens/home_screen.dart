import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/local_date.dart';
import '../../core/rules.dart';
import '../../l10n/app_localizations.dart';
import '../../model/models.dart';
import '../../state/actions.dart';
import '../../state/providers.dart';
import '../share_flow.dart';
import '../theme.dart';
import '../widgets/daruma_view.dart';

/// ホーム：現役のだるまを大きく。今日の一歩ボタン、筆の数、起き上がり回数、残り日数。
/// 開いてタップして閉じるまで画面遷移がない。
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _memo = TextEditingController();
  int? _memoForCheckin;
  int? _celebratedMilestone;
  bool _busy = false;

  @override
  void dispose() {
    _memo.dispose();
    super.dispose();
  }

  Future<void> _step(DarumaDetail detail) async {
    if (_busy) return;
    setState(() => _busy = true);
    final l = L10n.of(context);
    try {
      final r = await ref.read(actionsProvider).recordStep(detail);
      if (!mounted || r.alreadyDone) return;
      final messenger = ScaffoldMessenger.of(context);
      final msg = r.rose ? l.homeRose : l.homeStepRecorded;
      messenger.showSnackBar(SnackBar(content: Text(msg), duration: const Duration(seconds: 2)));
      if (r.milestone != null) {
        setState(() => _celebratedMilestone = r.milestone);
        if (r.milestone == Rules.browsMilestone) _maybeAskReview();
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// 7日目の節目の直後だけ評価を頼む（1回）。開眼直後には出さない。
  Future<void> _maybeAskReview() async {
    if (ref.read(settingsProvider).reviewRequested) return;
    await Future<void>.delayed(const Duration(seconds: 3));
    if (!mounted) return;
    await ref.read(settingsProvider.notifier).markReviewRequested();
    await ref.read(settingsProvider.notifier).increment(Counters.reviewRequests);
    await ref.read(reviewProvider).requestReview();
  }

  Future<void> _undo(DarumaDetail detail) async {
    await ref.read(actionsProvider).undoToday(detail);
    setState(() => _celebratedMilestone = null);
  }

  Future<void> _saveMemo(DarumaDetail detail) async {
    FocusScope.of(context).unfocus();
    await ref.read(actionsProvider).setTodayMemo(detail, _memo.text);
  }

  String _milestoneText(L10n l, int m) => switch (m) {
        Rules.browsMilestone => l.homeMilestone7,
        Rules.beardMilestone => l.homeMilestone21,
        Rules.goldTextMilestone => l.homeMilestone50,
        _ => l.homeMilestone100,
      };

  @override
  Widget build(BuildContext context) {
    final l = L10n.of(context);
    final today = ref.watch(todayProvider);
    final async = ref.watch(activeDarumaProvider);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(title: l.appName, darumaId: async.value?.daruma.id),
            Expanded(
              child: async.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('$e')),
                data: (detail) => detail == null ? _Empty(l: l) : _buildDaruma(context, l, detail, today),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDaruma(BuildContext context, L10n l, DarumaDetail detail, LocalDate today) {
    final d = detail.daruma;
    final look = detail.lookOn(today);
    final todayCheckin = detail.checkinOn(today);
    final done = todayCheckin != null;
    if (done && _memoForCheckin != todayCheckin.id) {
      _memoForCheckin = todayCheckin.id;
      _memo.text = todayCheckin.memo ?? '';
    }
    final daysLeft = detail.daysLeftOn(today);
    final label = d.deadlineLabel ?? l.homeDeadlineDefault;
    final deadlineText = daysLeft == null
        ? null
        : daysLeft > 0
            ? l.homeDaysLeft(label, daysLeft)
            : daysLeft == 0
                ? l.homeDaysLeftToday(label)
                : l.homeDaysLeftPassed(label, -daysLeft);
    final milestone = _celebratedMilestone;

    // だるまは画面の半分まで大きく。下の情報と操作は、小さい画面ではスクロールする。
    return LayoutBuilder(
      builder: (context, constraints) {
        final darumaHeight = (constraints.maxHeight * 0.52).clamp(220.0, 460.0);
        return SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: darumaHeight,
                child: GestureDetector(
                  key: const Key('home-daruma'),
                  onTap: () => context.push('/daruma/${d.id}'),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: DarumaView(look, key: ValueKey('home-${d.id}')),
                  ),
                ),
              ),
              if (deadlineText != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              deadlineText,
              key: const Key('home-deadline'),
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
        const SizedBox(height: 6),
        Text(
          '${l.homeDaysSince(Rules.daysSinceOpened(d.createdOn, today))} ・ '
          '${l.homeBrushes(detail.brushCount)} ・ ${l.homeRises(detail.riseCount)}',
          key: const Key('home-stats'),
          style: const TextStyle(color: NanakorobiTheme.inkDim, fontSize: 14),
        ),
        if (d.dailyAction != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(d.dailyAction!, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
          ),
        if (look.fallen && !done)
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
            child: Text(
              l.homeFallen,
              key: const Key('home-fallen'),
              textAlign: TextAlign.center,
              style: const TextStyle(color: NanakorobiTheme.redDeep, fontSize: 14),
            ),
          ),
        if (milestone != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
            child: Card(
              color: const Color(0xFFFFF4D6),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _milestoneText(l, milestone),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    TextButton.icon(
                      key: const Key('home-share-milestone'),
                      onPressed: () => shareDaruma(context, ref, detail, moment: ShareMoment.milestone),
                      icon: const Icon(Icons.ios_share, size: 18),
                      label: Text(l.homeShareMilestone),
                    ),
                  ],
                ),
              ),
            ),
          ),
              Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
          child: done
              ? Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.check_circle, color: NanakorobiTheme.red),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            l.homeDoneToday,
                            key: const Key('home-done'),
                            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                          ),
                        ),
                        TextButton(
                          key: const Key('home-undo'),
                          onPressed: () => _undo(detail),
                          child: Text(l.homeUndo),
                        ),
                      ],
                    ),
                    TextField(
                      key: const Key('home-memo'),
                      controller: _memo,
                      maxLength: Rules.memoMaxLength,
                      decoration: InputDecoration(
                        hintText: l.homeMemoHint,
                        isDense: true,
                        counterText: '',
                        suffixIcon: TextButton(
                          onPressed: () => _saveMemo(detail),
                          child: Text(l.homeMemoSave),
                        ),
                      ),
                      onSubmitted: (_) => _saveMemo(detail),
                    ),
                  ],
                )
              : SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    key: const Key('home-step'),
                    onPressed: _busy ? null : () => _step(detail),
                    icon: const Icon(Icons.brush),
                    label: Text(l.homeToday),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.title, this.darumaId});

  final String title;
  final int? darumaId;

  @override
  Widget build(BuildContext context) {
    final l = L10n.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 8, 0),
      child: Row(
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1)),
          const Spacer(),
          if (darumaId != null)
            IconButton(
              key: const Key('home-records'),
              tooltip: l.homeRecords,
              onPressed: () => context.push('/daruma/$darumaId'),
              icon: const Icon(Icons.calendar_month_outlined),
            ),
          IconButton(
            key: const Key('home-shelf'),
            tooltip: l.homeShelf,
            onPressed: () => context.push('/shelf'),
            icon: const Icon(Icons.shelves),
          ),
          IconButton(
            key: const Key('home-settings'),
            tooltip: l.homeSettings,
            onPressed: () => context.push('/settings'),
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.l});

  final L10n l;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        children: [
          const Spacer(),
          const Expanded(
            flex: 5,
            child: DarumaView(
              DarumaLook(color: DarumaColor.red, text: '合格', openedEyes: 0, seed: 5),
              animate: false,
            ),
          ),
          const SizedBox(height: 20),
          Text(l.tagline, textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              key: const Key('home-create'),
              onPressed: () => context.push('/new'),
              child: Text(l.homeCreate),
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
