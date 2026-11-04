import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;

import '../core/banned_words.dart';
import '../core/crop.dart';
import '../core/day_slots.dart';
import '../core/frames.dart';
import '../core/photo_meta.dart';
import '../core/places.dart';
import '../core/postmark_jitter.dart';
import '../core/reminder.dart';
import '../core/widget_snapshot.dart';
import '../data/db.dart';
import '../data/export_service.dart';
import '../data/image_store.dart';
import '../data/repository.dart';
import '../data/settings.dart';
import '../monetize/purchase_service.dart';
import '../platform/services.dart';
import '../render/postmark_painter.dart';
import '../render/sheet_painter.dart';
import '../render/stamp_painter.dart';
import 'photo_io.dart';

/// 画面に出す切手1枚（DB の行＋シートでの通し番号など）。
class StampEntry {
  const StampEntry({
    required this.row,
    required this.serial,
    required this.sheetTitle,
  });

  final StampRow row;
  final int serial;
  final String sheetTitle;

  Day get day => Day.parse(row.date);
  CropRect get crop => CropRect.parse(row.crop);
  StampShape get shape => StampShape.parse(row.shape);
  FrameSpec get frame => frameById(row.frameId);

  PostmarkData postmark(String fontId) => PostmarkData(
    date: Day.parse(row.postmarkDate),
    place: row.postmarkPlace,
    note: row.postmarkNote,
    seed: row.postmarkSeed,
    fontId: fontId,
  );

  StampVisual visual(ui.Image? photo, String fontId) => StampVisual(
    photo: photo,
    crop: crop,
    shape: shape,
    frame: frame,
    serial: serial,
    sheetName: sheetTitle,
    postmark: postmark(fontId),
  );
}

/// 月のシートの中身。
class MonthData {
  const MonthData({
    required this.year,
    required this.month,
    required this.sheet,
    required this.cells,
    required this.margin,
  });

  final int year;
  final int month;
  final SheetRow? sheet;

  /// 30マス。空欄は null。
  final List<StampEntry?> cells;
  final List<StampEntry> margin;

  Set<int> get filledDays => {
    for (var i = 0; i < cells.length; i++)
      if (cells[i] != null) i + 1,
  };

  ({int filled, int total}) get count => fillCount(filledDays, year, month);

  bool get complete => isMonthComplete(filledDays, year, month);

  List<StampEntry> get all => [...cells.whereType<StampEntry>(), ...margin];

  String get title => sheet?.title ?? '';
}

/// 切手を作っている途中の状態。
class StampDraft {
  StampDraft({
    required this.imagePath,
    required this.imageWidth,
    required this.imageHeight,
    required this.meta,
    required this.day,
    required this.dayFromPhoto,
    required this.shape,
    required this.crop,
    required this.frameId,
    required this.postmarkPlace,
    required this.placeFromPhoto,
    required this.seed,
  });

  final String imagePath;
  final int imageWidth;
  final int imageHeight;
  final PhotoMeta meta;

  Day day;

  /// [day] を写真の撮影日から決めたか。
  final bool dayFromPhoto;
  StampShape shape;
  CropRect crop;
  String frameId;
  Day? postmarkDate;
  String postmarkPlace;
  final bool placeFromPhoto;
  String postmarkNote = '';
  int seed;

  Day get effectivePostmarkDate => postmarkDate ?? day;

  void setShape(StampShape s) {
    shape = s;
    crop = CropRect.centered(
      imageWidth.toDouble(),
      imageHeight.toDouble(),
      s.aspect,
    );
  }
}

/// 保存の結果。
sealed class SaveResult {
  const SaveResult();
}

class Saved extends SaveResult {
  const Saved(this.row, {this.completedMonth = false});
  final StampRow row;

  /// この保存で月のシートが埋まった。
  final bool completedMonth;
}

class NeedsPremium extends SaveResult {
  const NeedsPremium(this.feature);
  final Premium feature;
}

class Rejected extends SaveResult {
  const Rejected(this.message);
  final String message;
}

/// まとめて貼った結果。
class BulkResult {
  const BulkResult({required this.saved, required this.skipped});
  final int saved;

  /// すでに切手がある日なので飛ばした数。
  final int skipped;
}

/// アプリ全体の状態。画面はこれを Provider で受け取る。
class AppState extends ChangeNotifier {
  AppState({
    required this.repo,
    required this.photoStore,
    required this.photoLoader,
    required this.settings,
    required this.purchases,
    required this.services,
    required this.places,
    this.exporter,
    DateTime Function()? clock,
  }) : clock = clock ?? DateTime.now {
    purchases.addListener(notifyListeners);
  }

