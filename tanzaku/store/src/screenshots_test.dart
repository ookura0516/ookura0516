// ストアのスクリーンショットを撮る。実際の画面を、本番と同じフォントで描いて見出しを付ける。
//   flutter test store/src/screenshots_test.dart \
//     --dart-define=SANS=/path/to/NotoSansJP-Regular.ttf --dart-define=OUT=store/screens
// 同じ場所に NotoSansJP-Bold.ttf も置く（ボタンの太字に使う）。
// SANS は画面の文字（端末ではシステムの日本語フォント）の代わり。リポジトリには入れない。
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tanzaku/main.dart';
import 'package:tanzaku/render/style.dart';
import 'package:tanzaku/ui/app_controller.dart';
import 'package:tanzaku/ui/screens/compose_screen.dart';
import 'package:tanzaku/ui/screens/tanzaku_screen.dart';

import '../../test/helpers.dart';

const _sans = String.fromEnvironment('SANS');
const _out = String.fromEnvironment('OUT');

Future<void> _font(String family, List<String> paths) async {
  final loader = FontLoader(family);
  for (final p in paths) {
    loader.addFont(
      Future.value(ByteData.sublistView(File(p).readAsBytesSync())),
    );
  }
  await loader.load();
}

/// 見本の句（すべて書き下ろし）。日付、本文、前書き、お気に入り。
final _samples = <(DateTime, String, String, bool)>[
  (DateTime(2026, 10, 6), '名月や\n屋根に残りし\n子らの声', '', false),
  (DateTime(2026, 10, 20), '案山子にも\n帽子を買つて\nやりたき日', '', true),
  (DateTime(2026, 10, 25), '菊の香の\n残る廊下を\n走らない', '', false),
  (DateTime(2026, 10, 28), '夜長し\n栞の位置を\n確かめる', '', false),
  (DateTime(2026, 11, 1), '鰯雲\n自転車の影\nのびてゆく', '', false),
  (DateTime(2026, 11, 2), '柿ひとつ\n夕日の色を\n手にのせて', '', true),
  (DateTime(2026, 11, 3), '秋深し\n湯気の向かうの\n母の声', '実家にて', true),
];

class _Shot {
  const _Shot(this.name, this.headline, this.sub, this.setup);
  final String name;
  final String headline;
  final String sub;
  final Future<void> Function(WidgetTester tester, AppController app) setup;
}

NavigatorState _nav(WidgetTester tester) =>
    tester.state<NavigatorState>(find.byType(Navigator).last);

