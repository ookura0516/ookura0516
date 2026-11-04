import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../render/style.dart';

/// 端末に保存する設定。サーバーには何も送らない。
class SettingsStore {
  SettingsStore(this._prefs);

  final SharedPreferences _prefs;

  static const _gago = 'tanzaku.gago';
  static const _notify = 'tanzaku.notify.enabled';
  static const _notifyMinutes = 'tanzaku.notify.minutes';
  static const _style = 'tanzaku.style';
  static const _reviewAt = 'tanzaku.review.at';
  static const _reviewMilestones = 'tanzaku.review.milestones';
  static const _kigoVersion = 'tanzaku.kigo.version';

  String get gago => _prefs.getString(_gago) ?? '';
  Future<void> setGago(String v) => _prefs.setString(_gago, v.trim());

  /// 兼題の通知（1日1回、初期はオフ）。
  bool get notifyEnabled => _prefs.getBool(_notify) ?? false;
  Future<void> setNotifyEnabled(bool v) => _prefs.setBool(_notify, v);

  /// 通知の時刻（0時からの分）。初期は朝8時。
  int get notifyMinutes => _prefs.getInt(_notifyMinutes) ?? 8 * 60;
  Future<void> setNotifyMinutes(int v) => _prefs.setInt(_notifyMinutes, v);

  TanzakuStyle get style {
    final raw = _prefs.getString(_style);
    if (raw == null) return const TanzakuStyle();
    try {
      return TanzakuStyle.fromJson(
        (jsonDecode(raw) as Map).cast<String, Object?>(),
      );
    } catch (_) {
      return const TanzakuStyle();
    }
  }

  Future<void> setStyle(TanzakuStyle s) =>
      _prefs.setString(_style, jsonEncode(s.toJson()));

  List<DateTime> get reviewAskedAt => [
    for (final s in _prefs.getStringList(_reviewAt) ?? const <String>[])
      if (DateTime.tryParse(s) != null) DateTime.parse(s),
  ];

  Set<int> get reviewMilestones => {
    for (final s in _prefs.getStringList(_reviewMilestones) ?? const <String>[])
      if (int.tryParse(s) != null) int.parse(s),
  };

  Future<void> recordReview(DateTime at, int milestone) async {
    await _prefs.setStringList(_reviewAt, [
      ...reviewAskedAt.map((t) => t.toIso8601String()),
      at.toIso8601String(),
    ]);
    await _prefs.setStringList(_reviewMilestones, [
      ...reviewMilestones.map((e) => '$e'),
      '$milestone',
    ]);
  }

  int get kigoVersion => _prefs.getInt(_kigoVersion) ?? 0;
  Future<void> setKigoVersion(int v) => _prefs.setInt(_kigoVersion, v);
}
