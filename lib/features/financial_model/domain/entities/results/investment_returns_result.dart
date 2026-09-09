import 'package:equatable/equatable.dart';

import '../../value_objects/money.dart';
import '../../value_objects/percentage.dart';
import 'calculation_outcome.dart';

/// Time-value-of-money metrics for the projected monthly cash-flow series.
class InvestmentReturnsResult extends Equatable {
  const InvestmentReturnsResult({
    required this.npv,
    required this.irr,
    required this.discountedPaybackMonth,
    required this.discountRateUsed,
  });

  final MetricResult<Money> npv;

  /// Effective annual IRR, compounded from the solved monthly rate.
  final MetricResult<Percentage> irr;
  final MetricResult<int> discountedPaybackMonth;

  /// Annual nominal discount rate supplied by the scenario.
  ///
  /// Calculators convert it transparently to a monthly rate by dividing by 12.
  final Percentage discountRateUsed;

  @override
  List<Object?> get props => [
    npv,
    irr,
    discountedPaybackMonth,
    discountRateUsed,
  ];
}
