import '../../domain/entities/results/financial_projection.dart';
import '../../domain/entities/scenario/financial_scenario.dart';
import '../../domain/services/financial_model_calculator.dart';
import '../../domain/validation/scenario_validator.dart';
import '../../domain/validation/validation_issue.dart';

/// A scenario's projection together with what is wrong with the scenario.
class FinancialModelOutput {
  const FinancialModelOutput({
    required this.projection,
    required this.validation,
  });

  final FinancialProjection projection;
  final ValidationReport validation;
}

/// Validates a scenario and runs the model over it.
///
/// Validation and calculation are deliberately both performed: a scenario with
/// an invalid field still produces numbers, so the user can see the effect of
/// what they typed while the field itself is flagged. Only saving is gated on
/// validity.
class CalculateFinancialModel {
  const CalculateFinancialModel({
    this.calculator = const FinancialModelCalculator(),
    this.validator = const ScenarioValidator(),
  });

  final FinancialModelCalculator calculator;
  final ScenarioValidator validator;

  FinancialModelOutput call(FinancialScenario scenario) {
    return FinancialModelOutput(
      projection: calculator.calculate(scenario),
      validation: validator.validate(scenario),
    );
  }
}
