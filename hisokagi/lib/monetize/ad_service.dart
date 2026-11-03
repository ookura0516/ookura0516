import 'dart:async';

import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ad_unit_ids.dart';

enum RewardOutcome {
  /// 最後まで見て、報酬を受け取った。
  earned,

  /// 途中で閉じた。
  skipped,

  /// 広告を出せなかった（通信がない、在庫がない、同意が得られていない）。
  unavailable,
}

/// 広告の窓口。
///
/// - 非パーソナライズ広告のみ。ATT（トラッキングの許可）は出さない
/// - リワード広告：ヒント2と答え（無料シナリオで、パスを持っていない人）
/// - インタースティシャル：シナリオのクリア後、タイトルに戻るときだけ
/// - プレイ中と謎の途中には出さない
abstract class AdService {
  Future<void> init();
  Future<RewardOutcome> showRewarded();
  Future<void> showInterstitial();

  /// EEA などで、広告のプライバシー設定の入口を出す必要があるか。
  Future<bool> privacyOptionsRequired();
  Future<void> showPrivacyOptions();
}

/// 広告を出さない。テストと、本番 ID が未設定のリリースビルドで使う。
class NoAdService implements AdService {
  const NoAdService();

  @override
  Future<void> init() async {}

  @override
  Future<RewardOutcome> showRewarded() async => RewardOutcome.unavailable;

  @override
  Future<void> showInterstitial() async {}

  @override
  Future<bool> privacyOptionsRequired() async => false;

  @override
  Future<void> showPrivacyOptions() async {}
}

class AdMobService implements AdService {
  AdMobService();

  static const _request = AdRequest(nonPersonalizedAds: true);

  bool _ready = false;
  Future<void>? _initFuture;
  RewardedAd? _rewarded;
  InterstitialAd? _interstitial;
  Completer<bool>? _rewardedLoading;

  @override
  Future<void> init() => _initFuture ??= _init();

  Future<void> _init() async {
    await _gatherConsent();
    if (!await ConsentInformation.instance.canRequestAds()) return;
    await MobileAds.instance.initialize();
    // 年齢レーティング（4+）に合う広告だけにする（App Store 2.5.18）。
    await MobileAds.instance.updateRequestConfiguration(
      RequestConfiguration(maxAdContentRating: MaxAdContentRating.g),
    );
    _ready = true;
    _loadRewarded();
    _loadInterstitial();
  }

  /// EEA・英国などでは、Google の同意フォーム（UMP）を出す。日本では通常出ない。
  Future<void> _gatherConsent() {
    final done = Completer<void>();
    ConsentInformation.instance.requestConsentInfoUpdate(
      ConsentRequestParameters(),
      () async {
        await ConsentForm.loadAndShowConsentFormIfRequired((_) {});
        if (!done.isCompleted) done.complete();
      },
      (_) {
        // 更新できなくても、前回の同意で広告を出せることがある。
        if (!done.isCompleted) done.complete();
      },
    );
    return done.future.timeout(const Duration(seconds: 10), onTimeout: () {});
  }

  Future<bool> _loadRewarded() {
    if (_rewarded != null) return Future.value(true);
    final pending = _rewardedLoading;
    if (pending != null) return pending.future;
    final c = _rewardedLoading = Completer<bool>();
    RewardedAd.load(
      adUnitId: AdUnitIds.rewarded,
      request: _request,
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewarded = ad;
          _rewardedLoading = null;
          c.complete(true);
        },
        onAdFailedToLoad: (_) {
          _rewardedLoading = null;
          c.complete(false);
        },
      ),
    );
    return c.future;
  }

  void _loadInterstitial() {
    if (_interstitial != null) return;
    InterstitialAd.load(
      adUnitId: AdUnitIds.interstitial,
      request: _request,
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) => _interstitial = ad,
        onAdFailedToLoad: (_) => _interstitial = null,
      ),
    );
  }

  @override
  Future<RewardOutcome> showRewarded() async {
    await init();
    if (!_ready) return RewardOutcome.unavailable;
    final loaded = await _loadRewarded()
        .timeout(const Duration(seconds: 8), onTimeout: () => false);
    final ad = _rewarded;
    if (!loaded || ad == null) return RewardOutcome.unavailable;
    _rewarded = null;

    final result = Completer<RewardOutcome>();
    var earned = false;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _loadRewarded();
        if (!result.isCompleted) {
          result.complete(earned ? RewardOutcome.earned : RewardOutcome.skipped);
        }
      },
      onAdFailedToShowFullScreenContent: (ad, _) {
        ad.dispose();
        _loadRewarded();
        if (!result.isCompleted) result.complete(RewardOutcome.unavailable);
      },
    );
    await ad.show(onUserEarnedReward: (_, _) => earned = true);
    return result.future;
  }

  @override
  Future<void> showInterstitial() async {
    if (!_ready) return;
    final ad = _interstitial;
    if (ad == null) return;
    _interstitial = null;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _loadInterstitial();
      },
      onAdFailedToShowFullScreenContent: (ad, _) {
        ad.dispose();
        _loadInterstitial();
      },
    );
    await ad.show();
  }

  @override
  Future<bool> privacyOptionsRequired() async =>
      await ConsentInformation.instance.getPrivacyOptionsRequirementStatus() ==
      PrivacyOptionsRequirementStatus.required;

  @override
  Future<void> showPrivacyOptions() =>
      ConsentForm.showPrivacyOptionsForm((_) {});
}
