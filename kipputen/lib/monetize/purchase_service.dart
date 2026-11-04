import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart' as iap;
import 'package:shared_preferences/shared_preferences.dart';

import 'products.dart';

enum PurchaseStatus {
  idle,

  /// 購入の画面を出している、または保護者の承認待ちなど。
  pending,
  purchased,
  restored,

  /// 復元したが、買った記録がなかった。
  nothingToRestore,
  failed,

  /// ストアに接続できない（機内モードなど）。
  unavailable,
}

/// 購入の窓口。画面はこの形だけを使う。
///
/// 購入状態は端末に保存し、通信がなくても分かるようにする。
/// サーバーでの検証はしない（数百円の買い切りなので、一定の不正は割り切る。ひそかぎと同じ判断）。
abstract class PurchaseService extends ChangeNotifier {
  bool owns(Product p);
  String priceOf(Product p);
  PurchaseStatus get status;

  /// 本物のストアにつながっていない（テスト・スクリーンショット用）か。
  bool get isPlaceholder;

  Future<void> init();
  Future<void> buy(Product p);
  Future<void> restore();
}

String _prefKey(Product p) => 'kipputen.owned.${p.name}';

/// App Store・Google Play で買う（in_app_purchase）。
class StorePurchaseService extends PurchaseService {
  StorePurchaseService(this._prefs, {iap.InAppPurchase? store})
    : _store = store ?? iap.InAppPurchase.instance {
    for (final p in Product.values) {
      if (_prefs.getBool(_prefKey(p)) ?? false) _owned.add(p);
    }
  }

  final SharedPreferences _prefs;
  final iap.InAppPurchase _store;
  final Set<Product> _owned = {};
  final Map<Product, iap.ProductDetails> _details = {};
  StreamSubscription<List<iap.PurchaseDetails>>? _sub;
  bool _available = false;
  PurchaseStatus _status = PurchaseStatus.idle;
  Timer? _restoreTimer;

  @override
  bool owns(Product p) => _owned.contains(p);

  @override
  String priceOf(Product p) => _details[p]?.price ?? p.fallbackPrice;

  @override
  PurchaseStatus get status => _status;

  @override
  bool get isPlaceholder => false;

  @override
  Future<void> init() async {
    _sub ??= _store.purchaseStream.listen(
      _onPurchases,
      onError: (_) {
        _set(PurchaseStatus.failed);
      },
    );
    _available = await _store.isAvailable();
    if (!_available) return;
    await _loadProducts();
    // Android はログインの確認なしに過去の購入を返すので、起動時に同期する。
    // iOS は Apple ID の確認が出ることがあるため、ユーザーが「復元」を押したときだけ。
    if (Platform.isAndroid && _owned.length < Product.values.length) {
      try {
        await _store.restorePurchases();
      } catch (_) {}
    }
  }

  Future<void> _loadProducts() async {
    try {
      final resp = await _store.queryProductDetails({
        for (final p in Product.values) p.storeId,
      });
      for (final d in resp.productDetails) {
        final p = Product.byStoreId(d.id);
        if (p != null) _details[p] = d;
      }
      notifyListeners();
    } catch (_) {
      // 価格は仮の表示のまま。
    }
  }

  Future<bool> _ensureAvailable() async {
    if (!_available) _available = await _store.isAvailable();
    if (!_available) {
      _set(PurchaseStatus.unavailable);
      return false;
    }
    if (_details.length < Product.values.length) await _loadProducts();
    return true;
  }

  @override
  Future<void> buy(Product p) async {
    if (!await _ensureAvailable()) return;
    final d = _details[p];
    if (d == null) {
      _set(PurchaseStatus.unavailable);
      return;
    }
    _set(PurchaseStatus.pending);
    try {
      final started = await _store.buyNonConsumable(
        purchaseParam: iap.PurchaseParam(productDetails: d),
      );
      if (!started) _set(PurchaseStatus.failed);
    } catch (_) {
      _set(PurchaseStatus.failed);
    }
  }

  @override
  Future<void> restore() async {
    if (!await _ensureAvailable()) return;
    _set(PurchaseStatus.pending);
    try {
      await _store.restorePurchases();
    } catch (_) {
      _set(PurchaseStatus.failed);
      return;
    }
    // 買った記録がないと、ストアは何も返さない。しばらく待って結果を決める。
    _restoreTimer?.cancel();
    _restoreTimer = Timer(const Duration(seconds: 6), () {
      if (_status == PurchaseStatus.pending) {
        _set(PurchaseStatus.nothingToRestore);
      }
    });
  }

  Future<void> _onPurchases(List<iap.PurchaseDetails> purchases) async {
    for (final d in purchases) {
      final p = Product.byStoreId(d.productID);
      if (p != null) {
        switch (d.status) {
          case iap.PurchaseStatus.pending:
            _set(PurchaseStatus.pending);
          case iap.PurchaseStatus.purchased:
            await _grant(p);
            _set(PurchaseStatus.purchased);
          case iap.PurchaseStatus.restored:
            await _grant(p);
            _set(PurchaseStatus.restored);
          case iap.PurchaseStatus.error:
            _set(PurchaseStatus.failed);
          case iap.PurchaseStatus.canceled:
            _set(PurchaseStatus.idle);
        }
      }
      // 完了を伝えないと、Android は3日後に自動で返金する。
      if (d.pendingCompletePurchase) await _store.completePurchase(d);
    }
  }

  Future<void> _grant(Product p) async {
    _restoreTimer?.cancel();
    if (_owned.contains(p)) return;
    _owned.add(p);
    await _prefs.setBool(_prefKey(p), true);
    notifyListeners();
  }

  void _set(PurchaseStatus s) {
    _status = s;
    notifyListeners();
  }

  @override
  void dispose() {
    _restoreTimer?.cancel();
    _sub?.cancel();
    super.dispose();
  }
}

/// ストアを使わない購入（テストとスクリーンショット用）。押すとすぐ「買った」ことになる。
class PlaceholderPurchaseService extends PurchaseService {
  PlaceholderPurchaseService(this._prefs) {
    for (final p in Product.values) {
      if (_prefs.getBool(_prefKey(p)) ?? false) _owned.add(p);
    }
  }

  final SharedPreferences _prefs;
  final Set<Product> _owned = {};
  PurchaseStatus _status = PurchaseStatus.idle;

  @override
  bool owns(Product p) => _owned.contains(p);

  @override
  String priceOf(Product p) => p.fallbackPrice;

  @override
  PurchaseStatus get status => _status;

  @override
  bool get isPlaceholder => true;

  @override
  Future<void> init() async {}

  @override
  Future<void> buy(Product p) async {
    _owned.add(p);
    await _prefs.setBool(_prefKey(p), true);
    _set(PurchaseStatus.purchased);
  }

  @override
  Future<void> restore() async => _set(
    _owned.isEmpty ? PurchaseStatus.nothingToRestore : PurchaseStatus.restored,
  );

  void _set(PurchaseStatus s) {
    _status = s;
    notifyListeners();
  }
}
