// 見本の画像を書き出す（目で確かめる用）。通常の `flutter test` では動かない。
//   flutter test tool/render_samples_test.dart --dart-define=OUT=/path/to/dir
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tanzaku/core/kigo.dart';
import 'package:tanzaku/core/season.dart';
import 'package:tanzaku/render/image_export.dart';
import 'package:tanzaku/render/poster_painter.dart';
import 'package:tanzaku/render/style.dart';
import 'package:tanzaku/render/tanzaku_painter.dart';

Future<void> _font(String family, String path) async {
  final loader = FontLoader(family)
    ..addFont(Future.value(ByteData.sublistView(File(path).readAsBytesSync())));
  await loader.load();
}

void main() {
  const out = String.fromEnvironment('OUT');
  test('見本', () async {
    if (out.isEmpty) return;
    await _font('NotoSerifJP', 'assets/fonts/NotoSerifJP-Regular.ttf');
    await _font('ShipporiMincho', 'assets/fonts/ShipporiMincho-Regular.ttf');
    await _font('YujiSyuku', 'assets/fonts/YujiSyuku-Regular.ttf');
    final dict = KigoDictionary.fromJsonString(
      File('assets/data/kigo.json').readAsStringSync(),
    );
    Future<void> one(
      String name,
      List<String> lines,
      TanzakuStyle style, {
      String maegaki = '',
      String gago = '月庵',
    }) async {
      final body = lines.join('\n');
      final d = dict.detect(body);
      final content = TanzakuContent(
        lines: lines,
        maegaki: maegaki,
        gago: gago,
        date: DateTime(2026, 11, 4),
        kigoRanges: [for (final h in d.hits) (h.start, h.end)],
        season: d.primary?.season ?? Season.autumn,
      );
      final png = await renderPng(
        TanzakuPainter(content: content, style: style),
        style.form.imageSize,
      );
      File('$out/$name.png').writeAsBytesSync(png);
    }

    await one(
      'a_basic',
      ['古池や', '蛙飛びこむ', '水の音'],
      const TanzakuStyle(),
      maegaki: '深川にて',
    );
    await one('b_long', [
      'コーヒーの',
      'ちょっと冷めたる（朝）、ラーメン屋',
      'SL走る😊',
    ], const TanzakuStyle(font: TanzakuFont.yuji, washi: Washi.ai));
    await one(
      'c_shikishi',
      ['柿食へば', '鐘が鳴るなり', '法隆寺'],
      const TanzakuStyle(
        form: TanzakuForm.shikishi,
        font: TanzakuFont.shippori,
        washi: Washi.kinsunago,
        seal: SealStyle(shape: SealShape.round, carve: SealCarve.shubun),
      ),
      maegaki: '法隆寺の茶店に憩ひて',
    );
    await one(
      'd_sakura',
      ['さまざまの', '事おもひ出す', '桜かな'],
      const TanzakuStyle(washi: Washi.sakura, showDate: false),
      gago: '',
    );
    final poster = PosterPainter(
      year: 2026,
      month: 11,
      haiku: [
        for (var i = 0; i < 10; i++)
          ['木枯や\n竹に隠れて\nしづまりぬ', '柿食へば\n鐘が鳴るなり\n法隆寺', '秋深き\n隣は何を\nする人ぞ'][i % 3],
      ],
      style: const TanzakuStyle(washi: Washi.wakatake),
      gago: '月庵',
    );
    File('$out/e_poster.png')
        .writeAsBytesSync(await renderPng(poster, const Size(1080, 1350)));
  });
}
