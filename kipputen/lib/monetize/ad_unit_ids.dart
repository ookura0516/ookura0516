import 'dart:io';

import 'package:flutter/foundation.dart';

/// AdMob の広告ユニット ID（バナー1つだけ。図鑑画面の下に出す）。
///
/// いまは本番 ID が未設定で、[isPlaceholder] が true。
/// AdMob でアプリ「キップテン」とバナー広告ユニットを作ったら、下の本番 ID を置き換えて
/// [isPlaceholder] を false にする。あわせて Info.plist の GADApplicationIdentifier と、
/// AndroidManifest.xml の com.google.android.gms.ads.APPLICATION_ID も本番のアプリ ID にする
/// （手順は docs/STORE_SETUP.md）。
///
/// [isPlaceholder] が true のままリリースビルドを作ると、広告は出さない
/// （テスト広告が本番で出るのを防ぐ）。デバッグビルドでは Google 公式のテスト広告が出る。
class AdUnitIds {
  static const bool isPlaceholder = true;

  // ── 本番 ID（要置換） ─────────────────────────
  static const _bannerAndroid = 'ca-app-pub-0000000000000000/0000000000';
  static const _bannerIos = 'ca-app-pub-0000000000000000/0000000000';

  // ── Google 公式テスト ID ───────────────────────
  static const _testBannerAndroid = 'ca-app-pub-3940256099942544/6300978111';
  static const _testBannerIos = 'ca-app-pub-3940256099942544/2934735716';

  /// 広告を出してよいか。
  static bool get enabled => kDebugMode || !isPlaceholder;

  static bool get _useTest => kDebugMode || isPlaceholder;

  static String get banner => Platform.isAndroid
      ? (_useTest ? _testBannerAndroid : _bannerAndroid)
      : (_useTest ? _testBannerIos : _bannerIos);
}
