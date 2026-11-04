import 'package:flutter/widgets.dart';

/// アクセシビリティの小道具（ookura_a11y の代わり。README「共有パッケージの差し替え」）。
class A11y {
  const A11y._();

  /// 端末の「視覚効果を減らす」。開眼・転倒・筆の演出を短くする。
  static bool reduceMotion(BuildContext context) => MediaQuery.disableAnimationsOf(context);

  static Duration motion(BuildContext context, Duration normal) =>
      reduceMotion(context) ? Duration.zero : normal;

  /// 文字サイズの拡大に合わせた最小タップ領域。
  static const minTap = 48.0;
}
