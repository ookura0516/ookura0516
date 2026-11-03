import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../core/passphrase.dart';
import '../core/room_code.dart';
import '../scenario/model.dart';
import '../scenario/registry.dart';

enum PlayMode {
  /// 1人1台。自分の役だけを持ち、相棒の合言葉で進む。
  linked,

  /// 1台を回して遊ぶ。全部の役を持ち、合言葉は要らない。
  solo,
}

/// ヒントの段階。0=未使用、1=ヒント1、2=ヒント2、3=答え。
const int hintAnswerLevel = 3;

enum SubmitResult { correct, wrong }

/// 手帳の1行。
class NotebookEntry {
  const NotebookEntry(this.stage, this.label, this.value);
  final int stage;
  final String label;
  final String value;
}

/// 遊んでいる1つの部屋。
class GameSession extends ChangeNotifier {
  GameSession({
    required this.code,
    required this.mode,
    required Set<Role> roles,
    DateTime? startedAt,
    Map<Role, int>? progress,
    Map<String, int>? hintLevels,
    this.mistakes = 0,
    this.finishedAt,
    Role? activeRole,
  })  : roles = Set.unmodifiable(roles),
        scenario = scenarioById(code.scenario)!,
        startedAt = startedAt ?? DateTime.now(),
        _progress = {for (final r in roles) r: progress?[r] ?? 0},
        _hintLevels = {...?hintLevels},
        _activeRole = activeRole ?? (roles.toList()..sort(_byIndex)).first {
    stages = scenario.build(code.seed);
  }

  final RoomCode code;
  final PlayMode mode;

  /// この端末が持っている役。
  final Set<Role> roles;
  final ScenarioDef scenario;
  late final List<StageInstance> stages;
  final DateTime startedAt;
  DateTime? finishedAt;
  int mistakes;

  final Map<Role, int> _progress;
  final Map<String, int> _hintLevels;
  Role _activeRole;

  static int _byIndex(Role x, Role y) => x.index.compareTo(y.index);

  // ------------------------------------------------------------ 読み取り

  /// 画面に出している役。1人1台なら自分の役のまま。
  Role get activeRole => _activeRole;

  List<Role> get sortedRoles => roles.toList()..sort(_byIndex);

  RoleInfo roleInfo(Role role) =>
      scenario.rolesFor(code.players).firstWhere((r) => r.role == role);

  /// [role] がいま取り組んでいるステージ番号。全部終わると [stages] の長さになる。
  int stageIndexOf(Role role) => _progress[role]!;

  int get currentIndex => stageIndexOf(_activeRole);

  bool get isCleared =>
      roles.every((r) => stageIndexOf(r) >= stages.length);

  bool isClearedFor(Role role) => stageIndexOf(role) >= stages.length;

  StageInstance? get currentStage =>
      currentIndex < stages.length ? stages[currentIndex] : null;

  /// いまの役が答えを入れる番か（そうでなければ合言葉を入れる番）。
  bool get isInputTurn => currentStage?.inputRole == _activeRole;

  /// この端末の手帳。この端末の役で解いたステージの答えだけが残る。
  List<NotebookEntry> notebookFor(Role role) {
    final entries = <NotebookEntry>[];
    final reached = stageIndexOf(role);
    for (var i = 0; i < reached && i < stages.length; i++) {
      final s = stages[i];
      if (roles.contains(s.inputRole) &&
          (mode == PlayMode.solo || s.inputRole == role)) {
        entries.add(NotebookEntry(i, s.notebookLabel, s.answerDisplay));
      }
    }
    return entries;
  }

  String passphraseOf(int stage) =>
      passphraseFor(scenario: code.scenario, seed: code.seed, stage: stage);

  int hintLevel(Role role, int stage) => _hintLevels[_hintKey(role, stage)] ?? 0;

  int get hintsUsed => _hintLevels.values.fold(0, (a, b) => a + b);

  Duration get elapsed => (finishedAt ?? DateTime.now()).difference(startedAt);

  // ------------------------------------------------------------ 操作

  void switchRole(Role role) {
    assert(roles.contains(role));
    if (_activeRole == role) return;
    _activeRole = role;
    notifyListeners();
  }

  /// 答えを入れる。正解なら、この役を次へ進める（1台モードなら全部の役）。
  SubmitResult submitAnswer(String raw) {
    final stage = currentStage;
    if (stage == null || !isInputTurn) {
      throw StateError('いまは答えを入れる番ではありません');
    }
    if (!stage.check(raw)) {
      mistakes++;
      notifyListeners();
      return SubmitResult.wrong;
    }
    final index = currentIndex;
    if (mode == PlayMode.solo) {
      for (final r in roles) {
        _progress[r] = index + 1;
      }
    } else {
      _progress[_activeRole] = index + 1;
    }
    _markFinished();
    notifyListeners();
    return SubmitResult.correct;
  }

  /// 相棒が出した合言葉を入れる。
  SubmitResult submitPassphrase(String raw) {
    final stage = currentStage;
    if (stage == null || isInputTurn) {
      throw StateError('いまは合言葉を入れる番ではありません');
    }
    if (!matchesPassphrase(raw, passphraseOf(currentIndex))) {
      notifyListeners();
      return SubmitResult.wrong;
    }
    _progress[_activeRole] = currentIndex + 1;
    _markFinished();
    notifyListeners();
    return SubmitResult.correct;
  }

  /// ヒントを1段進める。答えまで開いたら、それ以上は進まない。
  void revealNextHint() {
    final key = _hintKey(_activeRole, currentIndex);
    final level = _hintLevels[key] ?? 0;
    if (level >= hintAnswerLevel) return;
    _hintLevels[key] = level + 1;
    notifyListeners();
  }

  void _markFinished() {
    if (isCleared && finishedAt == null) finishedAt = DateTime.now();
  }

  static String _hintKey(Role role, int stage) => '${role.name}:$stage';

  // ------------------------------------------------------------ 保存

  Map<String, Object?> toJson() => {
        'v': 1,
        'code': code.text,
        'mode': mode.name,
        'roles': [for (final r in sortedRoles) r.name],
        'active': _activeRole.name,
        'progress': {for (final e in _progress.entries) e.key.name: e.value},
        'hints': _hintLevels,
        'mistakes': mistakes,
        'startedAt': startedAt.toIso8601String(),
        'finishedAt': finishedAt?.toIso8601String(),
      };

  String encode() => jsonEncode(toJson());

  /// 保存した部屋を読み戻す。読めない（版が変わった等）ときは null。
  static GameSession? decode(String raw) {
    try {
      final json = jsonDecode(raw) as Map<String, Object?>;
      if (json['v'] != 1) return null;
      final (code, _) = RoomCode.parse(
        json['code'] as String,
        knownScenarios: knownScenarioIds,
      );
      if (code == null) return null;
      Role role(String name) => Role.values.byName(name);
      final progress = (json['progress'] as Map).map(
        (k, v) => MapEntry(role(k as String), v as int),
      );
      return GameSession(
        code: code,
        mode: PlayMode.values.byName(json['mode'] as String),
        roles: {for (final r in json['roles'] as List) role(r as String)},
        activeRole: role(json['active'] as String),
        progress: progress,
        hintLevels: (json['hints'] as Map)
            .map((k, v) => MapEntry(k as String, v as int)),
        mistakes: json['mistakes'] as int,
        startedAt: DateTime.parse(json['startedAt'] as String),
        finishedAt: json['finishedAt'] == null
            ? null
            : DateTime.parse(json['finishedAt'] as String),
      );
    } catch (_) {
      return null;
    }
  }
}
