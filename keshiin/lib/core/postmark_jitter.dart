import 'dart:math' as math;

import 'rng.dart';

/// 消印を手で押したような「ずれ」。シードだけから決まる。
class PostmarkJitter {
  const PostmarkJitter({
    required this.dx,
    required this.dy,
    required this.angle,
    required this.inkStrength,
  });

  /// 基準位置からのずれ（消印の直径に対する割合）。
  final double dx;
  final double dy;

  /// 回転（ラジアン）。
  final double angle;

  /// インクの濃さ（0.75〜1.0）。
  final double inkStrength;

  static const double maxShift = 0.08;
  static const double maxAngle = 14 * math.pi / 180;

  factory PostmarkJitter.fromSeed(int seed) {
    final r = SeededRng(seed);
    return PostmarkJitter(
      dx: r.range(-maxShift, maxShift),
      dy: r.range(-maxShift, maxShift),
      angle: r.range(-maxAngle, maxAngle),
      inkStrength: r.range(0.75, 1.0),
    );
  }
}

/// 新しい切手のシード。時刻から作るが、保存したあとは変えない。
int newPostmarkSeed([DateTime? now]) =>
    ((now ?? DateTime.now()).microsecondsSinceEpoch * 2654435761) & 0x7FFFFFFF;
