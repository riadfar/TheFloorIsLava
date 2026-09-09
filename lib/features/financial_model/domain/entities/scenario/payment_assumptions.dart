import 'package:equatable/equatable.dart';

import '../../value_objects/percentage.dart';

/// Configurable payment-cost stub. Both rates default to zero.
class PaymentAssumptions extends Equatable {
  const PaymentAssumptions({
    this.digitalPaymentShare = Percentage.zero,
    this.digitalPaymentFeeRate = Percentage.zero,
  });

  final Percentage digitalPaymentShare;
  final Percentage digitalPaymentFeeRate;

  @override
  List<Object?> get props => [digitalPaymentShare, digitalPaymentFeeRate];
}
