import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../../model/models.dart';
import '../../state/providers.dart';
import '../theme.dart';
import '../widgets/daruma_view.dart';

/// 初回説明：目を入れる → 毎日1筆 → 転んでも減らない。最後に作成へ直行。
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  static const _looks = [
    DarumaLook(color: DarumaColor.red, text: '合格', brushCount: 0, openedEyes: 1, seed: 11),
    DarumaLook(color: DarumaColor.red, text: '合格', brushCount: 12, openedEyes: 1, seed: 11),
    DarumaLook(color: DarumaColor.red, text: '合格', brushCount: 12, goldStripes: 3, openedEyes: 1, seed: 11),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    await ref.read(settingsProvider.notifier).markOnboardingDone();
    if (mounted) context.go('/new');
  }

  @override
  Widget build(BuildContext context) {
    final l = L10n.of(context);
    final pages = [
      (l.onboarding1Title, l.onboarding1Body),
      (l.onboarding2Title, l.onboarding2Body),
      (l.onboarding3Title, l.onboarding3Body),
    ];
    final last = _page == pages.length - 1;
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
                  final (title, body) = pages[i];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Column(
                      children: [
                        const Spacer(),
                        Expanded(
                          flex: 6,
                          child: DarumaView(_looks[i], key: ValueKey('onboarding-$i'), animate: false),
                        ),
                        const SizedBox(height: 28),
                        Text(
                          title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, height: 1.4),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          body,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 16, color: NanakorobiTheme.inkDim, height: 1.7),
                        ),
                        const Spacer(),
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
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: i == _page ? 22 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: i == _page ? NanakorobiTheme.red : NanakorobiTheme.line,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  key: const Key('onboarding-next'),
                  onPressed: last
                      ? _finish
                      : () => _controller.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOut,
                          ),
                  child: Text(last ? l.onboardingStart : l.onboardingNext),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
