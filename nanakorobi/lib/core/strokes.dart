/// 筆の数と、筆がどこに入るか、節目。
///
/// 筆の数 = 「今日の一歩」を記録した日数（step の件数）。順番は
/// 眉（1〜7筆）→ ひげ（8〜21筆）→ 腹の文字の縁（22〜50筆）→ 衣の模様（51筆〜）。
/// 節目の 7・21・50・100 はそれぞれの部位が揃う筆の数と一致する。
enum StrokeZone { eyebrow, beard, bellyOutline, robe }

class StrokePlan {
  const StrokePlan._();

  /// 7日：眉が揃う。
  static const eyebrowStrokes = 7;

  /// 21日：ひげが揃う（8〜21筆目）。
  static const beardStrokes = 14;

  /// 50日：腹の文字の縁が揃い、文字が金になる（22〜50筆目）。
  static const bellyStrokes = 29;

  /// 100日：衣の模様が揃い、金彩が入る（51〜100筆目）。101筆目からも衣に入り続ける。
  static const robeStrokes = 50;

  static const eyebrowEnd = eyebrowStrokes;
  static const beardEnd = eyebrowEnd + beardStrokes;
  static const bellyEnd = beardEnd + bellyStrokes;
  static const robeEnd = bellyEnd + robeStrokes;

  /// n 筆目（1始まり）が入る部位。
  static StrokeZone zoneOf(int strokeIndex) {
    if (strokeIndex <= eyebrowEnd) return StrokeZone.eyebrow;
    if (strokeIndex <= beardEnd) return StrokeZone.beard;
    if (strokeIndex <= bellyEnd) return StrokeZone.bellyOutline;
    return StrokeZone.robe;
  }

  static int eyebrowCount(int strokes) => strokes.clamp(0, eyebrowStrokes);
  static int beardCount(int strokes) => (strokes - eyebrowEnd).clamp(0, beardStrokes);
  static int bellyCount(int strokes) => (strokes - beardEnd).clamp(0, bellyStrokes);

  /// 衣の筆は上限なし（100筆を超えても入り続ける）。
  static int robeCount(int strokes) => strokes > bellyEnd ? strokes - bellyEnd : 0;
}

/// 見た目が一段変わる節目。
enum StrokeMilestone {
  day7(7),
  day21(21),
  day50(50),
  day100(100);

  const StrokeMilestone(this.strokes);

  final int strokes;

  /// ちょうど節目に達した筆の数なら、その節目。
  static StrokeMilestone? reachedAt(int strokes) {
    for (final m in values) {
      if (m.strokes == strokes) return m;
    }
    return null;
  }

  /// これまでに達した最高の節目。
  static StrokeMilestone? highest(int strokes) {
    StrokeMilestone? result;
    for (final m in values) {
      if (strokes >= m.strokes) result = m;
    }
    return result;
  }

  /// 次の節目。100 を超えたら null。
  static StrokeMilestone? next(int strokes) {
    for (final m in values) {
      if (strokes < m.strokes) return m;
    }
    return null;
  }
}
