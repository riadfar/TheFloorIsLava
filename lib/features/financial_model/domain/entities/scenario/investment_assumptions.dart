import 'package:equatable/equatable.dart';

import '../../value_objects/percentage.dart';

/// Assumptions used only by time-value-of-money calculations.
class InvestmentAssumptions extends Equatable {
  const InvestmentAssumptions({required this.annualDiscountRate});

  final Percentage annualDiscountRate;

  InvestmentAssumptions copyWith({Percentage? annualDiscountRate}) {
    return InvestmentAssumptions(
      annualDiscountRate: annualDiscountRate ?? this.annualDiscountRate,
    );
  }

  @override
  List<Object?> get props => [annualDiscountRate];
}
