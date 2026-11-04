import 'fraction.dart';

/// 四則演算。記号は画面に出すものと同じ全角寄りの字（+ − × ÷）を使う。
enum Op {
  add('+'),
  sub('−'),
  mul('×'),
  div('÷');

  const Op(this.symbol);
  final String symbol;

  bool get isAdditive => this == add || this == sub;

  static Op? fromChar(String c) => switch (c) {
    '+' => add,
    '−' || '-' => sub,
    '×' || '*' => mul,
    '÷' || '/' => div,
    _ => null,
  };

  Frac? apply(Frac a, Frac b) => switch (this) {
    add => a + b,
    sub => a - b,
    mul => a * b,
    div => a.div(b),
  };
}

// ------------------------------------------------------------ トークン

/// 入力の1単位。数字は「切符の何桁目か」（[slot]）を持つので、同じ数字が2つあっても区別できる。
sealed class Token {
  const Token();
}

class DigitToken extends Token {
  const DigitToken(this.value, {this.slot = -1});
  final int value;

  /// 切符の何桁目（0〜3）か。文字列から読んだときは -1。
  final int slot;

  @override
  bool operator ==(Object other) =>
      other is DigitToken && other.value == value && other.slot == slot;
  @override
  int get hashCode => Object.hash(value, slot);
  @override
  String toString() => '$value';
}

class OpToken extends Token {
  const OpToken(this.op);
  final Op op;
  @override
  bool operator ==(Object other) => other is OpToken && other.op == op;
  @override
  int get hashCode => op.hashCode;
  @override
  String toString() => op.symbol;
}

class ParenToken extends Token {
  const ParenToken(this.open);
  final bool open;
  @override
  bool operator ==(Object other) => other is ParenToken && other.open == open;
  @override
  int get hashCode => open.hashCode;
  @override
  String toString() => open ? '(' : ')';
}

const lparen = ParenToken(true);
const rparen = ParenToken(false);

/// 「8 ÷ (1 − 1 ÷ 5)」のような文字列をトークンにする。1文字ずつ読むので、数字の連結はできない。
List<Token> tokenize(String s) {
  final out = <Token>[];
  for (final ch in s.split('')) {
    if (ch.trim().isEmpty) continue;
    final d = '0123456789'.indexOf(ch);
    if (d >= 0) {
      out.add(DigitToken(d));
      continue;
    }
    if (ch == '(') {
      out.add(lparen);
      continue;
    }
    if (ch == ')') {
      out.add(rparen);
      continue;
    }
    final op = Op.fromChar(ch);
    if (op == null) throw FormatException('使えない文字: $ch');
    out.add(OpToken(op));
  }
  return out;
}

String tokensToString(List<Token> tokens) {
  final b = StringBuffer();
  for (final t in tokens) {
    switch (t) {
      case OpToken():
        b.write(' ${t.op.symbol} ');
      default:
        b.write(t);
    }
  }
  return b.toString();
}

// ------------------------------------------------------------ 式の木

sealed class Expr {
  const Expr();

  /// 値。途中で 0 で割ると null。
  Frac? eval();

  /// 途中（葉以外の各節）に整数でない値が出てくるか。0 で割るときは null。
  bool? usesFraction();

  /// 使った数字（左から順）。
  List<int> get digits;
}

class NumExpr extends Expr {
  const NumExpr(this.value, {this.slot = -1});
  final int value;
  final int slot;

  @override
  Frac eval() => Frac(value);

  @override
  bool usesFraction() => false;

  @override
  List<int> get digits => [value];

  @override
  String toString() => '$value';
}

class BinExpr extends Expr {
  const BinExpr(this.op, this.left, this.right);
  final Op op;
  final Expr left;
  final Expr right;

  @override
  Frac? eval() {
    final a = left.eval();
    final b = right.eval();
    if (a == null || b == null) return null;
    return op.apply(a, b);
  }

  @override
  bool? usesFraction() {
    final l = left.usesFraction();
    final r = right.usesFraction();
    final v = eval();
    if (l == null || r == null || v == null) return null;
    return l || r || !v.isInteger;
  }

  @override
  List<int> get digits => [...left.digits, ...right.digits];

  @override
  String toString() => '($left ${op.symbol} $right)';
}

// ------------------------------------------------------------ 構文解析

/// 読めない式。
class ParseError implements Exception {
  const ParseError(this.message);
  final String message;
  @override
  String toString() => 'ParseError: $message';
}

/// ふつうの優先順位（× ÷ が先、同じ強さは左から）で読む。
/// 単項のマイナス（「−3」）は読まない。UI でも入れられない。
Expr parse(List<Token> tokens) {
  final p = _Parser(tokens);
  final e = p.expr();
  if (!p.done) throw const ParseError('余分な入力');
  return e;
}

class _Parser {
  _Parser(this.t);
  final List<Token> t;
  int i = 0;

  bool get done => i >= t.length;

  Expr expr() {
    var e = term();
    while (!done) {
      final tok = t[i];
      if (tok is OpToken && tok.op.isAdditive) {
        i++;
        e = BinExpr(tok.op, e, term());
      } else {
        break;
      }
    }
    return e;
  }

  Expr term() {
    var e = factor();
    while (!done) {
      final tok = t[i];
      if (tok is OpToken && !tok.op.isAdditive) {
        i++;
        e = BinExpr(tok.op, e, factor());
      } else {
        break;
      }
    }
    return e;
  }

  Expr factor() {
    if (done) throw const ParseError('式が途中で終わっている');
    final tok = t[i++];
    switch (tok) {
      case DigitToken():
        if (!done && t[i] is DigitToken) {
          throw const ParseError('数字はつなげられない');
        }
        return NumExpr(tok.value, slot: tok.slot);
      case ParenToken(open: true):
        final e = expr();
        if (done || t[i] != rparen) throw const ParseError('括弧が閉じていない');
        i++;
        return e;
      default:
        throw ParseError('ここに「$tok」は置けない');
    }
  }
}
