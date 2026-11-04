import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../model/models.dart';

/// 設定の保存先（ookura_settings の窓口）。
///
/// 共有パッケージが手元にある環境では、この抽象クラスを ookura_settings の
/// アダプタで差し替える（README「共有パッケージの差し替え」）。
abstract class SettingsStore {
  Future<AppSettings> load();
  Future<void> save(AppSettings settings);
}

class PrefsSettingsStore implements SettingsStore {
  PrefsSettingsStore(this._prefs);

  static const key = 'nanakorobi.settings.v1';

  final SharedPreferences _prefs;

  @override
  Future<AppSettings> load() async {
    final raw = _prefs.getString(key);
    if (raw == null) return const AppSettings();
    try {
      return AppSettings.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return const AppSettings();
    }
  }

  @override
  Future<void> save(AppSettings settings) =>
      _prefs.setString(key, jsonEncode(settings.toJson()));
}

class MemorySettingsStore implements SettingsStore {
  MemorySettingsStore([this.settings = const AppSettings()]);

  AppSettings settings;
  int saves = 0;

  @override
  Future<AppSettings> load() async => settings;

  @override
  Future<void> save(AppSettings s) async {
    settings = s;
    saves++;
  }
}

/// 端末内カウンタ（計測）。サーバーへは送らず、設定画面で見せて任意で共有するだけ。
abstract class MetricsStore {
  Future<Map<String, int>> load();
  Future<void> increment(String key, [int by = 1]);
}

class MetricKeys {
  const MetricKeys._();

  static const darumaCreated = 'daruma_created';
  static const eyeOpened = 'eye_opened';
  static const stepRecorded = 'step_recorded';
  static const stepUndone = 'step_undone';
  static const fellSeen = 'fell_seen';
  static const rose = 'rose';
  static const restDeclared = 'rest_declared';
  static const milestone7 = 'milestone_7';
  static const milestone21 = 'milestone_21';
  static const milestone50 = 'milestone_50';
  static const milestone100 = 'milestone_100';
  static const completed = 'completed';
  static const retired = 'retired';
  static const shared = 'shared';
  static const presetUsed = 'preset_used';
  static const paywallShown = 'paywall_shown';
  static const plusPurchased = 'plus_purchased';
  static const reviewPrompted = 'review_prompted';
  static const widgetGuideShown = 'widget_guide_shown';
  static const reminderEnabled = 'reminder_enabled';
  static const exported = 'exported';
  static const imported = 'imported';
}

class PrefsMetricsStore implements MetricsStore {
  PrefsMetricsStore(this._prefs);

  static const key = 'nanakorobi.metrics.v1';

  final SharedPreferences _prefs;

  @override
  Future<Map<String, int>> load() async {
    final raw = _prefs.getString(key);
    if (raw == null) return {};
    try {
      final m = jsonDecode(raw) as Map<String, dynamic>;
      return m.map((k, v) => MapEntry(k, (v as num).toInt()));
    } catch (_) {
      return {};
    }
  }

  @override
  Future<void> increment(String key, [int by = 1]) async {
    final m = await load();
    m[key] = (m[key] ?? 0) + by;
    await _prefs.setString(PrefsMetricsStore.key, jsonEncode(m));
  }
}

class MemoryMetricsStore implements MetricsStore {
  final Map<String, int> counters = {};

  @override
  Future<Map<String, int>> load() async => Map.of(counters);

  @override
  Future<void> increment(String key, [int by = 1]) async {
    counters[key] = (counters[key] ?? 0) + by;
  }
}
