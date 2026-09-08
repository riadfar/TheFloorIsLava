import 'package:flutter_test/flutter_test.dart';
import 'package:the_floor_is_lava/features/financial_model/domain/entities/scenario/financial_scenario.dart';
import 'package:the_floor_is_lava/features/financial_model/domain/entities/scenario/projection_settings.dart';
import 'package:the_floor_is_lava/features/financial_model/domain/entities/scenario/revenue_model.dart';
import 'package:the_floor_is_lava/features/financial_model/domain/services/financial_model_calculator.dart';
import 'package:the_floor_is_lava/features/financial_model/domain/value_objects/money.dart';
import 'package:the_floor_is_lava/features/financial_model/domain/value_objects/percentage.dart';

import '../fixtures/money_matchers.dart';
import '../fixtures/scenario_fixtures.dart';

/// Rebuilds the baseline at a flat occupancy, which makes every trading month
/// identical and the cash-flow arithmetic easy to reason about.
FinancialScenario flatOccupancy(num percent, {int months = 24}) {
  final scenario = baseline();
  return scenario.copyWith(
    revenue: scenario.revenue.copyWith(
      occupancy: OccupancySchedule(
        rampUp: const [],
        stable: Percentage.fromPercent(percent),
      ),
    ),
    projection: ProjectionSettings(projectionMonths: months),
  );
}

