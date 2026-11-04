/// 無料とプラスの線引き（設計書「収益」）。
///
/// 無料：現役のだるま1体（満願・納めは何体でも棚に残る）、色は赤・白・黒、共有テンプレ2種。
/// プラス（買い切り ¥600）：現役無制限、全12色、年末の棚ポスター、共有テンプレ全種、
/// JSON の書き出し・読み込み。
enum ShareTemplate {
  /// 無料：無地の和紙。
  plain,

  /// 無料：枠付き。
  framed,

  /// プラス：金屏風（正月）。
  goldScreen,

  /// プラス：桜（合格）。
  sakura,

  /// プラス：お焚き上げ（年末）。
  bonfire;

  bool get isFree => this == plain || this == framed;
}

/// 購入導線は3回だけ。初回起動とオンボーディングでは出さない。
enum PaywallEntry { secondDaruma, firstMilestoneShare, afterCompletion, settings }

class Entitlements {
  const Entitlements._();

  static const freeActiveLimit = 1;
  static const freeColorIds = {0, 1, 2};
  static const colorCount = 12;

  static bool canAddActive({required int activeCount, required bool hasPlus}) =>
      hasPlus || activeCount < freeActiveLimit;

  static bool colorAllowed({required int colorId, required bool hasPlus}) =>
      hasPlus || freeColorIds.contains(colorId);

  static bool canExport(bool hasPlus) => hasPlus;

  static bool canPoster(bool hasPlus) => hasPlus;

  static List<ShareTemplate> templates(bool hasPlus) =>
      hasPlus ? ShareTemplate.values : ShareTemplate.values.where((t) => t.isFree).toList();

  static bool templateAllowed({required ShareTemplate template, required bool hasPlus}) =>
      hasPlus || template.isFree;
}
