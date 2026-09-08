import '../entities/scenario/assumption_status.dart';
import '../entities/scenario/financial_scenario.dart';
import '../entities/scenario/sensitivity_settings.dart';
import '../entities/scenario/scenario_fields.dart';
import 'input_rules.dart';
import 'validation_issue.dart';

/// Checks a whole scenario against the model's rules.
///
/// Validation lives here, in the domain, not in text fields. Widgets reuse
/// [InputRules] for immediate feedback, but this is the check that decides
/// whether a scenario is a coherent business.
class ScenarioValidator {
  const ScenarioValidator();

  ValidationReport validate(FinancialScenario scenario) {
    return ValidationReport([
      ..._validateFields(scenario),
      ..._validateCrossFieldRules(scenario),
    ]);
  }

  /// Each named input against its own allowed range.
  ///
  /// Driven by [ScenarioFields] rather than a second hand-written list of
  /// fields, so validation cannot fall out of step with editing.
  Iterable<ValidationIssue> _validateFields(FinancialScenario scenario) sync* {
    for (final key in AssumptionKey.values) {
      final value = ScenarioFields.read(scenario, key);
      if (value == null) continue;
      final issue = InputRules.validate(key, value);
      if (issue != null) yield issue;
    }

    // Ramp-up months past the three the study names have no key of their own;
    // they are held to the same rule as the stable level.
    final rampUp = scenario.revenue.occupancy.rampUp;
    for (var index = 3; index < rampUp.length; index++) {
      final issue = InputRules.validate(
        AssumptionKey.stableOccupancy,
        rampUp[index].percent,
      );
      if (issue != null) yield issue;
    }

    // Prices of options the user can switch to must still be sane, even when
    // they are not the selected one.
    for (final package in scenario.startupCosts.equipment.packages) {
      if (package.cost.isNegative) {
        yield const ValidationIssue(
          key: AssumptionKey.selectedEquipmentPackage,
          code: ValidationCode.mustBeAtLeast,
          limit: 0,
        );
        break;
      }
    }
  }

  /// Rules that no single field can see on its own.
  Iterable<ValidationIssue> _validateCrossFieldRules(
    FinancialScenario scenario,
  ) sync* {
    final revenue = scenario.revenue;

    // A round cannot sell more seats than the room holds.
    if (revenue.pricing.averagePlayersPerRound >
        revenue.capacity.maximumPlayersPerRound) {
      yield ValidationIssue(
        key: AssumptionKey.averagePlayersPerRound,
        code: ValidationCode.averagePlayersExceedCapacity,
        limit: revenue.capacity.maximumPlayersPerRound,
      );
    }

    // A round that consumes no time would allow infinite capacity.
    final roundTime =
        revenue.capacity.roundDuration + revenue.capacity.turnaroundTime;
    if (!roundTime.isPositive) {
      yield const ValidationIssue(
        key: AssumptionKey.roundDuration,
        code: ValidationCode.roundTimeNotPositive,
      );
    }

    if (scenario.staffing.expandedEmployeeCount <
        scenario.staffing.initialEmployeeCount) {
      yield const ValidationIssue.warning(
        key: AssumptionKey.expandedEmployeeCount,
        code: ValidationCode.expandedHeadcountBelowInitial,
      );
    }

    // Allowed, but a contingency larger than the project itself is almost
    // certainly a typo.
    if (scenario.startupCosts.preOpening.contingencyRate.percent > 100) {
      yield const ValidationIssue.warning(
        key: AssumptionKey.contingencyRate,
        code: ValidationCode.contingencyAboveOneHundredPercent,
        limit: 100,
      );
    }

    yield* _validateSensitivityOrdering(scenario);
  }

  /// The what-if cases should bracket the base case.
  ///
  /// The source study does not: its optimistic case (60%) sits below its own
  /// stable occupancy (69%). That is flagged rather than corrected - the study's
  /// numbers are preserved, and the user decides what to do about it.
  Iterable<ValidationIssue> _validateSensitivityOrdering(
    FinancialScenario scenario,
  ) sync* {
    final stable = scenario.revenue.occupancy.stable;
    for (final definition in scenario.sensitivity.scenarios) {
      final occupancy = definition.occupancy;
      if (occupancy == null) continue;

      if (definition.kind == SensitivityScenarioKind.optimistic &&
          occupancy < stable) {
        yield ValidationIssue.warning(
          key: AssumptionKey.optimisticOccupancy,
          code: ValidationCode.optimisticOccupancyBelowBase,
          limit: stable.percent,
        );
      }
      if (definition.kind == SensitivityScenarioKind.conservative &&
          occupancy > stable) {
        yield ValidationIssue.warning(
          key: AssumptionKey.conservativeOccupancy,
          code: ValidationCode.conservativeOccupancyAboveBase,
          limit: stable.percent,
        );
      }
    }
  }
}
