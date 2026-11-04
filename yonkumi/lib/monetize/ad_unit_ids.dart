import 'dart:io';

import 'package:flutter/foundation.dart';

/// AdMob の広告ユニット ID（結果画面のバナーだけ）。
///
/// いまは Google 公式のテスト ID だけ（[isPlaceholder] が true）。AdMob でアプリ
/// 「ヨンクミ」とバナーの広告ユニットを作ったら、下の本番 ID を置き換えて
/// [isPlaceholder] を false にする。あわせて Info.plist の GADApplicationIdentifier と、
/// AndroidManifest.xml の com.google.android.gms.ads.APPLICATION_ID も本番のアプリ ID に
/// 置き換える（手順は docs/STORE_SETUP.md）。
///
/// [isPlaceholder] が true のままリリースビルドを作ると、広告は出さない
/// （テスト広告が本番で出るのを防ぐ）。
class AdUnitIds {
  static const bool isPlaceholder = true;

  // ── 本番 ID（要置換） ─────────────────────────
  static const _bannerAndroid = 'ca-app-pub-0000000000000000/0000000000';
  static const _bannerIos = 'ca-app-pub-0000000000000000/0000000000';

  // ── Google 公式テスト ID（アダプティブバナー） ───────
  static const _testBannerAndroid = 'ca-app-pub-3940256099942544/9214589741';
  static const _testBannerIos = 'ca-app-pub-3940256099942544/2435281174';

  /// 広告を出してよいか。
  static bool get enabled =>
      decide(debug: kDebugMode, placeholder: isPlaceholder);

  /// テスト用：デバッグなら常にテスト広告、リリースは本番 ID があるときだけ。
  @visibleForTesting
  static bool decide({required bool debug, required bool placeholder}) =>
      debug || !placeholder;

  static bool get _useTest => kDebugMode || isPlaceholder;

  static String get banner => Platform.isAndroid
      ? (_useTest ? _testBannerAndroid : _bannerAndroid)
      : (_useTest ? _testBannerIos : _bannerIos);
}
