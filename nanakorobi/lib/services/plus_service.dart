import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 「ナナコロビ プラス」（非消耗型・買い切り）。App Store Connect と Play Console で
/// この ID の商品を作る。価格は ¥600 を仮置き（設計書「収益」、¥480〜730 で未決）。
const String plusProductId = 'nanakorobi_plus';

/// ストアから価格が取れないときに出す価格。
const String plusFallbackPrice = '¥600';

enum PlusStatus {
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

@immutable
class PlusState {
  const PlusState({
    this.hasPlus = false,
    this.status = PlusStatus.idle,
    this.priceLabel = plusFallbackPrice,
  });

  final bool hasPlus;
  final PlusStatus status;
  final String priceLabel;

  PlusState copyWith({bool? hasPlus, PlusStatus? status, String? priceLabel}) => PlusState(
        hasPlus: hasPlus ?? this.hasPlus,
        status: status ?? this.status,
        priceLabel: priceLabel ?? this.priceLabel,
      );

  @override
  bool operator ==(Object other) =>
      other is PlusState &&
      other.hasPlus == hasPlus &&
      other.status == status &&
      other.priceLabel == priceLabel;

  @override
  int get hashCode => Object.hash(hasPlus, status, priceLabel);
}

/// プラスの窓口（ookura_iap の代わり）。
///
/// 共有パッケージが手元にある環境では [StorePlusService] を ookura_iap のアダプタで
/// 差し替える（README「共有パッケージの差し替え」）。購入状態は端末に保存し、
/// 通信がなくても分かるようにする。サーバーでの検証はしない。
abstract class PlusService {
  ValueListenable<PlusState> get state;
  bool get hasPlus => state.value.hasPlus;
  Future<void> init();
  Future<void> buy();
  Future<void> restore();
  void dispose();
}

class StorePlusService extends PlusService {
  StorePlusService(this._prefs, {InAppPurchase? iap})
      : _iap = iap ?? InAppPurchase.instance,
        _state = ValueNotifier(PlusState(hasPlus: _prefs.getBool(_prefKey) ?? false));

  static const _prefKey = 'nanakorobi.plus.v1';

  final SharedPreferences _prefs;
  final InAppPurchase _iap;
  final ValueNotifier<PlusState> _state;
  StreamSubscription<List<PurchaseDetails>>? _sub;
  ProductDetails? _product;
  bool _available = false;
  Timer? _restoreTimer;

  @override
  ValueListenable<PlusState> get state => _state;

  @override
  Future<void> init() async {
    _sub ??= _iap.purchaseStream.listen(_onPurchases, onError: (_) {
      _setStatus(PlusStatus.failed);
    });
    try {
      _available = await _iap.isAvailable();
    } catch (_) {
      _available = false;
    }
    if (!_available) return;
    await _loadProduct();
    // Android はログインの確認なしに過去の購入を返すので、起動時に同期する。
    // iOS は Apple ID の確認が出ることがあるため、「購入を復元」を押したときだけ。
    if (!kIsWeb && Platform.isAndroid && !hasPlus) {
      try {
        await _iap.restorePurchases();
      } catch (_) {}
    }
  }

  Future<void> _loadProduct() async {
    try {
      final resp = await _iap.queryProductDetails({plusProductId});
      if (resp.productDetails.isNotEmpty) {
        _product = resp.productDetails.first;
        _state.value = _state.value.copyWith(priceLabel: _product!.price);
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
      _setStatus(PlusStatus.unavailable);
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
      _setStatus(PlusStatus.unavailable);
      return;
    }
    _setStatus(PlusStatus.pending);
    try {
      final started = await _iap.buyNonConsumable(
        purchaseParam: PurchaseParam(productDetails: product),
      );
      if (!started) _setStatus(PlusStatus.failed);
    } catch (_) {
      _setStatus(PlusStatus.failed);
    }
  }

  @override
  Future<void> restore() async {
    if (!await _ensureAvailable()) return;
    _setStatus(PlusStatus.pending);
    try {
      await _iap.restorePurchases();
    } catch (_) {
      _setStatus(PlusStatus.failed);
      return;
    }
    // 買った記録がないと、ストアは何も返さない。しばらく待って結果を決める。
    _restoreTimer?.cancel();
    _restoreTimer = Timer(const Duration(seconds: 6), () {
      if (_state.value.status == PlusStatus.pending) {
        _setStatus(PlusStatus.nothingToRestore);
      }
    });
  }

  Future<void> _onPurchases(List<PurchaseDetails> purchases) async {
    for (final p in purchases) {
      if (p.productID != plusProductId) {
        if (p.pendingCompletePurchase) await _iap.completePurchase(p);
        continue;
      }
      switch (p.status) {
        case PurchaseStatus.pending:
          _setStatus(PlusStatus.pending);
        case PurchaseStatus.purchased:
          await _grant();
          _setStatus(PlusStatus.purchased);
        case PurchaseStatus.restored:
          await _grant();
          _setStatus(PlusStatus.restored);
        case PurchaseStatus.error:
          _setStatus(PlusStatus.failed);
        case PurchaseStatus.canceled:
          _setStatus(PlusStatus.idle);
      }
      // 完了を伝えないと、Android は3日後に自動で返金する。
      if (p.pendingCompletePurchase) await _iap.completePurchase(p);
    }
  }

  Future<void> _grant() async {
    _restoreTimer?.cancel();
    if (hasPlus) return;
    _state.value = _state.value.copyWith(hasPlus: true);
    await _prefs.setBool(_prefKey, true);
  }

  void _setStatus(PlusStatus s) => _state.value = _state.value.copyWith(status: s);

  @override
  void dispose() {
    _restoreTimer?.cancel();
    _sub?.cancel();
    _state.dispose();
  }
}

/// テストと、ストアのない環境で使う。
class FakePlusService extends PlusService {
  FakePlusService({bool hasPlus = false, this.restoreFinds = false})
      : _state = ValueNotifier(PlusState(hasPlus: hasPlus));

  final ValueNotifier<PlusState> _state;
  bool restoreFinds;
  int buys = 0;
  int restores = 0;

  @override
  ValueListenable<PlusState> get state => _state;

  @override
  Future<void> init() async {}

  @override
  Future<void> buy() async {
    buys++;
    _state.value = _state.value.copyWith(hasPlus: true, status: PlusStatus.purchased);
  }

  @override
  Future<void> restore() async {
    restores++;
    _state.value = _state.value.copyWith(
      hasPlus: restoreFinds || hasPlus,
      status: restoreFinds ? PlusStatus.restored : PlusStatus.nothingToRestore,
    );
  }

  @override
  void dispose() => _state.dispose();
}