  final StampRepository repo;
  final PhotoStore photoStore;
  final PhotoLoader photoLoader;
  final AppSettings settings;
  final PurchaseService purchases;
  final PlatformServices services;
  final MunicipalityIndex places;
  final ExportService? exporter;
  final DateTime Function() clock;

  Day get today => Day.fromDateTime(clock());

  /// DB が変わるたびに増える。画面はこれを見て読み直す。
  int revision = 0;

  void _changed() {
    revision++;
    notifyListeners();
  }

  bool unlocked(Premium f) => purchases.unlocked(f);

  String get fontId {
    final f = postmarkFontById(settings.postmarkFontId);
    return f.premium && !unlocked(Premium.extraFonts)
        ? postmarkFonts.first.id
        : f.id;
  }

  // ---- 読む ----

  Future<MonthData> loadMonth(int year, int month) async {
    final sheet = await repo.monthSheet(year, month);
    final rows = await repo.stampsInMonth(year, month);
    final title = sheet?.title ?? '';
    final placements = placeInMonth([
      for (var i = 0; i < rows.length; i++)
        (day: Day.parse(rows[i].date), order: i),
    ]);
    final cells = List<StampEntry?>.filled(sheetCells, null);
    final margin = <StampEntry>[];
    for (var i = 0; i < rows.length; i++) {
      final e = StampEntry(row: rows[i], serial: i + 1, sheetTitle: title);
      switch (placements[i]) {
        case InCell(:final index):
          cells[index] = e;
        case Margin():
          margin.add(e);
      }
    }
    return MonthData(
      year: year,
      month: month,
      sheet: sheet,
      cells: cells,
      margin: margin,
    );
  }

  Future<StampEntry?> loadStamp(int id) async {
    final row = await repo.stampById(id);
    if (row == null) return null;
    final d = Day.parse(row.date);
    final sheet = await repo.monthSheet(d.year, d.month);
    return StampEntry(
      row: row,
      serial: await repo.serialInMonth(row),
      sheetTitle: sheet?.title ?? '',
    );
  }

  Future<List<StampEntry>> loadRange(Day from, Day to) async {
    final rows = await repo.stampsInRange(from, to);
    return [
      for (var i = 0; i < rows.length; i++)
        StampEntry(row: rows[i], serial: i + 1, sheetTitle: ''),
    ];
  }

  // ---- 作る ----

  /// 写真を取り込んで下書きを作る。[target] はシートでタップしたマスの日。
  Future<StampDraft> startDraft(PickedPhoto photo, {Day? target}) async {
    final meta = await readPhotoMeta(photo.bytes);
    final imported = await photoStore.importPhoto(photo.bytes);
    final now = today;
    var day = meta.taken != null
        ? Day.fromDateTime(meta.taken!)
        : (target ?? now);
    if (day > now) day = now;
    final place = await resolvePlace(meta);
    final shape = settings.lastShape;
    return StampDraft(
      imagePath: imported.path,
      imageWidth: imported.width,
      imageHeight: imported.height,
      meta: meta,
      day: day,
      dayFromPhoto: meta.taken != null,
      shape: shape,
      crop: CropRect.centered(
        imported.width.toDouble(),
        imported.height.toDouble(),
        shape.aspect,
      ),
      frameId: settings.lastFrameId,
      postmarkPlace: place ?? '',
      placeFromPhoto: place != null,
      seed: newPostmarkSeed(clock()),
    );
  }

  /// 写真の GPS から場所。国内は内蔵の表で、海外は通信できるときだけ OS に聞く。
  Future<String?> resolvePlace(PhotoMeta meta) async {
    if (!meta.hasLocation) return null;
    final hit = places.nearest(meta.lat!, meta.lng!);
    if (hit != null) return postmarkPlaceName(hit.place);
    final name = await services.geocoder.placeName(meta.lat!, meta.lng!);
    if (name == null) return null;
    // OS の答えも禁止語の判定を通す。
    return checkPostmarkPlace(name).ok ? name : null;
  }

  Future<void> discardDraft(StampDraft d) => photoStore.delete(d.imagePath);

  Future<List<String>> recentPlaces() => repo.recentPlaces();

