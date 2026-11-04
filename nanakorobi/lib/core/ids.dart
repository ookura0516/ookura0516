import 'dart:math';

/// だるまや記録の id。乱数の 128 ビットを 16 進で（外部パッケージなし）。
String newId([Random? random]) {
  final r = random ?? Random.secure();
  final b = StringBuffer();
  for (var i = 0; i < 16; i++) {
    b.write(r.nextInt(256).toRadixString(16).padLeft(2, '0'));
  }
  return b.toString();
}

/// だるまの seed（眉とひげの揺らぎの種）。32 ビット。
int newSeed([Random? random]) => (random ?? Random.secure()).nextInt(0x7FFFFFFF) + 1;
