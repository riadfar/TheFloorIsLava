import 'package:equatable/equatable.dart';

import '../entities/results/monthly_financial_result.dart';
import '../entities/scenario/actuals_ledger.dart';
import '../value_objects/money.dart';

class MonthlyVariance extends Equatable {
  const MonthlyVariance({
    required this.monthNumber,
    required this.forecastRevenue,
    required this.actualRevenue,
    required this.revenueVariance,
    required this.forecastExpenses,
    required this.actualExpenses,
    required this.expenseVariance,
    required this.forecastProfit,
    required this.actualProfit,
    required this.profitVariance,
  });

  final int monthNumber;
  final Money forecastRevenue;
  final Money? actualRevenue;
  final Money? revenueVariance;
  final Money forecastExpenses;
  final Money? actualExpenses;
  final Money? expenseVariance;
  final Money forecastProfit;
  final Money? actualProfit;
  final Money? profitVariance;

  @override
  List<Object?> get props => [
    monthNumber,
    forecastRevenue,
    actualRevenue,
    revenueVariance,
    forecastExpenses,
    actualExpenses,
    expenseVariance,
    forecastProfit,
    actualProfit,
    profitVariance,
  ];
}

class VarianceCalculator {
  const VarianceCalculator();

  List<MonthlyVariance> calculate({
    required List<MonthlyFinancialResult> forecasts,
    required ActualsLedger actuals,
  }) {
    final forecastByMonth = {
      for (final forecast in forecasts)
        if (!forecast.isInvestmentMonth) forecast.monthNumber: forecast,
    };
    final variances = <MonthlyVariance>[];

    for (final actual in actuals.months) {
      final forecast = forecastByMonth[actual.monthNumber];
      if (forecast == null) continue;
      final actualProfit =
          actual.revenue != null && actual.operatingExpenses != null
          ? actual.revenue! - actual.operatingExpenses!
          : null;
      variances.add(
        MonthlyVariance(
          monthNumber: actual.monthNumber,
          forecastRevenue: forecast.monthlyRevenue,
          actualRevenue: actual.revenue,
          revenueVariance: actual.revenue == null
              ? null
              : actual.revenue! - forecast.monthlyRevenue,
          forecastExpenses: forecast.totalOperatingExpenses,
          actualExpenses: actual.operatingExpenses,
          expenseVariance: actual.operatingExpenses == null
              ? null
              : actual.operatingExpenses! - forecast.totalOperatingExpenses,
          forecastProfit: forecast.operatingProfit,
          actualProfit: actualProfit,
          profitVariance: actualProfit == null
              ? null
              : actualProfit - forecast.operatingProfit,
        ),
      );
    }
    variances.sort(
      (left, right) => left.monthNumber.compareTo(right.monthNumber),
    );
    return List.unmodifiable(variances);
  }
}
