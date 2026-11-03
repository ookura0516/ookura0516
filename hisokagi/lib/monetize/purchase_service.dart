import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 「ひそかぎパス」（非消耗型・買い切り）。App Store Connect と Play Console で
/// この ID の商品を作る。価格は ¥600 を想定（設計書 4章）。
const String passProductId = 'hisokagi_pass';

/// ストアから価格が取れないときに出す価格。
const String passFallbackPrice = '¥600';

enum PassStatus {
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

/// パスを持っているかと、購入・復元の窓口。
///
/// 購入状態は端末に保存し、通信がなくても分かるようにする。
/// サーバーでの検証はしない（設計書 7章：¥600 規模なので一定の不正は割り切る）。
abstract class PurchaseService extends ChangeNotifier {
  bool get hasPass;

  /// 「¥600」などの表示用の価格。
  String get priceLabel;

  PassStatus get status;

  Future<void> init();
  Future<void> buyPass();
  Future<void> restore();
}

class StorePurchaseService extends PurchaseService {
  StorePurchaseService(this._prefs, {InAppPurchase? iap})
      : _iap = iap ?? InAppPurchase.instance,
        _hasPass = _prefs.getBool(_prefKey) ?? false;

  static const _prefKey = 'hisokagi.pass.v1';

  final SharedPreferences _prefs;
  final InAppPurchase _iap;
  StreamSubscription<List<PurchaseDetails>>? _sub;
  ProductDetails? _product;
  bool _available = false;
  bool _hasPass;
  PassStatus _status = PassStatus.idle;
  Timer? _restoreTimer;

  @override
  bool get hasPass => _hasPass;

  @override
  String get priceLabel => _product?.price ?? passFallbackPrice;

  @override
  PassStatus get status => _status;

  @override
  Future<void> init() async {
    _sub ??= _iap.purchaseStream.listen(_onPurchases, onError: (_) {
      _setStatus(PassStatus.failed);
    });
    _available = await _iap.isAvailable();
    if (!_available) return;
    await _loadProduct();
    // Android はログインの確認なしに過去の購入を返すので、起動時に同期する。
    // iOS は Apple ID の確認が出ることがあるため、ユーザーが「復元」を押したときだけ。
    if (Platform.isAndroid && !_hasPass) {
      try {
        await _iap.restorePurchases();
      } catch (_) {}
    }
  }

  Future<void> _loadProduct() async {
    try {
      final resp = await _iap.queryProductDetails({passProductId});
      if (resp.productDetails.isNotEmpty) {
        _product = resp.productDetails.first;
        notifyListeners();
      }
    } catch (_) {
      // 価格は仮の表示のまま。
    }
  }

  Future<bool> _ensureAvailable() async {
    if (!_available) _available = await _iap.isAvailable();
    if (!_available) {
      _setStatus(PassStatus.unavailable);
      return false;
    }
    if (_product == null) await _loadProduct();
    return true;
  }

  @override
  Future<void> buyPass() async {
    if (!await _ensureAvailable()) return;
    final product = _product;
    if (product == null) {
      _setStatus(PassStatus.unavailable);
      return;
    }
    _setStatus(PassStatus.pending);
    try {
      final started = await _iap.buyNonConsumable(
        purchaseParam: PurchaseParam(productDetails: product),
      );
      if (!started) _setStatus(PassStatus.failed);
    } catch (_) {
      _setStatus(PassStatus.failed);
    }
  }

  @override
  Future<void> restore() async {
    if (!await _ensureAvailable()) return;
    _setStatus(PassStatus.pending);
    try {
      await _iap.restorePurchases();
    } catch (_) {
      _setStatus(PassStatus.failed);
      return;
    }
    // 買った記録がないと、ストアは何も返さない。しばらく待って結果を決める。
    _restoreTimer?.cancel();
    _restoreTimer = Timer(const Duration(seconds: 6), () {
      if (_status == PassStatus.pending) {
        _setStatus(PassStatus.nothingToRestore);
      }
    });
  }

  Future<void> _onPurchases(List<PurchaseDetails> purchases) async {
    for (final p in purchases) {
      if (p.productID != passProductId) {
        if (p.pendingCompletePurchase) await _iap.completePurchase(p);
        continue;
      }
      switch (p.status) {
        case PurchaseStatus.pending:
          _setStatus(PassStatus.pending);
        case PurchaseStatus.purchased:
          await _grant();
          _setStatus(PassStatus.purchased);
        case PurchaseStatus.restored:
          await _grant();
          _setStatus(PassStatus.restored);
        case PurchaseStatus.error:
          _setStatus(PassStatus.failed);
        case PurchaseStatus.canceled:
          _setStatus(PassStatus.idle);
      }
      // 完了を伝えないと、Android は3日後に自動で返金する。
      if (p.pendingCompletePurchase) await _iap.completePurchase(p);
    }
  }

  Future<void> _grant() async {
    _restoreTimer?.cancel();
    if (_hasPass) return;
    _hasPass = true;
    await _prefs.setBool(_prefKey, true);
    notifyListeners();
  }

  void _setStatus(PassStatus s) {
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
