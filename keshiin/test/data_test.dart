import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:keshiin/app/app_state.dart';
import 'package:keshiin/core/crop.dart';
import 'package:keshiin/core/day_slots.dart';
import 'package:keshiin/core/photo_meta.dart';
import 'package:keshiin/data/export_service.dart';
import 'package:keshiin/data/image_store.dart';
import 'package:keshiin/data/settings.dart';
import 'package:keshiin/platform/services.dart';

import 'fakes.dart';

/// 撮影日と GPS を書き込んだ小さな JPEG。
Uint8List jpegWithExif({String? date, double? lat, double? lng}) {
  final image = img.Image(width: 16, height: 12);
  img.fill(image, color: img.ColorRgb8(200, 120, 80));
  if (date != null) {
    image.exif.exifIfd['DateTimeOriginal'] = img.IfdValueAscii(date);
  }
  if (lat != null && lng != null) {
    // 度を1つの有理数で書く（度・分・秒の3つに分けないカメラもある）。
    img.IfdValueRational deg(double v) =>
        img.IfdValueRational((v.abs() * 1000000).round(), 1000000);

    image.exif.gpsIfd['GPSLatitudeRef'] = img.IfdValueAscii(
      lat >= 0 ? 'N' : 'S',
    );
    image.exif.gpsIfd['GPSLatitude'] = deg(lat);
    image.exif.gpsIfd['GPSLongitudeRef'] = img.IfdValueAscii(
      lng >= 0 ? 'E' : 'W',
    );
    image.exif.gpsIfd['GPSLongitude'] = deg(lng);
  }
  return img.encodeJpg(image);
}

