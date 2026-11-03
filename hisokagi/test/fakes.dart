import 'dart:async';

import 'package:hisokagi/monetize/ad_service.dart';
import 'package:hisokagi/monetize/purchase_service.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class FakePurchaseService extends PurchaseService {
  FakePurchaseService({bool hasPass = false, this.restoreFinds = false})
      : _hasPass = hasPass;

  bool _hasPass;
  bool restoreFinds;
  PassStatus _status = PassStatus.idle;
  int buys = 0;

  @override
  bool get hasPass => _hasPass;

  @override
  String get priceLabel => '¥600';

  @override
  PassStatus get status => _status;

  @override
  Future<void> init() async {}

  @override
  Future<void> buyPass() async {
    buys++;
    _hasPass = true;
    _status = PassStatus.purchased;
    notifyListeners();
  }

  @override
  Future<void> restore() async {
    if (restoreFinds) _hasPass = true;
    _status = restoreFinds ? PassStatus.restored : PassStatus.nothingToRestore;
    notifyListeners();
  }
}

class FakeAdService implements AdService {
  FakeAdService({this.outcome = RewardOutcome.earned});

  RewardOutcome outcome;
  int rewardedShown = 0;
  int interstitialShown = 0;

  @override
  Future<void> init() async {}

  @override
  Future<RewardOutcome> showRewarded() async {
    rewardedShown++;
    return outcome;
  }

  @override
  Future<void> showInterstitial() async => interstitialShown++;

  @override
  Future<bool> privacyOptionsRequired() async => false;

  @override
  Future<void> showPrivacyOptions() async {}
}

/// ストア（in_app_purchase）の代わり。購入の結果は [emit] で流す。
class FakeInAppPurchase implements InAppPurchase {
  final _stream = StreamController<List<PurchaseDetails>>.broadcast();
  bool available = true;
  int restoreCalls = 0;
  final completed = <String>[];
  PurchaseParam? lastBuy;

  void emit(List<PurchaseDetails> p) => _stream.add(p);

  static PurchaseDetails details(String id, PurchaseStatus status) =>
      PurchaseDetails(
        productID: id,
        verificationData: PurchaseVerificationData(
          localVerificationData: '',
          serverVerificationData: '',
          source: 'test',
        ),
        transactionDate: '0',
        status: status,
      )..pendingCompletePurchase = true;

  @override
  Stream<List<PurchaseDetails>> get purchaseStream => _stream.stream;

  @override
  Future<bool> isAvailable() async => available;

  @override
  Future<ProductDetailsResponse> queryProductDetails(Set<String> ids) async =>
      ProductDetailsResponse(
        productDetails: [
          ProductDetails(
            id: passProductId,
            title: 'ひそかぎパス',
            description: '',
            price: '¥610',
            rawPrice: 610,
            currencyCode: 'JPY',
          ),
        ],
        notFoundIDs: const [],
      );

  @override
  Future<bool> buyNonConsumable({required PurchaseParam purchaseParam}) async {
    lastBuy = purchaseParam;
    return true;
  }

  @override
  Future<void> completePurchase(PurchaseDetails purchase) async =>
      completed.add(purchase.productID);

  @override
  Future<void> restorePurchases({String? applicationUserName}) async =>
      restoreCalls++;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
