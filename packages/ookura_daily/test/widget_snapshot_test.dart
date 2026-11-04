import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ookura_daily/ookura_daily_flutter.dart';

void main() {
  const today = DailyWidgetEntry(
    title: '第4日',
    status: '済',
    done: true,
    streak: 3,
  );
  const tomorrow = DailyWidgetEntry(
    title: '第5日',
    status: '未',
    done: false,
    streak: 3,
  );
  final snap = DailyWidgetSnapshot(
    today: today,
    tomorrow: tomorrow,
    switchAt: DateTime.utc(2026, 11, 4, 15),
  );

  test('値はすべて文字列で書き出す', () {
    final m = snap.toMap();
    expect(m['ookura_daily.today.title'], '第4日');
    expect(m['ookura_daily.today.done'], '1');
    expect(m['ookura_daily.tomorrow.done'], '0');
    expect(m['ookura_daily.tomorrow.streak'], '3');
    expect(
      m[DailyWidgetSnapshot.switchAtKey],
      '${DateTime.utc(2026, 11, 4, 15).millisecondsSinceEpoch}',
    );
  });

  test('切り替え時刻を過ぎたら翌日分', () {
    expect(snap.entryAt(DateTime.utc(2026, 11, 4, 14, 59)), same(today));
    expect(snap.entryAt(DateTime.utc(2026, 11, 4, 15)), same(tomorrow));
  });

  test('絵文字の行', () {
    expect(
      emojiGrid(
        [
          [1, 1],
          [2, 9],
        ],
        {1: 'A', 2: 'B'},
        fallback: '?',
      ),
      'AA\nB?',
    );
  });

  testWidgets('結果画像は指定の大きさの PNG になる', (tester) async {
    for (final format in ShareImageFormat.values) {
      final png = await tester.runAsync(
        () => renderShareImage(
          const ColoredBox(color: Color(0xFF336699)),
          format: format,
        ),
      );
      expect(png, isNotNull);
      // PNG の IHDR から幅と高さを読む。
      final bd = ByteData.sublistView(png!);
      expect(png.sublist(1, 4), 'PNG'.codeUnits);
      expect(bd.getUint32(16), format.width);
      expect(bd.getUint32(20), format.height);
    }
  });

  test('NoWidgetSink は何もしない', () async {
    await const NoWidgetSink().write(snap);
  });
}
