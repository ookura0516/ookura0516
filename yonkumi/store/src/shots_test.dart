// ストアのスクリーンショット用に、アプリの画面を PNG で撮る。
//
//   YONKUMI_SHOTS=<保存先> YONKUMI_FONT=<日本語フォントの .ttf/.otf> \
//     flutter test store/src/shots_test.dart
//
// 撮った画面は `node store/src/render.js . <保存先>` で見出しをつけて仕上げる。
// 画面は 440×956（6.9インチの iPhone の論理サイズ）を3倍で撮る。
// YONKUMI_SHOTS がなければ何もしない（ふだんの flutter test では動かない）。
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:yonkumi/ui/screens/archive_screen.dart';
import 'package:yonkumi/ui/screens/home.dart';
import 'package:yonkumi/ui/theme.dart';

import '../../test/fakes.dart';

const _family = 'ShotFont';

Future<void> _loadFont(String family, String path) async {
  final l = FontLoader(family)
    ..addFont(Future.value(ByteData.sublistView(File(path).readAsBytesSync())));
  await l.load();
}

void main() {
  final out = Platform.environment['YONKUMI_SHOTS'];
  testWidgets('ストア用の画面', skip: out == null, (tester) async {
    final font =
        Platform.environment['YONKUMI_FONT'] ??
        '/usr/share/fonts/opentype/ipafont-gothic/ipag.ttf';
    await tester.runAsync(() async {
      await _loadFont(_family, font);
      await _loadFont(
        'MaterialIcons',
        '${Platform.environment['FLUTTER_ROOT']}/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
      );
    });
    tester.view.physicalSize = const Size(1320, 2868);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    // 第20問の日。前の日までに何日か遊んだ記録を入れて、連続日数とアーカイブを見せる。
    // 仮の広告枠は写さない（全問パックを持っている状態で撮る）。
    final t = await TestApp.create(
      prefs: {
        'yonkumi.records.v1': _records(),
        'yonkumi.fullpack.placeholder': true,
      },
    );
    final base = YonkumiTheme.light;
    final theme = base.copyWith(
      textTheme: base.textTheme.apply(fontFamily: _family),
    );
    final key = GlobalKey();
    final nav = GlobalKey<NavigatorState>();
    await tester.pumpWidget(
      RepaintBoundary(
        key: key,
        child: ChangeNotifierProvider.value(
          value: t.controller,
          child: DefaultTextStyle(
            style: const TextStyle(fontFamily: _family),
            child: MaterialApp(
              navigatorKey: nav,
              debugShowCheckedModeBanner: false,
              theme: theme,
              home: const Home(),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    Future<void> shot(String name) async {
      await tester.pumpAndSettle();
      await tester.runAsync(() async {
        final b =
            key.currentContext!.findRenderObject() as RenderRepaintBoundary;
        final img = await b.toImage(pixelRatio: 3);
        final d = await img.toByteData(format: ui.ImageByteFormat.png);
        Directory(out!).createSync(recursive: true);
        File('$out/$name.png').writeAsBytesSync(d!.buffer.asUint8List());
      });
    }

    final entry = t.controller.todayEntry!;
    final p = entry.puzzle;
    Future<void> guess(List<String> words) async {
      t.controller.sessionFor(entry).deselectAll();
      for (final w in words) {
        await tester.tap(find.byKey(ValueKey('tile-$w')));
        await tester.pump();
      }
      await tester.tap(find.text('決定'));
      await tester.pumpAndSettle();
    }

    await shot('01_today');
    await guess(p.groups[1].words);
    await guess([...p.groups[0].words.take(3), p.groups[2].words.first]);
    await shot('02_oneaway');
    for (final g in [p.groups[0], p.groups[3], p.groups[2]]) {
      await guess(g.words);
    }
    await shot('03_result');
    await tester.scrollUntilVisible(
      find.text('答えと解説'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.drag(find.byType(Scrollable).first, const Offset(0, -120));
    await shot('04_notes');
    nav.currentState!.push(
      MaterialPageRoute(builder: (_) => const ArchiveScreen()),
    );
    await shot('05_archive');
  });
}

/// 第14〜19問を解いた記録（決定の並びは、組をそのまま当てた形と、1回間違えた形）。
String _records() {
  final b = realBundle();
  final items = <String>[];
  for (var d = 14; d <= 19; d++) {
    final p = b.open(d, today: 20);
    final g = p.groups;
    final guesses = <List<String>>[
      if (d.isOdd) [...g[2].words.take(3), g[3].words.first],
      for (final i in d.isOdd ? [0, 1, 2, 3] : [0, 2, 1, 3]) g[i].words,
    ];
    final enc = guesses
        .map((x) => '[${x.map((w) => '"$w"').join(',')}]')
        .join(',');
    items.add(
      '{"day":$d,"puzzle":$d,"playedOn":$d,"guesses":[$enc],'
      '"cleared":true,"mistakes":${d.isOdd ? 1 : 0}}',
    );
  }
  return '[${items.join(',')}]';
}
