import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'game/services.dart';
import 'monetize/ad_service.dart';
import 'monetize/ad_unit_ids.dart';
import 'monetize/purchase_service.dart';
import 'ui/app_controller.dart';
import 'ui/screens/title_screen.dart';
import 'ui/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final controller = AppController(
    store: SessionStore(prefs),
    purchases: StorePurchaseService(prefs),
    ads: AdUnitIds.enabled ? AdMobService() : const NoAdService(),
  );
  runApp(HisokagiApp(controller: controller));
  // ストアと広告の準備は、画面を出してから裏で進める。
  controller.initMonetization();
}

class HisokagiApp extends StatelessWidget {
  const HisokagiApp({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: controller,
      child: MaterialApp(
        title: 'ひそかぎ',
        debugShowCheckedModeBanner: false,
        theme: HisokagiTheme.dark,
        home: const TitleScreen(),
      ),
    );
  }
}
