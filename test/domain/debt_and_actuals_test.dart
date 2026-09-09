import 'package:flutter_test/flutter_test.dart';
import 'package:the_floor_is_lava/features/financial_model/domain/entities/scenario/actuals_ledger.dart';
import 'package:the_floor_is_lava/features/financial_model/domain/entities/scenario/debt_assumptions.dart';
import 'package:the_floor_is_lava/features/financial_model/domain/services/debt_calculator.dart';
import 'package:the_floor_is_lava/features/financial_model/domain/services/financial_model_calculator.dart';
import 'package:the_floor_is_lava/features/financial_model/domain/value_objects/money.dart';
import 'package:the_floor_is_lava/features/financial_model/domain/value_objects/percentage.dart';

import '../fixtures/scenario_fixtures.dart';

void main() {
  const debtCalculator = DebtCalculator();
  const modelCalculator = FinancialModelCalculator();

  group('debt financing', () {
    test('disabled debt leaves baseline cash flows unchanged', () {
      final original = modelCalculator.calculate(baseline());
      final explicitlyDisabled = modelCalculator.calculate(
        baseline().copyWith(
          debtAssumptions: const DebtAssumptions(
            enabled: false,
            principal: Money.units(10000),
            annualInterestRate: Percentage.fromPercent(12),
            termMonths: 12,
          ),
        ),
      );

      expect(
        explicitlyDisabled.monthlyResults
            .map((month) => month.netCashFlow)
            .toList(),
        original.monthlyResults.map((month) => month.netCashFlow).toList(),
      );
      expect(explicitlyDisabled.roi, original.roi);
    });

    test('zero-interest annuity repays equal principal amounts', () {
      final schedule = debtCalculator.calculate(
        const DebtAssumptions(
          enabled: true,
          principal: Money.units(1200),
          termMonths: 12,
        ),
      );

      expect(schedule, hasLength(12));
      for (final payment in schedule) {
        expect(payment.interest, Money.zero);
        expect(payment.principalPortion, const Money.units(100));
        expect(payment.totalPayment, const Money.units(100));
      }
      expect(schedule.last.remainingBalance, Money.zero);
    });

    test('annuity matches a known 12% nominal annual case', () {
      final schedule = debtCalculator.calculate(
        const DebtAssumptions(
          enabled: true,
          principal: Money.units(1200),
          annualInterestRate: Percentage.fromPercent(12),
          termMonths: 12,
        ),
      );

      expect(schedule.first.interest.amount, closeTo(12, 0.000001));
      expect(schedule.first.totalPayment.amount, closeTo(106.618546, 0.000001));
      expect(
        schedule.first.principalPortion.amount,
        closeTo(94.618546, 0.000001),
      );
      expect(schedule.last.remainingBalance, Money.zero);
    });

    test('month-zero disbursement reduces the funding gap', () {
      final withoutDebt = modelCalculator.calculate(baseline());
      final withDebt = modelCalculator.calculate(
        baseline().copyWith(
          debtAssumptions: const DebtAssumptions(
            enabled: true,
            principal: Money.units(10000),
            termMonths: 24,
          ),
        ),
      );

      expect(withDebt.investmentMonth.debtInflow, const Money.units(10000));
      expect(
        withDebt.investmentMonth.netCashFlow,
        withoutDebt.investmentMonth.netCashFlow + const Money.units(10000),
      );
      expect(withDebt.fundingGap, lessThan(withoutDebt.fundingGap));
      expect(
        withDebt.monthlyResults[1].operatingProfit,
        withoutDebt.monthlyResults[1].operatingProfit,
        reason: 'debt service is financing, not an operating expense',
      );
    });
  });

  group('actual versus forecast', () {
    test('an empty ledger produces no variance rows', () {
      expect(modelCalculator.calculate(baseline()).variances, isEmpty);
    });

    test('variance is actual minus forecast', () {
      final forecast = modelCalculator.calculate(baseline()).monthlyResults[1];
      final scenario = baseline().copyWith(
        actuals: ActualsLedger(
          months: [
            MonthlyActuals(
              monthNumber: 1,
              revenue: forecast.monthlyRevenue + const Money.units(250),
              operatingExpenses:
                  forecast.totalOperatingExpenses + const Money.units(40),
            ),
          ],
        ),
      );

      final variance = modelCalculator.calculate(scenario).variances.single;
      expect(variance.revenueVariance, const Money.units(250));
      expect(variance.expenseVariance, const Money.units(40));
      expect(variance.profitVariance, const Money.units(210));
      expect(
        variance.actualProfit,
        variance.actualRevenue! - variance.actualExpenses!,
      );
    });
  });
}
