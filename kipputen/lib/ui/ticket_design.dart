import 'package:flutter/material.dart';

/// 入鋏（ハサミの切り欠き）の形。
enum PunchShape { notchV, notchSquare, round, crescent }

/// 硬券のデザイン。すべて自作。実在の鉄道事業者・駅・地紋にちなむものは作らない。
class TicketDesign {
  const TicketDesign({
    required this.id,
    required this.name,
    required this.paper,
    required this.ink,
    required this.accent,
    required this.punch,
    this.serif = false,
    this.pack = false,
  });

  final String id;
  final String name;

  /// 厚紙の地色。
  final Color paper;

  /// 印字の色。
  final Color ink;

  /// 地紋（自作の波線）と帯の色。
  final Color accent;

  final PunchShape punch;

  /// 明朝寄りの書体にするか。
  final bool serif;

  /// 硬券デザインパックに入っているか。
  final bool pack;

  static const standard = TicketDesign(
    id: 'standard',
    name: '若草',
    paper: Color(0xFFE6EFD9),
    ink: Color(0xFF263A2C),
    accent: Color(0xFFB9CFA5),
    punch: PunchShape.notchV,
  );

  static const all = <TicketDesign>[
    standard,
    TicketDesign(
      id: 'sakura',
      name: '桜鼠',
      paper: Color(0xFFF4E3E3),
      ink: Color(0xFF4A2B33),
      accent: Color(0xFFE2BFC3),
      punch: PunchShape.round,
      pack: true,
    ),
    TicketDesign(
      id: 'kohaku',
      name: '琥珀（昭和の雰囲気）',
      paper: Color(0xFFF0E2BF),
      ink: Color(0xFF3E2A12),
      accent: Color(0xFFD9BF85),
      punch: PunchShape.notchSquare,
      serif: true,
      pack: true,
    ),
    TicketDesign(
      id: 'yukiguni',
      name: '雪原（北の雰囲気）',
      paper: Color(0xFFEAF1F6),
      ink: Color(0xFF1F3550),
      accent: Color(0xFFBCD0E0),
      punch: PunchShape.crescent,
      pack: true,
    ),
    TicketDesign(
      id: 'yako',
      name: '夜行（紺地）',
      paper: Color(0xFF26324F),
      ink: Color(0xFFF1E6C8),
      accent: Color(0xFF3A4A72),
      punch: PunchShape.notchV,
      serif: true,
      pack: true,
    ),
  ];

  static TicketDesign byId(String id) =>
      all.firstWhere((d) => d.id == id, orElse: () => standard);
}
