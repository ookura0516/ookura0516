// ストア用のスクリーンショットを撮るための入口（Web で動かす）。手順は store/README.md。
//   ?v=eye      開眼（なぞる前）
//   ?v=home     ホーム（筆12・起き上がり2・共通テストまで）
//   ?v=fallen   転んでいるホーム
//   ?v=detail   記録
//   ?v=shelf    棚
//   ?v=new      作成
// 記録は端末に残さない（メモリ）。
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nanakorobi/core/local_date.dart';
import 'package:nanakorobi/data/repository.dart';
import 'package:nanakorobi/l10n/app_localizations.dart';
import 'package:nanakorobi/model/models.dart';
import 'package:nanakorobi/state/providers.dart';
import 'package:nanakorobi/ui/screens/detail_screen.dart';
import 'package:nanakorobi/ui/screens/eye_screen.dart';
import 'package:nanakorobi/ui/screens/home_screen.dart';
import 'package:nanakorobi/ui/screens/new_daruma_screen.dart';
import 'package:nanakorobi/ui/screens/presets_screen.dart';
import 'package:nanakorobi/ui/screens/shelf_screen.dart';
import 'package:nanakorobi/ui/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SemanticsBinding.instance.ensureSemantics();
  final v = Uri.base.queryParameters['v'] ?? 'home';
  final today = LocalDate(2026, 11, 4);
  final repo = MemoryDarumaRepository();
  final opened = today.addDays(-13);
  final d = await repo.create(
    NewDaruma(
      name: '合格',
      color: DarumaColor.red,
      eyeSide: EyeSide.left,
      deadline: LocalDate(2027, 1, 16),
      deadlineLabel: '共通テスト',
      dailyAction: '英単語20個',
    ),
    today: opened,
  );
  if (v != 'eye') {
    // 14日のうち12日記録。2回転んで、2回起き上がった。
    final skip = {4, 9};
    final last = v == 'fallen' ? 11 : 13;
    for (var i = 0; i <= last; i++) {
      if (skip.contains(i)) continue;
      await repo.addCheckin(darumaId: d.id, date: opened.addDays(i), memo: i == 13 ? '模試の復習' : null);
    }
    await repo.addRecovery(darumaId: d.id, fellAfter: opened.addDays(3), roseOn: opened.addDays(5));
    await repo.addRecovery(darumaId: d.id, fellAfter: opened.addDays(8), roseOn: opened.addDays(10));
  }
  if (v == 'shelf') {
    await repo.updateDaruma(d.copyWith(status: DarumaStatus.completed, completedOn: today.addDays(-1)));
    await repo.create(
      const NewDaruma(name: '必勝', color: DarumaColor.black, eyeSide: EyeSide.left, dailyAction: '走る'),
      today: today,
    );
  }
  final settings = MemorySettingsStore();
  await settings.setBool('onboarding_done', true);

  final home = switch (v) {
    'eye' => EyeScreen(darumaId: d.id, mode: EyeMode.open),
    'detail' => DetailScreen(darumaId: d.id),
    'shelf' => const ShelfScreen(),
    'new' => const NewDarumaScreen(),
    'presets' => const PresetsScreen(),
    _ => const HomeScreen(),
  };
  final router = GoRouter(routes: [
    GoRoute(path: '/', builder: (_, _) => home),
    GoRoute(path: '/presets', builder: (_, _) => const PresetsScreen()),
    GoRoute(path: '/shelf', builder: (_, _) => const ShelfScreen()),
    GoRoute(path: '/settings', builder: (_, _) => const HomeScreen()),
    GoRoute(path: '/new', builder: (_, _) => const NewDarumaScreen()),
    GoRoute(path: '/daruma/:id', builder: (_, s) => DetailScreen(darumaId: int.parse(s.pathParameters['id']!))),
    GoRoute(path: '/daruma/:id/complete', builder: (_, s) => EyeScreen(darumaId: int.parse(s.pathParameters['id']!), mode: EyeMode.complete)),
    GoRoute(path: '/new/eye/:id', builder: (_, s) => EyeScreen(darumaId: int.parse(s.pathParameters['id']!), mode: EyeMode.open)),
  ]);
  runApp(
    ProviderScope(
      overrides: [
        settingsStoreProvider.overrideWithValue(settings),
        repositoryProvider.overrideWithValue(repo),
        clockProvider.overrideWithValue(() => DateTime(2026, 11, 4, 9)),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        theme: NanakorobiTheme.light,
        localizationsDelegates: L10n.localizationsDelegates,
        supportedLocales: L10n.supportedLocales,
        locale: const Locale('ja'),
        routerConfig: router,
      ),
    ),
  );
}
