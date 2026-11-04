import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase/in_app_purchase.dart' as iap;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tanzaku/services/purchase_service.dart';

/// ストア（in_app_purchase）の代わり。購入の結果は [emit] で流す。
class FakeStore implements iap.InAppPurchase {
  final _stream = StreamController<List<iap.PurchaseDetails>>.broadcast();
  bool available = true;
  bool hasProduct = true;
  int restoreCalls = 0;
  final completed = <String>[];
  iap.PurchaseParam? lastBuy;

  void emit(List<iap.PurchaseDetails> p) => _stream.add(p);

  static iap.PurchaseDetails details(String id, iap.PurchaseStatus status) =>
      iap.PurchaseDetails(
        productID: id,
        verificationData: iap.PurchaseVerificationData(
          localVerificationData: '',
          serverVerificationData: '',
          source: 'test',
        ),
        transactionDate: '0',
        status: status,
      )..pendingCompletePurchase = true;

  @override
  Stream<List<iap.PurchaseDetails>> get purchaseStream => _stream.stream;

  @override
  Future<bool> isAvailable() async => available;

  @override
  Future<iap.ProductDetailsResponse> queryProductDetails(
    Set<String> ids,
  ) async => iap.ProductDetailsResponse(
    productDetails: [
      if (hasProduct)
        iap.ProductDetails(
          id: suzuriProductId,
          title: 'すずり',
          description: '',
          price: '¥730',
          rawPrice: 730,
          currencyCode: 'JPY',
        ),
    ],
    notFoundIDs: hasProduct ? const [] : [suzuriProductId],
  );

  @override
  Future<bool> buyNonConsumable({
    required iap.PurchaseParam purchaseParam,
  }) async {
    lastBuy = purchaseParam;
    return true;
  }

  @override
  Future<void> completePurchase(iap.PurchaseDetails purchase) async =>
      completed.add(purchase.productID);

  @override
  Future<void> restorePurchases({String? applicationUserName}) async =>
      restoreCalls++;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<(StorePurchaseService, FakeStore, SharedPreferences)> _service({
  Map<String, Object> prefs = const {},
}) async {
  SharedPreferences.setMockInitialValues(prefs);
  final p = await SharedPreferences.getInstance();
  final store = FakeStore();
  return (StorePurchaseService(p, store: store), store, p);
}

void main() {
  test('ストアの価格を出し、買うとすずりが使えて端末に残る', () async {
    final (s, store, prefs) = await _service();
    await s.init();
    expect(s.priceLabel, '¥730');
    expect(s.hasSuzuri, isFalse);
    await s.buy();
    expect(store.lastBuy!.productDetails.id, suzuriProductId);
    expect(s.status, PurchaseStatus.pending);
    store.emit([
      FakeStore.details(suzuriProductId, iap.PurchaseStatus.purchased),
    ]);
    await pumpEventQueue();
    expect(s.hasSuzuri, isTrue);
    expect(s.status, PurchaseStatus.purchased);
    expect(store.completed, [suzuriProductId]);
    // 次に起動したときも使える（通信なしでも）
    expect(
      StorePurchaseService(
        prefs,
        store: FakeStore()..available = false,
      ).hasSuzuri,
      isTrue,
    );
  });

  test('失敗・キャンセルではすずりにならない', () async {
    final (s, store, _) = await _service();
    await s.init();
    await s.buy();
    store.emit([
      FakeStore.details(suzuriProductId, iap.PurchaseStatus.canceled),
    ]);
    await pumpEventQueue();
    expect(s.hasSuzuri, isFalse);
    expect(s.status, PurchaseStatus.idle);
    store.emit([FakeStore.details(suzuriProductId, iap.PurchaseStatus.error)]);
    await pumpEventQueue();
    expect(s.hasSuzuri, isFalse);
    expect(s.status, PurchaseStatus.failed);
  });

  test('復元：記録があれば使える、なければ6秒後に「見つからない」', () {
    fakeAsync((async) {
      late StorePurchaseService s;
      late FakeStore store;
      _service().then((r) {
        s = r.$1;
        store = r.$2;
      });
      async.flushMicrotasks();
      s.init();
      async.flushMicrotasks();
      s.restore();
      async.flushMicrotasks();
      expect(s.status, PurchaseStatus.pending);
      async.elapse(const Duration(seconds: 7));
      expect(s.status, PurchaseStatus.nothingToRestore);

      s.restore();
      async.flushMicrotasks();
      store.emit([
        FakeStore.details(suzuriProductId, iap.PurchaseStatus.restored),
      ]);
      async.flushMicrotasks();
      async.elapse(const Duration(seconds: 7));
      expect(s.hasSuzuri, isTrue);
      expect(s.status, PurchaseStatus.restored);
    });
  });

  test('ストアにつながらない、商品が見つからないときは案内する', () async {
    final (s, store, _) = await _service();
    store.available = false;
    await s.init();
    await s.buy();
    expect(s.status, PurchaseStatus.unavailable);
    expect(s.priceLabel, suzuriFallbackPrice);

    final (s2, store2, _) = await _service();
    store2.hasProduct = false;
    await s2.init();
    await s2.buy();
    expect(s2.status, PurchaseStatus.unavailable);
    expect(store2.lastBuy, isNull);
  });

  test('ほかの商品の購入も完了させる（Android の自動返金を防ぐ）', () async {
    final (s, store, _) = await _service();
    await s.init();
    store.emit([FakeStore.details('other', iap.PurchaseStatus.purchased)]);
    await pumpEventQueue();
    expect(store.completed, ['other']);
    expect(s.hasSuzuri, isFalse);
  });

  test('買ってあれば、もう買わない', () async {
    final (s, store, _) = await _service(prefs: {'tanzaku.suzuri.v1': true});
    await s.init();
    expect(s.hasSuzuri, isTrue);
    await s.buy();
    expect(store.lastBuy, isNull);
  });
}
