import 'package:flutter_test/flutter_test.dart';
import 'package:the_floor_is_lava/features/financial_model/domain/defaults/baseline_scenario.dart';
import 'package:the_floor_is_lava/features/financial_model/domain/services/financial_model_calculator.dart';

import '../fixtures/money_matchers.dart';

/// Golden test for the original workbook.
///
/// Every figure below comes from the source feasibility study, not from this
/// implementation. If one of these fails, the engine has drifted away from the
/// study and the cause must be traced through the dependency chain rather than
/// papered over by adjusting the expectation.
void main() {
  const calculator = FinancialModelCalculator();
  final projection = calculator.calculate(BaselineScenario.build());

  group('baseline regression - capacity', () {
    test('a round consumes 20 minutes', () {
      expect(projection.capacity.totalRoundTime.value, 20);
    });

    test('39 rounds fit into a 13 hour day', () {
      expect(projection.capacity.maximumRoundsPerDay, 39);
    });
  });

  group('baseline regression - start-up costs', () {
    final startup = projection.startupCosts;

    test('the study selects equipment package 2 at \$5,270', () {
      expect(
        projection.scenario.startupCosts.equipment.selectedPackage.id,
        BaselineScenario.equipmentPackage2Id,
      );
      expect(startup.equipmentCost, isMoney(5270));
    });

    test('sea freight is 12% of equipment value', () {
      expect(startup.shipping, isMoney(632.40));
    });

    test('customs and clearance are 25% of equipment value', () {
      expect(startup.customs, isMoney(1317.50));
    });

    test('delivered equipment is \$7,219.90', () {
      expect(startup.deliveredEquipment.total, isMoney(7219.90));
    });

    test('fit-out is \$2,400', () {
      expect(startup.fitOut.total, isMoney(2400));
    });

    test('property is \$3,000 - no deposit plus one month of rent', () {
      expect(startup.property.total, isMoney(3000));
    });

    test('other pre-opening costs are \$2,300', () {
      expect(startup.preOpening.total, isMoney(2300));
    });

    test('subtotal before contingency is \$14,919.90', () {
      expect(startup.subtotal, isMoney(14919.90));
    });

    test('contingency at 10% is \$1,491.99', () {
      expect(startup.contingency, isMoney(1491.99));
    });

    test('total initial investment is \$16,411.89', () {
      expect(startup.total, isMoney(16411.89));
    });
  });

  group('baseline regression - monthly projection', () {
    test('month 0 carries the investment and nothing else', () {
      final month0 = projection.investmentMonth;
      expect(month0.monthlyRevenue, isMoney(0));
      expect(month0.totalOperatingExpenses, isMoney(0));
      expect(month0.operatingProfit, isMoney(0));
      expect(month0.investmentOutflow, isMoney(16411.89));
      expect(month0.netCashFlow, isMoney(-16411.89));
      expect(month0.cumulativeCashFlow, isMoney(-16411.89));
    });

    test('the occupancy ramp follows the study', () {
      expect(projection.monthlyResults[1].occupancy.percent, closeTo(8, 1e-9));
      expect(projection.monthlyResults[2].occupancy.percent, closeTo(23, 1e-9));
      expect(projection.monthlyResults[3].occupancy.percent, closeTo(46, 1e-9));
      expect(projection.monthlyResults[4].occupancy.percent, closeTo(69, 1e-9));
      expect(
        projection.monthlyResults[24].occupancy.percent,
        closeTo(69, 1e-9),
      );
    });

    test('a stable month runs 26.91 rounds a day', () {
      expect(
        projection.monthlyResults[4].actualRoundsPerDay,
        closeTo(26.91, 1e-9),
      );
    });

    test('a stable month takes \$390.7332 a day', () {
      expect(projection.monthlyResults[4].dailyRevenue, isMoney(390.7332));
    });

    test('a stable month takes \$11,878.28928', () {
      expect(projection.monthlyResults[4].monthlyRevenue, isMoney(11878.28928));
    });

    test('headcount steps up in month 3', () {
      expect(projection.monthlyResults[1].employeeCount, 2);
      expect(projection.monthlyResults[2].employeeCount, 2);
      expect(projection.monthlyResults[3].employeeCount, 3);
    });

    test(
      'operating expenses are \$3,930 before the expansion and \$4,120 after',
      () {
        expect(
          projection.monthlyResults[1].totalOperatingExpenses,
          isMoney(3930),
        );
        expect(
          projection.monthlyResults[2].totalOperatingExpenses,
          isMoney(3930),
        );
        expect(
          projection.monthlyResults[3].totalOperatingExpenses,
          isMoney(4120),
        );
        expect(
          projection.monthlyResults[4].totalOperatingExpenses,
          isMoney(4120),
        );
      },
    );

    test('a stable month profits \$7,758.28928', () {
      expect(projection.monthlyResults[4].operatingProfit, isMoney(7758.28928));
    });

    test('cumulative cash flow crosses zero during month 5', () {
      expect(
        projection.monthlyResults[4].cumulativeCashFlow,
        isMoney(-7378.11848),
      );
      expect(
        projection.monthlyResults[5].cumulativeCashFlow,
        isMoney(380.1708),
      );
    });
  });

  group('baseline regression - headline results', () {
    test('year-1 profit is \$71,100.08576', () {
      expect(projection.yearOne!.operatingProfit, isMoney(71100.08576));
    });

    test('year-2 profit is \$93,099.47136', () {
      expect(projection.yearTwo!.operatingProfit, isMoney(93099.47136));
    });

    test('year-1 ROI is 433.2% on the study definition', () {
      expect(projection.roi.yearOneRoi!.percent, closeTo(433.223, 0.001));
    });

    test('the investment is recovered in month 5', () {
      expect(projection.payback.paybackMonth, 5);
      expect(projection.payback.lastNegativeMonth, 4);
      expect(projection.payback.interpolatedMonths, closeTo(4.951, 0.001));
    });

    test('the steady state is month 4', () {
      expect(projection.steadyStateMonthNumber, 4);
      expect(projection.steadyStateMonth!.monthNumber, 4);
    });
  });

  group('baseline regression - sensitivity', () {
    test('the conservative case at 20% never recovers the investment', () {
      final conservative = projection.sensitivityResults[0];
      expect(conservative.occupancy.percent, closeTo(20, 1e-9));
      expect(conservative.monthlyRevenue, isMoney(3442.9824));
      expect(conservative.monthlyProfit, isMoney(-677.0176));
      expect(conservative.isRecoverable, isFalse);
      expect(conservative.approximatePaybackMonths, isNull);
    });

    test('the base case tracks the stable occupancy', () {
      final base = projection.sensitivityResults[1];
      expect(base.occupancy.percent, closeTo(69, 1e-9));
      expect(base.monthlyRevenue, isMoney(11878.28928));
      expect(base.monthlyProfit, isMoney(7758.28928));
      expect(base.approximatePaybackMonths, closeTo(2.1154, 0.0001));
    });

    test('the optimistic case at 60% recovers in about 2.6 months', () {
      final optimistic = projection.sensitivityResults[2];
      expect(optimistic.monthlyRevenue, isMoney(10328.9472));
      expect(optimistic.monthlyProfit, isMoney(6208.9472));
      expect(optimistic.approximatePaybackMonths, closeTo(2.6433, 0.0001));
    });
  });

  group('baseline regression - internal consistency', () {
    test('the projection covers month 0 plus 24 trading months', () {
      expect(projection.monthlyResults.length, 25);
      expect(projection.tradingMonths.length, 24);
    });

    test('cumulative cash flow equals the running sum of net cash flow', () {
      var running = 0;
      for (final month in projection.monthlyResults) {
        running += month.netCashFlow.micros;
        expect(
          month.cumulativeCashFlow.micros,
          running,
          reason: 'month ${month.monthNumber}',
        );
      }
    });

    test('cumulative revenue equals the running sum of monthly revenue', () {
      var running = 0;
      for (final month in projection.monthlyResults) {
        running += month.monthlyRevenue.micros;
        expect(
          month.cumulativeRevenue.micros,
          running,
          reason: 'month ${month.monthNumber}',
        );
      }
    });

    test('each month reconciles revenue, expenses and profit', () {
      for (final month in projection.monthlyResults) {
        expect(
          month.operatingProfit,
          month.monthlyRevenue - month.totalOperatingExpenses,
          reason: 'month ${month.monthNumber}',
        );
        expect(
          month.totalOperatingExpenses,
          month.payroll + month.otherOperatingExpenses,
          reason: 'month ${month.monthNumber}',
        );
      }
    });

    test('start-up groups reconcile to the total investment', () {
      final startup = projection.startupCosts;
      final groupTotal = startup.groups.fold(
        0,
        (sum, group) => sum + group.total.micros,
      );
      expect(startup.subtotal.micros, groupTotal);
      expect(
        startup.total.micros,
        startup.subtotal.micros + startup.contingency.micros,
      );

      for (final group in startup.groups) {
        final lineTotal = group.lines.fold(
          0,
          (sum, line) => sum + line.amount.micros,
        );
        expect(group.total.micros, lineTotal, reason: '${group.id}');
      }
    });

    test('year totals reconcile with the months they cover', () {
      for (final year in projection.annualResults) {
        final months = projection.tradingMonths.where(
          (month) =>
              month.monthNumber >= year.firstMonth &&
              month.monthNumber <= year.lastMonth,
        );
        final expected = months.fold(
          0,
          (sum, month) => sum + month.operatingProfit.micros,
        );
        expect(
          year.operatingProfit.micros,
          expected,
          reason: 'year ${year.yearNumber}',
        );
      }
    });
  });
}
