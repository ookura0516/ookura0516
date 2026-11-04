import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:nanakorobi/ui/theme.dart';

void main() {
  test('毛筆体 Yuji Syuku と OFL を同梱し、pubspec とテーマで使っている', () {
    final ttf = File('assets/fonts/YujiSyuku-Regular.ttf').readAsBytesSync();
    expect(ttf.length, greaterThan(1000000));
    // TrueType の先頭（sfnt version 1.0）
    expect(ttf.sublist(0, 4), [0, 1, 0, 0]);

    final ofl = File('assets/fonts/OFL.txt').readAsStringSync();
    expect(ofl, contains('SIL Open Font License'));
    expect(ofl, contains('Yuji Project Authors'));

    final pubspec = File('pubspec.yaml').readAsStringSync();
    expect(pubspec, contains('family: NanakorobiBrush'));
    expect(pubspec, contains('asset: assets/fonts/YujiSyuku-Regular.ttf'));
    expect(pubspec, contains('- assets/fonts/OFL.txt'));
    expect(NanakorobiTheme.brushFontFamily, 'NanakorobiBrush');
  });
}
