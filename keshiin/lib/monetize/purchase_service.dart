import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 買い切り「記念」（非消耗型）。App Store Connect と Play Console でこの ID の商品を作る。
const String kinenProductId = 'keshiin_kinen';

/// ストアから価格が取れないときの表示（設計書「収益化」）。
const String kinenFallbackPrice = '¥730';

/// 「記念」で解放するもの。
enum Premium {
  extraFrames('追加フレーム8種'),
  extraFonts('消印の書体2種'),
  tripSheet('旅の小型シート'),
  yearPoster('年間ポスター'),
  multiplePerDay('1日に複数枚（欄外）'),
  highResExport('高解像度の書き出し');

  const Premium(this.label);
  final String label;
}

enum KinenStatus {
  idle,
  pending,
  purchased,
  restored,
  nothingToRestore,
  failed,
  unavailable,
}

/// 購入の窓口。画面はこの型にだけ依存するので、実装を差し替えられる。
abstract class PurchaseService extends ChangeNotifier {
  bool get hasKinen;
  String get priceLabel;
  KinenStatus get status;

  /// いまの実装が仮のものか（設定画面に注記を出す）。
  bool get isProvisional;

  bool unlocked(Premium p) => hasKinen;

  Future<void> init();
  Future<void> buy();
  Future<void> restore();
}

/// 仮の実装。ストアに商品を登録するまでの間、端末内のフラグだけで解放する。
///
/// 本番では [StorePurchaseService] に差し替える（main.dart の [usesStorePurchases]）。
class ProvisionalPurchaseService extends PurchaseService {
  ProvisionalPurchaseService(this._prefs)
    : _has = _prefs.getBool(_key) ?? false;

  static const _key = 'keshiin.kinen.provisional';
  final SharedPreferences _prefs;
  bool _has;
  KinenStatus _status = KinenStatus.idle;

  @override
  bool get hasKinen => _has;
  @override
  String get priceLabel => kinenFallbackPrice;
  @override
  KinenStatus get status => _status;
  @override
  bool get isProvisional => true;

  @override
  Future<void> init() async {}

  @override
  Future<void> buy() async {
    _has = true;
    await _prefs.setBool(_key, true);
    _status = KinenStatus.purchased;
    notifyListeners();
  }

  @override
  Future<void> restore() async {
    _status = _has ? KinenStatus.restored : KinenStatus.nothingToRestore;
    notifyListeners();
  }

  /// 開発中の確認用：購入を取り消す。
  Future<void> reset() async {
    _has = false;
    await _prefs.remove(_key);
    _status = KinenStatus.idle;
    notifyListeners();
  }
}

/// ストアでの購入（in_app_purchase）。ひそかぎの StorePurchaseService と同じ作り。
class StorePurchaseService extends PurchaseService {
  StorePurchaseService(this._prefs, {InAppPurchase? iap})
    : _iap = iap ?? InAppPurchase.instance,
      _has = _prefs.getBool(_key) ?? false;

  static const _key = 'keshiin.kinen.v1';
  final SharedPreferences _prefs;
  final InAppPurchase _iap;
  StreamSubscription<List<PurchaseDetails>>? _sub;
  ProductDetails? _product;
  bool _available = false;
  bool _has;
  KinenStatus _status = KinenStatus.idle;
  Timer? _restoreTimer;

  @override
  bool get hasKinen => _has;
  @override
  String get priceLabel => _product?.price ?? kinenFallbackPrice;
  @override
  KinenStatus get status => _status;
  @override
  bool get isProvisional => false;

  @override
  Future<void> init() async {
    _sub ??= _iap.purchaseStream.listen(
      _onPurchases,
      onError: (_) {
        _set(KinenStatus.failed);
      },
    );
    _available = await _iap.isAvailable();
    if (!_available) return;
    await _load();
    if (Platform.isAndroid && !_has) {
      try {
        await _iap.restorePurchases();
      } catch (_) {}
    }
  }

  Future<void> _load() async {
    try {
      final resp = await _iap.queryProductDetails({kinenProductId});
      if (resp.productDetails.isNotEmpty) {
        _product = resp.productDetails.first;
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<bool> _ready() async {
    if (!_available) _available = await _iap.isAvailable();
    if (!_available) {
      _set(KinenStatus.unavailable);
      return false;
    }
    if (_product == null) await _load();
    return true;
  }

  @override
  Future<void> buy() async {
    if (!await _ready()) return;
    final product = _product;
    if (product == null) {
      _set(KinenStatus.unavailable);
      return;
    }
    _set(KinenStatus.pending);
    try {
      final ok = await _iap.buyNonConsumable(
        purchaseParam: PurchaseParam(productDetails: product),
      );
      if (!ok) _set(KinenStatus.failed);
    } catch (_) {
      _set(KinenStatus.failed);
    }
  }

  @override
  Future<void> restore() async {
    if (!await _ready()) return;
    _set(KinenStatus.pending);
    try {
      await _iap.restorePurchases();
    } catch (_) {
      _set(KinenStatus.failed);
      return;
    }
    _restoreTimer?.cancel();
    _restoreTimer = Timer(const Duration(seconds: 6), () {
      if (_status == KinenStatus.pending) _set(KinenStatus.nothingToRestore);
    });
  }

  Future<void> _onPurchases(List<PurchaseDetails> list) async {
    for (final p in list) {
      if (p.productID == kinenProductId) {
        switch (p.status) {
          case PurchaseStatus.pending:
            _set(KinenStatus.pending);
          case PurchaseStatus.purchased:
            await _grant();
            _set(KinenStatus.purchased);
          case PurchaseStatus.restored:
            await _grant();
            _set(KinenStatus.restored);
          case PurchaseStatus.error:
            _set(KinenStatus.failed);
          case PurchaseStatus.canceled:
            _set(KinenStatus.idle);
        }
      }
      // 完了を伝えないと、Android は3日後に自動で返金する。
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

  void _set(KinenStatus s) {
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
