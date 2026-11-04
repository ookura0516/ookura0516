import 'package:flutter/foundation.dart';
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
/// 画面はこの抽象だけを見る。ストアとつなぐときは、ひそかぎの
/// `StorePurchaseService`（in_app_purchase）と同じ形の実装に差し替える。
abstract class PurchaseService extends ChangeNotifier {
  bool get hasSuzuri;
  String get priceLabel;
  PurchaseStatus get status;

  Future<void> init();
  Future<void> buy();
  Future<void> restore();
}

/// 仮の実装。ストアにはつながず、端末の記録だけで「買った」ことにする。
///
/// リリース前に、in_app_purchase を使う実装に差し替える（README の「まだのこと」）。
/// 差し替えるのは main.dart の1行だけ。
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
