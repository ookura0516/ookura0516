// ストア素材（アイコン・スプラッシュ・フィーチャーグラフィック・スクリーンショット）を描く。
//
//   sh store/src/fetch_fonts.sh
//   flutter test store/src/render_store_test.dart --dart-define=STORE=1
//
// 画面は実際に組み立てて撮り、上に見出しを乗せる。--dart-define=STORE=1 がなければ何もしない。
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nanakorobi/app/app.dart';
import 'package:nanakorobi/app/router.dart';
import 'package:nanakorobi/core/local_date.dart';
import 'package:nanakorobi/data/database.dart';
import 'package:nanakorobi/data/repository.dart';
import 'package:nanakorobi/model/models.dart';
import 'package:nanakorobi/state/app_deps.dart';
import 'package:nanakorobi/state/create_daruma.dart';
import 'package:nanakorobi/ui/daruma/daruma_painter.dart';

const enabled = String.fromEnvironment('STORE') == '1';

/// 1場面だけ作り直すとき：--dart-define=STORE_ONLY=02_eye
const only = String.fromEnvironment('STORE_ONLY');
const uiFont = 'NanakorobiUI';
const brush = 'NanakorobiBrush';
const paper = Color(0xFFF7F1E6);
const ink = Color(0xFF2A2320);
const inkDim = Color(0xFF7A6E66);
const vermilion = Color(0xFFC73E2E);
const gold = Color(0xFFC9A227);

bool hasUiFont = false;
String? get textFont => hasUiFont ? uiFont : null;

