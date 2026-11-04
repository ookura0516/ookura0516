import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'products.dart';

enum PurchaseStatus { idle, pending, purchased, restored, failed, unavailable }

/// 購入の窓口。画面はこの形だけを使う。
///
/// いまの実装は [PlaceholderPurchaseService]（仮）。本番では in_app_purchase を使う実装に差し替える
/// （ひそかぎの StorePurchaseService と同じ形で書ける）。
abstract class PurchaseService extends ChangeNotifier {
  bool owns(Product p);
  String priceOf(Product p);
  PurchaseStatus get status;

  /// 本物のストアにつながっているか。仮の実装では false。
  bool get isPlaceholder;

  Future<void> init();
  Future<void> buy(Product p);
  Future<void> restore();
}

/// 仮の購入。商品 ID がないのでストアには行かない。
///
/// デバッグビルドでは押すとすぐ「買った」ことにして、画面の流れを確かめられるようにする。
/// リリースビルドでは何も買えない（[PurchaseStatus.unavailable]）。誤って無料で配らないため。
class PlaceholderPurchaseService extends PurchaseService {
  PlaceholderPurchaseService(this._prefs, {bool? grantForFree})
    : _grant = grantForFree ?? kDebugMode {
    for (final p in Product.values) {
      if (_prefs.getBool(_key(p)) ?? false) _owned.add(p);
    }
  }

  final SharedPreferences _prefs;
  final bool _grant;
  final Set<Product> _owned = {};
  PurchaseStatus _status = PurchaseStatus.idle;

  static String _key(Product p) => 'kipputen.owned.${p.name}';

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
    if (!_grant) {
      _set(PurchaseStatus.unavailable);
      return;
    }
    _owned.add(p);
    await _prefs.setBool(_key(p), true);
    _set(PurchaseStatus.purchased);
  }

  @override
  Future<void> restore() async {
    // 端末に保存した分だけ。ストアがないので、ほかに戻すものはない。
    _set(_owned.isEmpty ? PurchaseStatus.idle : PurchaseStatus.restored);
  }

  void _set(PurchaseStatus s) {
    _status = s;
    notifyListeners();
  }
}
