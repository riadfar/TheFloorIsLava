import '../entities/results/annual_result.dart';
import '../entities/results/monthly_financial_result.dart';
import '../entities/scenario/projection_settings.dart';
import '../value_objects/money.dart';

/// Rolls trading months up into years.
class AnnualResultsCalculator {
  const AnnualResultsCalculator();

  /// Groups months 1..12 into year 1, 13..24 into year 2, and so on.
  ///
  /// Month 0 is excluded: it carries the investment, not an operating result.
  /// A year that the projection does not fully cover is still reported, marked
  /// incomplete, rather than silently dropped.
  List<AnnualResult> calculate(List<MonthlyFinancialResult> monthlyResults) {
    final tradingMonths = monthlyResults
        .where((month) => !month.isInvestmentMonth)
        .toList();
    if (tradingMonths.isEmpty) return const [];

    const monthsPerYear = ProjectionSettings.monthsPerYear;
    final lastMonthNumber = tradingMonths.last.monthNumber;
    final yearCount = (lastMonthNumber / monthsPerYear).ceil();

    return [
      for (var year = 1; year <= yearCount; year++)
        _buildYear(tradingMonths, year, monthsPerYear),
    ];
  }

  AnnualResult _buildYear(
    List<MonthlyFinancialResult> tradingMonths,
    int yearNumber,
    int monthsPerYear,
  ) {
    final firstMonth = (yearNumber - 1) * monthsPerYear + 1;
    final lastMonth = yearNumber * monthsPerYear;
    final monthsInYear = tradingMonths
        .where(
          (month) =>
              month.monthNumber >= firstMonth && month.monthNumber <= lastMonth,
        )
        .toList();

    return AnnualResult(
      yearNumber: yearNumber,
      firstMonth: firstMonth,
      lastMonth: lastMonth,
      revenue: Money.sum(monthsInYear.map((month) => month.monthlyRevenue)),
      operatingExpenses: Money.sum(
        monthsInYear.map((month) => month.totalOperatingExpenses),
      ),
      operatingProfit: Money.sum(
        monthsInYear.map((month) => month.operatingProfit),
      ),
      isComplete: monthsInYear.length == monthsPerYear,
    );
  }
}
