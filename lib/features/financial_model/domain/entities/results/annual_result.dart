import 'package:equatable/equatable.dart';

import '../../value_objects/money.dart';

/// Twelve months of trading rolled up.
///
/// Month 0 never contributes: the initial investment is a cash event, not an
/// operating result, which is exactly how the study reports year-1 profit.
class AnnualResult extends Equatable {
  const AnnualResult({
    required this.yearNumber,
    required this.firstMonth,
    required this.lastMonth,
    required this.revenue,
    required this.operatingExpenses,
    required this.operatingProfit,
    required this.isComplete,
  });

  final int yearNumber;
  final int firstMonth;
  final int lastMonth;

  final Money revenue;
  final Money operatingExpenses;
  final Money operatingProfit;

  /// False when the projection is shorter than the year, so the total is a
  /// partial one and should be labelled as such.
  final bool isComplete;

  @override
  List<Object?> get props => [
    yearNumber,
    firstMonth,
    lastMonth,
    revenue,
    operatingExpenses,
    operatingProfit,
    isComplete,
  ];
}
