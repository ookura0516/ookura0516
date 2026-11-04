import 'dart:io';

import 'package:flutter/foundation.dart' show LicenseEntryWithLineBreaks, LicenseRegistry;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'data/database.dart';
import 'services/plus_service.dart';
import 'services/presets_service.dart';
import 'services/reminder_service.dart';
import 'services/review_service.dart';
import 'services/settings_store.dart';
import 'services/share_service.dart';
import 'services/widget_sync_service.dart';
import 'state/app_deps.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // 毛筆体 Yuji Syuku の SIL Open Font License を、設定 → ライセンスに出す。
  LicenseRegistry.addLicense(() async* {
    yield LicenseEntryWithLineBreaks(
      const ['Yuji Syuku'],
      await rootBundle.loadString('assets/fonts/OFL.txt'),
    );
  });
  final prefs = await SharedPreferences.getInstance();
  final settingsStore = PrefsSettingsStore(prefs);
  final settings = await settingsStore.load();
  final support = await getApplicationSupportDirectory();
  final plus = StorePlusService(prefs);

  final deps = AppDeps(
    db: AppDatabase.open(),
    settingsStore: settingsStore,
    initialSettings: settings,
    metrics: PrefsMetricsStore(prefs),
    plus: plus,
    widgetSync: const HomeWidgetSyncService(),
    reminders: LocalReminderService(),
    share: const SharePlusService(),
    review: const InAppReviewService(),
    presets: PresetRepository(
      loadBundled: PresetRepository.fromAssets,
      fetcher: const HttpPresetFetcher(),
      cacheFile: File('${support.path}/exam_dates.cache.json'),
    ),
    backupFiles: const PlatformBackupFileService(),
    locale: _deviceLocale(),
  );

  runApp(
    ProviderScope(
      overrides: [appDepsProvider.overrideWithValue(deps)],
      child: const NanakorobiApp(),
    ),
  );
  // ストアの準備は、画面を出してから裏で進める。
  plus.init();
}

/// 端末の言語が英語なら en、それ以外は ja（英語版は後回し。ARB のキーだけ先に用意）。
Locale _deviceLocale() {
  final code = WidgetsBinding.instance.platformDispatcher.locale.languageCode;
  return code == 'en' ? const Locale('en') : const Locale('ja');
}
