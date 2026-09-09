import 'package:equatable/equatable.dart';

import '../../value_objects/money.dart';
import '../../value_objects/percentage.dart';

enum MarketingForecastMode { occupancyDriven, marketingDriven }

/// Optional demand forecast. Marketing-driven mode replaces the occupancy
/// schedule when its demand inputs produce rounds; seasonality still multiplies
/// the resulting occupancy.
class MarketingAssumptions extends Equatable {
  const MarketingAssumptions({
    this.mode = MarketingForecastMode.occupancyDriven,
    this.monthlyMarketingBudget = Money.zero,
    this.reach = 0,
    this.conversionRate = Percentage.zero,
    this.averageRoundsPerConvertedCustomer = 1,
  });

  final MarketingForecastMode mode;
  final Money monthlyMarketingBudget;
  final double reach;
  final Percentage conversionRate;
  final double averageRoundsPerConvertedCustomer;

  MarketingAssumptions copyWith({
    MarketingForecastMode? mode,
    Money? monthlyMarketingBudget,
    double? reach,
    Percentage? conversionRate,
    double? averageRoundsPerConvertedCustomer,
  }) => MarketingAssumptions(
    mode: mode ?? this.mode,
    monthlyMarketingBudget:
        monthlyMarketingBudget ?? this.monthlyMarketingBudget,
    reach: reach ?? this.reach,
    conversionRate: conversionRate ?? this.conversionRate,
    averageRoundsPerConvertedCustomer:
        averageRoundsPerConvertedCustomer ??
        this.averageRoundsPerConvertedCustomer,
  );

  double get estimatedRounds =>
      reach * conversionRate.fraction * averageRoundsPerConvertedCustomer;

  @override
  List<Object?> get props => [
    mode,
    monthlyMarketingBudget,
    reach,
    conversionRate,
    averageRoundsPerConvertedCustomer,
  ];
}
