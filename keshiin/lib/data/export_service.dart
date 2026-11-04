import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:archive/archive.dart';
import 'package:path/path.dart' as p;

import 'db.dart';
import 'image_store.dart';
import 'repository.dart';

/// 書き出し：JSON＋元画像の ZIP。写真が増えると大きくなるので、年ごとに1つずつ作る
/// （設計書「データと技術」）。
class ExportService {
  ExportService(this.repo, this.images);

  final StampRepository repo;
  final ImageStore images;

  static const int formatVersion = 1;

  /// [outDir] に keshiin_YYYY.zip を年ごとに作り、作ったファイルのパスを返す。
  Future<List<String>> exportByYear(Directory outDir, {DateTime? now}) async {
    final stamps = await repo.allStamps();
    final sheets = await repo.allSheets();
    final places = await repo.allPlaces();
    final at = (now ?? DateTime.now()).toIso8601String();

    final years = <int>{
      for (final s in stamps) int.parse(s.date.substring(0, 4)),
    }.toList()..sort();
    await outDir.create(recursive: true);
    final out = <String>[];
    for (final y in years) {
      final ys = stamps.where((s) => s.date.startsWith('$y-')).toList();
      final sheetIds = {for (final s in ys) s.sheetId};
      final ySheets = sheets
          .where(
            (s) =>
                sheetIds.contains(s.id) ||
                (s.kind == 'trip' && (s.dateFrom ?? '').startsWith('$y-')),
          )
          .toList();
      final json = buildExportJson(
        stamps: ys,
        sheets: ySheets,
        places: places,
        exportedAt: at,
        year: y,
      );
      final files = <String, String>{
        for (final s in ys) s.imagePath: images.absolute(s.imagePath),
      };
      final path = p.join(outDir.path, 'keshiin_$y.zip');
      await Isolate.run(() => _writeZip(path, json, files));
      out.add(path);
    }
    return out;
  }
}

/// ZIP に入れる JSON。列名は DB と同じ（設計書のデータモデル）。
String buildExportJson({
  required List<StampRow> stamps,
  required List<SheetRow> sheets,
  required List<PlaceHistoryRow> places,
  required String exportedAt,
  int? year,
}) {
  return const JsonEncoder.withIndent('  ').convert({
    'app': 'keshiin',
    'format': ExportService.formatVersion,
    'exported_at': exportedAt,
    'year': ?year,
    'stamp': [
      for (final s in stamps)
        {
          'id': s.id,
          'date': s.date,
          'image_path': s.imagePath,
          'crop': s.crop,
          'shape': s.shape,
          'frame_id': s.frameId,
          'postmark_date': s.postmarkDate,
          'postmark_place': s.postmarkPlace,
          'postmark_note': s.postmarkNote,
          'postmark_seed': s.postmarkSeed,
          'sheet_id': s.sheetId,
          'created_at': s.createdAt.toIso8601String(),
        },
    ],
    'sheet': [
      for (final s in sheets)
        {
          'id': s.id,
          'kind': s.kind,
          'year': s.year,
          'month': s.month,
          'title': s.title,
          'date_from': s.dateFrom,
          'date_to': s.dateTo,
          'completed_at': s.completedAt?.toIso8601String(),
        },
    ],
    'place_history': [
      for (final pl in places)
        {'place': pl.place, 'last_used_at': pl.lastUsedAt.toIso8601String()},
    ],
  });
}

void _writeZip(String path, String json, Map<String, String> files) {
  final archive = Archive()..add(ArchiveFile.string('keshiin.json', json));
  for (final e in files.entries) {
    final f = File(e.value);
    if (!f.existsSync()) continue;
    archive.add(
      ArchiveFile.bytes(e.key.replaceAll('\\', '/'), f.readAsBytesSync()),
    );
  }
  File(path).writeAsBytesSync(ZipEncoder().encodeBytes(archive));
}
