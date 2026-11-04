import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app_controller.dart';
import 'screens/home_screen.dart';
import 'screens/kucho_screen.dart';
import 'screens/saijiki_screen.dart';
import 'screens/settings_screen.dart';

/// 下のタブ：ホーム・句帳・歳時記・設定。「詠む」はホームと句帳から開く。
class RootScreen extends StatefulWidget {
  const RootScreen({super.key});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  int _tab = 0;
  StreamSubscription<Uri?>? _clicks;

  @override
  void initState() {
    super.initState();
    final app = context.read<AppController>();
    // ウィジェットをタップしたら「詠む」を開く。
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final uri = await app.widgets.initialLaunch();
      if (mounted) _openFromWidget(uri);
    });
    _clicks = app.widgets.clicks.listen(_openFromWidget, onError: (_) {});
  }

  void _openFromWidget(Uri? uri) {
    if (uri == null || uri.host != 'compose') return;
    final app = context.read<AppController>();
    Navigator.of(context).popUntil((r) => r.isFirst);
    openCompose(context, theme: app.todayTheme);
  }

  @override
  void dispose() {
    _clicks?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _tab,
        children: const [
          HomeScreen(),
          KuchoScreen(),
          SaijikiScreen(),
          SettingsScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'ホーム',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book),
            label: '句帳',
          ),
          NavigationDestination(
            icon: Icon(Icons.local_florist_outlined),
            selectedIcon: Icon(Icons.local_florist),
            label: '歳時記',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: '設定',
          ),
        ],
      ),
    );
  }
}
