import '../../domain/defaults/baseline_scenario.dart';
import '../../domain/entities/scenario/financial_scenario.dart';
import '../../domain/repositories/scenario_repository.dart';

/// Discards the user's edits and returns to the study's own numbers.
///
/// Destructive, so the UI must confirm before calling it.
class ResetScenario {
  const ResetScenario(this._repository);

  final ScenarioRepository _repository;

  Future<FinancialScenario> call({DateTime? now}) async {
    await _repository.clearActiveScenario();
    return BaselineScenario.build(now: now);
  }
}
