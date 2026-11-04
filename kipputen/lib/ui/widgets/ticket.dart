import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../daily/seeded_random.dart';
import '../ticket_design.dart';

/// 硬券（厚紙の切符）。横長で、縦横比はおよそ 57.5 : 30.5。
///
/// 地紋は自作の波線。実在の切符の地紋・事業者名・駅名は使わない。
class Ticket extends StatelessWidget {
  const Ticket({
    super.key,
    required this.design,
    required this.number,
    required this.dateText,
    this.serial,
    this.expression,
    this.punch = 0,
    this.caption,
  });

  static const aspect = 57.5 / 30.5;

  final TicketDesign design;
  final String number;

  /// 「2026.11.04」
  final String dateText;

  /// 通し番号。練習の切符は null（「練習」と出す）。
  final int? serial;

  /// 下の欄に印字する式（「8 ÷ (1 − 1 ÷ 5) = 10」）。null なら空欄。
  final String? expression;

  /// 入鋏の進み具合（0 = まだ、1 = 入った）。
  final double punch;

  /// 帯に出す文字（記念日の名前など）。
  final String? caption;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: aspect,
      child: LayoutBuilder(
        builder: (context, c) {
          final w = c.maxWidth;
          final u = w / 100; // 幅の1%
          final ink = design.ink;
          final family = design.serif ? 'serif' : null;
          TextStyle st(
            double size, {
            FontWeight weight = FontWeight.w600,
            double spacing = 0,
          }) => TextStyle(
            color: ink.withValues(alpha: 0.92),
            fontSize: size * u,
            fontWeight: weight,
            letterSpacing: spacing * u,
            fontFamily: family,
            height: 1.1,
          );
          return ClipPath(
            clipper: _PunchClipper(design.punch, punch),
            child: CustomPaint(
              painter: _PaperPainter(design, seed: number),
              child: Padding(
                padding: EdgeInsets.fromLTRB(6 * u, 4.5 * u, 6 * u, 4 * u),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Text(dateText, style: st(4.2, spacing: 0.2)),
                        const Spacer(),
                        Text(
                          serial == null
                              ? '練習'
                              : 'No.${serial!.toString().padLeft(4, '0')}',
                          style: st(4.2, spacing: 0.2),
                        ),
                      ],
                    ),
                    SizedBox(height: 1.5 * u),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('四数', style: st(4.6)),
                        Text(
                          ' 発  ⟶  ',
                          style: st(3.6, weight: FontWeight.w400),
                        ),
                        Text('十', style: st(4.6)),
                        Text(' ゆき', style: st(3.6, weight: FontWeight.w400)),
                      ],
                    ),
                    Expanded(
                      child: Center(
                        child: FittedBox(
                          child: Text(
                            number.split('').join(' '),
                            key: const Key('ticket-number'),
                            style: st(19, weight: FontWeight.w800, spacing: 1.2)
                                .copyWith(
                                  fontFeatures: const [
                                    FontFeature.tabularFigures(),
                                  ],
                                ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      height: 9 * u,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(
                            color: ink.withValues(alpha: 0.35),
                            width: 0.35 * u,
                          ),
                        ),
                      ),
                      child: FittedBox(
                        child: Text(
                          expression == null || expression!.isEmpty
                              ? ' '
                              : expression!,
                          key: const Key('ticket-expression'),
                          style: st(5.2, weight: FontWeight.w600),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        if (caption != null)
                          Text(
                            caption!,
                            style: st(3.2, weight: FontWeight.w500),
                          ),
                        const Spacer(),
                        Text(
                          '発行 キップテン',
                          style: st(2.9, weight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// 厚紙の地色、ごく薄いノイズ、自作の波線の地紋、内側の罫。
class _PaperPainter extends CustomPainter {
  _PaperPainter(this.design, {required this.seed});

  final TicketDesign design;
  final String seed;

  @override
  void paint(Canvas canvas, Size size) {
    final r = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(size.width * 0.018),
    );
    canvas.drawRRect(r, Paint()..color = design.paper);

    // 地紋：位相をずらした波線を重ねる。
    final wave = Paint()
      ..color = design.accent.withValues(alpha: 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.0035;
    final rows = 16;
    for (var i = 0; i < rows; i++) {
      final y0 = size.height * (i + 0.5) / rows;
      final path = Path()..moveTo(0, y0);
      for (var x = 0.0; x <= size.width; x += size.width / 120) {
        final y =
            y0 +
            math.sin(x / size.width * math.pi * 7 + i * 0.9) *
                size.height *
                0.018;
        path.lineTo(x, y);
      }
      canvas.drawPath(path, wave);
    }

    // 厚紙のノイズ（番号ごとに決まった並び）。
    final rng = SeededRandom.fromString('paper:$seed');
    final dot = Paint()..color = design.ink.withValues(alpha: 0.05);
    for (var i = 0; i < 260; i++) {
      final x = rng.nextInt(10000) / 10000 * size.width;
      final y = rng.nextInt(10000) / 10000 * size.height;
      canvas.drawCircle(Offset(x, y), size.width * 0.0025, dot);
    }

    // 内側の罫。
    final inset = size.width * 0.025;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          inset,
          inset,
          size.width - inset * 2,
          size.height - inset * 2,
        ),
        Radius.circular(size.width * 0.01),
      ),
      Paint()
        ..color = design.ink.withValues(alpha: 0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * 0.004,
    );
  }

  @override
  bool shouldRepaint(_PaperPainter old) =>
      old.design != design || old.seed != seed;
}

/// 入鋏の切り欠き。上の辺の右寄りを [shape] の形で切り取る。
class _PunchClipper extends CustomClipper<Path> {
  _PunchClipper(this.shape, this.progress);

  final PunchShape shape;
  final double progress;

  @override
  Path getClip(Size size) {
    final whole = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Offset.zero & size,
          Radius.circular(size.width * 0.018),
        ),
      );
    if (progress <= 0) return whole;
    final s =
        size.width * 0.095 * Curves.easeOutBack.transform(progress.clamp(0, 1));
    final cx = size.width * 0.74;
    final notch = Path();
    switch (shape) {
      case PunchShape.notchV:
        notch
          ..moveTo(cx - s / 2, -1)
          ..lineTo(cx + s / 2, -1)
          ..lineTo(cx, s * 0.9)
          ..close();
      case PunchShape.notchSquare:
        notch.addRect(Rect.fromLTWH(cx - s / 2, -1, s, s * 0.7));
      case PunchShape.round:
        notch.addOval(Rect.fromCircle(center: Offset(cx, 0), radius: s * 0.55));
      case PunchShape.crescent:
        notch
          ..moveTo(cx - s / 2, -1)
          ..quadraticBezierTo(cx, s * 1.3, cx + s / 2, -1)
          ..close();
    }
    return Path.combine(PathOperation.difference, whole, notch);
  }

  @override
  bool shouldReclip(_PunchClipper old) =>
      old.progress != progress || old.shape != shape;
}

/// 切符を3枚、扇に並べる（全解の日の共有画像）。
class TicketFan extends StatelessWidget {
  const TicketFan({super.key, required this.tickets});

  final List<Widget> tickets;

  @override
  Widget build(BuildContext context) {
    final n = tickets.length;
    return LayoutBuilder(
      builder: (context, c) {
        final w = c.maxWidth * 0.78;
        return SizedBox(
          width: c.maxWidth,
          height: w / Ticket.aspect * 1.75,
          child: Stack(
            alignment: Alignment.center,
            children: [
              for (var i = 0; i < n; i++)
                Transform.translate(
                  offset: Offset(
                    (i - (n - 1) / 2) * w * 0.1,
                    (i - (n - 1) / 2).abs() * w * 0.05 - w * 0.02,
                  ),
                  child: Transform.rotate(
                    angle: (i - (n - 1) / 2) * 0.2,
                    alignment: Alignment.bottomCenter,
                    child: SizedBox(
                      width: w,
                      child: DecoratedBox(
                        decoration: const BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Color(0x33000000),
                              blurRadius: 8,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: tickets[i],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