  /// 保存してよいかの判定だけ（画面で先に案内を出すため）。
  Future<SaveResult?> checkDraft(StampDraft d) async {
    final place = checkPostmarkPlace(d.postmarkPlace);
    if (!place.ok) return Rejected(place.reason!);
    final note = checkPostmarkNote(d.postmarkNote);
    if (!note.ok) return Rejected(note.reason!);
    if (frameById(d.frameId).premium && !unlocked(Premium.extraFrames)) {
      return const NeedsPremium(Premium.extraFrames);
    }
    if (d.day > today) return const Rejected('まだ来ていない日には貼れません');
    if (!unlocked(Premium.multiplePerDay)) {
      final occupied = await repo.occupiedDays();
      if (occupied.contains(d.day)) {
        return const NeedsPremium(Premium.multiplePerDay);
      }
    }
    return null;
  }

  Future<SaveResult> saveDraft(StampDraft d) async {
    final problem = await checkDraft(d);
    if (problem != null) return problem;
    final before = await loadMonth(d.day.year, d.day.month);
    final row = await repo.addStamp(
      day: d.day,
      imagePath: d.imagePath,
      crop: d.crop.encode(),
      shape: d.shape.name,
      frameId: d.frameId,
      postmarkDate: d.effectivePostmarkDate,
      postmarkPlace: d.postmarkPlace.trim(),
      postmarkNote: d.postmarkNote.trim(),
      postmarkSeed: d.seed,
      defaultSheetTitle: settings.sheetTitle,
      now: clock(),
    );
    await settings.setLastFrameId(d.frameId);
    await settings.setLastShape(d.shape);
    final completed = await _afterSave(before);
    return Saved(row, completedMonth: completed);
  }

  /// 保存のあと：シートの完成、評価依頼、ウィジェット。
  Future<bool> _afterSave(MonthData before) async {
    final after = await loadMonth(before.year, before.month);
    var completed = false;
    if (!before.complete && after.complete && after.sheet != null) {
      await repo.markCompleted(after.sheet!.id, clock());
      completed = true;
    }
    final count = settings.savedCount + 1;
    await settings.setSavedCount(count);
    // 評価依頼：1枚目・30枚目の保存直後と、月のシートが初めて完成した直後（設計書）。
    if (count == 1 || count == 30 || completed) await _maybeAskReview();
    await refreshWidget();
    _changed();
    return completed;
  }

  Future<void> _maybeAskReview() async {
    final now = clock();
    if (!canAskReview(settings.reviewPrompts, now)) return;
    await settings.addReviewPrompt(now);
    await services.review.request();
  }

  /// 写真をまとめて選び、撮影日で振り分けて貼る。すでに切手がある日は飛ばす。
  Future<BulkResult> bulkImport(List<PickedPhoto> photos) async {
    final metas = [for (final ph in photos) await readPhotoMeta(ph.bytes)];
    final occupied = await repo.occupiedDays();
    final plan = assignPhotosToDays(
      captureDates: [for (final m in metas) m.taken],
      occupied: occupied,
      today: today,
      fallback: today,
      allowMultiple: unlocked(Premium.multiplePerDay),
    );
    var saved = 0, skipped = 0;
    final frame = frameById(settings.lastFrameId);
    final frameId = frame.premium && !unlocked(Premium.extraFrames)
        ? defaultFrameId
        : frame.id;
    for (final a in plan) {
      if (a.skipped) {
        skipped++;
        continue;
      }
      final imported = await photoStore.importPhoto(photos[a.photoIndex].bytes);
      final meta = metas[a.photoIndex];
      final place = await resolvePlace(meta) ?? '';
      final shape = settings.lastShape;
      final before = await loadMonth(a.day.year, a.day.month);
      await repo.addStamp(
        day: a.day,
        imagePath: imported.path,
        crop: CropRect.centered(
          imported.width.toDouble(),
          imported.height.toDouble(),
          shape.aspect,
        ).encode(),
        shape: shape.name,
        frameId: frameId,
        postmarkDate: a.day,
        postmarkPlace: place,
        postmarkNote: '',
        postmarkSeed: newPostmarkSeed(clock()) ^ (a.photoIndex * 7919),
        defaultSheetTitle: settings.sheetTitle,
        now: clock(),
      );
      saved++;
      final after = await loadMonth(a.day.year, a.day.month);
      if (!before.complete && after.complete && after.sheet != null) {
        await repo.markCompleted(after.sheet!.id, clock());
      }
    }
    if (saved > 0) {
      await settings.setSavedCount(settings.savedCount + saved);
      await refreshWidget();
      _changed();
    }
    return BulkResult(saved: saved, skipped: skipped);
  }

