import '../core/kana.dart';

/// 役。2人用はAとBだけを使う。
enum Role { a, b, c, d }

class RoleInfo {
  const RoleInfo({
    required this.role,
    required this.name,
    required this.place,
  });

  final Role role;

  /// 「ドームの中」など、役の短い名前。
  final String name;

  /// 役の立場の一文。役の確認画面に出す。
  final String place;
}

// ---------------------------------------------------------------- パネル

/// 画面に出す手がかりの1枚。
sealed class PanelSpec {
  const PanelSpec({this.title, this.caption});
  final String? title;
  final String? caption;
}

class TextPanel extends PanelSpec {
  const TextPanel({super.title, required this.body, super.caption});
  final String body;
}

/// 箇条書き（番号つき）。
class ListPanel extends PanelSpec {
  const ListPanel({
    super.title,
    required this.items,
    this.numbered = true,
    super.caption,
  });
  final List<String> items;
  final bool numbered;
}

/// 大きな記号を横に並べる。
class SymbolRowPanel extends PanelSpec {
  const SymbolRowPanel({super.title, required this.symbols, super.caption});
  final List<String> symbols;
}

class TablePanel extends PanelSpec {
  const TablePanel({
    super.title,
    required this.headers,
    required this.rows,
    super.caption,
  });
  final List<String> headers;
  final List<List<String>> rows;
}

/// アナログ時計。[minute] は5の倍数。
class ClockPanel extends PanelSpec {
  const ClockPanel({
    super.title,
    required this.hour,
    required this.minute,
    super.caption,
  });
  final int hour;
  final int minute;
}

/// 色つきのケーブル。答えを入れる役なら、タップして1本選べる。
class CablePanel extends PanelSpec {
  const CablePanel({super.title, required this.colors, super.caption});
  final List<CableColor> colors;
}

/// 行ラベルと列ラベルのついた文字の表。
class GridPanel extends PanelSpec {
  const GridPanel({
    super.title,
    required this.rowLabels,
    required this.colLabels,
    required this.cells,
    super.caption,
  });
  final List<String> rowLabels;
  final List<String> colLabels;
  final List<List<String>> cells;
}

enum CableColor {
  red('赤', 0xFFE5534B),
  blue('青', 0xFF4C8DF6),
  yellow('黄', 0xFFF2C94C),
  green('緑', 0xFF4CBB6A),
  white('白', 0xFFF4F4F0);

  const CableColor(this.label, this.argb);
  final String label;
  final int argb;
}

// ---------------------------------------------------------------- 入力

/// 答えの入れ方。どの入力も、決まった形の文字列（正規形）を返す。
sealed class InputSpec {
  const InputSpec();

  /// 入力の正規形を作る。
  String canonical(String raw) => normalizeInput(raw);
}

/// 数字 [length] 桁。正規形は数字の並び（"0427"）。
class DigitsInput extends InputSpec {
  const DigitsInput(this.length);
  final int length;
}

/// ひらがな。正規形はひらがなの並び。
class KanaInput extends InputSpec {
  const KanaInput(this.length);
  final int length;
}

/// 12時間表記の時刻。分は5分きざみ。正規形は "7:05"。
class TimeInput extends InputSpec {
  const TimeInput();

  static String format(int hour, int minute) =>
      '$hour:${minute.toString().padLeft(2, '0')}';
}

/// ケーブルを1本選ぶ。正規形は左から数えた番号（"1"〜）。
class CableChoiceInput extends InputSpec {
  const CableChoiceInput();
}

// ---------------------------------------------------------------- ステージ

/// 1つの役から見たステージ。
class StageView {
  const StageView({required this.intro, required this.panels});

  /// ステージの最初に読む短い文。
  final String intro;
  final List<PanelSpec> panels;
}

/// 部屋番号のシードから作られた、1つのステージ。
class StageInstance {
  const StageInstance({
    required this.title,
    required this.inputRole,
    required this.views,
    required this.input,
    required this.answer,
    required this.answerDisplay,
    required this.hints,
    required this.notebookLabel,
    this.waitingNote,
  });

  final String title;

  /// 答えを入れる役。ほかの役は合言葉を入れて進む。
  final Role inputRole;

  final Map<Role, StageView> views;
  final InputSpec input;

  /// 正解の正規形。
  final String answer;

  /// 手帳や「答え」ヒントに出す、人が読む形の答え。
  final String answerDisplay;

  /// 役ごとのヒント（ヒント1・ヒント2）。
  final Map<Role, List<String>> hints;

  /// 手帳に書く見出し（「星図の扉の番号」など）。
  final String notebookLabel;

  /// 答えを入れない役に出す一文。省略すると決まり文句を出す。
  final String? waitingNote;

  bool check(String raw) => input.canonical(raw) == answer;
}

/// 1本のシナリオ。
abstract class ScenarioDef {
  const ScenarioDef();

  /// 部屋番号の1桁目。
  int get id;
  String get title;
  String get tagline;
  int get minutes;

  /// 無料シナリオか。無料ならヒント2と答えはリワード広告で開く。
  bool get free;

  /// この人数で使う役。
  List<RoleInfo> rolesFor(int players);

  /// 対応する人数。
  List<int> get playerCounts;

  String prologue(Role role);
  String ending(Role role);

  /// シード（000〜999）からステージを作る。同じシードなら必ず同じ結果になる。
  List<StageInstance> build(int seed);
}
