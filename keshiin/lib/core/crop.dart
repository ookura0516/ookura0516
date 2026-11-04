import 'dart:ui';

/// トリミングの矩形。元画像に対する割合（0〜1）で持つので、元画像と縮小版の
/// どちらにも同じ値が使える。
class CropRect {
  const CropRect(this.left, this.top, this.width, this.height);

  static const full = CropRect(0, 0, 1, 1);

  final double left;
  final double top;
  final double width;
  final double height;

  /// 'l,t,w,h'
  String encode() =>
      [left, top, width, height].map((v) => v.toStringAsFixed(5)).join(',');

  static CropRect parse(String s) {
    final p = s.split(',').map(double.tryParse).toList();
    if (p.length != 4 || p.any((v) => v == null)) return full;
    return CropRect(p[0]!, p[1]!, p[2]!, p[3]!).clamped();
  }

  CropRect clamped() {
    final w = width.clamp(0.01, 1.0);
    final h = height.clamp(0.01, 1.0);
    return CropRect(left.clamp(0.0, 1 - w), top.clamp(0.0, 1 - h), w, h);
  }

  Rect toPixels(double imageW, double imageH) => Rect.fromLTWH(
    left * imageW,
    top * imageH,
    width * imageW,
    height * imageH,
  );

  /// 画像（[imageW]×[imageH]）の中で、縦横比 [aspect]（幅÷高さ）の最大の矩形を中央に置く。
  static CropRect centered(double imageW, double imageH, double aspect) {
    final imgAspect = imageW / imageH;
    if (imgAspect > aspect) {
      final w = aspect / imgAspect;
      return CropRect((1 - w) / 2, 0, w, 1);
    } else {
      final h = imgAspect / aspect;
      return CropRect(0, (1 - h) / 2, 1, h);
    }
  }

  @override
  bool operator ==(Object other) =>
      other is CropRect && other.encode() == encode();

  @override
  int get hashCode => encode().hashCode;
}
