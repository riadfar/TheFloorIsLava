import 'package:equatable/equatable.dart';

import '../../value_objects/money.dart';
import '../../value_objects/percentage.dart';
import '../scenario/sensitivity_settings.dart';

/// One what-if case evaluated at steady state.
///
/// Sensitivity cases answer "what does a normal month look like at this
/// occupancy?", so they use the steady-state cost base (the expanded headcount)
/// rather than a ramp-up month.
class SensitivityResult extends Equatable {
  const SensitivityResult({
    required this.definition,
    required this.occupancy,
    required this.actualRoundsPerDay,
    required this.monthlyRevenue,
    required this.monthlyOperatingExpenses,
    required this.monthlyProfit,
    required this.approximatePaybackMonths,
  });

  final SensitivityScenarioDefinition definition;
  final Percentage occupancy;
  final double actualRoundsPerDay;
  final Money monthlyRevenue;
  final Money monthlyOperatingExpenses;
  final Money monthlyProfit;

  /// Initial investment divided by monthly profit. `null` when the case does
  /// not turn a profit, in which case the investment is simply not recoverable
  /// and no number should be shown.
  final double? approximatePaybackMonths;

  bool get isRecoverable => approximatePaybackMonths != null;

  @override
  List<Object?> get props => [
    definition,
    occupancy,
    actualRoundsPerDay,
    monthlyRevenue,
    monthlyOperatingExpenses,
    monthlyProfit,
    approximatePaybackMonths,
  ];
}
