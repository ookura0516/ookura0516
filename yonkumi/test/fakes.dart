import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:ookura_daily/ookura_daily_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yonkumi/core/puzzle_bundle.dart';
import 'package:yonkumi/core/schedule.dart';
import 'package:yonkumi/game/daily_notice.dart';
import 'package:yonkumi/monetize/ad_service.dart';
import 'package:yonkumi/monetize/purchase_service.dart';
import 'package:yonkumi/ui/app_controller.dart';

/// 収録した本物のアセット。
PuzzleBundle realBundle() =>
    PuzzleBundle.parse(File('assets/puzzles.json').readAsStringSync(), kClock);

/// 日本時間の y/m/d h:00 の瞬間。
DateTime jst(int y, int m, int d, [int h = 12]) =>
    DateTime.utc(y, m, d, h).subtract(const Duration(hours: 9));

class FakeShareSheet implements ShareSheet {
  final texts = <String>[];
  final images = <Uint8List>[];
  final imageTexts = <String?>[];

  @override
  Future<void> shareText(String text, {Rect? origin}) async => texts.add(text);

  @override
  Future<void> sharePng(
    Uint8List png, {
    required String fileName,
    String? text,
    Rect? origin,
  }) async {
    images.add(png);
    imageTexts.add(text);
  }
}

class FakeWidgetSink implements DailyWidgetSink {
  final written = <DailyWidgetSnapshot>[];

  @override
  Future<void> write(DailyWidgetSnapshot snapshot) async =>
      written.add(snapshot);
}

class FakeNotifications implements NotificationService {
  FakeNotifications({this.allow = true});

  bool allow;
  List<ScheduledNotice> scheduled = [];

  @override
  Future<void> init() async {}

  @override
  Future<bool> requestPermission() async => allow;

  @override
  Future<void> replaceAll(List<ScheduledNotice> notices) async =>
      scheduled = notices;
}

/// テスト用のアプリ全体。[now] は差し替えられる。
class TestApp {
  TestApp._(
    this.controller,
    this.share,
    this.widgets,
    this.notices,
    this.clock,
  );

  final AppController controller;
  final FakeShareSheet share;
  final FakeWidgetSink widgets;
  final FakeNotifications notices;
  final MutableClock clock;

  static Future<TestApp> create({
    DateTime? now,
    Map<String, Object> prefs = const {},
    bool tutorialDone = true,
  }) async {
    SharedPreferences.setMockInitialValues({
      if (tutorialDone) 'yonkumi.tutorial_done': true,
      ...prefs,
    });
    final p = await SharedPreferences.getInstance();
    final share = FakeShareSheet();
    final widgets = FakeWidgetSink();
    final notices = FakeNotifications();
    final clock = MutableClock(now ?? jst(2026, 11, 20));
    final c = AppController(
      prefs: p,
      bundle: realBundle(),
      purchases: PlaceholderPurchaseService(p, allowLocalUnlock: true),
      ads: const PlaceholderAdService(),
      notifications: notices,
      widgets: widgets,
      share: share,
      now: clock.call,
    );
    return TestApp._(c, share, widgets, notices, clock);
  }
}

class MutableClock {
  MutableClock(this.value);

  DateTime value;

  DateTime call() => value;
}