void main() {
  final shots = <_Shot>[
    _Shot('1_home', '毎日ひとつ、季語のお題', '二十四節気で季節がめぐる', (t, app) async {}),
    _Shot('2_compose', '季語と音数を、その場で', '季重なりも知らせます', (t, app) async {
      _nav(t).push(
        MaterialPageRoute(builder: (_) => ComposeScreen(theme: app.todayTheme)),
      );
      await t.pumpAndSettle();
      await t.enterText(find.byKey(const Key('line-0')), '鰯雲');
      await t.enterText(find.byKey(const Key('line-1')), 'ポストの赤を');
      await t.enterText(find.byKey(const Key('line-2')), '遠くまで');
      await t.enterText(find.byKey(const Key('maegaki')), '郵便局の前で');
      FocusManager.instance.primaryFocus?.unfocus();
      await t.pumpAndSettle();
    }),
    _Shot('3_tanzaku', '詠んだ句が、そのまま短冊に', '縦書き・和紙・落款', (t, app) async {
      final id = app.haiku.firstWhere((h) => h.body.startsWith('秋深し')).id;
      _nav(t)
          .push(MaterialPageRoute(builder: (_) => TanzakuScreen(haikuId: id)));
      await t.pumpAndSettle();
    }),
    _Shot('4_shikishi', '書体と和紙を選んで', '色紙の形や筆の書体も（すずり）', (t, app) async {
      await t.runAsync(() => app.purchases.buy());
      await t.runAsync(
        () => app.rememberStyle(
          const TanzakuStyle(
            form: TanzakuForm.shikishi,
            font: TanzakuFont.yuji,
            washi: Washi.kinsunago,
            seal: SealStyle(shape: SealShape.round),
          ),
        ),
      );
      final id = app.haiku.firstWhere((h) => h.body.startsWith('柿ひとつ')).id;
      _nav(t)
          .push(MaterialPageRoute(builder: (_) => TanzakuScreen(haikuId: id)));
      await t.pumpAndSettle();
    }),
    _Shot('5_kucho', '推敲も残る、自分の句帳', '日付・季節・季語で並べ替え', (t, app) async {
      await t.tap(find.text('句帳'));
      await t.pumpAndSettle();
    }),
    _Shot('6_saijiki', '歳時記を、いつも手元に', '150語。読みでも探せます', (t, app) async {
      await t.tap(find.text('歳時記'));
      await t.pumpAndSettle();
    }),
  ];

  const targets = <(String, Size, double)>[
    ('ios', Size(1320, 2868), 3), // App Store 6.9 インチ
    ('android', Size(1080, 1920), 2.5),
  ];

  for (final (platform, size, dpr) in targets) {
    for (final shot in shots) {
      testWidgets('$platform ${shot.name}', (tester) async {
        if (_sans.isEmpty || _out.isEmpty) return;
        // flutter_test は影を黒い縁で描く。見本では本物の影にする。
        debugDisableShadows = false;
        await tester.runAsync(() async {
          final sans = [_sans, _sans.replaceAll('Regular', 'Bold')];
          await _font('Roboto', sans);
          await _font('MaterialIcons', [
            '${Platform.environment['FLUTTER_ROOT'] ?? '/opt/flutter'}/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
          ]);
          await _font('NotoSerifJP', ['assets/fonts/NotoSerifJP-Regular.ttf']);
          await _font('ShipporiMincho', [
            'assets/fonts/ShipporiMincho-Regular.ttf',
          ]);
          await _font('YujiSyuku', ['assets/fonts/YujiSyuku-Regular.ttf']);
        });
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = dpr;
        addTearDown(tester.view.reset);
        final t = (await tester.runAsync(() async {
          final t = await makeApp(prefs: {'tanzaku.gago': '月庵'});
          for (final (d, body, mae, fav) in _samples) {
            final h = await t.controller.addHaiku(
              lines: splitLines(body),
              maegaki: mae,
              composedOn: d,
            );
            if (fav) await t.controller.toggleFavorite(h);
          }
          final kaki = t.controller.haiku.firstWhere(
            (h) => h.body.startsWith('柿ひとつ'),
          );
          await t.controller.revise(
            kaki.id,
            lines: splitLines('柿ひとつ\n夕日の色を\n手のひらに'),
          );
          await t.controller.revise(
            kaki.id,
            lines: splitLines('柿ひとつ\n夕日の色を\n手にのせて'),
          );
          return t;
        }))!;
        final logical = size / dpr;
        final phone = Size(390, 390 * logical.height / logical.width * 0.86);
        final palette = SeasonPalette.of(t.controller.season);
        final key = GlobalKey();
        await tester.pumpWidget(
          RepaintBoundary(
            key: key,
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: ColoredBox(
                color: palette.accent,
                child: Column(
                  children: [
                    SizedBox(height: logical.height * 0.05),
                    Text(
                      shot.headline,
                      style: TextStyle(
                        fontFamily: 'NotoSerifJP',
                        fontSize: logical.width * 0.075,
                        color: const Color(0xFFFBF7F0),
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      shot.sub,
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: logical.width * 0.04,
                        color: const Color(0xDDFBF7F0),
                      ),
                    ),
                    SizedBox(height: logical.height * 0.03),
                    Expanded(
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(
                              color: const Color(0xFF231C17),
                              width: 6,
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x55000000),
                                blurRadius: 24,
                                offset: Offset(0, 10),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(22),
                            child: FittedBox(
                              child: SizedBox.fromSize(
                                size: phone,
                                child: MediaQuery(
                                  data: MediaQueryData(
                                    size: phone,
                                    devicePixelRatio: dpr,
                                  ),
                                  child: TanzakuApp(controller: t.controller),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        await shot.setup(tester, t.controller);
        await tester.pumpAndSettle();
        await tester.runAsync(() async {
          final boundary =
              key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
          final image = await boundary.toImage(pixelRatio: dpr);
          final data = await image.toByteData(format: ui.ImageByteFormat.png);
          final dir = Directory('$_out/$platform')..createSync(recursive: true);
          File('${dir.path}/${shot.name}.png')
              .writeAsBytesSync(data!.buffer.asUint8List());
        });
        // テストの終わりの検査より前に戻す。
        debugDisableShadows = true;
      });
    }
  }
}
