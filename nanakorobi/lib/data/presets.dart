import 'dart:convert';

import 'package:flutter/services.dart' show AssetBundle, rootBundle;

import '../core/local_date.dart';

/// 試験日のプリセット。同梱 JSON（assets/presets/exam_dates.json）から読む。
///
/// 日程は各団体の公式ページで確認できたものだけを入れる（確認元は [source]）。
class ExamPreset {
  const ExamPreset({
    required this.id,
    required this.name,
    required this.short,
    required this.date,
    required this.category,
    required this.source,
    required this.checked,
  });

  factory ExamPreset.fromJson(Map<String, Object?> j) => ExamPreset(
        id: j['id'] as String,
        name: j['name'] as String,
        short: j['short'] as String,
        date: LocalDate.parse(j['date'] as String),
        category: j['category'] as String,
        source: j['source'] as String,
        checked: j['checked'] as String,
      );

  final String id;

  /// 一覧に出す名前。
  final String name;

  /// ウィジェットや残り日数の見出しに使う短い名前（「共通テスト」）。
  final String short;
  final LocalDate date;
  final String category;
  final String source;
  final String checked;
}

class ExamPresets {
  const ExamPresets({required this.updated, required this.presets});

  factory ExamPresets.fromJsonString(String s) {
    final j = jsonDecode(s) as Map<String, Object?>;
    final list = (j['presets'] as List<Object?>)
        .map((e) => ExamPreset.fromJson(e as Map<String, Object?>))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    return ExamPresets(updated: j['updated'] as String, presets: list);
  }

  static const assetPath = 'assets/presets/exam_dates.json';

  static Future<ExamPresets> load({AssetBundle? bundle}) async {
    final s = await (bundle ?? rootBundle).loadString(assetPath);
    return ExamPresets.fromJsonString(s);
  }

  final String updated;
  final List<ExamPreset> presets;

  /// 今日以降のものだけ、近い順。
  List<ExamPreset> upcoming(LocalDate today) =>
      presets.where((p) => !p.date.isBefore(today)).toList();
}
