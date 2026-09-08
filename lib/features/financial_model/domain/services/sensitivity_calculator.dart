import '../entities/results/sensitivity_result.dart';
import '../entities/scenario/financial_scenario.dart';
import '../entities/scenario/sensitivity_settings.dart';
import '../value_objects/money.dart';
import '../value_objects/percentage.dart';
import 'capacity_calculator.dart';
import 'revenue_calculator.dart';

/// Evaluates the same business at different demand levels.
///
/// Each case describes a *normal* month, so it is costed at steady state - the
/// final headcount and the flat monthly cost base - rather than at a ramp-up
/// month. The source study leaves this implicit; making it explicit is the only
/// way the numbers can be reproduced and explained.
class SensitivityCalculator {
  const SensitivityCalculator({
    this.capacityCalculator = const CapacityCalculator(),
    this.revenueCalculator = const RevenueCalculator(),
  });

  final CapacityCalculator capacityCalculator;
  final RevenueCalculator revenueCalculator;

  List<SensitivityResult> calculate({
    required FinancialScenario scenario,
    required int maximumRoundsPerDay,
    required Money steadyStateOperatingExpenses,
    required Money initialInvestment,
  }) {
    return [
      for (final definition in scenario.sensitivity.scenarios)
        _evaluate(
          definition: definition,
          scenario: scenario,
          maximumRoundsPerDay: maximumRoundsPerDay,
          steadyStateOperatingExpenses: steadyStateOperatingExpenses,
          initialInvestment: initialInvestment,
        ),
    ];
  }

  SensitivityResult _evaluate({
    required SensitivityScenarioDefinition definition,
    required FinancialScenario scenario,
    required int maximumRoundsPerDay,
    required Money steadyStateOperatingExpenses,
    required Money initialInvestment,
  }) {
    // A case without its own occupancy tracks the scenario's stable level -
    // this is how the study defines its Base case.
    final Percentage occupancy =
        definition.occupancy ?? scenario.revenue.occupancy.stable;

    final actualRoundsPerDay = capacityCalculator.actualRoundsPerDay(
      maximumRoundsPerDay,
      occupancy,
    );
    final dailyRevenue = revenueCalculator.dailyRevenue(
      actualRoundsPerDay: actualRoundsPerDay,
      pricing: scenario.revenue.pricing,
    );
    final monthlyRevenue = revenueCalculator.monthlyRevenue(
      dailyRevenue: dailyRevenue,
      operatingDaysPerMonth: scenario.revenue.schedule.daysPerMonth,
    );
    final monthlyProfit = monthlyRevenue - steadyStateOperatingExpenses;

    return SensitivityResult(
      definition: definition,
      occupancy: occupancy,
      actualRoundsPerDay: actualRoundsPerDay,
      monthlyRevenue: monthlyRevenue,
      monthlyOperatingExpenses: steadyStateOperatingExpenses,
      monthlyProfit: monthlyProfit,
      // A case that does not turn a profit never pays the investment back;
      // reporting a negative or infinite number of months would be meaningless.
      approximatePaybackMonths: monthlyProfit.isPositive
          ? initialInvestment.ratioTo(monthlyProfit)
          : null,
    );
  }
}
