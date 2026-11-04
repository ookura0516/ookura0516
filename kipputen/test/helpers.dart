import 'dart:io';

import 'package:kipputen/core/puzzle_picker.dart';
import 'package:kipputen/core/solution_book.dart';
import 'package:kipputen/daily/daily.dart';
import 'package:kipputen/data/records.dart';
import 'package:kipputen/monetize/ad_service.dart';
import 'package:kipputen/monetize/purchase_service.dart';
import 'package:kipputen/platform/adapters.dart';
import 'package:kipputen/ui/app_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

SolutionBook? _book;

/// assets/solutions.json を読む（テストのあいだ使い回す）。
SolutionBook loadBook() => _book ??= SolutionBook.fromJson(
  File('assets/solutions.json').readAsStringSync(),
);

AnniversaryTable loadAnniversaries() => AnniversaryTable.fromJson(
  File('assets/anniversaries.json').readAsStringSync(),
);

/// [day] の日本時間 正午。
DateTime noonJst(Day day) =>
    DailyClock.startOf(day).add(const Duration(hours: 12));

class FakeShare implements ShareService {
  final shared = <({List<int> png, String text})>[];
  @override
  Future<void> sharePng(List<int> png, {required String text}) async =>
      shared.add((png: png, text: text));
}

class RecordingWidgetSink implements WidgetSink {
  final saved = <Map<String, Object>>[];
  final refreshed = <List<DateTime>>[];
  @override
  Future<void> save(Map<String, Object> data) async => saved.add(data);
  @override
  Future<void> refresh({required List<DateTime> at}) async => refreshed.add(at);
}

class FakeReview implements ReviewService {
  int asked = 0;
  @override
  Future<void> request() async => asked++;
}

class Harness {
  Harness(this.app, this.prefs, this.sink, this.share, this.review);
  final AppController app;
  final SharedPreferences prefs;
  final RecordingWidgetSink sink;
  final FakeShare share;
  final FakeReview review;
}

/// テスト用のアプリ。購入はすぐ通り、バナーは仮の枠を出す。
Future<Harness> makeHarness(
  Day day, {
  Map<String, Object> prefs = const {},
  bool reuse = false,
}) async {
  if (!reuse) SharedPreferences.setMockInitialValues(prefs);
  final p = await SharedPreferences.getInstance();
  final book = loadBook();
  final sink = RecordingWidgetSink();
  final share = FakeShare();
  final review = FakeReview();
  final app = AppController(
    book: book,
    picker: PuzzlePicker(book, anniversaries: loadAnniversaries()),
    records: Records(p),
    purchases: PlaceholderPurchaseService(p, grantForFree: true),
    ads: const PlaceholderAdService(visible: true),
    clock: DailyClock.fixed(noonJst(day)),
    widgets: WidgetExporter(sink),
    review: review,
    share: share,
  );
  return Harness(app, p, sink, share, review);
}
