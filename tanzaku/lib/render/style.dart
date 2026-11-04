import 'dart:ui';

import '../core/season.dart';

/// 短冊の形。共有画像のサイズも決める。
enum TanzakuForm {
  /// 縦長の短冊。画像は 1080×1350。
  tanzaku('短冊', Size(1080, 1350)),

  /// 正方形の色紙。画像は 1080×1080。有料。
  shikishi('色紙', Size(1080, 1080));

  const TanzakuForm(this.label, this.imageSize);
  final String label;
  final Size imageSize;

  bool get premium => this == shikishi;
}

/// 書体。Noto Serif JP は無料、ほかの2つは有料（すずり）。
enum TanzakuFont {
  notoSerif('明朝（Noto Serif JP）', 'NotoSerifJP'),
  shippori('しっぽり明朝', 'ShipporiMincho'),
  yuji('筆（Yuji Syuku）', 'YujiSyuku');

  const TanzakuFont(this.label, this.family);
  final String label;
  final String family;

  bool get premium => this != notoSerif;
}

/// 和紙の地。生成りは無料、ほかの5つは有料。
enum Washi {
  kinari('生成り', Color(0xFFF4ECDD), Color(0xFF231C17)),
  sakura('桜', Color(0xFFF7E4E2), Color(0xFF2A1C1E)),
  wakatake('若竹', Color(0xFFE2EBD6), Color(0xFF1C2418)),
  asagi('浅葱', Color(0xFFDCE8EE), Color(0xFF16222B)),
  kinsunago('金砂子', Color(0xFFF1E5C6), Color(0xFF2A2012)),
  ai('藍', Color(0xFF1F3050), Color(0xFFF3EEE2));

  const Washi(this.label, this.paper, this.ink);
  final String label;
  final Color paper;
  final Color ink;

  bool get premium => this != kinari;
  bool get dark => this == ai;
}

enum SealShape { square, round }

/// 落款の彫り方。白文は朱地に白い字、朱文は白地に朱の字。
enum SealCarve { hakubun, shubun }

/// 落款の形。四角の白文が無料。それ以外の組み合わせと色は有料。
class SealStyle {
  const SealStyle({
    this.shape = SealShape.square,
    this.carve = SealCarve.hakubun,
    this.color = const Color(0xFFB8282F),
  });

  final SealShape shape;
  final SealCarve carve;
  final Color color;

  static const free = SealStyle();

  static const colors = [
    Color(0xFFB8282F), // 朱
    Color(0xFFD0532F), // 丹
    Color(0xFF7A2131), // 臙脂
    Color(0xFF2E3A5C), // 藍
  ];

  bool get premium =>
      shape != free.shape || carve != free.carve || color != free.color;

  SealStyle copyWith({SealShape? shape, SealCarve? carve, Color? color}) =>
      SealStyle(
        shape: shape ?? this.shape,
        carve: carve ?? this.carve,
        color: color ?? this.color,
      );

  Map<String, Object?> toJson() => {
    'shape': shape.name,
    'carve': carve.name,
    'color': color.toARGB32(),
  };

  factory SealStyle.fromJson(Map<String, Object?> j) => SealStyle(
    shape: SealShape.values.asNameMap()[j['shape']] ?? SealShape.square,
    carve: SealCarve.values.asNameMap()[j['carve']] ?? SealCarve.hakubun,
    color: Color((j['color'] as int?) ?? free.color.toARGB32()),
  );

  @override
  bool operator ==(Object other) =>
      other is SealStyle &&
      other.shape == shape &&
      other.carve == carve &&
      other.color == color;

  @override
  int get hashCode => Object.hash(shape, carve, color);
}

/// 短冊の見た目の切り替え。
class TanzakuStyle {
  const TanzakuStyle({
    this.form = TanzakuForm.tanzaku,
    this.font = TanzakuFont.notoSerif,
    this.washi = Washi.kinari,
    this.showSeal = true,
    this.seal = SealStyle.free,
    this.showDate = true,
  });

  final TanzakuForm form;
  final TanzakuFont font;
  final Washi washi;
  final bool showSeal;
  final SealStyle seal;
  final bool showDate;

  /// 有料の要素を使っているか。
  bool get premium =>
      form.premium || font.premium || washi.premium || seal.premium;

  /// 無料の範囲に戻したもの。
  TanzakuStyle get freeOnly => TanzakuStyle(
    form: form.premium ? TanzakuForm.tanzaku : form,
    font: font.premium ? TanzakuFont.notoSerif : font,
    washi: washi.premium ? Washi.kinari : washi,
    showSeal: showSeal,
    seal: seal.premium ? SealStyle.free : seal,
    showDate: showDate,
  );

  TanzakuStyle copyWith({
    TanzakuForm? form,
    TanzakuFont? font,
    Washi? washi,
    bool? showSeal,
    SealStyle? seal,
    bool? showDate,
  }) => TanzakuStyle(
    form: form ?? this.form,
    font: font ?? this.font,
    washi: washi ?? this.washi,
    showSeal: showSeal ?? this.showSeal,
    seal: seal ?? this.seal,
    showDate: showDate ?? this.showDate,
  );

  Map<String, Object?> toJson() => {
    'form': form.name,
    'font': font.name,
    'washi': washi.name,
    'showSeal': showSeal,
    'seal': seal.toJson(),
    'showDate': showDate,
  };

  factory TanzakuStyle.fromJson(Map<String, Object?> j) => TanzakuStyle(
    form: TanzakuForm.values.asNameMap()[j['form']] ?? TanzakuForm.tanzaku,
    font: TanzakuFont.values.asNameMap()[j['font']] ?? TanzakuFont.notoSerif,
    washi: Washi.values.asNameMap()[j['washi']] ?? Washi.kinari,
    showSeal: j['showSeal'] as bool? ?? true,
    seal: j['seal'] is Map
        ? SealStyle.fromJson((j['seal'] as Map).cast<String, Object?>())
        : SealStyle.free,
    showDate: j['showDate'] as bool? ?? true,
  );

  @override
  bool operator ==(Object other) =>
      other is TanzakuStyle &&
      other.form == form &&
      other.font == font &&
      other.washi == washi &&
      other.showSeal == showSeal &&
      other.seal == seal &&
      other.showDate == showDate;

  @override
  int get hashCode => Object.hash(form, font, washi, showSeal, seal, showDate);
}

/// 季節ごとの色。ホームの配色と、短冊の季語のごく薄い色分けに使う。
class SeasonPalette {
  const SeasonPalette(this.accent, this.wash, this.tint);

  /// ボタンなどの色。
  final Color accent;

  /// 背景のうすい色。
  final Color wash;

  /// 短冊で季語に重ねる色。
  final Color tint;

  static SeasonPalette of(Season s) => switch (s) {
    Season.newYear => const SeasonPalette(
      Color(0xFFB8282F),
      Color(0xFFF8EDE6),
      Color(0xFFC0392B),
    ),
    Season.spring => const SeasonPalette(
      Color(0xFFC2577A),
      Color(0xFFF8EEF0),
      Color(0xFFD16A8C),
    ),
    Season.summer => const SeasonPalette(
      Color(0xFF2E7D6B),
      Color(0xFFEAF4EF),
      Color(0xFF2F8F73),
    ),
    Season.autumn => const SeasonPalette(
      Color(0xFFB4632A),
      Color(0xFFF7EEE4),
      Color(0xFFC0702F),
    ),
    Season.winter => const SeasonPalette(
      Color(0xFF3D5A80),
      Color(0xFFEDF1F6),
      Color(0xFF4A6FA5),
    ),
  };
}
