import 'package:shared_preferences/shared_preferences.dart';

import 'session.dart';

/// リワード広告の窓口。
///
/// まだAdMobを組み込んでいないので、[PlaceholderAdService] は広告を出さずに
/// すぐ報酬を渡す。組み込むときはこのクラスを差し替える（非パーソナライズ広告のみ）。
abstract class AdService {
  /// 広告を最後まで見たら true。
  Future<bool> showRewarded();
}

class PlaceholderAdService implements AdService {
  const PlaceholderAdService();

  @override
  Future<bool> showRewarded() async => true;
}

/// 遊びかけの部屋を端末に保存する。サーバーには何も送らない。
class SessionStore {
  SessionStore(this._prefs);

  static const _key = 'hisokagi.session';
  final SharedPreferences _prefs;

  static Future<SessionStore> open() async =>
      SessionStore(await SharedPreferences.getInstance());

  GameSession? load() {
    final raw = _prefs.getString(_key);
    return raw == null ? null : GameSession.decode(raw);
  }

  Future<void> save(GameSession session) =>
      _prefs.setString(_key, session.encode());

  Future<void> clear() => _prefs.remove(_key);
}