  // ---- 直す・消す ----

  Future<String?> updatePostmark(
    StampEntry e, {
    required Day date,
    required String place,
    required String note,
    required int seed,
  }) async {
    final pc = checkPostmarkPlace(place);
    if (!pc.ok) return pc.reason;
    final nc = checkPostmarkNote(note);
    if (!nc.ok) return nc.reason;
    await repo.updatePostmark(
      e.row.id,
      date: date,
      place: place.trim(),
      note: note.trim(),
      seed: seed,
      now: clock(),
    );
    _changed();
    return null;
  }

  Future<void> deleteStamp(StampEntry e) async {
    await repo.deleteStamp(e.row.id);
    photoLoader.evict(e.row.imagePath);
    await photoStore.delete(e.row.imagePath);
    // 埋まっていたシートから欠けたら「完」を外す。
    final d = e.day;
    final m = await loadMonth(d.year, d.month);
    if (m.sheet?.completedAt != null && !m.complete) {
      await repo.clearCompleted(m.sheet!.id);
    }
    await refreshWidget();
    _changed();
  }

  // ---- シート名 ----

  /// シート名を変える。今月のシートがあればその名前も変える。理由付きで弾くことがある。
  Future<String?> setSheetTitle(String title) async {
    final t = title.trim();
    final c = checkSheetTitle(t);
    if (!c.ok) return c.reason;
    if (t.characters > 16) return 'シート名は16文字までです';
    await settings.setSheetTitle(t);
    final sheet = await repo.monthSheet(today.year, today.month);
    if (sheet != null) await repo.renameSheet(sheet.id, t);
    _changed();
    return null;
  }

  Future<void> setFont(String id) async {
    await settings.setPostmarkFontId(id);
    _changed();
  }

  // ---- 旅の小型シート ----

  Future<List<SheetRow>> tripSheets() => repo.tripSheets();

  Future<String?> createTrip(String title, Day from, Day to) async {
    if (!unlocked(Premium.tripSheet)) return '旅の小型シートは「記念」で使えます';
    final t = title.trim();
    final c = checkSheetTitle(t);
    if (!c.ok) return c.reason;
    await repo.createTripSheet(t, from, to);
    _changed();
    return null;
  }

  Future<void> deleteTrip(SheetRow s) async {
    await repo.deleteSheet(s.id);
    _changed();
  }

  // ---- ウィジェットとリマインダー ----

  /// ホーム画面のウィジェットとリマインダーを、いまの切手に合わせて書き直す。
  /// 起動時と、切手を貼った・消したときに呼ぶ。
  Future<void> refreshWidget() async {
    await _publishWidget();
    await refreshReminders();
  }

  /// リマインダーを予約し直す。オフなら全部取り消す。すでに貼った日は予約しない。
  Future<void> refreshReminders() async {
    if (!settings.reminderOn) {
      await services.reminders.replaceAll(const []);
      return;
    }
    final plan = reminderSchedule(
      now: clock(),
      time: settings.reminderTime,
      filled: await repo.occupiedDays(),
    );
    await services.reminders.replaceAll([for (final p in plan) p.at]);
  }

  /// リマインダーをオン・オフする。オンにするときだけ通知の許可を求め、
  /// 許可されなければオフのままにして偽を返す。
  Future<bool> setReminder({required bool on, ReminderTime? time}) async {
    if (time != null) await settings.setReminderTime(time);
    if (on && !await services.reminders.requestPermission()) {
      await settings.setReminderOn(false);
      await refreshReminders();
      _changed();
      return false;
    }
    await settings.setReminderOn(on);
    await refreshReminders();
    _changed();
    return true;
  }

  Future<void> _publishWidget() async {
    final t = today;
    final tomorrow = t.addDays(1);
    final m = await loadMonth(t.year, t.month);
    final next = tomorrow.sameMonth(t)
        ? m
        : await loadMonth(tomorrow.year, tomorrow.month);
    await services.widgets.publish(
      snapshotFor(t, m.filledDays),
      snapshotFor(tomorrow, next.filledDays),
    );
  }

  // ---- 共有画像 ----

  /// 共有画像の倍率。高解像度の書き出しは「記念」。
  double get exportScale => unlocked(Premium.highResExport) ? 2 : 1;

