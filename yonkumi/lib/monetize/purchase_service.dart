import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 「全問」パック（買い切り）。広告削除・過去問の全解放・成績の軸別分析。
const String kFullPackName = '全問パック';

/// ストアから価格が取れないときに出す価格。
const String kFullPackPrice = '¥600';

enum PurchaseStatus {
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
/// いまは [PlaceholderPurchaseService] だけ。ストアの商品を作ったら、
/// in_app_purchase を使う実装（ひそかぎの StorePurchaseService と同じ形）に
/// main.dart で差し替える。
abstract class PurchaseService extends ChangeNotifier {
  /// 全問パックを持っているか。
  bool get owned;

  String get priceLabel;

  PurchaseStatus get status;

  Future<void> init();
  Future<void> buy();
  Future<void> restore();
}

/// 仮の購入。ストアの商品 ID は使わない。
///
/// 開発中（デバッグビルド）は「購入」で端末にだけ記録し、画面の流れを確かめ
/// られるようにする。リリースビルドでは買えない（[PurchaseStatus.unavailable]）。
class PlaceholderPurchaseService extends PurchaseService {
  PlaceholderPurchaseService(this._prefs, {bool? allowLocalUnlock})
    : _allowLocalUnlock = allowLocalUnlock ?? kDebugMode,
      _owned = _prefs.getBool(_key) ?? false;

  static const _key = 'yonkumi.fullpack.placeholder';

  final SharedPreferences _prefs;
  final bool _allowLocalUnlock;
  bool _owned;
  PurchaseStatus _status = PurchaseStatus.idle;

  @override
  bool get owned => _owned;

  @override
  String get priceLabel => kFullPackPrice;

  @override
  PurchaseStatus get status => _status;

  @override
  Future<void> init() async {}

  @override
  Future<void> buy() async {
    if (!_allowLocalUnlock) {
      _set(PurchaseStatus.unavailable);
      return;
    }
    _owned = true;
    await _prefs.setBool(_key, true);
    _set(PurchaseStatus.purchased);
  }

  @override
  Future<void> restore() async {
    _set(_owned ? PurchaseStatus.restored : PurchaseStatus.nothingToRestore);
  }

  void _set(PurchaseStatus s) {
    _status = s;
    notifyListeners();
  }
}
