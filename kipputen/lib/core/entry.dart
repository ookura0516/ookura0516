import 'expr.dart';
import 'fraction.dart';

/// 式の入力。できない操作（数字の連結、単項のマイナス、閉じすぎの括弧）は、
/// そもそも押せないようにする（can* が false のキーは無効になる）。
class Entry {
  Entry(this.number) : assert(number.length == 4);

  /// 切符の4桁。
  final String number;

  final List<Token> _tokens = [];

  List<Token> get tokens => List.unmodifiable(_tokens);

  int digitAt(int slot) => int.parse(number[slot]);

  Set<int> get usedSlots => {
    for (final t in _tokens)
      if (t is DigitToken) t.slot,
  };

  int get _openCount {
    var n = 0;
    for (final t in _tokens) {
      if (t == lparen) n++;
      if (t == rparen) n--;
    }
    return n;
  }

  Token? get _last => _tokens.isEmpty ? null : _tokens.last;

  /// 直前が「数字」か「)」なら、値が1つ終わったところ。
  bool get _afterValue => _last is DigitToken || _last == rparen;

  bool get isEmpty => _tokens.isEmpty;

  bool canDigit(int slot) => !_afterValue && !usedSlots.contains(slot);
  bool get canOp => _afterValue;
  bool get canOpen => !_afterValue && usedSlots.length < 4;
  bool get canClose => _afterValue && _openCount > 0;

  /// 4つ全部使い、括弧が閉じている。
  bool get isComplete =>
      usedSlots.length == 4 && _openCount == 0 && _afterValue;

  void addDigit(int slot) {
    if (canDigit(slot)) _tokens.add(DigitToken(digitAt(slot), slot: slot));
  }

  void addOp(Op op) {
    if (canOp) _tokens.add(OpToken(op));
  }

  void open() {
    if (canOpen) _tokens.add(lparen);
  }

  void close() {
    if (canClose) _tokens.add(rparen);
  }

  void backspace() {
    if (_tokens.isNotEmpty) _tokens.removeLast();
  }

  void clear() => _tokens.clear();

  /// 入れ終わった式。まだなら null。
  Expr? get expr => isComplete ? parse(_tokens) : null;

  /// 「8 ÷ (1 − 1 ÷ 5)」
  String get text => tokensToString(_tokens).trim();

  /// 途中結果。末尾の演算子と開き括弧を除き、開いている括弧を閉じて計算する。
  Preview get preview {
    final t = [..._tokens];
    while (t.isNotEmpty && (t.last is OpToken || t.last == lparen)) {
      t.removeLast();
    }
    if (t.isEmpty) return const Preview.none();
    var open = 0;
    for (final x in t) {
      if (x == lparen) open++;
      if (x == rparen) open--;
    }
    for (var i = 0; i < open; i++) {
      t.add(rparen);
    }
    try {
      final v = parse(t).eval();
      return v == null ? const Preview.divByZero() : Preview.value(v);
    } on ParseError {
      return const Preview.none();
    }
  }
}

class Preview {
  const Preview.value(Frac this.value) : divByZero = false;
  const Preview.none() : value = null, divByZero = false;
  const Preview.divByZero() : value = null, divByZero = true;

  final Frac? value;
  final bool divByZero;
}
