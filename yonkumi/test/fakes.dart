import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:in_app_purchase/in_app_purchase.dart';
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

/// ストア（in_app_purchase）の代わり。購入の結果は [emit] で流す。
class FakeInAppPurchase implements InAppPurchase {
  final _stream = StreamController<List<PurchaseDetails>>.broadcast();
  bool available = true;
  int restoreCalls = 0;
  final completed = <String>[];
  PurchaseParam? lastBuy;

  void emit(List<PurchaseDetails> p) => _stream.add(p);

  static PurchaseDetails details(String id, PurchaseStatus status) =>
      PurchaseDetails(
        productID: id,
        verificationData: PurchaseVerificationData(
          localVerificationData: '',
          serverVerificationData: '',
          source: 'test',
        ),
        transactionDate: '0',
        status: status,
      )..pendingCompletePurchase = true;

  @override
  Stream<List<PurchaseDetails>> get purchaseStream => _stream.stream;

  @override
  Future<bool> isAvailable() async => available;

  @override
  Future<ProductDetailsResponse> queryProductDetails(Set<String> ids) async =>
      ProductDetailsResponse(
        productDetails: [
          ProductDetails(
            id: kFullPackProductId,
            title: '全問パック',
            description: '',
            price: '¥610',
            rawPrice: 610,
            currencyCode: 'JPY',
          ),
        ],
        notFoundIDs: const [],
      );

  @override
  Future<bool> buyNonConsumable({required PurchaseParam purchaseParam}) async {
    lastBuy = purchaseParam;
    return true;
  }

  @override
  Future<void> completePurchase(PurchaseDetails purchase) async =>
      completed.add(purchase.productID);

  @override
  Future<void> restorePurchases({String? applicationUserName}) async =>
      restoreCalls++;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
