import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ookura_daily/ookura_daily_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/puzzle_bundle.dart';
import 'core/schedule.dart';
import 'game/local_notifications.dart';
import 'monetize/ad_service.dart';
import 'monetize/purchase_service.dart';
import 'ui/app_controller.dart';
import 'ui/screens/home.dart';
import 'ui/theme.dart';

/// iOS の App Group（ウィジェットと記録を分け合う）。Xcode の設定と合わせる。
const String kAppGroupId = 'group.com.ookura.yonkumi';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final bundle = PuzzleBundle.parse(
    await rootBundle.loadString('assets/puzzles.json'),
    kClock,
  );
  final controller = AppController(
    prefs: prefs,
    bundle: bundle,
    // どちらも仮の実装。ID とストアの商品を作ったら差し替える（README）。
    purchases: PlaceholderPurchaseService(prefs),
    ads: const PlaceholderAdService(),
    notifications: LocalNotificationService(),
    widgets: const HomeWidgetSink(
      appGroupId: kAppGroupId,
      iOSName: 'YonkumiWidget',
      androidName: 'YonkumiWidgetProvider',
    ),
  );
  runApp(YonkumiApp(controller: controller));
  controller.start();
}

class YonkumiApp extends StatelessWidget {
  const YonkumiApp({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: controller,
      child: MaterialApp(
        title: 'ヨンクミ',
        debugShowCheckedModeBanner: false,
        theme: YonkumiTheme.light,
        home: const Home(),
      ),
    );
  }
}
