// ストアのスクリーンショット用に、アプリの画面を PNG で撮る（440×956 を3倍の 1320×2868 で）。
//
//   flutter test store/src/shots_test.dart --dart-define=OUT=<保存先> --dart-define=FONT=<日本語のフォント>
//
// 写真の代わりに store/src/photos/ の見本の絵を使う（node store/src/render.js . で作る）。
// 通常の `flutter test`（test/ の中だけを走らせる）では実行されない。
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:keshiin/app/app_state.dart';
import 'package:keshiin/app/photo_io.dart';
import 'package:keshiin/core/crop.dart';
import 'package:keshiin/core/day_slots.dart';
import 'package:keshiin/data/repository.dart';
import 'package:keshiin/data/settings.dart';
import 'package:keshiin/main.dart';
import 'package:keshiin/monetize/purchase_service.dart';
import 'package:keshiin/platform/services.dart';
import 'package:keshiin/ui/screens/month_sheet_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../test/data_test.dart' show jpegWithExif;
import '../../test/fakes.dart';

const outDir = String.fromEnvironment('OUT', defaultValue: 'build/shots');
const fontPath = String.fromEnvironment(
  'FONT',
  defaultValue: '/usr/share/fonts/opentype/ipafont-gothic/ipag.ttf',
);

const scenes = [
  'umi', 'yama', 'machi', 'cafe', 'hana', 'densha', //
  'momiji', 'gohan', 'neko', 'yuki', 'koen', 'todai',
];
const places = [
  '鎌倉市', '渋谷区', '京都市東山区', '家', '金沢市', '札幌市中央区', //
  '那覇市', '職場', '松本市', '尾道市', '函館市', '横浜市中区',
];
const notes = ['', '晴れ', '', 'おやつ', '', '', '雨上がり', '', 'ねこ', '', '', '旅'];

/// 見本の絵を返す。パスの番号で絵を決める。
class ScenePhotoLoader implements PhotoLoader {
  ScenePhotoLoader(this.images);
  final Map<String, ui.Image> images;

  @override
  Future<ui.Image?> load(String relative, {bool full = false}) async {
    final m = RegExp(r'(\d+)').firstMatch(relative);
    final n = m == null ? 0 : int.parse(m[1]!);
    if (relative.contains('fake')) return images['umi'];
    return images[scenes[n % scenes.length]];
  }

  @override
  void evict(String relative) {}
}

Future<void> _loadFonts() async {
  final jp = File(fontPath).readAsBytesSync();
  for (final fam in ['Roboto', 'Hiragino Sans', 'Noto Sans CJK JP']) {
    await (FontLoader(
      fam,
    )..addFont(Future.value(ByteData.sublistView(jp)))).load();
  }
  final flutterRoot =
      Platform.environment['FLUTTER_ROOT'] ??
      File(Platform.resolvedExecutable).parent.parent.parent.parent.parent.path;
  final icons = File(
    '$flutterRoot/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
  );
  await (FontLoader('MaterialIcons')
        ..addFont(Future.value(ByteData.sublistView(icons.readAsBytesSync()))))
      .load();
}

Future<Map<String, ui.Image>> _loadScenes() async {
  final out = <String, ui.Image>{};
  for (final s in scenes) {
    final bytes = File('store/src/photos/$s.png').readAsBytesSync();
    final frame = await (await ui.instantiateImageCodec(bytes)).getNextFrame();
    out[s] = frame.image;
  }
  return out;
}

Future<void> _seed(StampRepository repo) async {
  var i = 0;
  Future<void> add(
    Day d, {
    String frame = 'shiro',
    String shape = 'square',
  }) async {
    final n = i++;
    await repo.addStamp(
      day: d,
      imagePath: 'photos/p$n.jpg',
      crop: CropRect.centered(1200, 900, shape == 'square' ? 1 : 0.75).encode(),
      shape: shape,
      frameId: frame,
      postmarkDate: d,
      postmarkPlace: places[n % places.length],
      postmarkNote: notes[n % notes.length],
      postmarkSeed: 1000 + n * 7919,
      defaultSheetTitle: '2026 日常',
      now: DateTime(d.year, d.month, d.day, 21),
    );
  }

  const frames = ['shiro', 'shiro', 'kinari', 'shiro', 'sumi', 'kinari'];
  for (var d = 1; d <= 31; d++) {
    await add(Day(2026, 10, d), frame: frames[d % frames.length]);
  }
  for (var d = 1; d <= 23; d++) {
    if (d == 6 || d == 14 || d == 19) continue; // 空欄も見せる
    await add(Day(2026, 11, d), frame: frames[d % frames.length]);
  }
  final oct = await repo.monthSheet(2026, 10);
  await repo.markCompleted(oct!.id, DateTime(2026, 10, 30, 21));
}

