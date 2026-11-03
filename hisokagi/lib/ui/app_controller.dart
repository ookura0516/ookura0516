import 'dart:math';

import 'package:flutter/foundation.dart';

import '../core/room_code.dart';
import '../game/services.dart';
import '../game/session.dart';
import '../scenario/model.dart';

/// アプリ全体の状態。遊んでいる部屋を1つだけ持ち、変わるたびに端末に保存する。
class AppController extends ChangeNotifier {
  AppController({required this.store, this.ads = const PlaceholderAdService()}) {
    _session = store.load();
    _session?.addListener(_save);
  }

  final SessionStore store;
  final AdService ads;
  GameSession? _session;

  GameSession? get session => _session;

  /// 「つづきから」を出すか。
  bool get canResume => _session != null && !_session!.isCleared;

  /// 新しい部屋の番号を作る。シードは毎回ランダム。
  static RoomCode newRoomCode(ScenarioDef scenario, {Random? random}) {
    final r = random ?? Random();
    return RoomCode(scenario: scenario.id, players: 2, seed: r.nextInt(1000));
  }

  GameSession start({
    required RoomCode code,
    required PlayMode mode,
    required Set<Role> roles,
  }) {
    _session?.removeListener(_save);
    final s = GameSession(code: code, mode: mode, roles: roles);
    _session = s..addListener(_save);
    _save();
    notifyListeners();
    return s;
  }

  Future<void> discard() async {
    _session?.removeListener(_save);
    _session = null;
    await store.clear();
    notifyListeners();
  }

  void _save() {
    final s = _session;
    if (s != null) store.save(s);
  }
}