void main() {
  const calculator = FinancialModelCalculator();

  group('cash flow', () {
    test('month 0 is the only month that spends the investment', () {
      final projection = calculator.calculate(baseline());
      expect(projection.investmentMonth.investmentOutflow, isMoney(16411.89));
      for (final month in projection.tradingMonths) {
        expect(month.investmentOutflow, isMoney(0));
        expect(month.netCashFlow, month.operatingProfit);
      }
    });

    test('a projection of zero months still reports the investment', () {
      final projection = calculator.calculate(
        baseline().copyWith(
          projection: const ProjectionSettings(projectionMonths: 0),
        ),
      );
      expect(projection.monthlyResults.length, 1);
      expect(projection.investmentMonth.cumulativeCashFlow, isMoney(-16411.89));
      expect(projection.payback.isRecovered, isFalse);
      expect(projection.annualResults, isEmpty);
    });

    test('zero revenue gives a zero margin flagged as undefined', () {
      final projection = calculator.calculate(flatOccupancy(0));
      final month = projection.monthlyResults[1];
      expect(month.monthlyRevenue, isMoney(0));
      expect(month.isProfitMarginDefined, isFalse);
      expect(month.profitMargin, Percentage.zero);
      // Month 1 still runs on the starting headcount of two, so the loss is
      // the pre-expansion cost base, not the steady-state one.
      expect(month.employeeCount, 2);
      expect(month.operatingProfit, isMoney(-3930));
    });
  });

  group('payback', () {
    test(
      'a profitable project reports both the month and a finer estimate',
      () {
        final projection = calculator.calculate(baseline());
        expect(projection.payback.lastNegativeMonth, 4);
        expect(projection.payback.firstNonNegativeMonth, 5);
        expect(projection.payback.paybackMonth, 5);
        expect(projection.payback.interpolatedMonths, closeTo(4.951, 1e-3));
      },
    );

    test('a loss-making project never recovers', () {
      final projection = calculator.calculate(flatOccupancy(10));
      expect(projection.payback.isRecovered, isFalse);
      expect(projection.payback.paybackMonth, isNull);
      expect(projection.payback.interpolatedMonths, isNull);
      expect(projection.payback.lastNegativeMonth, 24);
    });

    test('a project that only breaks even never recovers the investment', () {
      // Revenue exactly equal to the cost base: profit is zero every month, so
      // the month-0 outflow is never repaid.
      final scenario = flatOccupancy(0);
      final breakEven = scenario.copyWith(
        operatingExpenses: scenario.operatingExpenses.copyWith(
          rent: Money.zero,
          mallSharedServices: Money.zero,
          electricity: Money.zero,
          maintenanceAndConsumables: Money.zero,
          continuousMarketing: Money.zero,
        ),
        staffing: scenario.staffing.copyWith(
          monthlySalaryPerEmployee: Money.zero,
          monthlyIncentivePerEmployee: Money.zero,
        ),
      );
      final projection = calculator.calculate(breakEven);
      for (final month in projection.tradingMonths) {
        expect(month.operatingProfit, isMoney(0));
      }
      expect(projection.payback.isRecovered, isFalse);
    });

    test('a project with no investment is paid back at month 0', () {
      final scenario = baseline();
      final free = scenario.copyWith(
        operatingExpenses: scenario.operatingExpenses.copyWith(
          rent: Money.zero,
        ),
        startupCosts: scenario.startupCosts.copyWith(
          equipment: scenario.startupCosts.equipment.copyWith(
            packages: [
              for (final package in scenario.startupCosts.equipment.packages)
                package.copyWith(cost: Money.zero),
            ],
          ),
          fitOut: scenario.startupCosts.fitOut.copyWith(
            receptionFurniture: Money.zero,
            paintingAndGraphics: Money.zero,
            signage: Money.zero,
            hvac: Money.zero,
            installationLabour: Money.zero,
          ),
          preOpening: scenario.startupCosts.preOpening.copyWith(
            registrationAndLicensing: Money.zero,
            openingMarketingCampaign: Money.zero,
          ),
        ),
      );
      final projection = calculator.calculate(free);
      expect(projection.initialInvestment, isMoney(0));
      expect(projection.payback.paybackMonth, 0);
      expect(projection.payback.lastNegativeMonth, isNull);
      expect(projection.payback.interpolatedMonths, 0);
    });

    test('the interpolated payback sits inside the crossing month', () {
      final projection = calculator.calculate(baseline());
      final interpolated = projection.payback.interpolatedMonths!;
      expect(interpolated, greaterThan(4));
      expect(interpolated, lessThanOrEqualTo(5));
    });
  });

  group('annual results and ROI', () {
    test('years cover months 1-12 and 13-24, never month 0', () {
      final projection = calculator.calculate(baseline());
      expect(projection.yearOne!.firstMonth, 1);
      expect(projection.yearOne!.lastMonth, 12);
      expect(projection.yearTwo!.firstMonth, 13);
      expect(projection.yearTwo!.lastMonth, 24);
      expect(projection.annualResults.length, 2);
      expect(projection.yearOne!.isComplete, isTrue);
    });

    test('a short projection reports a partial year as incomplete', () {
      final projection = calculator.calculate(
        baseline().copyWith(
          projection: const ProjectionSettings(projectionMonths: 8),
        ),
      );
      expect(projection.annualResults.length, 1);
      expect(projection.yearOne!.isComplete, isFalse);
      expect(projection.yearTwo, isNull);
    });

    test('ROI is year-1 profit over the initial investment', () {
      final projection = calculator.calculate(baseline());
      final roi = projection.roi;
      expect(
        roi.yearOneRoi!.fraction,
        closeTo(roi.yearOneProfit.amount / roi.initialInvestment.amount, 1e-12),
      );
    });

    test('ROI is undefined, not infinite, when nothing was invested', () {
      final scenario = baseline();
      final free = scenario.copyWith(
        operatingExpenses: scenario.operatingExpenses.copyWith(
          rent: Money.zero,
        ),
        startupCosts: scenario.startupCosts.copyWith(
          equipment: scenario.startupCosts.equipment.copyWith(
            packages: [
              for (final package in scenario.startupCosts.equipment.packages)
                package.copyWith(cost: Money.zero),
            ],
          ),
          fitOut: scenario.startupCosts.fitOut.copyWith(
            receptionFurniture: Money.zero,
            paintingAndGraphics: Money.zero,
            signage: Money.zero,
            hvac: Money.zero,
            installationLabour: Money.zero,
          ),
          preOpening: scenario.startupCosts.preOpening.copyWith(
            registrationAndLicensing: Money.zero,
            openingMarketingCampaign: Money.zero,
          ),
        ),
      );
      final projection = calculator.calculate(free);
      expect(projection.roi.isDefined, isFalse);
      expect(projection.roi.yearOneRoi, isNull);
    });

    test('a loss-making year gives a negative ROI', () {
      final projection = calculator.calculate(flatOccupancy(5));
      expect(projection.roi.yearOneRoi!.fraction, lessThan(0));
    });
  });

  group('sensitivity edge cases', () {
    test('a case that breaks exactly even is not recoverable', () {
      // Occupancy chosen so revenue equals the steady-state cost base.
      final scenario = baseline();
      final zeroCost = scenario.copyWith(
        operatingExpenses: scenario.operatingExpenses.copyWith(
          rent: Money.zero,
          mallSharedServices: Money.zero,
          electricity: Money.zero,
          maintenanceAndConsumables: Money.zero,
          continuousMarketing: Money.zero,
        ),
        staffing: scenario.staffing.copyWith(
          monthlySalaryPerEmployee: Money.zero,
          monthlyIncentivePerEmployee: Money.zero,
        ),
        revenue: scenario.revenue.copyWith(
          occupancy: const OccupancySchedule(
            rampUp: [],
            stable: Percentage.zero,
          ),
        ),
      );
      final projection = calculator.calculate(zeroCost);
      final base = projection.sensitivityResults.firstWhere(
        (result) => result.definition.id == 'base',
      );
      expect(base.monthlyProfit, isMoney(0));
      expect(base.isRecoverable, isFalse);
      expect(base.approximatePaybackMonths, isNull);
    });

    test('every case is costed at the steady-state expense base', () {
      final projection = calculator.calculate(baseline());
      for (final result in projection.sensitivityResults) {
        expect(result.monthlyOperatingExpenses, isMoney(4120));
      }
    });

    test('the base case follows a change to stable occupancy', () {
      final projection = calculator.calculate(flatOccupancy(50));
      final base = projection.sensitivityResults.firstWhere(
        (result) => result.definition.id == 'base',
      );
      expect(base.occupancy.percent, closeTo(50, 1e-9));
    });
  });

  group('propagation', () {
    test('a ticket price change flows through to ROI', () {
      final cheaper = baseline().copyWith(
        revenue: baseline().revenue.copyWith(
          pricing: baseline().revenue.pricing.copyWith(
            ticketPricePerPlayer: Money.units(2),
          ),
        ),
      );
      final before = calculator.calculate(baseline());
      final after = calculator.calculate(cheaper);

      expect(
        after.steadyStateMonth!.monthlyRevenue.micros,
        before.steadyStateMonth!.monthlyRevenue.micros ~/ 2,
      );
      expect(
        after.roi.yearOneRoi!.fraction,
        lessThan(before.roi.yearOneRoi!.fraction),
      );
      expect(
        after.payback.paybackMonth,
        greaterThan(before.payback.paybackMonth!),
      );
    });

    test('the calculation is deterministic', () {
      final scenario = baseline();
      expect(calculator.calculate(scenario), calculator.calculate(scenario));
    });
  });
}
