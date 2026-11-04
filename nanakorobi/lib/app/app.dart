import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/generated/app_localizations.dart';
import '../state/app_deps.dart';
import '../state/daruma_actions.dart';
import '../state/providers.dart';
import '../ui/theme.dart';
import 'router.dart';

class NanakorobiApp extends ConsumerStatefulWidget {
  const NanakorobiApp({super.key});

  @override
  ConsumerState<NanakorobiApp> createState() => _NanakorobiAppState();
}

class _NanakorobiAppState extends ConsumerState<NanakorobiApp> with WidgetsBindingObserver {
  var _syncedOnce = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // 最初の読み込みが済んだら、ウィジェットと通知をそろえる。
    ref.listenManual(bundlesProvider, (prev, next) {
      if (!_syncedOnce && next.hasValue) {
        _syncedOnce = true;
        ref.read(darumaActionsProvider).syncOutside();
      }
    });
    // 日付が進んだとき、通知やウィジェットの設定が変わったときもそろえる。
    ref.listenManual(todayProvider, (prev, next) {
      if (prev != null && prev != next) ref.read(darumaActionsProvider).syncOutside();
    });
    ref.listenManual(
      settingsProvider.select((s) => (s.reminderEnabled, s.reminderMinuteOfDay, s.widgetStyle, s.widgetDarumaId)),
      (prev, next) {
        if (prev != null && prev != next) ref.read(darumaActionsProvider).syncOutside();
      },
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.read(todayProvider.notifier).refresh();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    final deps = ref.watch(appDepsProvider);
    final locale = deps.locale;
    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context).appName,
      debugShowCheckedModeBanner: false,
      theme: NanakorobiTheme.light(fontFamily: deps.uiFontFamily),
      routerConfig: router,
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}
