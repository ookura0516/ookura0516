import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../state/providers.dart';
import '../ui/screens/complete_screen.dart';
import '../ui/screens/daruma_detail_screen.dart';
import '../ui/screens/eye_opening_screen.dart';
import '../ui/screens/home_screen.dart';
import '../ui/screens/new_daruma_screen.dart';
import '../ui/screens/onboarding_screen.dart';
import '../ui/screens/paywall_screen.dart';
import '../ui/screens/presets_screen.dart';
import '../ui/screens/settings_screen.dart';
import '../ui/screens/share_screen.dart';
import '../ui/screens/shelf_screen.dart';

/// 画面構成（設計書「画面構成（go_router）」）。
class Routes {
  const Routes._();

  static const onboarding = '/onboarding';
  static const home = '/';
  static const newDaruma = '/new';
  static const eye = '/new/eye';
  static const shelf = '/shelf';
  static const share = '/share';
  static const presets = '/presets';
  static const settings = '/settings';
  static const paywall = '/paywall';

  static String daruma(String id) => '/daruma/$id';
  static String complete(String id) => '/daruma/$id/complete';

  static String shareFor({String? id, required String occasion, int? year}) {
    final q = <String, String>{'occasion': occasion, 'id': ?id, 'year': ?year?.toString()};
    return Uri(path: share, queryParameters: q).toString();
  }

  static String paywallFrom(String entry) => '$paywall?entry=$entry';
}

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: Routes.home,
    redirect: (context, state) {
      final done = ref.read(settingsProvider).onboardingDone;
      final path = state.uri.path;
      if (!done && path != Routes.onboarding) return Routes.onboarding;
      if (done && path == Routes.onboarding) return Routes.home;
      return null;
    },
    routes: [
      GoRoute(path: Routes.onboarding, builder: (_, _) => const OnboardingScreen()),
      GoRoute(path: Routes.home, builder: (_, _) => const HomeScreen()),
      GoRoute(
        path: Routes.newDaruma,
        builder: (_, _) => const NewDarumaScreen(),
        routes: [
          GoRoute(path: 'eye', builder: (_, _) => const EyeOpeningScreen()),
        ],
      ),
      GoRoute(
        path: '/daruma/:id',
        builder: (_, state) => DarumaDetailScreen(id: state.pathParameters['id']!),
        routes: [
          GoRoute(
            path: 'complete',
            builder: (_, state) => CompleteScreen(id: state.pathParameters['id']!),
          ),
        ],
      ),
      GoRoute(path: Routes.shelf, builder: (_, _) => const ShelfScreen()),
      GoRoute(
        path: Routes.share,
        builder: (_, state) => ShareScreen(
          darumaId: state.uri.queryParameters['id'],
          occasion: ShareOccasion.parse(state.uri.queryParameters['occasion']),
          year: int.tryParse(state.uri.queryParameters['year'] ?? ''),
        ),
      ),
      GoRoute(path: Routes.presets, builder: (_, _) => const PresetsScreen()),
      GoRoute(path: Routes.settings, builder: (_, _) => const SettingsScreen()),
      GoRoute(
        path: Routes.paywall,
        builder: (_, state) => PaywallScreen(entry: state.uri.queryParameters['entry']),
      ),
    ],
  );
});
