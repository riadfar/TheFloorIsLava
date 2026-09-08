import '../../../../core/error/result.dart';
import '../entities/scenario/financial_scenario.dart';

/// Storage for scenarios, described in domain terms.
///
/// The domain depends on this interface only; where a scenario actually lives
/// is a detail of the data layer. The shape is deliberately narrow - the first
/// version keeps a single active scenario - but nothing here would have to
/// change to add a scenario list later.
abstract interface class ScenarioRepository {
  /// The scenario the user is working on, or `null` if nothing is stored yet.
  Future<Result<FinancialScenario?>> loadActiveScenario();

  Future<Result<void>> saveActiveScenario(FinancialScenario scenario);

  /// Forgets the stored scenario, so the app falls back to the baseline.
  Future<Result<void>> clearActiveScenario();
}