void main() {
  testWidgets('ストアのスクリーンショット', (tester) async {
    late Map<String, ui.Image> images;
    await tester.runAsync(() async {
      await _loadFonts();
      images = await _loadScenes();
    });
    debugDisableShadows = false;

    // ignore: invalid_use_of_visible_for_testing_member
    SharedPreferences.setMockInitialValues({
      'keshiin.noticeSeen': true,
      'keshiin.sheetTitle': '2026 日常',
    });
    final sp = await SharedPreferences.getInstance();
    final repo = StampRepository(memoryDb());
    final photos = FakePhotoSource()
      ..next = [
        PickedPhoto(
          jpegWithExif(
            date: '2026:11:24 16:40:00',
            lat: 35.3192,
            lng: 139.5467,
          ),
        ),
      ];
    final app = AppState(
      repo: repo,
      photoStore: FakePhotoStore(),
      photoLoader: ScenePhotoLoader(images),
      settings: AppSettings(sp),
      purchases: ProvisionalPurchaseService(sp),
      services: PlatformServices(
        photos: photos,
        geocoder: FakeGeocoder(),
        sharer: FakeSharer(),
        widgets: FakeWidgetBridge(),
        review: FakeReview(),
        reminders: FakeReminders(),
      ),
      places: loadMunicipalities(),
      clock: () => DateTime(2026, 11, 24, 10),
    );
    await _seed(repo);

    tester.view.physicalSize = const Size(1320, 2868);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    final boundary = GlobalKey();
    await tester.pumpWidget(
      RepaintBoundary(
        key: boundary,
        child: KeshiinApp(app: app, animate: false),
      ),
    );
    await tester.pumpAndSettle();
    Directory(outDir).createSync(recursive: true);

    Future<void> snap(String name) async {
      await tester.pumpAndSettle();
      await tester.runAsync(() async {
        final ro =
            boundary.currentContext!.findRenderObject()!
                as RenderRepaintBoundary;
        final img = await ro.toImage(pixelRatio: 3);
        final data = await img.toByteData(format: ui.ImageByteFormat.png);
        File('$outDir/$name.png').writeAsBytesSync(data!.buffer.asUint8List());
      });
      // ignore: avoid_print
      print('wrote $outDir/$name.png');
    }

    NavigatorState nav() =>
        tester.state<NavigatorState>(find.byType(Navigator).first);
    Future<void> back() async {
      nav().pop();
      await tester.pumpAndSettle();
    }

    Future<void> tap(Finder f) async {
      await tester.ensureVisible(f);
      await tester.pumpAndSettle();
      await tester.tap(f);
      await tester.pumpAndSettle();
    }

    // 1. 今月のシート
    await snap('sheet');

    // 2. 切手を作る（フレームの選択）
    await tap(find.byKey(const Key('cell-2026-11-24')));
    await tap(find.text('フレーム'));
    await snap('create');
    await back();

    // 3. 切手の詳細（消印に撮影日と場所）
    await tester.drag(find.byType(Scrollable).first, const Offset(0, 600));
    await tester.pumpAndSettle();
    await tap(find.byKey(const Key('stamp-2026-11-02')));
    await snap('detail');

    // 5. 共有の選択肢
    await tap(find.byKey(const Key('share-stamp')));
    await snap('share');
    await tester.tapAt(const Offset(20, 40));
    await tester.pumpAndSettle();
    await back();

    // 4. 完成した月のシート
    nav().push(
      MaterialPageRoute<void>(
        builder: (_) => const MonthSheetScreen(year: 2026, month: 10),
      ),
    );
    await tester.pumpAndSettle();
    await snap('month');

    debugDisableShadows = true;
    await repo.db.close();
  });
}
