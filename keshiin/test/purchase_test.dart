import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:keshiin/main.dart' show usesStorePurchases;
import 'package:keshiin/monetize/purchase_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
            id: kinenProductId,
            title: '記念',
            description: '',
            price: '¥730',
            rawPrice: 730,
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

void main() {
  late FakeInAppPurchase store;
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    store = FakeInAppPurchase();
  });

  test('テスト（デバッグ）では仮の購入、リリースではストアの購入を使う', () {
    expect(usesStorePurchases, isFalse);
  });

  test('購入すると「記念」が有効になり、端末に残る', () async {
    final p = StorePurchaseService(prefs, iap: store);
    await p.init();
    expect(p.priceLabel, '¥730');
    await p.buy();
    expect(store.lastBuy!.productDetails.id, kinenProductId);
    expect(p.status, KinenStatus.pending);

    store.emit([
      FakeInAppPurchase.details(kinenProductId, PurchaseStatus.purchased),
    ]);
    await pumpEventQueue();
    expect(p.hasKinen, isTrue);
    for (final f in Premium.values) {
      expect(p.unlocked(f), isTrue);
    }
    expect(store.completed, [kinenProductId]);

    store.available = false;
    expect(StorePurchaseService(prefs, iap: store).hasKinen, isTrue);
  });

  test('失敗・キャンセルでは有効にならない', () async {
    final p = StorePurchaseService(prefs, iap: store);
    await p.init();
    store.emit([
      FakeInAppPurchase.details(kinenProductId, PurchaseStatus.error),
    ]);
    await pumpEventQueue();
    expect(p.status, KinenStatus.failed);
    store.emit([
      FakeInAppPurchase.details(kinenProductId, PurchaseStatus.canceled),
    ]);
    await pumpEventQueue();
    expect(p.status, KinenStatus.idle);
    expect(p.hasKinen, isFalse);
  });

  test('復元：記録があれば有効、なければ6秒後に「見つからない」', () {
    fakeAsync((async) {
      final p = StorePurchaseService(prefs, iap: store);
      p.init();
      async.flushMicrotasks();
      p.restore();
      async.flushMicrotasks();
      expect(store.restoreCalls, 1);
      async.elapse(const Duration(seconds: 7));
      expect(p.status, KinenStatus.nothingToRestore);

      p.restore();
      async.flushMicrotasks();
      store.emit([
        FakeInAppPurchase.details(kinenProductId, PurchaseStatus.restored),
      ]);
      async.flushMicrotasks();
      async.elapse(const Duration(seconds: 7));
      expect(p.status, KinenStatus.restored);
      expect(p.hasKinen, isTrue);
    });
  });

  test('ストアにつながらないときは案内する', () async {
    store.available = false;
    final p = StorePurchaseService(prefs, iap: store);
    await p.init();
    await p.buy();
    expect(p.status, KinenStatus.unavailable);
  });

  test('ほかの商品の購入も完了させる（Android の自動返金を防ぐ）', () async {
    final p = StorePurchaseService(prefs, iap: store);
    await p.init();
    store.emit([FakeInAppPurchase.details('other', PurchaseStatus.purchased)]);
    await pumpEventQueue();
    expect(store.completed, ['other']);
    expect(p.hasKinen, isFalse);
  });
}
