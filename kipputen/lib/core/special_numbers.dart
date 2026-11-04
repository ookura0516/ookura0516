/// 図鑑で金縁にする特別な番号。
enum SpecialKind {
  zorome('ゾロ目'),
  sequence('連番'),
  palindrome('回文'),
  birthday('誕生日');

  const SpecialKind(this.label);
  final String label;
}

/// [number] が当てはまる特別な種類。[birthday] は「0516」のような月日（未設定なら null）。
/// ゾロ目は回文でもあるが、ゾロ目だけを返す。
Set<SpecialKind> specialKinds(String number, {String? birthday}) {
  final d = number.split('').map(int.parse).toList();
  final out = <SpecialKind>{};
  if (d.every((x) => x == d[0])) {
    out.add(SpecialKind.zorome);
  } else if (d[0] == d[3] && d[1] == d[2]) {
    out.add(SpecialKind.palindrome);
  }
  bool stepsBy(int s) =>
      [for (var i = 1; i < 4; i++) d[i] - d[i - 1]].every((x) => x == s);
  if (stepsBy(1) || stepsBy(-1)) out.add(SpecialKind.sequence);
  if (birthday != null && birthday == number) out.add(SpecialKind.birthday);
  return out;
}

bool isSpecial(String number, {String? birthday}) =>
    specialKinds(number, birthday: birthday).isNotEmpty;
