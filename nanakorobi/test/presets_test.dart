import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:nanakorobi/core/local_date.dart';
import 'package:nanakorobi/data/presets.dart';

void main() {
  test('同梱の試験日プリセットは形が正しく、日付順で、確認元がある', () {
    final s = File('assets/presets/exam_dates.json').readAsStringSync();
    final presets = ExamPresets.fromJsonString(s);
    expect(presets.presets, isNotEmpty);
    expect(presets.updated, matches(RegExp(r'^\d{4}-\d{2}-\d{2}$')));
    final ids = <String>{};
    LocalDate? prev;
    for (final p in presets.presets) {
      expect(ids.add(p.id), isTrue, reason: 'id が重複: ${p.id}');
      expect(p.name, isNotEmpty);
      expect(p.short, isNotEmpty);
      expect(p.source, startsWith('https://'));
      expect(p.checked, matches(RegExp(r'^\d{4}-\d{2}-\d{2}$')));
      if (prev != null) expect(p.date.isBefore(prev), isFalse);
      prev = p.date;
    }
    final kyotsu = presets.presets.firstWhere((p) => p.id == 'kyotsu-2027');
    expect(kyotsu.date, LocalDate(2027, 1, 16));
    expect(kyotsu.short, '共通テスト');
  });

  test('今日より前のものは upcoming に出ない', () {
    final presets = ExamPresets.fromJsonString('''
{"updated":"2026-11-04","presets":[
 {"id":"a","name":"A","short":"A","date":"2026-11-15","category":"資格","source":"https://x","checked":"2026-11-04"},
 {"id":"b","name":"B","short":"B","date":"2027-01-16","category":"大学入試","source":"https://x","checked":"2026-11-04"}
]}''');
    expect(presets.upcoming(LocalDate(2026, 11, 20)).map((p) => p.id), ['b']);
    expect(presets.upcoming(LocalDate(2026, 11, 15)).map((p) => p.id), ['a', 'b']);
  });
}
