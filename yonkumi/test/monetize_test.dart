import 'package:fake_async/fake_async.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yonkumi/monetize/ad_unit_ids.dart';
import 'package:yonkumi/monetize/purchase_service.dart';
import 'package:yonkumi/ui/screens/settings_screen.dart';
import 'package:yonkumi/ui/theme.dart';

import 'fakes.dart';

void main() {
  group('StorePurchaseService', () {
    late FakeInAppPurchase store;
    late SharedPreferences prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      store = FakeInAppPurchase();
    });

    test('ストアの価格を出し、買うと全問パックが有効になって保存される', () async {
      final p = StorePurchaseService(prefs, store: store);
      expect(p.priceLabel, kFullPackPrice);
      await p.init();
      expect(p.priceLabel, '¥610');

      await p.buy();
      expect(store.lastBuy!.productDetails.id, kFullPackProductId);
      expect(p.status, PackStatus.pending);

      store.emit([
        FakeInAppPurchase.details(kFullPackProductId, PurchaseStatus.purchased),
      ]);
      await pumpEventQueue();
      expect(p.owned, isTrue);
      expect(p.status, PackStatus.purchased);
      expect(store.completed, [kFullPackProductId]);

      // 次の起動では、通信がなくても端末の記録で分かる
      store.available = false;
      expect(StorePurchaseService(prefs, store: store).owned, isTrue);
    });

    test('失敗・キャンセルでは有効にならない', () async {
      final p = StorePurchaseService(prefs, store: store);
      await p.init();
      store.emit([
        FakeInAppPurchase.details(kFullPackProductId, PurchaseStatus.error),
      ]);
      await pumpEventQueue();
      expect(p.status, PackStatus.failed);
      store.emit([
        FakeInAppPurchase.details(kFullPackProductId, PurchaseStatus.canceled),
      ]);
      await pumpEventQueue();
      expect(p.status, PackStatus.idle);
      expect(p.owned, isFalse);
    });

    test('復元：記録があれば有効、なければ6秒後に「見つからない」', () {
      fakeAsync((async) {
        final p = StorePurchaseService(prefs, store: store);
        p.init();
        async.flushMicrotasks();
        p.restore();
        async.flushMicrotasks();
        expect(store.restoreCalls, 1);
        expect(p.status, PackStatus.pending);
        async.elapse(const Duration(seconds: 7));
        expect(p.status, PackStatus.nothingToRestore);

        p.restore();
        async.flushMicrotasks();
        store.emit([
          FakeInAppPurchase.details(
            kFullPackProductId,
            PurchaseStatus.restored,
          ),
        ]);
        async.flushMicrotasks();
        async.elapse(const Duration(seconds: 7));
        expect(p.status, PackStatus.restored);
        expect(p.owned, isTrue);
      });
    });

    test('ストアにつながらないときは「購入できません」', () async {
      store.available = false;
      final p = StorePurchaseService(prefs, store: store);
      await p.init();
      await p.buy();
      expect(p.status, PackStatus.unavailable);
    });

    test('ほかの商品の購入も完了させる（Android の自動返金を防ぐ）', () async {
      final p = StorePurchaseService(prefs, store: store);
      await p.init();
      store.emit([
        FakeInAppPurchase.details('other', PurchaseStatus.purchased),
      ]);
      await pumpEventQueue();
      expect(store.completed, ['other']);
      expect(p.owned, isFalse);
    });
  });

  group('仮の購入', () {
    test('リリースビルドでは買えない', () async {
      SharedPreferences.setMockInitialValues({});
      final p = PlaceholderPurchaseService(
        await SharedPreferences.getInstance(),
        allowLocalUnlock: false,
      );
      await p.buy();
      expect(p.owned, isFalse);
      expect(p.status, PackStatus.unavailable);
    });
  });

  test('広告：デバッグは常にテスト広告、リリースは本番 ID を入れたときだけ', () {
    expect(AdUnitIds.decide(debug: true, placeholder: true), isTrue);
    expect(AdUnitIds.decide(debug: false, placeholder: true), isFalse);
    expect(AdUnitIds.decide(debug: false, placeholder: false), isTrue);
  });

  testWidgets('設定にプライバシーポリシーへの入口がある', (tester) async {
    final t = await TestApp.create();
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: t.controller,
        child: MaterialApp(
          theme: YonkumiTheme.light,
          home: const SettingsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const Key('privacy-policy')),
      200,
    );
    expect(find.text('プライバシーポリシー'), findsOneWidget);
    // 同意フォームが要らない地域では、広告のプライバシー設定は出さない
    expect(find.byKey(const Key('ad-privacy')), findsNothing);
  });
}
