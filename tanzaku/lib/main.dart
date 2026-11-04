import 'dart:convert';

import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/kigo.dart';
import 'data/database.dart';
import 'data/repository.dart';
import 'services/platform_services.dart';
import 'services/purchase_service.dart';
import 'services/settings_store.dart';
import 'ui/app_controller.dart';
import 'ui/root_screen.dart';
import 'ui/screens/font_license_screen.dart';
import 'ui/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _registerFontLicenses();
  final prefs = await SharedPreferences.getInstance();
  final settings = SettingsStore(prefs);
  final repo = HaikuRepository(TanzakuDatabase(driftDatabase(name: 'tanzaku')));
  final dictionary = await loadDictionary(repo, settings, rootBundle);
  final yomi = await loadYomi(rootBundle);

  final controller = AppController(
    repo: repo,
    dictionary: dictionary,
    extraReadings: yomi,
    settings: settings,
    // 購入は仮の実装。ストアにつなぐときはここを差し替える。
    purchases: PlaceholderPurchaseService(prefs),
    share: PlatformShareSink(),
    notifications: LocalNotificationService(),
    widgets: HomeWidgetBridge(),
    review: InAppReviewPrompter(),
  );
  await controller.purchases.init();
  await controller.load();
  runApp(TanzakuApp(controller: controller));
}

/// 歳時記の JSON を、版が上がっていたらデータベースに入れ直し、データベースから読む。
Future<KigoDictionary> loadDictionary(
  HaikuRepository repo,
  SettingsStore settings,
  AssetBundle bundle,
) async {
  final raw = await bundle.loadString('assets/data/kigo.json');
  final data = jsonDecode(raw) as Map<String, Object?>;
  final version = data['version'] as int;
  if (settings.kigoVersion < version || await repo.kigoCount() == 0) {
    final fromAsset = KigoDictionary.fromJsonString(raw);
    await repo.seedKigo(fromAsset.entries);
    await settings.setKigoVersion(version);
  }
  return KigoDictionary(await repo.loadKigo());
}

Future<Map<String, String>> loadYomi(AssetBundle bundle) async {
  final raw = await bundle.loadString('assets/data/yomi.json');
  final data = jsonDecode(raw) as Map<String, Object?>;
  return (data['yomi'] as Map).cast<String, String>();
}

void _registerFontLicenses() {
  LicenseRegistry.addLicense(() async* {
    for (final (name, _, path) in bundledFonts) {
      yield LicenseEntryWithLineBreaks([
        name,
      ], await rootBundle.loadString(path));
    }
  });
}

class TanzakuApp extends StatelessWidget {
  const TanzakuApp({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: controller,
      child: Consumer<AppController>(
        builder: (context, app, _) => MaterialApp(
          title: 'タンザク',
          debugShowCheckedModeBanner: false,
          theme: TanzakuTheme.of(app.season),
          locale: const Locale('ja'),
          supportedLocales: const [Locale('ja')],
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          home: const RootScreen(),
        ),
      ),
    );
  }
}
