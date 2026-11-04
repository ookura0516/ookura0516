import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:nanakorobi/core/local_date.dart';
import 'package:nanakorobi/model/models.dart';
import 'package:nanakorobi/services/presets_service.dart';

void main() {
  final bundled = File('assets/presets/exam_dates.json').readAsStringSync();

  test('同梱の試験日 JSON は読めて、id が一意で、出典がある', () {
    final c = PresetRepository.tryParse(bundled)!;
    expect(c.version, 1);
    expect(c.presets.length, greaterThan(100));
    final ids = c.presets.map((p) => p.id).toSet();
    expect(ids.length, c.presets.length);
    for (final p in c.presets) {
      expect(p.name, isNotEmpty);
      expect(p.sourceUrl, startsWith('https://'));
      expect(p.sourceOrg, isNotEmpty);
      expect(['university', 'highschool', 'juniorhigh', 'certification'], contains(p.kind));
      expect(p.date.year, inInclusiveRange(2026, 2027));
    }
    // 主な日程
    final kyotsu = c.presets.firstWhere((p) => p.id == 'kyotsu_2027_main_day1');
    expect(kyotsu.date, const LocalDate(2027, 1, 16));
    expect(c.presets.where((p) => p.kind == 'highschool').length, 46);
    expect(c.presets.where((p) => p.region == '兵庫県'), isEmpty, reason: '公式ページを開けなかったので入れていない');
  });

  test('更新分が新しければ使い、古い・壊れている・取れないときは同梱版', () async {
    final newer = bundled.replaceFirst('"updated_on": "2026-11-04"', '"updated_on": "2027-01-01"');
    var repo = PresetRepository(loadBundled: () async => bundled, fetcher: FakePresetFetcher(newer));
    expect((await repo.load()).updatedOn, const LocalDate(2027, 1, 1));

    final older = bundled.replaceFirst('"updated_on": "2026-11-04"', '"updated_on": "2026-01-01"');
    repo = PresetRepository(loadBundled: () async => bundled, fetcher: FakePresetFetcher(older));
    expect((await repo.load()).updatedOn, const LocalDate(2026, 11, 4));

    repo = PresetRepository(loadBundled: () async => bundled, fetcher: FakePresetFetcher('<html>'));
    expect((await repo.load()).updatedOn, const LocalDate(2026, 11, 4));

    repo = PresetRepository(loadBundled: () async => bundled, fetcher: FakePresetFetcher(null));
    expect((await repo.load()).presets.length, greaterThan(100));

    repo = PresetRepository(loadBundled: () async => bundled, fetcher: FakePresetFetcher(newer), cacheFile: null);
    expect((await repo.load(refresh: false)).updatedOn, const LocalDate(2026, 11, 4));
  });

  test('更新分は控えに書き、次回は通信なしでも控えを使う', () async {
    final dir = Directory.systemTemp.createTempSync('nanakorobi_presets');
    addTearDown(() => dir.deleteSync(recursive: true));
    final cache = File('${dir.path}/cache.json');
    final newer = bundled.replaceFirst('"updated_on": "2026-11-04"', '"updated_on": "2027-01-01"');
    final fetcher = FakePresetFetcher(newer);
    var repo = PresetRepository(loadBundled: () async => bundled, fetcher: fetcher, cacheFile: cache);
    expect((await repo.load()).updatedOn, const LocalDate(2027, 1, 1));
    expect(cache.existsSync(), isTrue);

    repo = PresetRepository(loadBundled: () async => bundled, fetcher: FakePresetFetcher(null), cacheFile: cache);
    final c = await repo.load();
    expect(c.updatedOn, const LocalDate(2027, 1, 1));
    expect(c, isA<PresetCatalog>());
  });
}
