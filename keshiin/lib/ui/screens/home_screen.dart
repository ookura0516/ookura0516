import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/app_state.dart';
import '../theme.dart';
import 'album_screen.dart';
import 'settings_screen.dart';
import 'sheet_screen.dart';

/// 下のタブ：シート／アルバム／設定。
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.animate = true});

  final bool animate;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tab = 0;
  StreamSubscription<Uri?>? _sub;

  @override
  void initState() {
    super.initState();
    final app = context.read<AppState>();
    // ホーム画面のウィジェットから開かれたら、写真の選択を直接開く。
    app.services.widgets.initialLaunch().then(_onLaunch);
    _sub = app.services.widgets.launches.listen(_onLaunch, onError: (_) {});
    WidgetsBinding.instance.addPostFrameCallback((_) => _firstNotice());
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  void _onLaunch(Uri? uri) {
    if (!mounted || uri == null || uri.host != 'create') return;
    setState(() => _tab = 0);
    openCreate(context, target: context.read<AppState>().today);
  }

  Future<void> _firstNotice() async {
    final app = context.read<AppState>();
    if (app.settings.noticeSeen || !mounted) return;
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('ケシインへようこそ'),
        content: const Text(
          '1日1枚の写真が、切手と消印になります。月末にはシートが完成します。\n\n'
          '$kNotPostageNotice',
        ),
        actions: [
          FilledButton(
            key: const Key('notice-ok'),
            onPressed: () => Navigator.pop(ctx),
            child: const Text('はじめる'),
          ),
        ],
      ),
    );
    await app.settings.setNoticeSeen();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _tab,
        children: [
          SheetScreen(animate: widget.animate),
          const AlbumScreen(),
          const SettingsScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: const [
          NavigationDestination(
            key: Key('tab-sheet'),
            icon: Icon(Icons.grid_view),
            label: 'シート',
          ),
          NavigationDestination(
            key: Key('tab-album'),
            icon: Icon(Icons.photo_album_outlined),
            label: 'アルバム',
          ),
          NavigationDestination(
            key: Key('tab-settings'),
            icon: Icon(Icons.settings_outlined),
            label: '設定',
          ),
        ],
      ),
    );
  }
}