void main() {
  if (!enabled) {
    test('ストア素材は --dart-define=STORE=1 のときだけ作る', () {});
    return;
  }
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    Future<void> load(String family, List<String> paths) async {
      final loader = FontLoader(family);
      for (final p in paths) {
        loader.addFont(Future.value(ByteData.sublistView(File(p).readAsBytesSync())));
      }
      await loader.load();
    }

    await load(brush, ['assets/fonts/YujiSyuku-Regular.ttf']);
    const reg = 'store/src/fonts/NotoSansJP-Regular.ttf';
    const bold = 'store/src/fonts/NotoSansJP-Bold.ttf';
    hasUiFont = File(reg).existsSync() && File(bold).existsSync();
    if (hasUiFont) await load(uiFont, [reg, bold]);
    // Material のアイコン（Flutter SDK のキャッシュから）
    final root = Platform.environment['FLUTTER_ROOT'] ?? '/opt/flutter';
    final icons = File('$root/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf');
    if (icons.existsSync()) await load('MaterialIcons', [icons.path]);
  });

  test('アイコン・スプラッシュ・フィーチャーグラフィック', () async {
    const look = DarumaLook(
      darumaId: 'icon',
      text: '',
      colorId: 0,
      seed: 20261104,
      strokes: 7,
      goldLines: 3,
      firstEye: EyeSide.left,
      eyes: EyeState.one,
      sizeRank: 1,
      fallen: false,
      status: DarumaStatus.active,
    );
    void daruma(Canvas c, Rect r, {DarumaLook l = look}) {
      c.save();
      c.translate(r.left, r.top);
      DarumaPainter(look: l, brushFontFamily: brush).paint(c, r.size);
      c.restore();
    }

    // アプリのアイコン（不透明）
    await _png('assets/icon/icon.png', const Size(1024, 1024), (c) {
      c.drawRect(const Rect.fromLTWH(0, 0, 1024, 1024), Paint()..color = paper);
      c.drawCircle(const Offset(512, 540), 430, Paint()..color = vermilion.withValues(alpha: 0.10));
      daruma(c, const Rect.fromLTWH(192, 100, 640, 800));
    });
    // アダプティブアイコンの前景（中央 66% に収める）
    await _png('assets/icon/icon_foreground.png', const Size(1024, 1024), (c) {
      daruma(c, const Rect.fromLTWH(252, 180, 520, 650));
    });
    // スプラッシュ
    await _png('assets/splash/splash_icon.png', const Size(384, 384), (c) {
      daruma(c, const Rect.fromLTWH(52, 12, 280, 350));
    });
    // Google Play のアイコン
    await _png('store/icon_512.png', const Size(512, 512), (c) {
      c.drawRect(const Rect.fromLTWH(0, 0, 512, 512), Paint()..color = paper);
      c.drawCircle(const Offset(256, 270), 215, Paint()..color = vermilion.withValues(alpha: 0.10));
      daruma(c, const Rect.fromLTWH(96, 50, 320, 400));
    });
    // フィーチャーグラフィック
    await _png('store/feature_graphic.png', const Size(1024, 500), (c) {
      c.drawRect(const Rect.fromLTWH(0, 0, 1024, 500), Paint()..color = paper);
      c.drawCircle(const Offset(210, 260), 210, Paint()..color = vermilion.withValues(alpha: 0.10));
      daruma(
        c,
        const Rect.fromLTWH(70, 62, 300, 375),
        l: look.copyWith(text: '合格', strokes: 12, goldLines: 2),
      );
      var y = _text(c, 'ナナコロビ', const Offset(410, 120), 92, ink, FontWeight.w700, maxWidth: 600);
      y = _text(c, 'だるまに目を入れて、目標を始める', Offset(410, y + 6), 36, ink, FontWeight.w700, maxWidth: 600);
      _text(c, '毎日の一歩で1筆ずつ。転んでも、減らない。', Offset(410, y + 8), 28, inkDim, FontWeight.w400, maxWidth: 600);
    });
  });

  // 場面ごとに1つのテスト。撮影（runAsync）のあとに pump を続けると止まるので、撮影をテストの最後にする。
  const today = LocalDate(2026, 11, 4);
  for (final platform in const [_Platform('ios', 1320, 2868), _Platform('android', 1080, 1920)]) {
    for (final scene in _scenes(today)) {
      if (only.isNotEmpty && scene.file != only) continue;
      testWidgets('${platform.name}/${scene.file}', (tester) async {
        final now = DateTime(2026, 11, 4, 9, 30);
        final presets = File('assets/presets/exam_dates.json').readAsStringSync();
        final db = AppDatabase.memory();
        final repo = DarumaRepository(db);
        for (final b in scene.bundles) {
          await repo.insertDaruma(b.daruma, milestones: b.milestones);
          for (final c in b.checkins) {
            await repo.upsertCheckin(c);
          }
          for (final r in b.recoveries) {
            await repo.insertRecovery(r);
          }
        }
        final deps = AppDeps.fake(
          db: db,
          now: () => now,
          initialSettings: const AppSettings(onboardingDone: true),
          hasPlus: true,
          bundledPresets: presets,
          uiFontFamily: textFont,
        );
        tester.view.devicePixelRatio = 3;
        tester.view.physicalSize = Size(platform.w.toDouble(), platform.h.toDouble());
        addTearDown(tester.view.reset);
        final key = GlobalKey();
        await tester.pumpWidget(
          ProviderScope(
            overrides: [appDepsProvider.overrideWithValue(deps)],
            child: RepaintBoundary(key: key, child: const NanakorobiApp()),
          ),
        );
        await _settle(tester);
        final container = ProviderScope.containerOf(tester.element(find.byType(NanakorobiApp)));
        scene.setup?.call(container);
        if (scene.route != Routes.home) {
          container.read(routerProvider).go(scene.route);
          await _settle(tester);
        }
        await _settle(tester);

        // 画像の生成はすべてテストの疑似時間の外（runAsync）で行い、これをテストの最後にする。
        final boundary = key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
        final out = File('store/screens/${platform.name}/${scene.file}.png');
        await tester.runAsync(() async {
          final screen = await boundary.toImage(pixelRatio: 3);
          final bytes = await _composeShot(
            screen: screen,
            w: platform.w,
            h: platform.h,
            headline: scene.headline,
            sub: scene.sub,
          );
          out.parent.createSync(recursive: true);
          out.writeAsBytesSync(bytes);
          screen.dispose();
        });
        _log('wrote ${out.path}');
      });
    }
  }
}

void _log(String s) {
  // ignore: avoid_print
  print(s);
}

/// 止まらない演出があっても 20 秒（疑似時間）で諦めて、その場面を撮る。
Future<void> _settle(WidgetTester tester) async {
  try {
    await tester.pumpAndSettle(const Duration(milliseconds: 100), EnginePhase.sendSemanticsUpdate, const Duration(seconds: 20));
  } on FlutterError catch (e) {
    _log('settle gave up: ${e.message.split('\n').first}');
  }
}

class _Platform {
  const _Platform(this.name, this.w, this.h);

  final String name;
  final int w;
  final int h;
}

class _Scene {
  const _Scene({
    required this.file,
    required this.route,
    required this.headline,
    required this.sub,
    required this.bundles,
    this.setup,
  });

  final String file;
  final String route;
  final String headline;
  final String sub;
  final List<DarumaBundle> bundles;
  final void Function(ProviderContainer container)? setup;
}

