import 'package:fake_async/fake_async.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hisokagi/core/room_code.dart';
import 'package:hisokagi/game/services.dart';
import 'package:hisokagi/game/session.dart';
import 'package:hisokagi/monetize/ad_service.dart';
import 'package:hisokagi/monetize/purchase_service.dart';
import 'package:hisokagi/scenario/model.dart';
import 'package:hisokagi/scenario/observatory.dart';
import 'package:hisokagi/ui/app_controller.dart';
import 'package:hisokagi/ui/screens/pass_screen.dart';
import 'package:hisokagi/ui/screens/play_screen.dart';
import 'package:hisokagi/ui/theme.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fakes.dart';

const code = RoomCode(scenario: 1, players: 2, seed: 77);

/// 有料シナリオの見本（収録はまだないので、テストの中だけで使う）。
class _PaidScenario extends ObservatoryScenario {
  const _PaidScenario();
  @override
  bool get free => false;
}

Future<(AppController, FakePurchaseService, FakeAdService)> _app({
  bool hasPass = false,
  RewardOutcome outcome = RewardOutcome.earned,
}) async {
  SharedPreferences.setMockInitialValues({});
  final purchases = FakePurchaseService(hasPass: hasPass);
  final ads = FakeAdService(outcome: outcome);
  final app = AppController(
    store: await SessionStore.open(),
    purchases: purchases,
    ads: ads,
  );
  return (app, purchases, ads);
}

