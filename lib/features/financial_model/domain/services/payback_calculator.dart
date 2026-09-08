import '../entities/results/monthly_financial_result.dart';
import '../entities/results/payback_result.dart';
import '../value_objects/money.dart';

/// Finds the month in which the investment is earned back.
class PaybackCalculator {
  const PaybackCalculator();

  /// Scans the cumulative cash-flow column for the first crossing into
  /// non-negative territory.
  ///
  /// Two figures come out of this: the workbook's answer (the crossing month
  /// itself) and a fractional refinement that assumes the crossing month's cash
  /// arrives evenly across that month.
  PaybackResult calculate(List<MonthlyFinancialResult> monthlyResults) {
    int? lastNegativeMonth;
    Money? previousCumulative;

    for (final month in monthlyResults) {
      if (month.cumulativeCashFlow.isNegative) {
        lastNegativeMonth = month.monthNumber;
        previousCumulative = month.cumulativeCashFlow;
        continue;
      }

      return PaybackResult(
        lastNegativeMonth: lastNegativeMonth,
        firstNonNegativeMonth: month.monthNumber,
        interpolatedMonths: _interpolate(
          lastNegativeMonth: lastNegativeMonth,
          previousCumulative: previousCumulative,
          month: month,
        ),
      );
    }

    return PaybackResult.notRecovered(lastNegativeMonth: lastNegativeMonth);
  }

  double? _interpolate({
    required int? lastNegativeMonth,
    required Money? previousCumulative,
    required MonthlyFinancialResult month,
  }) {
    // Never went negative: there was nothing to pay back.
    if (lastNegativeMonth == null || previousCumulative == null) {
      return month.monthNumber.toDouble();
    }
    // The shortfall has to be closed by an inflow to interpolate across.
    if (!month.netCashFlow.isPositive) return null;

    final fraction = previousCumulative.abs.ratioTo(month.netCashFlow);
    if (fraction == null) return null;
    return lastNegativeMonth + fraction;
  }
}
