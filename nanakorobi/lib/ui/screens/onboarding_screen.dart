import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../core/local_date.dart';
import '../../model/models.dart';
import '../../state/providers.dart';
import '../daruma/daruma_view.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../widgets/l10n_ext.dart';

/// 初回説明：目を入れる → 毎日1筆 → 転んでも減らない。最後に作成へ直行。
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _controller = PageController();
  var _page = 0;

  static DarumaLook _look({required EyeState eyes, int strokes = 0, bool fallen = false, int goldLines = 0}) =>
      DarumaLook(
        darumaId: 'onboarding',
        text: '合格',
        colorId: 0,
        seed: 7,
        strokes: strokes,
        goldLines: goldLines,
        firstEye: EyeSide.left,
        eyes: eyes,
        sizeRank: 1,
        fallen: fallen,
        status: DarumaStatus.active,
        openedOn: const LocalDate(2027, 1, 1),
      );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _start() async {
    await ref.read(settingsProvider.notifier).markOnboardingDone();
    if (mounted) context.go(Routes.newDaruma);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final pages = [
      (l.onboarding1Title, l.onboarding1Body, _look(eyes: EyeState.none)),
      (l.onboarding2Title, l.onboarding2Body, _look(eyes: EyeState.one, strokes: 9)),
      (l.onboarding3Title, l.onboarding3Body, _look(eyes: EyeState.one, strokes: 9, fallen: true, goldLines: 2)),
    ];
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: pages.length,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (context, i) {
                  final (title, body, look) = pages[i];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        DarumaView(look: look, width: 220, semanticsLabel: title),
                        const SizedBox(height: 28),
                        Text(title, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        Text(body, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyLarge),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < pages.length; i++)
                  Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: i == _page ? NanakorobiTheme.vermilion : NanakorobiTheme.paperDeep,
                    ),
                  ),
              ],
            ),
            BottomAction(
              child: _page < pages.length - 1
                  ? FilledButton(
                      key: const Key('onboarding-next'),
                      onPressed: () => _controller.nextPage(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeOut,
                      ),
                      child: Text(l.next),
                    )
                  : FilledButton(
                      key: const Key('onboarding-start'),
                      onPressed: _start,
                      child: Text(l.onboardingStart),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