void main() {
  group('写真の撮影日と GPS', () {
    test('EXIF の日付の書式', () {
      expect(
        parseExifDate('2026:11:04 09:12:33'),
        DateTime(2026, 11, 4, 9, 12, 33),
      );
      expect(
        parseExifDate('2026-11-04T09:12:33'),
        DateTime(2026, 11, 4, 9, 12, 33),
      );
      expect(parseExifDate('0000:00:00 00:00:00'), isNull);
      expect(parseExifDate(null), isNull);
    });

    test('JPEG から撮影日と位置を読む', () async {
      final meta = await readPhotoMeta(
        jpegWithExif(date: '2026:10:21 15:00:00', lat: 35.3192, lng: 139.5467),
      );
      expect(meta.taken, DateTime(2026, 10, 21, 15));
      expect(meta.lat, closeTo(35.3192, 1e-3));
      expect(meta.lng, closeTo(139.5467, 1e-3));
    });

    test('南半球・西半球は負', () async {
      final meta = await readPhotoMeta(
        jpegWithExif(date: '2026:01:02 03:04:05', lat: -33.86, lng: -70.65),
      );
      expect(meta.lat, lessThan(0));
      expect(meta.lng, lessThan(0));
    });

    test('EXIF が無い・壊れていても失敗にしない', () async {
      expect((await readPhotoMeta(jpegWithExif())).taken, isNull);
      expect(
        (await readPhotoMeta(Uint8List.fromList([1, 2, 3]))).hasLocation,
        isFalse,
      );
    });
  });

  group('写真の縮小', () {
    test('長辺2400px を超えたら縮小、それ以下はそのまま', () {
      final big = img.Image(width: 4000, height: 3000);
      final r = resizeLongSide(big, ImageStore.maxLongSide);
      expect((r.width, r.height), (2400, 1800));
      final tall = resizeLongSide(img.Image(width: 1000, height: 3000), 2400);
      expect((tall.width, tall.height), (800, 2400));
      final small = img.Image(width: 800, height: 600);
      expect(identical(resizeLongSide(small, 2400), small), isTrue);
    });

    test('縮小版のパス', () {
      expect(ImageStore.thumbOf('photos/p1.jpg'), 'photos/p1_t.jpg');
    });
  });

  group('トリミング', () {
    test('中央に置いた最大の矩形', () {
      final c = CropRect.centered(1200, 900, 1);
      expect(c.width * 1200, closeTo(900, 1e-6));
      expect(c.height, 1);
      expect(c.left, closeTo(0.125, 1e-9));
      final p = CropRect.centered(1200, 900, 3 / 4);
      expect(p.width * 1200 / (p.height * 900), closeTo(0.75, 1e-9));
    });

    test('文字列との往復とはみ出しの補正', () {
      const c = CropRect(0.1, 0.2, 0.5, 0.6);
      expect(CropRect.parse(c.encode()), c);
      expect(CropRect.parse('0.9,0.9,0.5,0.5').left, closeTo(0.5, 1e-9));
      expect(CropRect.parse('こわれた'), CropRect.full);
    });
  });

  group('DB（stamp・sheet・place_history）', () {
    test('切手を貼ると月のシートと場所の履歴ができる', () async {
      final h = await Harness.create();
      addTearDown(h.close);
      final row = await h.repo.addStamp(
        day: const Day(2026, 11, 2),
        imagePath: 'photos/a.jpg',
        crop: CropRect.full.encode(),
        shape: 'square',
        frameId: 'shiro',
        postmarkDate: const Day(2026, 11, 2),
        postmarkPlace: '鎌倉市',
        postmarkNote: '',
        postmarkSeed: 5,
        defaultSheetTitle: '2026 日常',
      );
      final sheet = await h.repo.monthSheet(2026, 11);
      expect(sheet!.title, '2026 日常');
      expect(row.sheetId, sheet.id);
      expect(await h.repo.recentPlaces(), ['鎌倉市']);
      expect(await h.repo.serialInMonth(row), 1);
      expect(await h.repo.monthsWithStamps(), [(year: 2026, month: 11)]);
    });

    test('同じ日の2枚目は欄外、31日も欄外', () async {
      final h = await Harness.create(
        now: DateTime(2026, 12, 31),
        premium: true,
      );
      addTearDown(h.close);
      Future<void> add(int day) => h.repo.addStamp(
        day: Day(2026, 12, day),
        imagePath: 'photos/$day.jpg',
        crop: CropRect.full.encode(),
        shape: 'square',
        frameId: 'shiro',
        postmarkDate: Day(2026, 12, day),
        postmarkPlace: '',
        postmarkNote: '',
        postmarkSeed: day,
      );
      await add(1);
      await add(1);
      await add(31);
      final m = await h.app.loadMonth(2026, 12);
      expect(m.cells[0], isNotNull);
      expect(m.margin.length, 2);
      expect(m.count, (filled: 1, total: 30));
    });

    test('ZIP 用の JSON は設計書の列名で書く', () async {
      final h = await Harness.create();
      addTearDown(h.close);
      await h.repo.addStamp(
        day: const Day(2026, 11, 2),
        imagePath: 'photos/a.jpg',
        crop: CropRect.full.encode(),
        shape: 'portrait',
        frameId: 'kinari',
        postmarkDate: const Day(2026, 11, 2),
        postmarkPlace: '家',
        postmarkNote: 'ひとこと',
        postmarkSeed: 5,
      );
      final json =
          jsonDecode(
                buildExportJson(
                  stamps: await h.repo.allStamps(),
                  sheets: await h.repo.allSheets(),
                  places: await h.repo.allPlaces(),
                  exportedAt: '2026-11-04T00:00:00',
                  year: 2026,
                ),
              )
              as Map<String, dynamic>;
      final s = (json['stamp'] as List).single as Map<String, dynamic>;
      expect(
        s.keys,
        containsAll([
          'id',
          'date',
          'image_path',
          'crop',
          'frame_id',
          'postmark_date',
          'postmark_place',
          'postmark_note',
          'postmark_seed',
          'sheet_id',
          'created_at',
        ]),
      );
      expect((json['sheet'] as List).single['kind'], 'month');
      expect((json['place_history'] as List).single['place'], '家');
      expect(json['year'], 2026);
    });
  });

  group('アプリの状態', () {
    test('写真の撮影日と GPS から、日付と市区町村が自動で入る', () async {
      final h = await Harness.create();
      addTearDown(h.close);
      final d = await h.app.startDraft(
        PickedPhoto(
          jpegWithExif(
            date: '2026:10:21 15:00:00',
            lat: 35.3192,
            lng: 139.5467,
          ),
        ),
        target: const Day(2026, 11, 4),
      );
      expect(d.day, const Day(2026, 10, 21));
      expect(d.dayFromPhoto, isTrue);
      expect(d.postmarkPlace, '鎌倉市');
      expect(h.geocoder.calls, 0); // 国内は通信しない
    });

    test('海外の写真だけ OS の逆ジオコーディングに聞く。答えが無ければ空', () async {
      final h = await Harness.create();
      addTearDown(h.close);
      h.geocoder.answer = 'パリ';
      final d = await h.app.startDraft(
        PickedPhoto(
          jpegWithExif(date: '2026:08:01 10:00:00', lat: 48.8566, lng: 2.3522),
        ),
      );
      expect(d.postmarkPlace, 'パリ');
      expect(h.geocoder.calls, 1);
      h.geocoder.answer = null;
      final d2 = await h.app.startDraft(
        PickedPhoto(
          jpegWithExif(date: '2026:08:01 10:00:00', lat: 48.8566, lng: 2.3522),
        ),
      );
      expect(d2.postmarkPlace, '');
    });

    test('撮影日が無ければ、タップしたマスの日', () async {
      final h = await Harness.create();
      addTearDown(h.close);
      final d = await h.app.startDraft(
        PickedPhoto(jpegWithExif()),
        target: const Day(2026, 11, 2),
      );
      expect(d.day, const Day(2026, 11, 2));
      expect(d.dayFromPhoto, isFalse);
    });

    test('無料では1日1枚。有料フレームは保存時に案内', () async {
      final h = await Harness.create();
      addTearDown(h.close);
      final d = await h.app.startDraft(PickedPhoto(jpegWithExif()));
      expect(await h.app.saveDraft(d), isA<Saved>());
      final d2 = await h.app.startDraft(PickedPhoto(jpegWithExif()));
      final r = await h.app.saveDraft(d2);
      expect(r, isA<NeedsPremium>());
      d2.day = const Day(2026, 11, 3);
      d2.frameId = 'sankaku';
      expect(await h.app.saveDraft(d2), isA<NeedsPremium>());
      d2.frameId = 'kinari';
      expect(await h.app.saveDraft(d2), isA<Saved>());
      expect(h.widgets.published.last.$1.filled, 2);
      expect(h.review.calls, 1); // 1枚目の保存直後だけ
    });

    test('消印の場所に「○○郵便局」は保存できない', () async {
      final h = await Harness.create();
      addTearDown(h.close);
      final d = await h.app.startDraft(PickedPhoto(jpegWithExif()));
      d.postmarkPlace = '中央郵便局';
      expect(await h.app.saveDraft(d), isA<Rejected>());
    });

    test('月が埋まると「完」、1枚消すと外れる', () async {
      final h = await Harness.create(now: DateTime(2026, 11, 30, 20));
      addTearDown(h.close);
      Saved? last;
      for (var day = 1; day <= 30; day++) {
        final d = await h.app.startDraft(
          PickedPhoto(jpegWithExif()),
          target: Day(2026, 11, day),
        );
        last = await h.app.saveDraft(d) as Saved;
      }
      expect(last!.completedMonth, isTrue);
      final m = await h.app.loadMonth(2026, 11);
      expect(m.sheet!.completedAt, isNotNull);
      await h.app.deleteStamp(m.cells[10]!);
      expect((await h.app.loadMonth(2026, 11)).sheet!.completedAt, isNull);
    });

    test('ウィジェットには今日と明日の分を書く（月をまたぐときは翌月の分）', () async {
      final h = await Harness.create(now: DateTime(2026, 11, 30, 23, 50));
      addTearDown(h.close);
      await h.app.refreshWidget();
      final (today, tomorrow) = h.widgets.published.last;
      expect(today.date, const Day(2026, 11, 30));
      expect(tomorrow.date, const Day(2026, 12, 1));
      expect(tomorrow.countLabel, '0／30');
      expect(tomorrow.todayEmpty, isTrue);
    });

    test('評価依頼は365日に3回まで', () {
      final now = DateTime(2026, 11, 4);
      expect(canAskReview([], now), isTrue);
      expect(canAskReview([now, now, now], now), isFalse);
      expect(canAskReview([DateTime(2025, 1, 1), now, now], now), isTrue);
    });
  });
}
