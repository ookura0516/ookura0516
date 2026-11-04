import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_controller.dart';
import 'collection_screen.dart';
import 'play_screen.dart';
import 'settings_screen.dart';

/// 下のタブ：今日の切符・硬券図鑑・設定。
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> with WidgetsBindingObserver {
  int _tab = 0;
  Timer? _midnight;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _armMidnight();
  }

  /// JST の0時に今日の切符を切り替える（開いたままでも進む）。
  void _armMidnight() {
    _midnight?.cancel();
    final app = context.read<AppController>();
    final wait = app.clock.nextSwitch.difference(app.clock.nowUtc);
    _midnight = Timer(wait + const Duration(seconds: 1), () {
      if (!mounted) return;
      setState(() {});
      app.exportWidget();
      _armMidnight();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      setState(() {});
      _armMidnight();
    }
  }

  @override
  void dispose() {
    _midnight?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppController>();
    final p = app.todayPuzzle;
    return Scaffold(
      body: IndexedStack(
        index: _tab,
        children: [
          PlayScreen(
            key: ValueKey('daily-${p.day.key}'),
            number: p.number,
            daily: true,
            day: p.day,
            serial: p.serial,
            caption: p.anniversary ?? p.band.label,
          ),
          const CollectionScreen(),
          const SettingsScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: [
          NavigationDestination(
            icon: Icon(
              app.solvedToday()
                  ? Icons.confirmation_number
                  : Icons.confirmation_number_outlined,
            ),
            label: '今日の切符',
          ),
          const NavigationDestination(icon: Icon(Icons.grid_view), label: '図鑑'),
          const NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            label: '設定',
          ),
        ],
      ),
    );
  }
}
