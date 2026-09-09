import 'package:flutter_test/flutter_test.dart';
import 'package:the_floor_is_lava/features/financial_model/domain/defaults/baseline_scenario.dart';
import 'package:the_floor_is_lava/features/financial_model/domain/entities/scenario/equipment_lifecycle_assumptions.dart';
import 'package:the_floor_is_lava/features/financial_model/domain/entities/scenario/marketing_assumptions.dart';
import 'package:the_floor_is_lava/features/financial_model/domain/services/financial_model_calculator.dart';
import 'package:the_floor_is_lava/features/financial_model/domain/value_objects/money.dart';
import 'package:the_floor_is_lava/features/financial_model/domain/value_objects/percentage.dart';

void main() {
  const calculator = FinancialModelCalculator();

  test('default occupancy mode preserves every baseline monthly result', () {
    final baseline = BaselineScenario.build(now: DateTime.utc(2026));
    final explicitModeA = baseline.copyWith(
      marketingAssumptions: baseline.marketingAssumptions.copyWith(
        mode: MarketingForecastMode.occupancyDriven,
      ),
    );

    expect(
      calculator.calculate(explicitModeA).monthlyResults,
      calculator.calculate(baseline).monthlyResults,
    );
  });

  test('marketing mode derives demand and changes revenue', () {
    final baseline = BaselineScenario.build(now: DateTime.utc(2026));
    final scenario = baseline.copyWith(
      marketingAssumptions: const MarketingAssumptions(
        mode: MarketingForecastMode.marketingDriven,
        reach: 1000,
        conversionRate: Percentage.fromPercent(50),
        averageRoundsPerConvertedCustomer: 1,
      ),
    );

    final result = calculator.calculate(scenario);
    expect(result.monthlyResults[1].occupancy.percent, closeTo(42.1727, 0.001));
    expect(
      result.monthlyResults[1].monthlyRevenue,
      isNot(calculator.calculate(baseline).monthlyResults[1].monthlyRevenue),
    );
  });

  test('zero marketing demand falls back to occupancy schedule', () {
    final scenario = BaselineScenario.build(now: DateTime.utc(2026)).copyWith(
      marketingAssumptions: const MarketingAssumptions(
        mode: MarketingForecastMode.marketingDriven,
      ),
    );
    expect(
      calculator.calculate(scenario).monthlyResults[1].occupancy.percent,
      8,
    );
  });

  test('equipment reserves increase monthly other opex', () {
    final baseline = BaselineScenario.build(now: DateTime.utc(2026));
    final scenario = baseline.copyWith(
      startupCosts: baseline.startupCosts.copyWith(
        equipmentLifecycle: const EquipmentLifecycleAssumptions(
          monthlyMaintenanceReserve: Money.units(10),
        ),
      ),
    );

    final baseMonth = calculator.calculate(baseline).monthlyResults[1];
    final changedMonth = calculator.calculate(scenario).monthlyResults[1];
    expect(
      changedMonth.otherOperatingExpenses,
      baseMonth.otherOperatingExpenses + const Money.units(10),
    );
  });

  test('planned replacement adds an investment outflow at month 24', () {
    final baseline = BaselineScenario.build(now: DateTime.utc(2026));
    final scenario = baseline.copyWith(
      startupCosts: baseline.startupCosts.copyWith(
        equipmentLifecycle: const EquipmentLifecycleAssumptions(
          includeReplacementInProjection: true,
          replacementCost: Money.units(1000),
        ),
      ),
    );

    final projection = calculator.calculate(scenario);
    expect(projection.monthlyResults[23].investmentOutflow, Money.zero);
    expect(projection.monthlyResults[24].investmentOutflow, Money.units(1000));
    expect(
      projection.monthlyResults[24].netCashFlow,
      projection.monthlyResults[24].operatingProfit - const Money.units(1000),
    );
  });
}