void main() {
  group('ヒントと広告', () {
    test('ヒント1は広告なし、ヒント2と答えは広告を見て開く', () async {
      final (app, _, ads) = await _app();
      final s = app.start(code: code, mode: PlayMode.linked, roles: {Role.a});
      expect(await app.unlockHint(s, 1), HintUnlock.granted);
      expect(ads.rewardedShown, 0);
      expect(await app.unlockHint(s, 2), HintUnlock.granted);
      expect(await app.unlockHint(s, 3), HintUnlock.granted);
      expect(ads.rewardedShown, 2);
    });

    test('広告を途中で閉じたら開かない', () async {
      final (app, _, _) = await _app(outcome: RewardOutcome.skipped);
      final s = app.start(code: code, mode: PlayMode.linked, roles: {Role.a});
      expect(await app.unlockHint(s, 2), HintUnlock.skipped);
    });

    test('広告を出せない（通信がない等）ときは、遊びを止めないよう開く', () async {
      final (app, _, _) = await _app(outcome: RewardOutcome.unavailable);
      final s = app.start(code: code, mode: PlayMode.linked, roles: {Role.a});
      expect(await app.unlockHint(s, 2), HintUnlock.granted);
    });

    test('パスがあれば広告を出さない', () async {
      final (app, _, ads) = await _app(hasPass: true);
      final s = app.start(code: code, mode: PlayMode.linked, roles: {Role.a});
      expect(app.hintNeedsAd(s, 2), isFalse);
      expect(await app.unlockHint(s, 3), HintUnlock.granted);
      await app.afterClear();
      expect(ads.rewardedShown, 0);
      expect(ads.interstitialShown, 0);
    });

    test('全画面広告はクリア後だけ、パスがなければ出す', () async {
      final (app, _, ads) = await _app();
      await app.afterClear();
      expect(ads.interstitialShown, 1);
    });
  });

  group('有料シナリオ', () {
    test('部屋をつくるにはパスが要る。無料シナリオは誰でもつくれる', () async {
      final (app, purchases, _) = await _app();
      expect(app.canCreate(const ObservatoryScenario()), isTrue);
      expect(app.canCreate(const _PaidScenario()), isFalse);
      await purchases.buyPass();
      expect(app.canCreate(const _PaidScenario()), isTrue);
    });
  });

  group('StorePurchaseService', () {
    late FakeInAppPurchase store;
    late SharedPreferences prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      store = FakeInAppPurchase();
    });

    test('ストアの価格を表示し、購入するとパスが有効になって保存される', () async {
      final p = StorePurchaseService(prefs, iap: store);
      expect(p.priceLabel, passFallbackPrice);
      await p.init();
      expect(p.priceLabel, '¥610');

      await p.buyPass();
      expect(store.lastBuy!.productDetails.id, passProductId);
      expect(p.status, PassStatus.pending);

      store.emit([FakeInAppPurchase.details(passProductId, PurchaseStatus.purchased)]);
      await pumpEventQueue();
      expect(p.hasPass, isTrue);
      expect(p.status, PassStatus.purchased);
      expect(store.completed, [passProductId]);

      // 次の起動では、通信がなくても端末の記録でパスが分かる
      store.available = false;
      final next = StorePurchaseService(prefs, iap: store);
      expect(next.hasPass, isTrue);
    });

    test('失敗・キャンセルではパスにならない', () async {
      final p = StorePurchaseService(prefs, iap: store);
      await p.init();
      store.emit([FakeInAppPurchase.details(passProductId, PurchaseStatus.error)]);
      await pumpEventQueue();
      expect(p.status, PassStatus.failed);
      store.emit([FakeInAppPurchase.details(passProductId, PurchaseStatus.canceled)]);
      await pumpEventQueue();
      expect(p.status, PassStatus.idle);
      expect(p.hasPass, isFalse);
    });

    test('復元：記録があれば有効、なければ6秒後に「見つからない」', () {
      fakeAsync((async) {
        final p = StorePurchaseService(prefs, iap: store);
        p.init();
        async.flushMicrotasks();
        p.restore();
        async.flushMicrotasks();
        expect(store.restoreCalls, 1);
        expect(p.status, PassStatus.pending);
        async.elapse(const Duration(seconds: 7));
        expect(p.status, PassStatus.nothingToRestore);

        p.restore();
        async.flushMicrotasks();
        store.emit([FakeInAppPurchase.details(passProductId, PurchaseStatus.restored)]);
        async.flushMicrotasks();
        async.elapse(const Duration(seconds: 7));
        expect(p.status, PassStatus.restored);
        expect(p.hasPass, isTrue);
      });
    });

    test('ストアにつながらないときは案内する', () async {
      store.available = false;
      final p = StorePurchaseService(prefs, iap: store);
      await p.init();
      await p.buyPass();
      expect(p.status, PassStatus.unavailable);
    });

    test('ほかの商品の購入も完了させる（Android の自動返金を防ぐ）', () async {
      final p = StorePurchaseService(prefs, iap: store);
      await p.init();
      store.emit([FakeInAppPurchase.details('other', PurchaseStatus.purchased)]);
      await pumpEventQueue();
      expect(store.completed, ['other']);
      expect(p.hasPass, isFalse);
    });
  });

  group('画面', () {
    Widget wrap(AppController app, Widget child) => ChangeNotifierProvider.value(
          value: app,
          child: MaterialApp(theme: HisokagiTheme.dark, home: child),
        );

    testWidgets('パスの画面：価格を出し、買うと有効になる', (tester) async {
      final (app, purchases, _) = await _app();
      await tester.pumpWidget(wrap(app, const PassScreen()));
      await tester.pumpAndSettle();
      expect(find.text('買い切り　¥600'), findsOneWidget);
      // 有料シナリオがまだないので、その特典は書かない
      expect(find.textContaining('有料シナリオ'), findsNothing);

      await tester.tap(find.byKey(const Key('buy-pass')));
      await tester.pumpAndSettle();
      expect(purchases.buys, 1);
      expect(find.text('パスは有効です'), findsOneWidget);
      expect(find.byKey(const Key('buy-pass')), findsNothing);
      expect(find.textContaining('パスが有効になりました'), findsOneWidget);
    });

    testWidgets('パスの画面：復元して記録がなければ案内する', (tester) async {
      final (app, _, _) = await _app();
      await tester.pumpWidget(wrap(app, const PassScreen()));
      await tester.tap(find.byKey(const Key('restore-pass')));
      await tester.pumpAndSettle();
      expect(find.textContaining('購入の記録が見つかりませんでした'), findsOneWidget);
    });

    testWidgets('ヒント：広告を途中で閉じると開かず、パスへの案内が出る', (tester) async {
      tester.view.physicalSize = const Size(1170, 2532);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      final (app, _, ads) = await _app(outcome: RewardOutcome.skipped);
      final s = app.start(code: code, mode: PlayMode.linked, roles: {Role.a});
      await tester.pumpWidget(wrap(app, PlayScreen(session: s)));

      await tester.tap(find.byTooltip('ヒント'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('next-hint')));
      await tester.pumpAndSettle();
      expect(s.hintLevel(Role.a, 0), 1);
      expect(find.text('広告を見て ヒント2を開く'), findsOneWidget);
      expect(find.text('ひそかぎパスなら、広告なしで開きます'), findsOneWidget);

      await tester.tap(find.byKey(const Key('next-hint')));
      await tester.pumpAndSettle();
      expect(ads.rewardedShown, 1);
      expect(s.hintLevel(Role.a, 0), 1);
      expect(find.text('広告を最後まで見ると、ヒントが開きます。'), findsOneWidget);

      ads.outcome = RewardOutcome.earned;
      await tester.tap(find.byKey(const Key('next-hint')));
      await tester.pumpAndSettle();
      expect(s.hintLevel(Role.a, 0), 2);
    });
  });
}
