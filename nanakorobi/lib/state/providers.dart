import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/local_date.dart';
import '../data/presets.dart';
import '../data/repository.dart';
import '../model/models.dart';
import '../services/review.dart';
import '../services/share.dart';
import '../services/widget_sync.dart';

export 'settings.dart';

/// 現在時刻。テストでおきかえる。
final clockProvider = Provider<DateTime Function()>((_) => DateTime.now);

/// 今日の日付（端末のローカル日付）。0時を越えたら自動で進む。
class TodayNotifier extends Notifier<LocalDate> {
  Timer? _timer;

  @override
  LocalDate build() {
    ref.onDispose(() => _timer?.cancel());
    _schedule();
    return _now();
  }

  LocalDate _now() => LocalDate.fromDateTime(ref.read(clockProvider)());

  /// アプリに戻ったときなどに呼ぶ。
  void refresh() {
    final now = _now();
    if (now != state) state = now;
    _schedule();
  }

  void _schedule() {
    _timer?.cancel();
    final now = ref.read(clockProvider)();
    final nextMidnight = DateTime(now.year, now.month, now.day + 1, 0, 0, 2);
    var wait = nextMidnight.difference(now);
    if (wait.isNegative || wait > const Duration(hours: 25)) wait = const Duration(minutes: 30);
    _timer = Timer(wait, refresh);
  }
}

final todayProvider = NotifierProvider<TodayNotifier, LocalDate>(TodayNotifier.new);

final repositoryProvider = Provider<DarumaRepository>((_) {
  throw UnimplementedError('repositoryProvider は main でおきかえる');
});

final widgetSyncProvider = Provider<WidgetSyncService>((_) => const NoWidgetSync());
final shareProvider = Provider<ShareService>((_) => const NoShareService());
final reviewProvider = Provider<ReviewService>((_) => const NoReviewService());

final presetsProvider = FutureProvider<ExamPresets>((_) => ExamPresets.load());

/// 現役のだるま（無料は1体）。
final activeDarumaProvider =
    StreamProvider<DarumaDetail?>((ref) => ref.watch(repositoryProvider).watchActive());

final darumaDetailProvider = StreamProvider.family<DarumaDetail?, int>(
  (ref, id) => ref.watch(repositoryProvider).watchDetail(id),
);

/// 棚：全部のだるま。
final shelfProvider = StreamProvider<List<Daruma>>((ref) => ref.watch(repositoryProvider).watchAll());
