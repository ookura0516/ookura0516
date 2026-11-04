import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:keshiin/core/day_slots.dart';
import 'package:keshiin/platform/services.dart';
import 'package:keshiin/ui/theme.dart';

import 'data_test.dart' show jpegWithExif;
import 'fakes.dart';

Future<void> tapAndSettle(WidgetTester tester, Finder f) async {
  await tester.ensureVisible(f);
  await tester.pumpAndSettle();
  await tester.tap(f);
  await tester.pumpAndSettle();
}

/// 今日のマスから写真を選んで、そのまま保存する（3タップ）。
Future<void> makeStampFromCell(WidgetTester tester, String iso) async {
  await tapAndSettle(tester, find.byKey(Key('cell-$iso')));
  expect(find.text('切手を作る'), findsOneWidget);
  await tapAndSettle(tester, find.byKey(const Key('save-stamp')));
}

void main() {
  testWidgets('初回は注意書きを出す（郵便には使えない）', (tester) async {
    final h = await Harness.create(prefs: {});
    addTearDown(h.close);
    await pumpApp(tester, h);
    expect(find.text('ケシインへようこそ'), findsOneWidget);
    expect(find.textContaining(kNotPostageNotice), findsWidgets);
    await tapAndSettle(tester, find.byKey(const Key('notice-ok')));
    expect(h.app.settings.noticeSeen, isTrue);
    expect(find.text('今月のシート'), findsOneWidget);
  });

  testWidgets('今日の空欄→写真を選ぶ→保存で、シートに1枚貼られる', (tester) async {
    final h = await Harness.create();
    addTearDown(h.close);
    await pumpApp(tester, h);
    expect(find.byKey(const Key('fill-count')), findsOneWidget);
    expect(find.text('0／30'), findsOneWidget);

    await makeStampFromCell(tester, '2026-11-04');

    expect(find.text('1／30'), findsOneWidget);
    expect(find.text('11月4日に貼りました'), findsOneWidget);
    expect(find.byKey(const Key('stamp-2026-11-04')), findsOneWidget);
    expect(h.widgets.published, isNotEmpty);
  });

  testWidgets('過去の空欄にも貼れる。撮影日があればその日に振り分ける', (tester) async {
    final h = await Harness.create();
    addTearDown(h.close);
    await pumpApp(tester, h);
    // 撮影日のない写真を11月2日のマスに
    await makeStampFromCell(tester, '2026-11-02');
    expect(find.byKey(const Key('stamp-2026-11-02')), findsOneWidget);

    // 撮影日が11月1日の写真は、3日のマスから選んでも1日に入る
    h.photos.next = [PickedPhoto(jpegWithExif(date: '2026:11:01 12:00:00'))];
    await tapAndSettle(tester, find.byKey(const Key('cell-2026-11-03')));
    expect(find.text('2026年11月1日のマスに貼る'), findsOneWidget);
    await tapAndSettle(tester, find.byKey(const Key('save-stamp')));
    expect(find.byKey(const Key('stamp-2026-11-01')), findsOneWidget);
    expect(find.text('2／30'), findsOneWidget);
  });

  testWidgets('未来のマスは押しても作らない', (tester) async {
    final h = await Harness.create();
    addTearDown(h.close);
    await pumpApp(tester, h);
    await tapAndSettle(tester, find.byKey(const Key('cell-2026-11-20')));
    expect(find.text('まだ先の日です'), findsOneWidget);
    expect(h.photos.calls, 0);
  });

  testWidgets('写真を選ばずに戻ると、何も貼られない', (tester) async {
    final h = await Harness.create();
    addTearDown(h.close);
    h.photos.next = [];
    await pumpApp(tester, h);
    await tapAndSettle(tester, find.byKey(const Key('cell-2026-11-04')));
    expect(find.text('今月のシート'), findsOneWidget);
    expect(find.text('0／30'), findsOneWidget);
  });

  testWidgets('前の月に戻って空欄を埋められる', (tester) async {
    final h = await Harness.create();
    addTearDown(h.close);
    await pumpApp(tester, h);
    await tapAndSettle(tester, find.byKey(const Key('prev-month')));
    expect(find.text('2026年10月のシート'), findsOneWidget);
    await makeStampFromCell(tester, '2026-10-30');
    expect(find.text('1／30'), findsOneWidget);
    // 31日はマスが無いので、撮影日が31日の写真は欄外に入る
    h.photos.next = [PickedPhoto(jpegWithExif(date: '2026:10:31 21:00:00'))];
    await tapAndSettle(tester, find.byKey(const Key('cell-2026-10-29')));
    expect(find.text('2026年10月31日のマスに貼る'), findsOneWidget);
    await tapAndSettle(tester, find.byKey(const Key('save-stamp')));
    expect(find.text('欄外'), findsOneWidget);
    expect(find.text('1／30'), findsOneWidget);
  });

  testWidgets('切手の詳細：消印を直す（郵便局の形は弾く）→削除', (tester) async {
    final h = await Harness.create();
    addTearDown(h.close);
    await pumpApp(tester, h);
    await makeStampFromCell(tester, '2026-11-04');
    await tapAndSettle(tester, find.byKey(const Key('stamp-2026-11-04')));
    expect(find.text('11月4日　No.1'), findsOneWidget);
    expect(find.text(kNotPostageNotice), findsOneWidget);

    await tapAndSettle(tester, find.byKey(const Key('edit-postmark')));
    await tester.enterText(find.byKey(const Key('edit-place')), '中央郵便局');
    await tapAndSettle(tester, find.byKey(const Key('save-postmark')));
    expect(find.byKey(const Key('edit-error')), findsOneWidget);

    await tester.enterText(find.byKey(const Key('edit-place')), '鎌倉市');
    await tester.enterText(find.byKey(const Key('edit-note')), '晴れ');
    await tapAndSettle(tester, find.byKey(const Key('save-postmark')));
    expect(find.text('鎌倉市　晴れ'), findsOneWidget);
    expect(await h.repo.recentPlaces(), contains('鎌倉市'));

    await tapAndSettle(tester, find.byKey(const Key('delete-stamp')));
    await tapAndSettle(tester, find.byKey(const Key('confirm-delete')));
    expect(find.text('0／30'), findsOneWidget);
    expect(h.store.deleted, isNotEmpty);
  });

  testWidgets('1日に2枚目は「記念」の案内。買うと欄外に貼れる', (tester) async {
    final h = await Harness.create();
    addTearDown(h.close);
    await pumpApp(tester, h);
    await makeStampFromCell(tester, '2026-11-04');
    // 「貼りました」の知らせが消えるのを待つ
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    await tapAndSettle(tester, find.byKey(const Key('create-stamp')));
    await tapAndSettle(tester, find.byKey(const Key('save-stamp')));
    expect(find.textContaining('1日に複数枚'), findsWidgets);
    await tapAndSettle(tester, find.byKey(const Key('buy-kinen')));
    expect(find.text('欄外'), findsOneWidget);
    expect(h.app.purchases.hasKinen, isTrue);
  });

  testWidgets('有料フレームはプレビューでき、保存のときに案内する', (tester) async {
    final h = await Harness.create();
    addTearDown(h.close);
    await pumpApp(tester, h);
    await tapAndSettle(tester, find.byKey(const Key('cell-2026-11-04')));
    await tapAndSettle(tester, find.text('フレーム'));
    await tapAndSettle(tester, find.byKey(const Key('frame-nami')));
    await tapAndSettle(tester, find.byKey(const Key('save-stamp')));
    expect(find.text('「追加フレーム8種」は「記念」で使えます'), findsOneWidget);
    // 買わずに閉じると、作る画面に戻る
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();
    expect(find.text('切手を作る'), findsOneWidget);
    await tapAndSettle(tester, find.byKey(const Key('frame-kinari')));
    await tapAndSettle(tester, find.byKey(const Key('save-stamp')));
    expect(find.text('1／30'), findsOneWidget);
  });

  testWidgets('消印の場所に郵便局の形を入れると保存しない', (tester) async {
    final h = await Harness.create();
    addTearDown(h.close);
    await pumpApp(tester, h);
    await tapAndSettle(tester, find.byKey(const Key('cell-2026-11-04')));
    await tapAndSettle(tester, find.text('消印'));
    await tester.enterText(find.byKey(const Key('postmark-place')), '駅前郵便局');
    await tapAndSettle(tester, find.byKey(const Key('save-stamp')));
    expect(find.byKey(const Key('create-error')), findsOneWidget);
    expect(find.text('切手を作る'), findsOneWidget);
  });

  testWidgets('まとめて貼る：撮影日で振り分け、すでにある日は飛ばす', (tester) async {
    final h = await Harness.create();
    addTearDown(h.close);
    await pumpApp(tester, h);
    h.photos.next = [
      PickedPhoto(jpegWithExif(date: '2026:11:01 08:00:00')),
      PickedPhoto(jpegWithExif(date: '2026:11:01 20:00:00')),
      PickedPhoto(jpegWithExif(date: '2026:11:03 08:00:00')),
    ];
    await tapAndSettle(tester, find.byKey(const Key('bulk-import')));
    expect(find.textContaining('2枚を撮影日のマスに貼りました'), findsOneWidget);
    expect(find.textContaining('1枚は飛ばしました'), findsOneWidget);
    expect(find.byKey(const Key('stamp-2026-11-01')), findsOneWidget);
    expect(find.byKey(const Key('stamp-2026-11-03')), findsOneWidget);
  });

  testWidgets('設定：シート名に禁止語は使えない', (tester) async {
    final h = await Harness.create();
    addTearDown(h.close);
    await pumpApp(tester, h);
    await tapAndSettle(tester, find.byKey(const Key('tab-settings')));
    expect(find.byKey(const Key('notice')), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('sheet-title-field')),
      'NIPPON 2026',
    );
    await tapAndSettle(tester, find.byKey(const Key('sheet-title-save')));
    expect(find.text('シート名に「NIPPON」は使えません'), findsOneWidget);
    expect(h.app.settings.sheetTitle, '');

    await tester.enterText(find.byKey(const Key('sheet-title-field')), '¥84');
    await tapAndSettle(tester, find.byKey(const Key('sheet-title-save')));
    expect(find.text('シート名に通貨記号は使えません'), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('sheet-title-field')),
      '2026 日常',
    );
    await tapAndSettle(tester, find.byKey(const Key('sheet-title-save')));
    expect(find.text('保存しました'), findsOneWidget);
    expect(h.app.settings.sheetTitle, '2026 日常');
  });

  testWidgets('アルバム：月のシートが並び、旅の小型シートは「記念」', (tester) async {
    final h = await Harness.create();
    addTearDown(h.close);
    await pumpApp(tester, h);
    await makeStampFromCell(tester, '2026-11-04');
    await tapAndSettle(tester, find.byKey(const Key('tab-album')));
    expect(find.byKey(const Key('album-month-2026-11')), findsOneWidget);
    expect(find.text('1／30'), findsWidgets);

    await tapAndSettle(tester, find.byKey(const Key('new-trip')));
    expect(find.text('「旅の小型シート」は「記念」で使えます'), findsOneWidget);
  });

  testWidgets('アルバム→月のシートを開く', (tester) async {
    final h = await Harness.create();
    addTearDown(h.close);
    await pumpApp(tester, h);
    await makeStampFromCell(tester, '2026-11-04');
    await tapAndSettle(tester, find.byKey(const Key('tab-album')));
    await tapAndSettle(tester, find.byKey(const Key('album-month-2026-11')));
    expect(find.text('2026年11月のシート'), findsOneWidget);
    expect(find.byKey(const Key('share-month')), findsOneWidget);
  });

  testWidgets('ウィジェットから開かれたら、写真の選択を直接開く', (tester) async {
    final h = await Harness.create();
    addTearDown(h.close);
    await pumpApp(tester, h);
    h.widgets.controller.add(Uri.parse('keshiin://create'));
    await tester.pumpAndSettle();
    expect(h.photos.calls, 1);
    expect(find.text('切手を作る'), findsOneWidget);
    expect(find.text('2026年11月4日のマスに貼る'), findsOneWidget);
    expect(const Day(2026, 11, 4), h.app.today);
  });
}
