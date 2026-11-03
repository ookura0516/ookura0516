import 'dart:io';

import 'package:flutter/foundation.dart';

/// AdMob の広告ユニット ID。
///
/// いまはすべて Google 公式のテスト ID（[isPlaceholder] が true）。
/// AdMob でアプリ「ひそかぎ」と広告ユニット（リワード・インタースティシャル）を
/// 作ったら、下の本番 ID を置き換えて [isPlaceholder] を false にする。
/// あわせて Info.plist の GADApplicationIdentifier と、AndroidManifest.xml の
/// com.google.android.gms.ads.APPLICATION_ID も本番のアプリ ID に置き換える。
///
/// [isPlaceholder] が true のままリリースビルドを作ると、広告は出さない
/// （テスト広告が本番で出るのを防ぐ）。そのときヒントは広告なしで開く。
class AdUnitIds {
  static const bool isPlaceholder = true;

  // ── 本番 ID（要置換） ─────────────────────────
  static const _rewardedAndroid = 'ca-app-pub-0000000000000000/0000000000';
  static const _rewardedIos = 'ca-app-pub-0000000000000000/0000000000';
  static const _interstitialAndroid = 'ca-app-pub-0000000000000000/0000000000';
  static const _interstitialIos = 'ca-app-pub-0000000000000000/0000000000';

  // ── Google 公式テスト ID ───────────────────────
  static const _testRewardedAndroid = 'ca-app-pub-3940256099942544/5224354917';
  static const _testRewardedIos = 'ca-app-pub-3940256099942544/1712485313';
  static const _testInterstitialAndroid = 'ca-app-pub-3940256099942544/1033173712';
  static const _testInterstitialIos = 'ca-app-pub-3940256099942544/4411468910';

  /// 広告を出してよいか。
  static bool get enabled => kDebugMode || !isPlaceholder;

  static bool get _useTest => kDebugMode || isPlaceholder;

  static String get rewarded => Platform.isAndroid
      ? (_useTest ? _testRewardedAndroid : _rewardedAndroid)
      : (_useTest ? _testRewardedIos : _rewardedIos);

  static String get interstitial => Platform.isAndroid
      ? (_useTest ? _testInterstitialAndroid : _interstitialAndroid)
      : (_useTest ? _testInterstitialIos : _interstitialIos);
}
