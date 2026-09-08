import '../entities/scenario/assumption_status.dart';
import 'validation_issue.dart';

/// An allowed range for a single numeric input.
class NumericRule {
  const NumericRule({
    this.min,
    this.minExclusive = false,
    this.max,
    this.maxExclusive = false,
  });

  final num? min;

  /// True when the value must be strictly above [min].
  final bool minExclusive;

  final num? max;
  final bool maxExclusive;

  bool allows(num value) {
    if (min != null && (minExclusive ? value <= min! : value < min!)) {
      return false;
    }
    if (max != null && (maxExclusive ? value >= max! : value > max!)) {
      return false;
    }
    return true;
  }

  /// The issue this value causes, or `null` when it is in range.
  ValidationIssue? validate(AssumptionKey key, num value) {
    if (min != null && (minExclusive ? value <= min! : value < min!)) {
      return ValidationIssue(
        key: key,
        code: minExclusive
            ? ValidationCode.mustBeGreaterThan
            : ValidationCode.mustBeAtLeast,
        limit: min,
      );
    }
    if (max != null && (maxExclusive ? value >= max! : value > max!)) {
      return ValidationIssue(
        key: key,
        code: ValidationCode.mustNotExceed,
        limit: max,
      );
    }
    return null;
  }
}

/// The allowed range of every named numeric input.
///
/// One table, used both by the scenario validator and by the input widgets, so
/// a field can never enforce a different rule from the one the domain applies.
abstract final class InputRules {
  static const NumericRule _nonNegative = NumericRule(min: 0);
  static const NumericRule _positive = NumericRule(min: 0, minExclusive: true);
  static const NumericRule _percent = NumericRule(min: 0, max: 100);

  static const Map<AssumptionKey, NumericRule> rules = {
    AssumptionKey.roundDuration: _positive,
    AssumptionKey.turnaroundTime: _nonNegative,
    AssumptionKey.ticketPrice: _nonNegative,
    AssumptionKey.averagePlayersPerRound: _positive,
    AssumptionKey.maximumPlayersPerRound: NumericRule(min: 1),
    AssumptionKey.operatingHoursPerDay: NumericRule(
      min: 0,
      minExclusive: true,
      max: 24,
    ),
    AssumptionKey.operatingDaysPerWeek: NumericRule(min: 1, max: 7),
    AssumptionKey.operatingDaysPerMonth: NumericRule(
      min: 0,
      minExclusive: true,
      max: 31,
    ),
    AssumptionKey.occupancyMonth1: _percent,
    AssumptionKey.occupancyMonth2: _percent,
    AssumptionKey.occupancyMonth3: _percent,
    AssumptionKey.stableOccupancy: _percent,
    AssumptionKey.initialEmployeeCount: _nonNegative,
    AssumptionKey.expandedEmployeeCount: _nonNegative,
    AssumptionKey.expansionMonth: NumericRule(min: 1),
    AssumptionKey.monthlySalaryPerEmployee: _nonNegative,
    AssumptionKey.monthlyIncentivePerEmployee: _nonNegative,
    AssumptionKey.rent: _nonNegative,
    AssumptionKey.mallSharedServices: _nonNegative,
    AssumptionKey.electricity: _nonNegative,
    AssumptionKey.maintenance: _nonNegative,
    AssumptionKey.continuousMarketing: _nonNegative,
    AssumptionKey.mallDeposit: _nonNegative,
    AssumptionKey.contractDurationMonths: _nonNegative,
    AssumptionKey.shippingRate: _nonNegative,
    AssumptionKey.customsRate: _nonNegative,
    AssumptionKey.fitOutFurniture: _nonNegative,
    AssumptionKey.fitOutPainting: _nonNegative,
    AssumptionKey.fitOutSignage: _nonNegative,
    AssumptionKey.fitOutHvac: _nonNegative,
    AssumptionKey.fitOutInstallationLabour: _nonNegative,
    AssumptionKey.licensing: _nonNegative,
    AssumptionKey.openingMarketing: _nonNegative,
    AssumptionKey.contingencyRate: _nonNegative,
    AssumptionKey.maximumSetupDays: _nonNegative,
    AssumptionKey.projectionMonths: NumericRule(min: 1, max: 600),
    AssumptionKey.conservativeOccupancy: _percent,
    AssumptionKey.optimisticOccupancy: _percent,
  };

  static NumericRule ruleFor(AssumptionKey key) =>
      rules[key] ?? const NumericRule();

  /// Validates one value in isolation. Cross-field rules live in the scenario
  /// validator, because a single field cannot see them.
  static ValidationIssue? validate(AssumptionKey key, num value) =>
      ruleFor(key).validate(key, value);
}