Daruma _daruma({
  required String id,
  required String name,
  required int colorId,
  required LocalDate openedOn,
  DarumaStatus status = DarumaStatus.active,
  LocalDate? deadline,
  String? deadlineName,
  String? dailyAction,
  DateTime? completedAt,
  DateTime? retiredAt,
  int sizeRank = 1,
  int seed = 20261104,
}) =>
    Daruma(
      id: id,
      name: name,
      colorId: colorId,
      eyeSide: EyeSide.left,
      createdAt: openedOn.toDateTime().add(const Duration(hours: 9)),
      openedOn: openedOn,
      deadline: deadline,
      deadlineName: deadlineName,
      dailyAction: dailyAction,
      status: status,
      completedAt: completedAt,
      retiredAt: retiredAt,
      sizeRank: sizeRank,
      seed: seed,
    );

List<Checkin> _steps(String darumaId, Iterable<LocalDate> days, {Map<LocalDate, String> memos = const {}}) => [
      for (final d in days)
        Checkin(
          id: '$darumaId-${d.toIso()}',
          darumaId: darumaId,
          date: d,
          kind: CheckinKind.step,
          memo: memos[d],
          createdAt: d.toDateTime().add(const Duration(hours: 20)),
        ),
    ];

List<LocalDate> _range(LocalDate from, int days) => [for (var i = 0; i < days; i++) from.addDays(i)];

List<_Scene> _scenes(LocalDate today) {
  // 見本：開眼から12日、10筆、起き上がり2回、共通テストまで73日
  final opened = today.addDays(-12);
  final mainSteps = [
    ...[0, 1, 2, 3].map(opened.addDays),
    ...[6, 7].map(opened.addDays),
    ...[9, 10, 11].map(opened.addDays),
  ];
  final main = DarumaBundle(
    daruma: _daruma(
      id: 'main',
      name: '合格',
      colorId: 0,
      openedOn: opened,
      deadline: const LocalDate(2027, 1, 16),
      deadlineName: '共通テスト',
      dailyAction: '英単語20個',
    ),
    checkins: _steps('main', mainSteps, memos: {opened.addDays(11): '過去問を1年分'}),
    recoveries: [
      Recovery(id: 'r1', darumaId: 'main', fellAfter: opened.addDays(3), roseOn: opened.addDays(6)),
      Recovery(id: 'r2', darumaId: 'main', fellAfter: opened.addDays(7), roseOn: opened.addDays(9)),
    ],
    milestones: [
      Milestone(id: 'm1', darumaId: 'main', name: '模試', date: today.addDays(18)),
    ],
  );
  // 転倒中：昨日が空白
  final fallenOpened = today.addDays(-9);
  final fallen = DarumaBundle(
    daruma: _daruma(id: 'fallen', name: '走る', colorId: 2, openedOn: fallenOpened, dailyAction: '3km'),
    checkins: _steps('fallen', _range(fallenOpened, 8)),
  );
  final completed = DarumaBundle(
    daruma: _daruma(
      id: 'done',
      name: '必勝',
      colorId: 1,
      openedOn: const LocalDate(2026, 4, 1),
      status: DarumaStatus.completed,
      completedAt: DateTime(2026, 9, 15, 12),
      seed: 7,
    ),
    checkins: _steps('done', _range(const LocalDate(2026, 4, 1), 60)),
    recoveries: const [
      Recovery(id: 'd1', darumaId: 'done', fellAfter: LocalDate(2026, 5, 3), roseOn: LocalDate(2026, 5, 6)),
    ],
  );
  final retired = DarumaBundle(
    daruma: _daruma(
      id: 'retired',
      name: '英語',
      colorId: 5,
      openedOn: const LocalDate(2026, 1, 10),
      status: DarumaStatus.retired,
      retiredAt: DateTime(2026, 3, 1, 12),
      seed: 99,
    ),
    checkins: _steps('retired', _range(const LocalDate(2026, 1, 10), 20)),
  );
  final bigger = DarumaBundle(
    daruma: _daruma(
      id: 'bigger',
      name: '英語',
      colorId: 5,
      openedOn: const LocalDate(2026, 6, 1),
      sizeRank: 2,
      seed: 100,
      dailyAction: '音読10分',
    ),
    checkins: _steps('bigger', _range(const LocalDate(2026, 6, 1), 30)),
  );

  return [
    _Scene(
      file: '01_home',
      route: Routes.home,
      headline: 'だるまに目を入れて、目標を始める',
      sub: '毎日の一歩で、1筆ずつ模様が入る',
      bundles: [main],
    ),
    _Scene(
      file: '02_eye',
      route: Routes.eye,
      headline: '指でなぞって、開眼',
      sub: '片目を入れて、今日から始める',
      bundles: const [],
      setup: (c) {
        final form = c.read(createDarumaProvider.notifier);
        form.setName('合格');
        form.setColor(0);
      },
    ),
    _Scene(
      file: '03_fallen',
      route: Routes.home,
      headline: '転んでも、模様は減らない',
      sub: '次の記録で起き上がり、台座に金の筋が1本',
      bundles: [fallen],
    ),
    _Scene(
      file: '04_shelf',
      route: Routes.shelf,
      headline: '棚に並ぶ、だるまたち',
      sub: '満願は両目。納めても消えない',
      bundles: [main, bigger, completed, retired],
    ),
    _Scene(
      file: '05_presets',
      route: Routes.presets,
      headline: '本番の日まで、あと何日',
      sub: '共通テスト・公立高校入試・資格の日程を同梱',
      bundles: [main],
    ),
    _Scene(
      file: '06_share',
      route: Routes.shareFor(id: 'main', occasion: 'milestone'),
      headline: '節目を、1枚で共有',
      sub: '開眼から何日、起き上がり何回',
      bundles: [main],
    ),
  ];
}

