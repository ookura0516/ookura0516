/// 売るもの（どちらも非消耗型・買い切り）。
///
/// ストアの商品 ID はまだ入れていない。App Store Connect と Play Console で商品を作ったら
/// [storeId] に入れ、[PurchaseService] を本物の実装（in_app_purchase）に差し替える。
enum Product {
  /// 図鑑画面のバナーを消す。
  removeAds(fallbackPrice: '¥480', title: '広告削除'),

  /// 硬券のデザイン（地色・書体・入鋏の形）を増やす。共有画像にも反映。
  designPack(fallbackPrice: '¥320', title: '硬券デザインパック');

  const Product({required this.fallbackPrice, required this.title});

  /// ストアから価格が取れないときの表示。
  final String fallbackPrice;
  final String title;

  /// ストアの商品 ID。未設定（null）のあいだは本物の購入はできない。
  String? get storeId => null;
}
