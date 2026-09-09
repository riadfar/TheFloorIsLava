import 'package:flutter_test/flutter_test.dart';
import 'package:the_floor_is_lava/features/financial_model/domain/defaults/baseline_scenario.dart';
import 'package:the_floor_is_lava/features/financial_model/domain/entities/results/calculation_outcome.dart';
import 'package:the_floor_is_lava/features/financial_model/domain/services/discounted_payback_calculator.dart';
import 'package:the_floor_is_lava/features/financial_model/domain/services/financial_model_calculator.dart';
import 'package:the_floor_is_lava/features/financial_model/domain/services/irr_calculator.dart';
import 'package:the_floor_is_lava/features/financial_model/domain/services/npv_calculator.dart';
import 'package:the_floor_is_lava/features/financial_model/domain/value_objects/money.dart';
import 'package:the_floor_is_lava/features/financial_model/domain/value_objects/percentage.dart';

void main() {
  test('baseline operational break-even uses the steady-state cost base', () {
    final projection = const FinancialModelCalculator().calculate(
      BaselineScenario.build(),
    );

    final expected = 4120 / (39 * 3.63 * 4 * 30.4);
    expect(
      projection.breakEven.breakEvenOccupancy.value!.fraction,
      closeTo(expected, 1e-12),
    );
    expect(projection.breakEven.breakEvenRevenue.value, Money.units(4120));
  });

  test('NPV discounts monthly cash flows at annual nominal rate / 12', () {
    final npv = const NpvCalculator().calculate(
      monthlyCashFlows: [Money.units(-100), Money.units(110)],
      annualDiscountRate: const Percentage.fromPercent(12),
    );

    expect(npv.amount, closeTo(8.910891, 0.000001));
  });

  test('IRR solves a known monthly series and annualizes it', () {
    final result = const IrrCalculator().calculate([
      Money.units(-100),
      Money.units(60),
      Money.units(60),
    ]);

    expect(result.status, CalculationStatus.valid);
    expect(result.value!.monthly.fraction, closeTo(0.130662, 0.000001));
    expect(result.value!.annualized.fraction, closeTo(3.36507, 0.00001));
  });

  test('IRR with no cash-flow sign change has no solution, not zero', () {
    final result = const IrrCalculator().calculate([
      Money.units(100),
      Money.units(60),
      Money.units(60),
    ]);

    expect(result.status, CalculationStatus.noSolution);
    expect(result.value, isNull);
  });

  test('discounted payback reports the first non-negative month', () {
    final result = const DiscountedPaybackCalculator().calculate(
      monthlyCashFlows: [Money.units(-100), Money.units(60), Money.units(60)],
      annualDiscountRate: const Percentage.fromPercent(12),
    );

    expect(result.status, CalculationStatus.valid);
    expect(result.value, 2);
  });
}
