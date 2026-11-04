import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ad_unit_ids.dart';

/// 広告の窓口。出すのは図鑑画面の下のバナーだけ。全画面広告は使わない。
///
/// - 非パーソナライズ広告のみ。ATT（トラッキングの許可）は出さない
/// - EEA・英国などでは、起動時に Google の同意フォーム（UMP）を出す
abstract class AdService {
  Future<void> init();

  /// バナー。出さないときは null。
  Widget? banner();

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
  Widget? banner() => null;
  @override
  Future<bool> privacyOptionsRequired() async => false;
  @override
  Future<void> showPrivacyOptions() async {}
}

/// 仮のバナー枠（320×50）。テストとスクリーンショット用。
class PlaceholderAdService implements AdService {
  const PlaceholderAdService({this.visible = kDebugMode});

  final bool visible;

  @override
  Future<void> init() async {}

  @override
  Widget? banner() => visible ? const PlaceholderBanner() : null;

  @override
  Future<bool> privacyOptionsRequired() async => false;

  @override
  Future<void> showPrivacyOptions() async {}
}

class PlaceholderBanner extends StatelessWidget {
  const PlaceholderBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('ad-banner'),
      height: 50,
      width: 320,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0x14000000),
        border: Border.all(color: const Color(0x33000000)),
      ),
      child: const Text(
        '広告枠（仮）',
        style: TextStyle(fontSize: 12, color: Color(0x99000000)),
      ),
    );
  }
}

/// AdMob のバナー。
class AdMobService implements AdService {
  AdMobService();

  static const request = AdRequest(nonPersonalizedAds: true);

  /// 同意を取り、SDK の準備ができたら true。
  final ValueNotifier<bool> ready = ValueNotifier(false);
  Future<void>? _initFuture;

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
    ready.value = true;
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

  @override
  Widget? banner() => _AdMobBanner(service: this);

  @override
  Future<bool> privacyOptionsRequired() async =>
      await ConsentInformation.instance.getPrivacyOptionsRequirementStatus() ==
      PrivacyOptionsRequirementStatus.required;

  @override
  Future<void> showPrivacyOptions() =>
      ConsentForm.showPrivacyOptionsForm((_) {});
}

/// 準備ができたら読み込み、読み込めたら 320×50 で出す。読み込めなければ何も出さない
/// （画面の高さが変わらないよう、読み込み中も枠は空けない）。
class _AdMobBanner extends StatefulWidget {
  const _AdMobBanner({required this.service});

  final AdMobService service;

  @override
  State<_AdMobBanner> createState() => _AdMobBannerState();
}

class _AdMobBannerState extends State<_AdMobBanner> {
  BannerAd? _ad;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    widget.service.ready.addListener(_maybeLoad);
    widget.service.init();
    _maybeLoad();
  }

  void _maybeLoad() {
    if (!widget.service.ready.value || _ad != null) return;
    _ad = BannerAd(
      adUnitId: AdUnitIds.banner,
      size: AdSize.banner,
      request: AdMobService.request,
      listener: BannerAdListener(
        onAdLoaded: (_) {
          if (mounted) setState(() => _loaded = true);
        },
        onAdFailedToLoad: (ad, _) {
          ad.dispose();
          if (mounted) setState(() => _ad = null);
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    widget.service.ready.removeListener(_maybeLoad);
    _ad?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ad = _ad;
    if (ad == null || !_loaded) return const SizedBox.shrink();
    return SizedBox(
      key: const Key('ad-banner'),
      width: ad.size.width.toDouble(),
      height: ad.size.height.toDouble(),
      child: AdWidget(ad: ad),
    );
  }
}
