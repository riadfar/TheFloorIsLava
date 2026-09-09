import 'package:equatable/equatable.dart';

import '../../value_objects/money.dart';

/// Cash balance parallel to (and independent from) payback cash flow.
///
/// Month 0 opens with required funding and closes after the existing month-0
/// net cash flow (the initial investment). Each later month opens at the prior
/// ending balance. [fundingGapThisMonth] is the top-up needed if that ending
/// balance would otherwise be negative.
class MonthlyCashPosition extends Equatable {
  const MonthlyCashPosition({
    required this.monthNumber,
    required this.openingCash,
    required this.endingCash,
    required this.fundingGapThisMonth,
  });

  final int monthNumber;
  final Money openingCash;
  final Money endingCash;
  final Money fundingGapThisMonth;

  @override
  List<Object?> get props => [
    monthNumber,
    openingCash,
    endingCash,
    fundingGapThisMonth,
  ];
}
