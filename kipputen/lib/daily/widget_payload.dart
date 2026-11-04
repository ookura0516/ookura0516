import 'day.dart';

/// ホーム画面ウィジェットに渡す1日分のデータ。
class WidgetDay {
  const WidgetDay({required this.day, required this.title, required this.done});

  final Day day;

  /// 大きく出す文字（キップテンなら4桁の番号）。
  final String title;

  /// その日の用事を済ませたか。
  final bool done;
}

/// ウィジェットへの書き出し先。実装は home_widget など。テストでは記録するだけのものに差し替える。
abstract class WidgetSink {
  Future<void> save(Map<String, Object> data);

  /// ウィジェットの描き直しを頼み、[at] の各時刻（日替わり）にも描き直すよう予約する。
  Future<void> refresh({required List<DateTime> at});
}

/// 何もしない（ウィジェットのない環境・テスト）。
class NoWidgetSink implements WidgetSink {
  const NoWidgetSink();
  @override
  Future<void> save(Map<String, Object> data) async {}
  @override
  Future<void> refresh({required List<DateTime> at}) async {}
}

/// 今日と翌日の分を書く。ウィジェット側は、表示する瞬間の日付（JST）で
/// `day_<yyyymmdd>_title` を引く。アプリを開かないまま0時を過ぎても翌日の分が出る。
///
/// キー：
/// - `days`：書き出した日の一覧（「20261104,20261105」）
/// - `day_<yyyymmdd>_title`：大きく出す文字
/// - `day_<yyyymmdd>_done`：済んだか（"1" / "0"）
class WidgetExporter {
  const WidgetExporter(this.sink);

  final WidgetSink sink;

  static Map<String, Object> encode(List<WidgetDay> days) => {
    'days': days.map((d) => d.day.key).join(','),
    for (final d in days) ...{
      'day_${d.day.key}_title': d.title,
      'day_${d.day.key}_done': d.done ? '1' : '0',
    },
  };

  Future<void> export(
    List<WidgetDay> days, {
    required List<DateTime> switchAt,
  }) async {
    await sink.save(encode(days));
    await sink.refresh(at: switchAt);
  }
}
