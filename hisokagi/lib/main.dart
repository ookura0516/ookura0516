import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'game/services.dart';
import 'ui/app_controller.dart';
import 'ui/screens/title_screen.dart';
import 'ui/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final store = await SessionStore.open();
  runApp(HisokagiApp(controller: AppController(store: store)));
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