Future<Uint8List> _composeShot({
  required ui.Image screen,
  required int w,
  required int h,
  required String headline,
  required String sub,
}) =>
    _bytes(Size(w.toDouble(), h.toDouble()), (c) {
      final W = w.toDouble();
      final H = h.toDouble();
      c.drawRect(Rect.fromLTWH(0, 0, W, H), Paint()..color = paper);
      c.drawCircle(Offset(W * 0.5, H * 0.62), W * 0.62, Paint()..color = vermilion.withValues(alpha: 0.06));
      var y = _text(c, headline, Offset(W / 2, H * 0.045), W * 0.054, ink, FontWeight.w700, maxWidth: W * 0.9, center: true);
      _text(c, sub, Offset(W / 2, y + W * 0.012), W * 0.034, inkDim, FontWeight.w400, maxWidth: W * 0.9, center: true);

      final sw = W * 0.82;
      final sh = sw * screen.height / screen.width;
      final rect = Rect.fromLTWH((W - sw) / 2, H * 0.15, sw, sh);
      final rr = RRect.fromRectAndRadius(rect, Radius.circular(W * 0.045));
      c.drawRRect(
        rr.shift(Offset(0, W * 0.012)),
        Paint()
          ..color = Colors.black.withValues(alpha: 0.18)
          ..maskFilter = ui.MaskFilter.blur(ui.BlurStyle.normal, W * 0.02),
      );
      c.save();
      c.clipRRect(rr);
      c.drawImageRect(
        screen,
        Rect.fromLTWH(0, 0, screen.width.toDouble(), screen.height.toDouble()),
        rect,
        Paint()..filterQuality = FilterQuality.high,
      );
      c.restore();
      c.drawRRect(
        rr,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = W * 0.006
          ..color = ink.withValues(alpha: 0.85),
      );
    });

double _text(
  Canvas c,
  String text,
  Offset at,
  double size,
  Color color,
  FontWeight weight, {
  required double maxWidth,
  bool center = false,
}) {
  final tp = TextPainter(
    text: TextSpan(
      text: text,
      style: TextStyle(fontFamily: textFont, fontSize: size, color: color, fontWeight: weight, height: 1.3),
    ),
    textAlign: center ? TextAlign.center : TextAlign.left,
    textDirection: TextDirection.ltr,
    maxLines: 2,
  )..layout(maxWidth: maxWidth);
  tp.paint(c, center ? Offset(at.dx - tp.width / 2, at.dy) : at);
  return at.dy + tp.height;
}

Future<Uint8List> _bytes(Size size, void Function(Canvas) draw) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder, Offset.zero & size);
  draw(canvas);
  final picture = recorder.endRecording();
  final image = await picture.toImage(size.width.toInt(), size.height.toInt());
  final data = await image.toByteData(format: ui.ImageByteFormat.png);
  image.dispose();
  picture.dispose();
  return data!.buffer.asUint8List();
}

Future<void> _png(String path, Size size, void Function(Canvas) draw) async {
  final bytes = await _bytes(size, draw);
  final f = File(path);
  f.parent.createSync(recursive: true);
  f.writeAsBytesSync(bytes);
  // ignore: avoid_print
  print('wrote $path');
}
