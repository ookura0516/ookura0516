import 'dart:convert';

import 'package:drift/drift.dart';

import '../core/kigo.dart';
import '../core/month_day.dart';
import '../core/season.dart';
import 'database.dart';

/// 推敲履歴を1句につき何件まで残すか。
const maxRevisions = 20;

/// 書き出しファイルの形の版。
const exportFormat = 1;

DateTime dateOnly(DateTime t) => DateTime(t.year, t.month, t.day);

String _ymd(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

DateTime _parseYmd(String s) {
  final p = s.split('-').map(int.parse).toList();
  return DateTime(p[0], p[1], p[2]);
}

/// 句帳のデータの出し入れ。画面からはここだけを使う。
class HaikuRepository {
  HaikuRepository(this.db, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final TanzakuDatabase db;
  final DateTime Function() _clock;

  // ------------------------------------------------------------ 歳時記

  Future<int> kigoCount() async {
    final c = db.kigoTable.id.count();
    final q = db.selectOnly(db.kigoTable)..addColumns([c]);
    return (await q.getSingle()).read(c) ?? 0;
  }

  /// アセットの季語を入れ直す（id が同じものは上書き）。
  Future<void> seedKigo(List<Kigo> entries) async {
    await db.batch((b) {
      b.insertAllOnConflictUpdate(db.kigoTable, [
        for (final k in entries)
          KigoTableCompanion.insert(
            id: Value(k.id),
            word: k.word,
            reading: k.reading,
            season: k.season.label,
            category: k.category,
            period: Value(k.period),
            startDay: k.start.key,
            endDay: k.end.key,
            description: k.description,
            aliases: Value(jsonEncode(k.aliases)),
            examples: Value(
              jsonEncode([for (final e in k.examples) e.toJson()]),
            ),
          ),
      ]);
    });
  }

  Future<List<Kigo>> loadKigo() async {
    final rows = await (db.select(
      db.kigoTable,
    )..orderBy([(t) => OrderingTerm.asc(t.id)])).get();
    return [
      for (final r in rows)
        Kigo(
          id: r.id,
          word: r.word,
          reading: r.reading,
          season: Season.fromLabel(r.season),
          category: r.category,
          period: r.period,
          start: MonthDay.fromKey(r.startDay),
          end: MonthDay.fromKey(r.endDay),
          description: r.description,
          aliases: [for (final a in jsonDecode(r.aliases) as List) a as String],
          examples: [
            for (final e in jsonDecode(r.examples) as List)
              KigoExample.fromJson((e as Map).cast<String, Object?>()),
          ],
        ),
    ];
  }

  // ------------------------------------------------------------ 句

  Future<List<HaikuRow>> allHaiku() =>
      (db.select(db.haiku)..orderBy([
            (t) => OrderingTerm.desc(t.composedOn),
            (t) => OrderingTerm.desc(t.createdAt),
          ]))
          .get();

  Future<HaikuRow?> haikuById(int id) =>
      (db.select(db.haiku)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<HaikuRow> addHaiku({
    required String body,
    String maegaki = '',
    int? kigoId,
    String season = '',
    required DateTime composedOn,
    int? themeKigoId,
    String memo = '',
  }) async {
    final now = _clock();
    final id = await db
        .into(db.haiku)
        .insert(
          HaikuCompanion.insert(
            body: body,
            maegaki: Value(maegaki),
            kigoId: Value(kigoId),
            season: Value(season),
            composedOn: dateOnly(composedOn),
            themeKigoId: Value(themeKigoId),
            memo: Value(memo),
            createdAt: now,
            updatedAt: now,
          ),
        );
    return (await haikuById(id))!;
  }

  /// 推敲。本文が変わったら、前の本文を履歴に残す（最大 [maxRevisions] 件）。
  Future<HaikuRow> updateHaiku(
    int id, {
    String? body,
    String? maegaki,
    int? kigoId,
    bool clearKigo = false,
    String? season,
    String? memo,
  }) async {
    return db.transaction(() async {
      final old = (await haikuById(id))!;
      final now = _clock();
      if (body != null && body != old.body) {
        await db
            .into(db.haikuRevision)
            .insert(
              HaikuRevisionCompanion.insert(
                haikuId: id,
                body: old.body,
                savedAt: old.updatedAt,
              ),
            );
        await _trimRevisions(id);
      }
      await (db.update(db.haiku)..where((t) => t.id.equals(id))).write(
        HaikuCompanion(
          body: body == null ? const Value.absent() : Value(body),
          maegaki: maegaki == null ? const Value.absent() : Value(maegaki),
          kigoId: clearKigo
              ? const Value(null)
              : (kigoId == null ? const Value.absent() : Value(kigoId)),
          season: season == null ? const Value.absent() : Value(season),
          memo: memo == null ? const Value.absent() : Value(memo),
          updatedAt: Value(now),
        ),
      );
      return (await haikuById(id))!;
    });
  }

  Future<void> _trimRevisions(int haikuId) async {
    final revs = await revisions(haikuId);
    if (revs.length <= maxRevisions) return;
    final drop = revs.sublist(maxRevisions).map((r) => r.id).toList();
    await (db.delete(db.haikuRevision)..where((t) => t.id.isIn(drop))).go();
  }

  Future<void> setFavorite(int id, bool favorite) async {
    await (db.update(db.haiku)..where((t) => t.id.equals(id))).write(
      HaikuCompanion(favorite: Value(favorite)),
    );
  }

  Future<void> deleteHaiku(int id) async {
    await (db.delete(
      db.haikuRevision,
    )..where((t) => t.haikuId.equals(id))).go();
    await (db.delete(db.haiku)..where((t) => t.id.equals(id))).go();
  }

  /// 新しい順。
  Future<List<HaikuRevisionRow>> revisions(int haikuId) =>
      (db.select(db.haikuRevision)
            ..where((t) => t.haikuId.equals(haikuId))
            ..orderBy([
              (t) => OrderingTerm.desc(t.savedAt),
              (t) => OrderingTerm.desc(t.id),
            ]))
          .get();

  // ------------------------------------------------------------ 兼題

  Future<void> logTheme(DateTime date, int kigoId) async {
    await db
        .into(db.themeLog)
        .insert(
          ThemeLogCompanion.insert(date: dateOnly(date), kigoId: kigoId),
          mode: InsertMode.insertOrIgnore,
        );
  }

  Future<List<ThemeLogRow>> themeLog() => (db.select(
    db.themeLog,
  )..orderBy([(t) => OrderingTerm.desc(t.date)])).get();

  // ------------------------------------------------------------ 書き出し・読み込み

  /// 全句と推敲履歴、兼題の記録を JSON にする。
  Future<String> exportJson() async {
    final haiku = await allHaiku();
    final themes = await themeLog();
    final list = <Map<String, Object?>>[];
    for (final h in haiku.reversed) {
      final revs = await revisions(h.id);
      list.add({
        'text': h.body,
        'maegaki': h.maegaki,
        'kigoId': h.kigoId,
        'season': h.season,
        'composedOn': _ymd(h.composedOn),
        'themeKigoId': h.themeKigoId,
        'memo': h.memo,
        'favorite': h.favorite,
        'createdAt': h.createdAt.toIso8601String(),
        'updatedAt': h.updatedAt.toIso8601String(),
        'revisions': [
          for (final r in revs.reversed)
            {'text': r.body, 'savedAt': r.savedAt.toIso8601String()},
        ],
      });
    }
    return const JsonEncoder.withIndent(' ').convert({
      'app': 'tanzaku',
      'format': exportFormat,
      'exportedAt': _clock().toIso8601String(),
      'haiku': list,
      'themeLog': [
        for (final t in themes.reversed)
          {'date': _ymd(t.date), 'kigoId': t.kigoId},
      ],
    });
  }

  /// 書き出した JSON を読み込む。同じ日に同じ本文の句があれば飛ばす。読み込んだ句の数を返す。
  Future<int> importJson(String json) async {
    final Object? data;
    try {
      data = jsonDecode(json);
    } on FormatException {
      throw const ImportException('JSON として読めませんでした');
    }
    if (data is! Map || data['app'] != 'tanzaku') {
      throw const ImportException('タンザクの書き出しファイルではありません');
    }
    final format = data['format'];
    if (format is! int || format > exportFormat) {
      throw const ImportException('新しい版のアプリで書き出したファイルです');
    }
    final map = data.cast<String, Object?>();
    var added = 0;
    await db.transaction(() async {
      final existing = {
        for (final h in await allHaiku()) '${_ymd(h.composedOn)}\n${h.body}',
      };
      for (final raw in (map['haiku'] as List? ?? const [])) {
        final h = (raw as Map).cast<String, Object?>();
        final body = h['text'] as String;
        final composed = _parseYmd(h['composedOn'] as String);
        if (!existing.add('${_ymd(composed)}\n$body')) continue;
        final id = await db
            .into(db.haiku)
            .insert(
              HaikuCompanion.insert(
                body: body,
                maegaki: Value(h['maegaki'] as String? ?? ''),
                kigoId: Value(h['kigoId'] as int?),
                season: Value(h['season'] as String? ?? ''),
                composedOn: composed,
                themeKigoId: Value(h['themeKigoId'] as int?),
                memo: Value(h['memo'] as String? ?? ''),
                favorite: Value(h['favorite'] as bool? ?? false),
                createdAt: DateTime.parse(h['createdAt'] as String),
                updatedAt: DateTime.parse(h['updatedAt'] as String),
              ),
            );
        for (final r in (h['revisions'] as List? ?? const [])) {
          final rev = (r as Map).cast<String, Object?>();
          await db
              .into(db.haikuRevision)
              .insert(
                HaikuRevisionCompanion.insert(
                  haikuId: id,
                  body: rev['text'] as String,
                  savedAt: DateTime.parse(rev['savedAt'] as String),
                ),
              );
        }
        await _trimRevisions(id);
        added++;
      }
      for (final raw in (map['themeLog'] as List? ?? const [])) {
        final t = (raw as Map).cast<String, Object?>();
        await logTheme(_parseYmd(t['date'] as String), t['kigoId'] as int);
      }
    });
    return added;
  }
}

class ImportException implements Exception {
  const ImportException(this.message);
  final String message;

  @override
  String toString() => message;
}
