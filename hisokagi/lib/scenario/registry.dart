import 'model.dart';
import 'observatory.dart';

/// 収録シナリオ。部屋番号の1桁目（[ScenarioDef.id]）で引く。
const List<ScenarioDef> scenarios = [ObservatoryScenario()];

ScenarioDef? scenarioById(int id) {
  for (final s in scenarios) {
    if (s.id == id) return s;
  }
  return null;
}

Set<int> get knownScenarioIds => {for (final s in scenarios) s.id};
