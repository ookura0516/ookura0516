import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:keshiin/app/app_state.dart';
import 'package:keshiin/app/photo_io.dart';
import 'package:keshiin/core/places.dart';
import 'package:keshiin/core/widget_snapshot.dart';
import 'package:keshiin/data/db.dart';
import 'package:keshiin/data/repository.dart';
import 'package:keshiin/data/settings.dart';
import 'package:keshiin/main.dart';
import 'package:keshiin/monetize/purchase_service.dart';
import 'package:keshiin/platform/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

AppDatabase memoryDb() => AppDatabase(NativeDatabase.memory());

/// 市区町村の表（テストではファイルから直接読む）。
MunicipalityIndex loadMunicipalities() => MunicipalityIndex.parseCsv(
  File('assets/data/municipalities.csv').readAsStringSync(),
);

class FakePhotoStore implements PhotoStore {
  int _n = 0;
  final deleted = <String>[];
  int width = 1200;
  int height = 900;

  @override
  Future<({String path, int width, int height})> importPhoto(
    Uint8List bytes,
  ) async => (path: 'photos/fake${_n++}.jpg', width: width, height: height);

  @override
  Future<void> delete(String relative) async => deleted.add(relative);

  @override
  Future<int> totalBytes() async => 0;

  @override
  String absolute(String relative) => '/nonexistent/$relative';
}

class NullPhotoLoader implements PhotoLoader {
  @override
  Future<ui.Image?> load(String relative, {bool full = false}) async => null;
  @override
  void evict(String relative) {}
}

class FakePhotoSource implements PhotoSource {
  /// 次に選ばれる写真。空なら「キャンセル」。
  List<PickedPhoto> next = [
    PickedPhoto(Uint8List.fromList([1, 2, 3])),
  ];
  int calls = 0;

  @override
  Future<List<PickedPhoto>> pick({bool multiple = false}) async {
    calls++;
    return multiple ? next : next.take(1).toList();
  }
}

class FakeGeocoder implements OverseasGeocoder {
  String? answer;
  int calls = 0;
  @override
  Future<String?> placeName(double lat, double lng) async {
    calls++;
    return answer;
  }
}

class FakeSharer implements Sharer {
  final shared = <List<String>>[];
  @override
  Future<void> shareFiles(List<String> paths, {String? text}) async =>
      shared.add(paths);
}

class FakeWidgetBridge implements WidgetBridge {
  final published = <(WidgetSnapshot, WidgetSnapshot)>[];
  final controller = StreamController<Uri?>.broadcast();

  @override
  Future<void> publish(WidgetSnapshot today, WidgetSnapshot tomorrow) async =>
      published.add((today, tomorrow));

  @override
  Stream<Uri?> get launches => controller.stream;

  @override
  Future<Uri?> initialLaunch() async => null;
}

class FakeReminders implements ReminderScheduler {
  bool grant = true;
  int permissionAsks = 0;
  List<DateTime> scheduled = [];
  final controller = StreamController<Uri?>.broadcast();

  @override
  Future<bool> requestPermission() async {
    permissionAsks++;
    return grant;
  }

  @override
  Future<void> replaceAll(List<DateTime> times) async => scheduled = [...times];

  @override
  Stream<Uri?> get launches => controller.stream;

  @override
  Future<Uri?> initialLaunch() async => null;
}

class FakeReview implements ReviewPrompter {
  int calls = 0;
  @override
  Future<void> request() async => calls++;
}

class Harness {
  Harness._(
    this.app,
    this.photos,
    this.store,
    this.sharer,
    this.widgets,
    this.review,
    this.geocoder,
    this.reminders,
  );

  final AppState app;
  final FakePhotoSource photos;
  final FakePhotoStore store;
  final FakeSharer sharer;
  final FakeWidgetBridge widgets;
  final FakeReview review;
  final FakeGeocoder geocoder;
  final FakeReminders reminders;

  StampRepository get repo => app.repo;

  static MunicipalityIndex? _places;

  static Future<Harness> create({
    DateTime? now,
    Map<String, Object> prefs = const {'keshiin.noticeSeen': true},
    bool premium = false,
  }) async {
    SharedPreferences.setMockInitialValues({
      ...prefs,
      if (premium) 'keshiin.kinen.provisional': true,
    });
    final sp = await SharedPreferences.getInstance();
    final photos = FakePhotoSource();
    final store = FakePhotoStore();
    final sharer = FakeSharer();
    final widgets = FakeWidgetBridge();
    final review = FakeReview();
    final geocoder = FakeGeocoder();
    final reminders = FakeReminders();
    final t = now ?? DateTime(2026, 11, 4, 9, 30);
    final app = AppState(
      repo: StampRepository(memoryDb()),
      photoStore: store,
      photoLoader: NullPhotoLoader(),
      settings: AppSettings(sp),
      purchases: ProvisionalPurchaseService(sp),
      services: PlatformServices(
        photos: photos,
        geocoder: geocoder,
        sharer: sharer,
        widgets: widgets,
        review: review,
        reminders: reminders,
      ),
      places: _places ??= loadMunicipalities(),
      clock: () => t,
    );
    return Harness._(
      app,
      photos,
      store,
      sharer,
      widgets,
      review,
      geocoder,
      reminders,
    );
  }

  Future<void> close() => app.repo.db.close();
}

void phoneSize(WidgetTester tester) {
  tester.view.physicalSize = const Size(1170, 2532);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
}

Future<void> pumpApp(WidgetTester tester, Harness h) async {
  phoneSize(tester);
  await tester.pumpWidget(KeshiinApp(app: h.app, animate: false));
  await tester.pumpAndSettle();
}
