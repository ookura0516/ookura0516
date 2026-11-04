import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase/in_app_purchase.dart' as iap;
import 'package:kipputen/monetize/products.dart';
import 'package:kipputen/monetize/purchase_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// ストア（in_app_purchase）の代わり。購入の結果は [emit] で流す。
class FakeStore implements iap.InAppPurchase {
  final _stream = StreamController<List<iap.PurchaseDetails>>.broadcast();
  bool available = true;
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
      for (final p in Product.values)
        if (ids.contains(p.storeId))
          iap.ProductDetails(
            id: p.storeId,
            title: p.title,
            description: '',
            price: p == Product.removeAds ? '¥500' : '¥320',
            rawPrice: 0,
            currencyCode: 'JPY',
          ),
    ],
    notFoundIDs: const [],
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

Future<(StorePurchaseService, FakeStore, SharedPreferences)> _make({
  Map<String, Object> prefs = const {},
}) async {
  SharedPreferences.setMockInitialValues(prefs);
  final p = await SharedPreferences.getInstance();
  final store = FakeStore();
  final s = StorePurchaseService(p, store: store);
  await s.init();
  return (s, store, p);
}

Future<void> _flush() => Future<void>.delayed(Duration.zero);

void main() {
  test('商品 ID は2つとも別', () {
    expect(Product.values.map((p) => p.storeId).toSet().length, 2);
    expect(Product.byStoreId('kipputen_remove_ads'), Product.removeAds);
    expect(Product.byStoreId('other'), isNull);
  });

  test('価格はストアの表示を使う', () async {
    final (s, _, _) = await _make();
    expect(s.priceOf(Product.removeAds), '¥500');
    expect(s.isPlaceholder, isFalse);
  });

  test('購入：ストアに頼み、購入済みが流れてきたら持ち物にして完了を伝える', () async {
    final (s, store, prefs) = await _make();
    await s.buy(Product.designPack);
    expect(store.lastBuy!.productDetails.id, 'kipputen_design_pack');
    expect(s.status, PurchaseStatus.pending);

    store.emit([
      FakeStore.details('kipputen_design_pack', iap.PurchaseStatus.purchased),
    ]);
    await _flush();
    expect(s.owns(Product.designPack), isTrue);
    expect(s.owns(Product.removeAds), isFalse);
    expect(s.status, PurchaseStatus.purchased);
    expect(store.completed, ['kipputen_design_pack']);
    expect(prefs.getBool('kipputen.owned.designPack'), isTrue);
  });

  test('キャンセル・エラーでは持ち物にならない', () async {
    final (s, store, _) = await _make();
    store.emit([
      FakeStore.details('kipputen_remove_ads', iap.PurchaseStatus.canceled),
    ]);
    await _flush();
    expect(s.owns(Product.removeAds), isFalse);
    expect(s.status, PurchaseStatus.idle);
    store.emit([
      FakeStore.details('kipputen_remove_ads', iap.PurchaseStatus.error),
    ]);
    await _flush();
    expect(s.status, PurchaseStatus.failed);
  });

  test('復元：記録が戻る。なければ「復元するものなし」', () async {
    final (s, store, _) = await _make();
    await s.restore();
    store.emit([
      FakeStore.details('kipputen_remove_ads', iap.PurchaseStatus.restored),
    ]);
    await _flush();
    expect(s.owns(Product.removeAds), isTrue);
    expect(s.status, PurchaseStatus.restored);
  });

  test('ストアにつながらないときは unavailable', () async {
    final (s, store, _) = await _make();
    store.available = false;
    final s2 = StorePurchaseService(
      await SharedPreferences.getInstance(),
      store: store,
    );
    await s2.init();
    await s2.buy(Product.removeAds);
    expect(s2.status, PurchaseStatus.unavailable);
    expect(s.owns(Product.removeAds), isFalse);
  });

  test('買ったものは端末に残る（通信がなくても分かる）', () async {
    final (_, _, prefs) = await _make(
      prefs: {'kipputen.owned.removeAds': true},
    );
    final s = StorePurchaseService(
      prefs,
      store: FakeStore()..available = false,
    );
    expect(s.owns(Product.removeAds), isTrue);
  });

  test('ほかの商品 ID の購入も完了は伝える', () async {
    final (s, store, _) = await _make();
    store.emit([FakeStore.details('unknown', iap.PurchaseStatus.purchased)]);
    await _flush();
    expect(store.completed, ['unknown']);
    expect(Product.values.where(s.owns), isEmpty);
  });
}
