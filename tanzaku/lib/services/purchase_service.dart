import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart' as iap;
import 'package:shared_preferences/shared_preferences.dart';

/// 買い切り「すずり」。App Store Connect と Play Console でこの ID の非消耗型の商品を作る。
const String suzuriProductId = 'tanzaku_suzuri';

/// ストアから価格が取れないときに出す価格（設計書：買い切り¥730）。
const String suzuriFallbackPrice = '¥730';

/// すずりで解放されるもの（購入画面の説明に使う）。
const suzuriFeatures = [
  '書体の追加（しっぽり明朝、筆の書体 Yuji Syuku）',
  '和紙5種（桜・若竹・浅葱・金砂子・藍）と色紙の形',
  '落款のカスタム（丸印・朱文・印の色）',
  '月の十句ポスター',
  '縦書き PDF の書き出し（句会の清記用）',
];

enum PurchaseStatus {
  idle,
  pending,
  purchased,
  restored,
  nothingToRestore,
  failed,
  unavailable,
}

/// すずりを持っているかと、購入・復元の窓口。
///
/// 画面はこの抽象だけを見る。本番は [StorePurchaseService]、テストと見本画像は
/// [PlaceholderPurchaseService]。
abstract class PurchaseService extends ChangeNotifier {
  bool get hasSuzuri;
  String get priceLabel;
  PurchaseStatus get status;

  Future<void> init();
  Future<void> buy();
  Future<void> restore();
}

/// 仮の実装。ストアにはつながず、端末の記録だけで「買った」ことにする。
/// テストと、スクリーンショットを撮るときだけに使う。
class PlaceholderPurchaseService extends PurchaseService {
  PlaceholderPurchaseService(this._prefs)
    : _has = _prefs.getBool(_key) ?? false;

  static const _key = 'tanzaku.suzuri.placeholder';
  final SharedPreferences _prefs;
  bool _has;
  PurchaseStatus _status = PurchaseStatus.idle;

  @override
  bool get hasSuzuri => _has;

  @override
  String get priceLabel => suzuriFallbackPrice;

  @override
  PurchaseStatus get status => _status;

  @override
  Future<void> init() async {}

  @override
  Future<void> buy() async {
    _has = true;
    _status = PurchaseStatus.purchased;
    await _prefs.setBool(_key, true);
    notifyListeners();
  }

  @override
  Future<void> restore() async {
    _status = _has ? PurchaseStatus.restored : PurchaseStatus.nothingToRestore;
    notifyListeners();
  }
}

/// App Store と Google Play の非消耗型の商品「すずり」（in_app_purchase）。
///
/// 購入状態は端末に保存し、通信がなくても分かるようにする。サーバーでの検証はしない
/// （¥730 の買い切りで、サーバーを持たない方針のため。一定の不正は割り切る）。
class StorePurchaseService extends PurchaseService {
  StorePurchaseService(this._prefs, {iap.InAppPurchase? store})
    : _iap = store ?? iap.InAppPurchase.instance,
      _has = _prefs.getBool(_key) ?? false;

  static const _key = 'tanzaku.suzuri.v1';

  final SharedPreferences _prefs;
  final iap.InAppPurchase _iap;
  StreamSubscription<List<iap.PurchaseDetails>>? _sub;
  iap.ProductDetails? _product;
  bool _available = false;
  bool _has;
  PurchaseStatus _status = PurchaseStatus.idle;
  Timer? _restoreTimer;

  /// 復元で何も返ってこないとき、「見つからない」とするまでの時間。
  static const restoreTimeout = Duration(seconds: 6);

  @override
  bool get hasSuzuri => _has;

  @override
  String get priceLabel => _product?.price ?? suzuriFallbackPrice;

  @override
  PurchaseStatus get status => _status;

  @override
  Future<void> init() async {
    _sub ??= _iap.purchaseStream.listen(
      _onPurchases,
      onError: (_) => _setStatus(PurchaseStatus.failed),
    );
    try {
      _available = await _iap.isAvailable();
    } catch (_) {
      _available = false;
    }
    if (!_available) return;
    await _loadProduct();
    // Android はログインの確認なしに過去の購入を返すので、起動時に同期する。
    // iOS は Apple ID の確認が出ることがあるので、「購入を復元」を押したときだけ。
    if (!kIsWeb && Platform.isAndroid && !_has) {
      try {
        await _iap.restorePurchases();
      } catch (_) {}
    }
  }

  Future<void> _loadProduct() async {
    try {
      final resp = await _iap.queryProductDetails({suzuriProductId});
      if (resp.productDetails.isNotEmpty) {
        _product = resp.productDetails.first;
        notifyListeners();
      }
    } catch (_) {
      // 価格は仮の表示のまま。
    }
  }

  Future<bool> _ensureAvailable() async {
    if (!_available) {
      try {
        _available = await _iap.isAvailable();
      } catch (_) {
        _available = false;
      }
    }
    if (!_available) {
      _setStatus(PurchaseStatus.unavailable);
      return false;
    }
    if (_product == null) await _loadProduct();
    return true;
  }

  @override
  Future<void> buy() async {
    if (_has) return;
    if (!await _ensureAvailable()) return;
    final product = _product;
    if (product == null) {
      _setStatus(PurchaseStatus.unavailable);
      return;
    }
    _setStatus(PurchaseStatus.pending);
    try {
      final started = await _iap.buyNonConsumable(
        purchaseParam: iap.PurchaseParam(productDetails: product),
      );
      if (!started) _setStatus(PurchaseStatus.failed);
    } catch (_) {
      _setStatus(PurchaseStatus.failed);
    }
  }

  @override
  Future<void> restore() async {
    if (!await _ensureAvailable()) return;
    _setStatus(PurchaseStatus.pending);
    try {
      await _iap.restorePurchases();
    } catch (_) {
      _setStatus(PurchaseStatus.failed);
      return;
    }
    // 買った記録がないと、ストアは何も返さない。しばらく待って結果を決める。
    _restoreTimer?.cancel();
    _restoreTimer = Timer(restoreTimeout, () {
      if (_status == PurchaseStatus.pending) {
        _setStatus(PurchaseStatus.nothingToRestore);
      }
    });
  }

  Future<void> _onPurchases(List<iap.PurchaseDetails> purchases) async {
    for (final p in purchases) {
      if (p.productID == suzuriProductId) {
        switch (p.status) {
          case iap.PurchaseStatus.pending:
            _setStatus(PurchaseStatus.pending);
          case iap.PurchaseStatus.purchased:
            await _grant();
            _setStatus(PurchaseStatus.purchased);
          case iap.PurchaseStatus.restored:
            await _grant();
            _setStatus(PurchaseStatus.restored);
          case iap.PurchaseStatus.error:
            _setStatus(PurchaseStatus.failed);
          case iap.PurchaseStatus.canceled:
            _setStatus(PurchaseStatus.idle);
        }
      }
      // 完了を伝えないと、Android は3日後に自動で返金する。ほかの商品でも完了させる。
      if (p.pendingCompletePurchase) await _iap.completePurchase(p);
    }
  }

  Future<void> _grant() async {
    _restoreTimer?.cancel();
    if (_has) return;
    _has = true;
    await _prefs.setBool(_key, true);
    notifyListeners();
  }

  void _setStatus(PurchaseStatus s) {
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
