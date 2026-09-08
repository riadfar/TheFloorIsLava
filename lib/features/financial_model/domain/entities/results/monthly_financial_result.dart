import 'package:equatable/equatable.dart';

import '../../value_objects/money.dart';
import '../../value_objects/percentage.dart';

/// One row of the projection.
///
/// Month 0 is the investment month: it does not trade, so every trading figure
/// is zero and the whole start-up cost appears as [investmentOutflow].
class MonthlyFinancialResult extends Equatable {
  const MonthlyFinancialResult({
    required this.monthNumber,
    required this.occupancy,
    required this.maximumRoundsPerDay,
    required this.actualRoundsPerDay,
    required this.dailyRevenue,
    required this.monthlyRevenue,
    required this.cumulativeRevenue,
    required this.employeeCount,
    required this.payroll,
    required this.otherOperatingExpenses,
    required this.totalOperatingExpenses,
    required this.operatingProfit,
    required this.profitMargin,
    required this.isProfitMarginDefined,
    required this.investmentOutflow,
    required this.netCashFlow,
    required this.cumulativeCashFlow,
  });

  /// 0 for the investment month, then 1..n for trading months.
  final int monthNumber;

  final Percentage occupancy;
  final int maximumRoundsPerDay;
  final double actualRoundsPerDay;
  final Money dailyRevenue;
  final Money monthlyRevenue;
  final Money cumulativeRevenue;

  final int employeeCount;
  final Money payroll;
  final Money otherOperatingExpenses;
  final Money totalOperatingExpenses;

  final Money operatingProfit;

  /// Operating profit over revenue. Zero when there is no revenue, per the
  /// study's rule; check [isProfitMarginDefined] before presenting it as a
  /// meaningful ratio.
  final Percentage profitMargin;

  /// False when revenue is zero and the margin is therefore undefined.
  final bool isProfitMarginDefined;

  /// Start-up money leaving the business this month. Non-zero only in month 0.
  final Money investmentOutflow;

  final Money netCashFlow;
  final Money cumulativeCashFlow;

  bool get isInvestmentMonth => monthNumber == 0;

  @override
  List<Object?> get props => [
    monthNumber,
    occupancy,
    maximumRoundsPerDay,
    actualRoundsPerDay,
    dailyRevenue,
    monthlyRevenue,
    cumulativeRevenue,
    employeeCount,
    payroll,
    otherOperatingExpenses,
    totalOperatingExpenses,
    operatingProfit,
    profitMargin,
    isProfitMarginDefined,
    investmentOutflow,
    netCashFlow,
    cumulativeCashFlow,
  ];
}
