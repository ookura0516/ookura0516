import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/local_date.dart';
import '../core/look_builder.dart';
import '../model/models.dart';
import '../services/plus_service.dart';
import 'app_deps.dart';

// ------------------------------------------------------------ 設定

class SettingsNotifier extends Notifier<AppSettings> {
  @override
  AppSettings build() => ref.watch(appDepsProvider).initialSettings;

  Future<void> update(AppSettings Function(AppSettings) change) async {
    state = change(state);
    await ref.read(appDepsProvider).settingsStore.save(state);
  }

  Future<void> markOnboardingDone() => update((s) => s.copyWith(onboardingDone: true));

  Future<void> setReminder({required bool enabled, int? minuteOfDay}) => update(
        (s) => s.copyWith(
          reminderEnabled: enabled,
          reminderMinuteOfDay: minuteOfDay ?? s.reminderMinuteOfDay,
        ),
      );

  Future<void> setEyeSideDefault(EyeSide side) => update((s) => s.copyWith(eyeSideDefault: side));

  Future<void> setWidgetStyle(WidgetStyle style) => update((s) => s.copyWith(widgetStyle: style));

  Future<void> setWidgetDaruma(String? id) => update((s) => s.copyWith(widgetDarumaId: id));

  Future<void> addReviewPrompt(LocalDate day) =>
      update((s) => s.copyWith(reviewPromptedOn: [...s.reviewPromptedOn, day]));
}

final settingsProvider = NotifierProvider<SettingsNotifier, AppSettings>(SettingsNotifier.new);

// ------------------------------------------------------------ プラス

class PlusNotifier extends Notifier<PlusState> {
  @override
  PlusState build() {
    final service = ref.watch(appDepsProvider).plus;
    void listener() => state = service.state.value;
    service.state.addListener(listener);
    ref.onDispose(() => service.state.removeListener(listener));
    return service.state.value;
  }

  Future<void> buy() => ref.read(appDepsProvider).plus.buy();

  Future<void> restore() => ref.read(appDepsProvider).plus.restore();
}

final plusProvider = NotifierProvider<PlusNotifier, PlusState>(PlusNotifier.new);

final hasPlusProvider = Provider<bool>((ref) => ref.watch(plusProvider).hasPlus);

// ------------------------------------------------------------ 今日

/// 端末のローカル日付。0時（日付の境界）で進む。アプリに戻ったときも [refresh] する。
class TodayNotifier extends Notifier<LocalDate> {
  Timer? _timer;

  @override
  LocalDate build() {
    final deps = ref.watch(appDepsProvider);
    final boundary = ref.watch(settingsProvider.select((s) => s.dayBoundary));
    ref.onDispose(() => _timer?.cancel());
    final now = deps.now();
    _arm(boundary, now);
    return boundary.dateOf(now);
  }

  void _arm(DayBoundary boundary, DateTime now) {
    _timer?.cancel();
    if (!ref.read(appDepsProvider).scheduleClockTimer) return;
    final next = boundary.nextBoundary(now);
    _timer = Timer(next.difference(now) + const Duration(seconds: 1), refresh);
  }

  void refresh() {
    final now = ref.read(appDepsProvider).now();
    final boundary = ref.read(settingsProvider).dayBoundary;
    final today = boundary.dateOf(now);
    if (today != state) state = today;
    _arm(boundary, now);
  }
}

final todayProvider = NotifierProvider<TodayNotifier, LocalDate>(TodayNotifier.new);

// ------------------------------------------------------------ だるま

final bundlesProvider = StreamProvider<List<DarumaBundle>>(
  (ref) => ref.watch(appDepsProvider).repo.watchAll(),
);

/// 読み込み前は空。
final allBundlesProvider = Provider<List<DarumaBundle>>(
  (ref) => ref.watch(bundlesProvider).value ?? const [],
);

final activeDarumasProvider = Provider<List<DarumaBundle>>(
  (ref) => ref.watch(allBundlesProvider).where((b) => b.daruma.isActive).toList(),
);

final bundleProvider = Provider.family<DarumaBundle?, String>((ref, id) {
  for (final b in ref.watch(allBundlesProvider)) {
    if (b.id == id) return b;
  }
  return null;
});

final lookProvider = Provider.family<DarumaLook?, String>((ref, id) {
  final b = ref.watch(bundleProvider(id));
  if (b == null) return null;
  return buildLookFromBundle(b, ref.watch(todayProvider));
});

/// 棚：現役・満願・納めの3段。
class Shelf {
  const Shelf({required this.active, required this.completed, required this.retired});

  final List<DarumaBundle> active;
  final List<DarumaBundle> completed;
  final List<DarumaBundle> retired;

  List<int> get years {
    final set = <int>{
      for (final b in [...active, ...completed, ...retired]) b.daruma.year,
    };
    return set.toList()..sort((a, b) => b.compareTo(a));
  }

  Shelf ofYear(int? year) => year == null
      ? this
      : Shelf(
          active: active.where((b) => b.daruma.year == year).toList(),
          completed: completed.where((b) => b.daruma.year == year).toList(),
          retired: retired.where((b) => b.daruma.year == year).toList(),
        );

  bool get isEmpty => active.isEmpty && completed.isEmpty && retired.isEmpty;
}

final shelfProvider = Provider<Shelf>((ref) {
  final all = ref.watch(allBundlesProvider);
  List<DarumaBundle> of(DarumaStatus s) => all.where((b) => b.daruma.status == s).toList();
  return Shelf(
    active: of(DarumaStatus.active),
    completed: of(DarumaStatus.completed)..sort((a, b) => b.daruma.completedAt!.compareTo(a.daruma.completedAt!)),
    retired: of(DarumaStatus.retired)..sort((a, b) => b.daruma.retiredAt!.compareTo(a.daruma.retiredAt!)),
  );
});

// ------------------------------------------------------------ 試験日プリセット

final presetCatalogProvider = FutureProvider<PresetCatalog>(
  (ref) => ref.watch(appDepsProvider).presets.load(),
);

// ------------------------------------------------------------ 計測

final metricsProvider = FutureProvider<Map<String, int>>(
  (ref) => ref.watch(appDepsProvider).metrics.load(),
);
