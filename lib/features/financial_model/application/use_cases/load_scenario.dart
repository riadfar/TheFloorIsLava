import '../../../../core/error/failures.dart';
import '../../domain/defaults/baseline_scenario.dart';
import '../../domain/entities/scenario/financial_scenario.dart';
import '../../domain/repositories/scenario_repository.dart';

/// What was loaded, and whether anything went wrong on the way.
class LoadedScenario {
  const LoadedScenario({
    required this.scenario,
    required this.isFromStorage,
    this.failure,
  });

  final FinancialScenario scenario;

  /// False when the baseline was used because nothing usable was stored.
  final bool isFromStorage;

  /// Set when storage failed. The app still starts - on the baseline - but the
  /// user is told.
  final Failure? failure;
}

/// Loads the scenario the user was last working on.
///
/// A missing or unreadable store is not fatal: the study's baseline is a
/// perfectly good starting point, so the app always opens with something
/// meaningful on screen.
class LoadScenario {
  const LoadScenario(this._repository);

  final ScenarioRepository _repository;

  ScenarioRepository get repository => _repository;

  Future<LoadedScenario> call() async {
    final result = await _repository.loadActiveScenario();

    return result.fold(
      onSuccess: (scenario) => LoadedScenario(
        scenario: scenario ?? BaselineScenario.build(),
        isFromStorage: scenario != null,
      ),
      onFailure: (failure) => LoadedScenario(
        scenario: BaselineScenario.build(),
        isFromStorage: false,
        failure: failure,
      ),
    );
  }
}
