import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'data/database.dart';
import 'data/repository.dart';
import 'services/review.dart';
import 'services/share.dart';
import 'services/widget_sync.dart';
import 'state/providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final settings = await SharedPrefsSettingsStore.open();
  final db = AppDatabase.open();
  await HomeWidgetSync.init();
  runApp(
    ProviderScope(
      overrides: [
        settingsStoreProvider.overrideWithValue(settings),
        repositoryProvider.overrideWithValue(DriftDarumaRepository(db)),
        widgetSyncProvider.overrideWithValue(const HomeWidgetSync()),
        shareProvider.overrideWithValue(const SharePlusService()),
        // App Store の ID は iOS 版を出したら入れる。
        reviewProvider.overrideWithValue(const InAppReviewService()),
      ],
      child: const NanakorobiApp(),
    ),
  );
}
