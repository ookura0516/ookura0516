import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/models.dart';

/// 設定と端末内カウンタの保存先。
///
/// 共有パッケージ ookura_settings の窓口。非公開パッケージがこの環境にないため、
/// SharedPreferences の薄い実装を置いている。差し替えるときはこの抽象だけ合わせる。
abstract class SettingsStore {
  bool getBool(String key, {bool fallback = false});
  int getInt(String key, {int fallback = 0});
  String? getString(String key);
  Future<void> setBool(String key, bool value);
  Future<void> setInt(String key, int value);
  Future<void> setString(String key, String value);
  Iterable<String> get keys;
}

class SharedPrefsSettingsStore implements SettingsStore {
  SharedPrefsSettingsStore(this._prefs);

  static Future<SharedPrefsSettingsStore> open() async =>
      SharedPrefsSettingsStore(await SharedPreferences.getInstance());

  final SharedPreferences _prefs;

  @override
  bool getBool(String key, {bool fallback = false}) => _prefs.getBool(key) ?? fallback;
  @override
  int getInt(String key, {int fallback = 0}) => _prefs.getInt(key) ?? fallback;
  @override
  String? getString(String key) => _prefs.getString(key);
  @override
  Future<void> setBool(String key, bool value) => _prefs.setBool(key, value);
  @override
  Future<void> setInt(String key, int value) => _prefs.setInt(key, value);
  @override
  Future<void> setString(String key, String value) => _prefs.setString(key, value);
  @override
  Iterable<String> get keys => _prefs.getKeys();
}

/// テストと Web 撮影用。
class MemorySettingsStore implements SettingsStore {
  final Map<String, Object> _m = {};

  @override
  bool getBool(String key, {bool fallback = false}) => (_m[key] as bool?) ?? fallback;
  @override
  int getInt(String key, {int fallback = 0}) => (_m[key] as int?) ?? fallback;
  @override
  String? getString(String key) => _m[key] as String?;
  @override
  Future<void> setBool(String key, bool value) async => _m[key] = value;
  @override
  Future<void> setInt(String key, int value) async => _m[key] = value;
  @override
  Future<void> setString(String key, String value) async => _m[key] = value;
  @override
  Iterable<String> get keys => _m.keys;
}

/// 端末内カウンタの名前。送信はしない。設定画面の「開発者へ送る」で任意に写すだけ。
class Counters {
  Counters._();
  static const created = 'created';
  static const opened = 'opened';
  static const steps = 'steps';
  static const rises = 'rises';
  static const undo = 'undo';
  static const completed = 'completed';
  static const retired = 'retired';
  static const shares = 'shares';
  static const reviewRequests = 'review_requests';
  static const widgetHints = 'widget_hints';
  static const all = [created, opened, steps, rises, undo, completed, retired, shares, reviewRequests, widgetHints];
}

class AppSettings {
  const AppSettings({
    this.defaultEyeSide = EyeSide.left,
    this.onboardingDone = false,
    this.reviewRequested = false,
    this.counters = const {},
  });

  /// 最初に入れる目。既定は左目（向かって右）。
  final EyeSide defaultEyeSide;
  final bool onboardingDone;

  /// 評価依頼を出したか（7日目の節目で1回）。
  final bool reviewRequested;
  final Map<String, int> counters;

  AppSettings copyWith({
    EyeSide? defaultEyeSide,
    bool? onboardingDone,
    bool? reviewRequested,
    Map<String, int>? counters,
  }) =>
      AppSettings(
        defaultEyeSide: defaultEyeSide ?? this.defaultEyeSide,
        onboardingDone: onboardingDone ?? this.onboardingDone,
        reviewRequested: reviewRequested ?? this.reviewRequested,
        counters: counters ?? this.counters,
      );
}

final settingsStoreProvider = Provider<SettingsStore>((_) {
  throw UnimplementedError('settingsStoreProvider は main でおきかえる');
});

class SettingsNotifier extends Notifier<AppSettings> {
  static const _kEye = 'eye_side_default';
  static const _kOnboarding = 'onboarding_done';
  static const _kReview = 'review_requested';
  static const _kCounter = 'counter.';

  SettingsStore get _store => ref.read(settingsStoreProvider);

  @override
  AppSettings build() {
    final s = _store;
    return AppSettings(
      defaultEyeSide: s.getString(_kEye) == 'right' ? EyeSide.right : EyeSide.left,
      onboardingDone: s.getBool(_kOnboarding),
      reviewRequested: s.getBool(_kReview),
      counters: {for (final k in Counters.all) k: s.getInt('$_kCounter$k')},
    );
  }

  Future<void> setDefaultEyeSide(EyeSide side) async {
    await _store.setString(_kEye, side == EyeSide.right ? 'right' : 'left');
    state = state.copyWith(defaultEyeSide: side);
  }

  Future<void> markOnboardingDone() async {
    await _store.setBool(_kOnboarding, true);
    state = state.copyWith(onboardingDone: true);
  }

  Future<void> markReviewRequested() async {
    await _store.setBool(_kReview, true);
    state = state.copyWith(reviewRequested: true);
  }

  Future<void> increment(String counter) async {
    final next = (state.counters[counter] ?? 0) + 1;
    await _store.setInt('$_kCounter$counter', next);
    state = state.copyWith(counters: {...state.counters, counter: next});
  }
}

final settingsProvider = NotifierProvider<SettingsNotifier, AppSettings>(SettingsNotifier.new);
