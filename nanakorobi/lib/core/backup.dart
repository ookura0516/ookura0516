import 'dart:convert';

import '../model/models.dart';

/// JSON の書き出し・読み込み。1ファイルに全部入れる（機種変更で消えないように）。
class BackupCodec {
  const BackupCodec._();

  static const version = 1;

  static String encode(BackupData data) =>
      const JsonEncoder.withIndent('  ').convert(data.toJson());

  /// 読めないときは [FormatException]。
  static BackupData decode(String text) {
    final raw = jsonDecode(text);
    if (raw is! Map<String, dynamic>) throw const FormatException('JSON のオブジェクトではない');
    final v = raw['version'];
    if (v is! int || v < 1 || v > version) throw FormatException('対応していない版: $v');
    return BackupData.fromJson(raw);
  }

  static BackupData fromBundles(
    Iterable<DarumaBundle> bundles, {
    required DateTime exportedAt,
    AppSettings? settings,
  }) =>
      BackupData(
        version: version,
        exportedAt: exportedAt,
        darumas: [for (final b in bundles) b.daruma],
        milestones: [for (final b in bundles) ...b.milestones],
        checkins: [for (final b in bundles) ...b.checkins],
        recoveries: [for (final b in bundles) ...b.recoveries],
        settings: settings,
      );

  /// 読み込んだデータを、だるまごとにまとめ直す。
  static List<DarumaBundle> toBundles(BackupData data) => [
        for (final d in data.darumas)
          DarumaBundle(
            daruma: d,
            checkins: data.checkins.where((c) => c.darumaId == d.id).toList(),
            recoveries: data.recoveries.where((r) => r.darumaId == d.id).toList(),
            milestones: data.milestones.where((m) => m.darumaId == d.id).toList(),
          ),
      ];
}
