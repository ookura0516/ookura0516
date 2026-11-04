import 'dart:ui' show Locale;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/database.dart';
import '../data/repository.dart';
import '../model/models.dart';
import '../services/plus_service.dart';
import '../services/presets_service.dart';
import '../services/reminder_service.dart';
import '../services/review_service.dart';
import '../services/settings_store.dart';
import '../services/share_service.dart';
import '../services/widget_sync_service.dart';

/// アプリの外側（DB・設定・ストア・ウィジェット・通知・共有）を1つにまとめたもの。
///
/// main で本物を、テストで仮実装を入れて [appDepsProvider] に渡す。
class AppDeps {
  AppDeps({
    required this.db,
    required this.settingsStore,
    required this.initialSettings,
    required this.metrics,
    required this.plus,
    required this.widgetSync,
    required this.reminders,
    required this.share,
    required this.review,
    required this.presets,
    required this.backupFiles,
    DateTime Function()? now,
    this.scheduleClockTimer = true,
    this.locale = const Locale('ja'),
  })  : now = now ?? DateTime.now,
        repo = DarumaRepository(db);

  final AppDatabase db;
  final DarumaRepository repo;
  final SettingsStore settingsStore;

  /// 起動時に読んだ設定。画面を出す前に読み終えておく。
  final AppSettings initialSettings;
  final MetricsStore metrics;
  final PlusService plus;
  final WidgetSyncService widgetSync;
  final ReminderService reminders;
  final ShareService share;
  final ReviewService review;
  final PresetRepository presets;
  final BackupFileService backupFiles;

  /// 現在時刻。テストでは固定できる。
  final DateTime Function() now;

  /// 0時の切り替えタイマーを動かすか。テストでは止める。
  final bool scheduleClockTimer;

  /// 通知文などを作る言語。
  final Locale locale;

  /// テストと、ストアのない環境で使う仮の組み合わせ。
  static AppDeps fake({
    AppDatabase? db,
    AppSettings initialSettings = const AppSettings(onboardingDone: true),
    bool hasPlus = false,
    DateTime Function()? now,
    String bundledPresets = '{"version":1,"updated_on":"2026-11-04","presets":[]}',
    Locale locale = const Locale('ja'),
  }) =>
      AppDeps(
        db: db ?? AppDatabase.memory(),
        settingsStore: MemorySettingsStore(initialSettings),
        initialSettings: initialSettings,
        metrics: MemoryMetricsStore(),
        plus: FakePlusService(hasPlus: hasPlus),
        widgetSync: RecordingWidgetSyncService(),
        reminders: FakeReminderService(),
        share: FakeShareService(),
        review: FakeReviewService(),
        presets: PresetRepository(loadBundled: () async => bundledPresets),
        backupFiles: FakeBackupFileService(),
        now: now,
        scheduleClockTimer: false,
        locale: locale,
      );
}

final appDepsProvider = Provider<AppDeps>(
  (ref) => throw UnimplementedError('ProviderScope の overrides で AppDeps を渡す'),
);
