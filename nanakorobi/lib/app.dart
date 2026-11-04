import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'l10n/app_localizations.dart';
import 'state/actions.dart';
import 'state/providers.dart';
import 'ui/screens/detail_screen.dart';
import 'ui/screens/eye_screen.dart';
import 'ui/screens/home_screen.dart';
import 'ui/screens/new_daruma_screen.dart';
import 'ui/screens/onboarding_screen.dart';
import 'ui/screens/presets_screen.dart';
import 'ui/screens/settings_screen.dart';
import 'ui/screens/shelf_screen.dart';
import 'ui/theme.dart';

/// 画面構成（設計書「画面構成（go_router）」の最小版）。
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final onboarded = ref.read(settingsProvider).onboardingDone;
      if (!onboarded && state.matchedLocation == '/') return '/onboarding';
      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (_, _) => const HomeScreen()),
      GoRoute(path: '/onboarding', builder: (_, _) => const OnboardingScreen()),
      GoRoute(
        path: '/new',
        builder: (_, state) => NewDarumaScreen(
          parentId: int.tryParse(state.uri.queryParameters['parent'] ?? ''),
          sizeRank: int.tryParse(state.uri.queryParameters['size'] ?? ''),
          presetName: state.uri.queryParameters['name'],
        ),
      ),
      GoRoute(
        path: '/new/eye/:id',
        builder: (_, state) => EyeScreen(
          darumaId: int.parse(state.pathParameters['id']!),
          mode: EyeMode.open,
        ),
      ),
      GoRoute(
        path: '/daruma/:id',
        builder: (_, state) => DetailScreen(darumaId: int.parse(state.pathParameters['id']!)),
      ),
      GoRoute(
        path: '/daruma/:id/complete',
        builder: (_, state) => EyeScreen(
          darumaId: int.parse(state.pathParameters['id']!),
          mode: EyeMode.complete,
        ),
      ),
      GoRoute(path: '/shelf', builder: (_, _) => const ShelfScreen()),
      GoRoute(path: '/presets', builder: (_, _) => const PresetsScreen()),
      GoRoute(path: '/settings', builder: (_, _) => const SettingsScreen()),
    ],
  );
});

class NanakorobiApp extends ConsumerStatefulWidget {
  const NanakorobiApp({super.key});

  @override
  ConsumerState<NanakorobiApp> createState() => _NanakorobiAppState();
}

class _NanakorobiAppState extends ConsumerState<NanakorobiApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // 起動のたびにウィジェットを今日の日付で書き直す（日付が変わっているかもしれない）。
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(actionsProvider).syncWidget();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.read(todayProvider.notifier).refresh();
      ref.read(actionsProvider).syncWidget();
    }
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      onGenerateTitle: (context) => L10n.of(context).appName,
      debugShowCheckedModeBanner: false,
      theme: NanakorobiTheme.light,
      localizationsDelegates: L10n.localizationsDelegates,
      supportedLocales: L10n.supportedLocales,
      routerConfig: router,
    );
  }
}
