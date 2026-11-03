import 'kana.dart';

/// シナリオの中身（謎の作り方）を変えたら1つ上げる。
///
/// 上げると古いアプリで作った部屋番号は検査数字で弾かれ、
/// 「番号がちがうか、アプリのバージョンがちがいます」と案内される。
const int rulesVersion = 1;

enum RoomCodeError { length, check, scenario, players }

/// 6桁の部屋番号：シナリオ(1) 人数(1) シード(3) 検査数字(1)。
class RoomCode {
  const RoomCode({
    required this.scenario,
    required this.players,
    required this.seed,
  })  : assert(scenario >= 0 && scenario <= 9),
        assert(players >= 2 && players <= 4),
        assert(seed >= 0 && seed <= 999);

  final int scenario;
  final int players;
  final int seed;

  String get _body =>
      '$scenario$players${seed.toString().padLeft(3, '0')}';

  String get text => '$_body${checkDigit(_body)}';

  /// 読み上げやすいように3桁ずつ区切った表示。
  String get display => '${text.substring(0, 3)} ${text.substring(3)}';

  /// 重みが10と互いに素なので、1桁の打ち間違いは必ず見つかる。
  static int checkDigit(String body) {
    const weights = [3, 7, 1, 3, 7];
    var sum = rulesVersion * 9;
    for (var i = 0; i < body.length; i++) {
      sum += (body.codeUnitAt(i) - 0x30) * weights[i];
    }
    return (10 - sum % 10) % 10;
  }

  /// 入力を読み取る。失敗したら [RoomCodeError] を返す。
  static (RoomCode?, RoomCodeError?) parse(
    String input, {
    required Set<int> knownScenarios,
  }) {
    final digits = normalizeInput(input);
    if (digits.length != 6 || !RegExp(r'^\d{6}$').hasMatch(digits)) {
      return (null, RoomCodeError.length);
    }
    if (checkDigit(digits.substring(0, 5)) != digits.codeUnitAt(5) - 0x30) {
      return (null, RoomCodeError.check);
    }
    final scenario = digits.codeUnitAt(0) - 0x30;
    final players = digits.codeUnitAt(1) - 0x30;
    if (!knownScenarios.contains(scenario)) {
      return (null, RoomCodeError.scenario);
    }
    if (players < 2 || players > 4) return (null, RoomCodeError.players);
    return (
      RoomCode(
        scenario: scenario,
        players: players,
        seed: int.parse(digits.substring(2, 5)),
      ),
      null,
    );
  }

  @override
  bool operator ==(Object other) => other is RoomCode && other.text == text;

  @override
  int get hashCode => text.hashCode;
}
