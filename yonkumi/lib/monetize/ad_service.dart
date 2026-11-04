import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ad_unit_ids.dart';

/// 広告の窓口。
///
/// 出すのは結果画面の下のバナー1枚だけ（設計書：問題画面・全画面広告・
/// リワード広告は使わない）。
abstract class AdService {
  const AdService();

  Future<void> init();

  /// 結果画面の下に出すバナー。出せないときは null。
  Widget? banner(BuildContext context);

  /// EEA などで、広告のプライバシー設定の入口を出す必要があるか。
  Future<bool> privacyOptionsRequired() async => false;

  Future<void> showPrivacyOptions() async {}
}

/// 広告を出さない。テストと、本番 ID が未設定のリリースビルドで使う。
class NoAdService extends AdService {
  const NoAdService();

  @override
  Future<void> init() async {}

  @override
  Widget? banner(BuildContext context) => null;
}

/// 仮の広告。広告 ID もネットワークも使わず、バナーの場所と大きさだけを示す
/// （テストと、画面の確認用）。
class PlaceholderAdService extends AdService {
  const PlaceholderAdService();

  @override
  Future<void> init() async {}

  @override
  Widget? banner(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      key: const Key('ad-banner'),
      height: 50,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Text(
        '広告（仮）',
        style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 12),
      ),
    );
  }
}

/// AdMob のアンカー アダプティブ バナー。
///
/// - 非パーソナライズ広告のみ。ATT（トラッキングの許可）は出さない
/// - EEA・英国などでは、起動時に Google の同意フォーム（UMP）を出す
/// - 広告の内容は年齢レーティング G に絞る
class AdMobService extends AdService {
  AdMobService();

  static const request = AdRequest(nonPersonalizedAds: true);

  final _ready = Completer<bool>();
  Future<void>? _initFuture;

  /// 準備ができて広告を出してよいか。
  Future<bool> get ready => _ready.future;

  @override
  Future<void> init() => _initFuture ??= _init();

  Future<void> _init() async {
    try {
      await _gatherConsent();
      if (!await ConsentInformation.instance.canRequestAds()) {
        _ready.complete(false);
        return;
      }
      await MobileAds.instance.initialize();
      await MobileAds.instance.updateRequestConfiguration(
        RequestConfiguration(maxAdContentRating: MaxAdContentRating.g),
      );
      _ready.complete(true);
    } catch (_) {
      if (!_ready.isCompleted) _ready.complete(false);
    }
  }

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
  Widget? banner(BuildContext context) => _AdMobBanner(service: this);

  @override
  Future<bool> privacyOptionsRequired() async {
    try {
      return await ConsentInformation.instance
              .getPrivacyOptionsRequirementStatus() ==
          PrivacyOptionsRequirementStatus.required;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<void> showPrivacyOptions() =>
      ConsentForm.showPrivacyOptionsForm((_) {});
}

class _AdMobBanner extends StatefulWidget {
  const _AdMobBanner({required this.service});

  final AdMobService service;

  @override
  State<_AdMobBanner> createState() => _AdMobBannerState();
}

class _AdMobBannerState extends State<_AdMobBanner> {
  BannerAd? _ad;
  bool _loaded = false;
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    _load(MediaQuery.sizeOf(context).width.truncate());
  }

  Future<void> _load(int width) async {
    if (!await widget.service.ready) return;
    final size = await AdSize.getLargeAnchoredAdaptiveBannerAdSize(width);
    if (size == null || !mounted) return;
    final ad = BannerAd(
      adUnitId: AdUnitIds.banner,
      size: size,
      request: AdMobService.request,
      listener: BannerAdListener(
        onAdLoaded: (_) {
          if (mounted) setState(() => _loaded = true);
        },
        onAdFailedToLoad: (ad, _) => ad.dispose(),
      ),
    );
    _ad = ad;
    await ad.load();
  }

  @override
  void dispose() {
    _ad?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ad = _ad;
    // 読み込めるまでは場所を取らない（読めなければ何も出さない）。
    if (!_loaded || ad == null) return const SizedBox.shrink();
    return SizedBox(
      key: const Key('ad-banner'),
      width: ad.size.width.toDouble(),
      height: ad.size.height.toDouble(),
      child: AdWidget(ad: ad),
    );
  }
}
