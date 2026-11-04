import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:kipputen/ui/privacy_text.dart';

void main() {
  test('docs/PRIVACY.md とアプリ内の本文が同じ', () {
    final md = File('docs/PRIVACY.md').readAsStringSync();
    expect(md, contains('最終更新：$privacyUpdated'));
    for (final (title, body) in privacySections) {
      expect(md, contains('## $title\n\n$body\n'), reason: title);
    }
  });
}
