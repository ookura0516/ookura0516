import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app_state.dart';
import 'app/photo_io.dart';
import 'core/places.dart';
import 'data/db.dart';
import 'data/export_service.dart';
import 'data/image_store.dart';
import 'data/repository.dart';
import 'data/settings.dart';
import 'monetize/purchase_service.dart';
import 'platform/services.dart';
import 'ui/screens/home_screen.dart';
import 'ui/theme.dart';

/// 購入の実装の切り替え。ストアに商品「keshiin_kinen」を登録したら true にする。
/// false の間は端末内だけで解放する仮の実装（[ProvisionalPurchaseService]）を使う。
const bool usesStorePurchases = false;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final docs = await getApplicationDocumentsDirectory();
  final db = AppDatabase.open();
  final repo = StampRepository(db);
  final images = ImageStore(docs);
  final photoStore = FilePhotoStore(images);
  final places = MunicipalityIndex.parseCsv(
    await rootBundle.loadString('assets/data/municipalities.csv'),
  );
  final purchases = usesStorePurchases
      ? StorePurchaseService(prefs)
      : ProvisionalPurchaseService(prefs);
  final app = AppState(
    repo: repo,
    photoStore: photoStore,
    photoLoader: FilePhotoLoader(photoStore),
    settings: AppSettings(prefs),
    purchases: purchases,
    services: PlatformServices.system(),
    places: places,
    exporter: ExportService(repo, images),
  );
  runApp(KeshiinApp(app: app));
  purchases.init();
  app.refreshWidget();
}

class KeshiinApp extends StatelessWidget {
  const KeshiinApp({super.key, required this.app, this.animate = true});

  final AppState app;

  /// 今日のマスの点滅。テストでは止める。
  final bool animate;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: app,
      child: MaterialApp(
        title: 'ケシイン',
        debugShowCheckedModeBanner: false,
        theme: KeshiinTheme.light,
        locale: const Locale('ja', 'JP'),
        supportedLocales: const [Locale('ja', 'JP')],
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        home: HomeScreen(animate: animate),
      ),
    );
  }
}
