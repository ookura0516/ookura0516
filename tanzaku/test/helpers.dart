import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tanzaku/core/kigo.dart';
import 'package:tanzaku/core/mora.dart';
import 'package:tanzaku/data/database.dart';
import 'package:tanzaku/data/repository.dart';
import 'package:tanzaku/services/platform_services.dart';
import 'package:tanzaku/services/purchase_service.dart';
import 'package:tanzaku/services/settings_store.dart';
import 'package:tanzaku/ui/app_controller.dart';

final String kigoJson = File('assets/data/kigo.json').readAsStringSync();
final KigoDictionary dictionary = KigoDictionary.fromJsonString(kigoJson);
final Map<String, String> yomi =
    ((jsonDecode(File('assets/data/yomi.json').readAsStringSync())
                as Map)['yomi']
            as Map)
        .cast<String, String>();
final MoraCounter moraCounter = MoraCounter({...yomi, ...dictionary.readings});

TanzakuDatabase memoryDb() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  return TanzakuDatabase(NativeDatabase.memory());
}

/// 日本時間 2026年11月4日 10時（立冬の3日前、秋）。
final DateTime fixedNow = DateTime.utc(2026, 11, 4, 1);

class FakeShareSink implements ShareSink {
  final shared = <String>[];
  final saved = <String>[];
  final files = <String, Uint8List>{};
  String? toPick;

  @override
  Future<void> shareImage(Uint8List png, String name, {String? text}) async =>
      shared.add(name);

  @override
  Future<void> saveImage(Uint8List png, String name) async => saved.add(name);

  @override
  Future<void> shareFile(Uint8List bytes, String name, String mimeType) async =>
      files[name] = bytes;

  @override
  Future<String?> pickJsonText() async => toPick;
}

class FakeNotifications implements NotificationService {
  bool allow = true;
  List<(DateTime, String, String)> scheduled = [];
  int minutes = -1;

  @override
  Future<bool> requestPermission() async => allow;

  @override
  Future<void> scheduleThemes(
    List<(DateTime, String, String)> items,
    int minutes,
  ) async {
    scheduled = items;
    this.minutes = minutes;
  }

  @override
  Future<void> cancelAll() async => scheduled = [];

  Uri? launch;
  final tapController = StreamController<Uri?>.broadcast();

  @override
  Future<Uri?> launchLink() async => launch;

  @override
  Stream<Uri?> get taps => tapController.stream;
}

class FakeWidgets implements HomeWidgetService {
  WidgetSnapshot? last;
  final clickController = StreamController<Uri?>.broadcast();

  @override
  Future<void> update(WidgetSnapshot s) async => last = s;

  @override
  Future<Uri?> initialLaunch() async => null;

  @override
  Stream<Uri?> get clicks => clickController.stream;
}

class FakeReview implements ReviewPrompter {
  int requests = 0;

  @override
  Future<void> request() async => requests++;
}

class TestApp {
  TestApp(
    this.controller,
    this.share,
    this.notifications,
    this.widgets,
    this.review,
  );
  final AppController controller;
  final FakeShareSink share;
  final FakeNotifications notifications;
  final FakeWidgets widgets;
  final FakeReview review;
}

Future<TestApp> makeApp({
  DateTime? now,
  Map<String, Object> prefs = const {},
}) async {
  SharedPreferences.setMockInitialValues(prefs);
  final p = await SharedPreferences.getInstance();
  final t = now ?? fixedNow;
  final repo = HaikuRepository(memoryDb(), clock: () => t);
  await repo.seedKigo(dictionary.entries);
  final share = FakeShareSink();
  final notifications = FakeNotifications();
  final widgets = FakeWidgets();
  final review = FakeReview();
  final c = AppController(
    repo: repo,
    dictionary: KigoDictionary(await repo.loadKigo()),
    extraReadings: yomi,
    settings: SettingsStore(p),
    purchases: PlaceholderPurchaseService(p),
    share: share,
    notifications: notifications,
    widgets: widgets,
    review: review,
    clock: () => t,
  );
  await c.load();
  return TestApp(c, share, notifications, widgets, review);
}
