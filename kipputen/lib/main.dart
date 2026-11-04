import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/puzzle_picker.dart';
import 'core/solution_book.dart';
import 'daily/daily.dart';
import 'data/records.dart';
import 'monetize/ad_service.dart';
import 'monetize/ad_unit_ids.dart';
import 'monetize/purchase_service.dart';
import 'platform/adapters.dart';
import 'platform/local_reminders.dart';
import 'ui/app_controller.dart';
import 'ui/screens/home_shell.dart';
import 'ui/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // 画面は縦向きだけで作っている。
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  final prefs = await SharedPreferences.getInstance();
  final book = SolutionBook.fromJson(
    await rootBundle.loadString(SolutionBook.assetPath),
  );
  final anniversaries = AnniversaryTable.fromJson(
    await rootBundle.loadString(AnniversaryTable.assetPath),
  );
  final controller = AppController(
    book: book,
    picker: PuzzlePicker(book, anniversaries: anniversaries),
    records: Records(prefs),
    purchases: StorePurchaseService(prefs),
    ads: AdUnitIds.enabled ? AdMobService() : const NoAdService(),
    widgets: const WidgetExporter(HomeWidgetSink()),
    review: const InAppReviewService(),
    reminders: LocalReminderService(),
  );
  runApp(KipputenApp(controller: controller));
  // ストア・広告・ウィジェットの準備は、画面を出してから裏で進める。
  controller.initServices();
}

class KipputenApp extends StatelessWidget {
  const KipputenApp({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: controller,
      child: MaterialApp(
        title: 'キップテン',
        debugShowCheckedModeBanner: false,
        theme: KipTheme.light,
        home: const HomeShell(),
      ),
    );
  }
}
