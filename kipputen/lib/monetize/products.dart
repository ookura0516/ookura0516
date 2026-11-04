/// 売るもの（どちらも非消耗型・買い切り）。
///
/// App Store Connect と Play Console で、[storeId] と同じ ID の非消耗型の商品を作る
/// （手順は docs/STORE_SETUP.md）。
enum Product {
  /// 図鑑画面のバナーを消す。
  removeAds(
    storeId: 'kipputen_remove_ads',
    fallbackPrice: '¥480',
    title: '広告削除',
  ),

  /// 硬券のデザイン（地色・書体・入鋏の形）を増やす。共有画像にも反映。
  designPack(
    storeId: 'kipputen_design_pack',
    fallbackPrice: '¥320',
    title: '硬券デザインパック',
  );

  const Product({
    required this.storeId,
    required this.fallbackPrice,
    required this.title,
  });

  /// ストアの商品 ID。
  final String storeId;

  /// ストアから価格が取れないときの表示。
  final String fallbackPrice;
  final String title;

  static Product? byStoreId(String id) {
    for (final p in values) {
      if (p.storeId == id) return p;
    }
    return null;
  }
}