  Future<StampVisual> visualFor(StampEntry e, {bool full = false}) async =>
      e.visual(await photoLoader.load(e.row.imagePath, full: full), fontId);

  Future<MonthSheetVisual> monthVisual(
    MonthData m, {
    bool withToday = false,
  }) async {
    final cells = <StampVisual?>[];
    for (final c in m.cells) {
      cells.add(c == null ? null : await visualFor(c));
    }
    return MonthSheetVisual(
      year: m.year,
      month: m.month,
      title: m.title,
      cells: cells,
      margin: [for (final e in m.margin) await visualFor(e)],
      completed: m.complete,
      today: withToday ? today : null,
    );
  }

  Future<File> _writePng(ui.Image image, String name) async {
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    final dir = await _shareDir();
    final f = File(p.join(dir.path, name));
    await f.writeAsBytes(Uint8List.view(data!.buffer), flush: true);
    return f;
  }

  Directory Function()? shareDirOverride;

  Future<Directory> _shareDir() async {
    final d =
        shareDirOverride?.call() ??
        Directory(p.join(Directory.systemTemp.path, 'keshiin_share'));
    await d.create(recursive: true);
    return d;
  }

  /// 切手1枚を斜めに置いた画像（1080×1350）。
  Future<File> renderTiltedShare(StampEntry e, {bool dark = false}) async {
    final v = await visualFor(e, full: true);
    final s = exportScale;
    final img = await renderToImage(
      ui.Size(1080 * s, 1350 * s),
      (c, size) => paintTiltedStamp(c, size, v, dark: dark),
    );
    return _writePng(img, 'keshiin_${e.row.date}_${e.row.id}.png');
  }

  /// 背景が透明な切手単体の PNG。
  Future<File> renderTransparent(StampEntry e) async {
    final v = await visualFor(e, full: true);
    final s = exportScale;
    final w = 1280 * s;
    final h = w * 0.78 / v.shape.aspect;
    final img = await renderToImage(
      ui.Size(w, h),
      (c, size) => paintTransparentStamp(c, size, v),
    );
    return _writePng(img, 'keshiin_${e.row.date}_${e.row.id}_clear.png');
  }

  Future<File> renderMonthShare(MonthData m) async {
    final v = await monthVisual(m);
    final s = exportScale;
    final img = await renderToImage(
      ui.Size(1080 * s, 1350 * s),
      (c, size) => paintMonthSheet(c, size, v),
    );
    return _writePng(
      img,
      'keshiin_${m.year}_${m.month.toString().padLeft(2, '0')}.png',
    );
  }

  Future<File> renderTripShare(SheetRow sheet) async {
    final from = Day.parse(sheet.dateFrom!), to = Day.parse(sheet.dateTo!);
    final stamps = await loadRange(from, to);
    final v = TripSheetVisual(
      title: sheet.title,
      from: from,
      to: to,
      stamps: [for (final e in stamps) await visualFor(e)],
    );
    final s = exportScale;
    final img = await renderToImage(
      ui.Size(1080 * s, 1350 * s),
      (c, size) => paintTripSheet(c, size, v),
    );
    return _writePng(img, 'keshiin_trip_${sheet.id}.png');
  }

  Future<File?> renderYearPoster(int year) async {
    if (!unlocked(Premium.yearPoster)) return null;
    final months = <MonthSheetVisual?>[];
    for (var m = 1; m <= 12; m++) {
      final data = await loadMonth(year, m);
      months.add(data.all.isEmpty ? null : await monthVisual(data));
    }
    final s = exportScale;
    final img = await renderToImage(
      ui.Size(1080 * s, 1350 * s),
      (c, size) => paintYearPoster(c, size, year, months),
    );
    return _writePng(img, 'keshiin_$year.png');
  }

  Future<void> share(File f) => services.sharer.shareFiles([f.path]);

  // ---- 書き出し ----

  Future<List<String>> exportZip() async {
    final ex = exporter;
    if (ex == null) return const [];
    final dir = await _shareDir();
    final files = await ex.exportByYear(
      Directory(p.join(dir.path, 'export')),
      now: clock(),
    );
    if (files.isNotEmpty) await services.sharer.shareFiles(files);
    return files;
  }

  @override
  void dispose() {
    purchases.removeListener(notifyListeners);
    super.dispose();
  }
}

extension on String {
  int get characters => runes.length;
}

/// ImageStore を使った本番の組み立て。
PhotoStore filePhotoStore(Directory docs) => FilePhotoStore(ImageStore(docs));
