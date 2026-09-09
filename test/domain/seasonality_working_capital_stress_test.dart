import 'package:flutter_test/flutter_test.dart';
import 'package:the_floor_is_lava/features/financial_model/domain/entities/scenario/payment_assumptions.dart';
import 'package:the_floor_is_lava/features/financial_model/domain/entities/scenario/revenue_model.dart';
import 'package:the_floor_is_lava/features/financial_model/domain/entities/scenario/seasonality_model.dart';
import 'package:the_floor_is_lava/features/financial_model/domain/entities/scenario/stress_assumptions.dart';
import 'package:the_floor_is_lava/features/financial_model/domain/entities/scenario/working_capital_model.dart';
import 'package:the_floor_is_lava/features/financial_model/domain/services/financial_model_calculator.dart';
import 'package:the_floor_is_lava/features/financial_model/domain/services/seasonality_calculator.dart';
import 'package:the_floor_is_lava/features/financial_model/domain/value_objects/money.dart';
import 'package:the_floor_is_lava/features/financial_model/domain/value_objects/percentage.dart';

import '../fixtures/money_matchers.dart';
import '../fixtures/scenario_fixtures.dart';

void main() {
  const calculator = FinancialModelCalculator();

  test('disabled seasonality preserves the baseline occupancy path', () {
    final base = calculator.calculate(baseline());
    final disabled = calculator.calculate(
      baseline().copyWith(seasonality: const SeasonalityModel(enabled: false)),
    );

    expect(disabled.monthlyResults, base.monthlyResults);
  });

  test('a 2x month factor clamps 50% occupancy to 100%', () {
    final result = SeasonalityCalculator().effectiveOccupancy(
      baseOccupancy: Percentage.fromPercent(50),
      projectionMonth: 1,
      model: SeasonalityModel(enabled: true, monthFactors: {1: 2}),
    );

    expect(result, Percentage.one);
  });

  test('fixed working capital increases funding and remains after month 0', () {
    final projection = calculator.calculate(
      baseline().copyWith(
        workingCapital: const WorkingCapitalModel(
          fixedAmount: Money.units(5000),
        ),
      ),
    );

    expect(projection.workingCapitalRequirement, isMoney(5000));
    expect(
      projection.requiredFunding,
      projection.initialInvestment + const Money.units(5000),
    );
    expect(projection.cashPositions.first.endingCash, isMoney(5000));
    expect(
      projection.monthlyResults.first.netCashFlow,
      -projection.initialInvestment,
    );
  });

  test('critical failure reduces only its configured month revenue', () {
    final base = calculator.calculate(baseline());
    final stressed = calculator.calculate(
      baseline().copyWith(
        stressAssumptions: const StressAssumptions(
          criticalFailureEnabled: true,
          failureStartMonth: 6,
          downtimeDays: 14,
        ),
      ),
    );

    expect(
      stressed.monthlyResults[5].monthlyRevenue,
      base.monthlyResults[5].monthlyRevenue,
    );
    expect(
      stressed.monthlyResults[6].monthlyRevenue,
      lessThan(base.monthlyResults[6].monthlyRevenue),
    );
    expect(
      base.monthlyResults[6].monthlyRevenue,
      base.monthlyResults[5].monthlyRevenue,
    );
  });

  test('zero payment fee assumptions leave results unchanged', () {
    final base = calculator.calculate(baseline());
    final zeroFees = calculator.calculate(
      baseline().copyWith(
        paymentAssumptions: const PaymentAssumptions(
          digitalPaymentShare: Percentage.one,
          digitalPaymentFeeRate: Percentage.zero,
        ),
      ),
    );

    expect(zeroFees.monthlyResults, base.monthlyResults);
  });

  test('funding gap exposes a negative cash balance', () {
    final scenario = baseline();
    final projection = calculator.calculate(
      scenario.copyWith(
        revenue: scenario.revenue.copyWith(
          occupancy: const OccupancySchedule(
            rampUp: [],
            stable: Percentage.zero,
          ),
        ),
      ),
    );

    expect(projection.minimumEndingCash.isNegative, isTrue);
    expect(projection.fundingGap, -projection.minimumEndingCash);
    expect(
      projection.cashPositions.any(
        (position) => position.fundingGapThisMonth.isPositive,
      ),
      isTrue,
    );
  });
}
