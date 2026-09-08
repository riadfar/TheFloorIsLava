import '../../../../core/error/failures.dart';
import '../../domain/entities/scenario/financial_scenario.dart';
import '../../domain/repositories/scenario_repository.dart';

/// Persists the working scenario, stamping the time it was last touched.
class SaveScenario {
  const SaveScenario(this._repository);

  final ScenarioRepository _repository;

  /// Returns the failure if saving did not work, or `null` on success.
  Future<Failure?> call(FinancialScenario scenario, {DateTime? now}) async {
    final stamped = scenario.copyWith(
      metadata: scenario.metadata.copyWith(updatedAt: now ?? DateTime.now()),
    );
    final result = await _repository.saveActiveScenario(stamped);
    return result.failureOrNull;
  }
}
