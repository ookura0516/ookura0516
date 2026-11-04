import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart' as iap;
import 'package:shared_preferences/shared_preferences.dart';

/// 「全問」パック（買い切り）。広告削除・過去問の全解放・成績の軸別分析。
const String kFullPackName = '全問パック';

/// ストアの商品 ID（非消耗型）。App Store Connect と Play Console で
/// この ID の商品を作る（docs/STORE_SETUP.md）。
const String kFullPackProductId = 'yonkumi_fullpack';

/// ストアから価格が取れないときに出す価格。
const String kFullPackPrice = '¥600';

enum PackStatus {
  idle,

  /// 購入の画面を出している、承認待ちなど。
  pending,
  purchased,
  restored,

  /// 復元したが、買った記録がなかった。
  nothingToRestore,

  /// ストアに接続できない、またはまだストアとつないでいない。
  unavailable,
  failed,
}

/// 購入の窓口。
///
/// 本番は [StorePurchaseService]。テストと画面の確認には [PlaceholderPurchaseService]。
abstract class PurchaseService extends ChangeNotifier {
  /// 全問パックを持っているか。
  bool get owned;

  String get priceLabel;

  PackStatus get status;

  Future<void> init();
  Future<void> buy();
  Future<void> restore();
}

/// 仮の購入。ストアの商品 ID は使わない。
///
/// 開発中（デバッグビルド）は「購入」で端末にだけ記録し、画面の流れを確かめ
/// られるようにする。リリースビルドでは買えない（[PackStatus.unavailable]）。
class PlaceholderPurchaseService extends PurchaseService {
  PlaceholderPurchaseService(this._prefs, {bool? allowLocalUnlock})
    : _allowLocalUnlock = allowLocalUnlock ?? kDebugMode,
      _owned = _prefs.getBool(_key) ?? false;

  static const _key = 'yonkumi.fullpack.placeholder';

  final SharedPreferences _prefs;
  final bool _allowLocalUnlock;
  bool _owned;
  PackStatus _status = PackStatus.idle;

  @override
  bool get owned => _owned;

  @override
  String get priceLabel => kFullPackPrice;

  @override
  PackStatus get status => _status;

  @override
  Future<void> init() async {}

  @override
  Future<void> buy() async {
    if (!_allowLocalUnlock) {
      _set(PackStatus.unavailable);
      return;
    }
    _owned = true;
    await _prefs.setBool(_key, true);
    _set(PackStatus.purchased);
  }

  @override
  Future<void> restore() async {
    _set(_owned ? PackStatus.restored : PackStatus.nothingToRestore);
  }

  void _set(PackStatus s) {
    _status = s;
    notifyListeners();
  }
}

/// ストア（App Store・Google Play）での購入。
///
/// 購入状態は端末に保存し、通信がなくても分かるようにする。サーバーでの検証は
/// しない（¥600 規模なので一定の不正は割り切る。ひそかぎと同じ判断）。
class StorePurchaseService extends PurchaseService {
  StorePurchaseService(this._prefs, {iap.InAppPurchase? store})
    : _iap = store ?? iap.InAppPurchase.instance,
      _owned = _prefs.getBool(_key) ?? false;

  static const _key = 'yonkumi.fullpack.v1';

  final SharedPreferences _prefs;
  final iap.InAppPurchase _iap;
  StreamSubscription<List<iap.PurchaseDetails>>? _sub;
  iap.ProductDetails? _product;
  bool _available = false;
  bool _owned;
  PackStatus _status = PackStatus.idle;
  Timer? _restoreTimer;

  @override
  bool get owned => _owned;

  @override
  String get priceLabel => _product?.price ?? kFullPackPrice;

  @override
  PackStatus get status => _status;

  @override
  Future<void> init() async {
    _sub ??= _iap.purchaseStream.listen(
      _onPurchases,
      onError: (_) {
        _set(PackStatus.failed);
      },
    );
    _available = await _iap.isAvailable();
    if (!_available) return;
    await _loadProduct();
    // Android はログインの確認なしに過去の購入を返すので、起動時に同期する。
    // iOS は Apple ID の確認が出ることがあるため、「購入を復元」を押したときだけ。
    if (!kIsWeb && Platform.isAndroid && !_owned) {
      try {
        await _iap.restorePurchases();
      } catch (_) {}
    }
  }

  Future<void> _loadProduct() async {
    try {
      final resp = await _iap.queryProductDetails({kFullPackProductId});
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
      _set(PackStatus.unavailable);
      return false;
    }
    if (_product == null) await _loadProduct();
    return true;
  }

  @override
  Future<void> buy() async {
    if (!await _ensureAvailable()) return;
    final product = _product;
    if (product == null) {
      _set(PackStatus.unavailable);
      return;
    }
    _set(PackStatus.pending);
    try {
      final started = await _iap.buyNonConsumable(
        purchaseParam: iap.PurchaseParam(productDetails: product),
      );
      if (!started) _set(PackStatus.failed);
    } catch (_) {
      _set(PackStatus.failed);
    }
  }

  @override
  Future<void> restore() async {
    if (!await _ensureAvailable()) return;
    _set(PackStatus.pending);
    try {
      await _iap.restorePurchases();
    } catch (_) {
      _set(PackStatus.failed);
      return;
    }
    // 買った記録がないと、ストアは何も返さない。しばらく待って結果を決める。
    _restoreTimer?.cancel();
    _restoreTimer = Timer(const Duration(seconds: 6), () {
      if (_status == PackStatus.pending) {
        _set(PackStatus.nothingToRestore);
      }
    });
  }

  Future<void> _onPurchases(List<iap.PurchaseDetails> purchases) async {
    for (final p in purchases) {
      if (p.productID == kFullPackProductId) {
        switch (p.status) {
          case iap.PurchaseStatus.pending:
            _set(PackStatus.pending);
          case iap.PurchaseStatus.purchased:
            await _grant();
            _set(PackStatus.purchased);
          case iap.PurchaseStatus.restored:
            await _grant();
            _set(PackStatus.restored);
          case iap.PurchaseStatus.error:
            _set(PackStatus.failed);
          case iap.PurchaseStatus.canceled:
            _set(PackStatus.idle);
        }
      }
      // 完了を伝えないと、Android は3日後に自動で返金する（ほかの商品も同じ）。
      if (p.pendingCompletePurchase) await _iap.completePurchase(p);
    }
  }

  Future<void> _grant() async {
    _restoreTimer?.cancel();
    if (_owned) return;
    _owned = true;
    await _prefs.setBool(_key, true);
    notifyListeners();
  }

  void _set(PackStatus s) {
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
