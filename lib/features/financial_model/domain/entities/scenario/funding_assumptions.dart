import 'package:equatable/equatable.dart';

import '../../value_objects/money.dart';

/// Funding inputs outside startup investment and working capital.
class FundingAssumptions extends Equatable {
  const FundingAssumptions({this.openingDelayBuffer = Money.zero});

  final Money openingDelayBuffer;

  FundingAssumptions copyWith({Money? openingDelayBuffer}) {
    return FundingAssumptions(
      openingDelayBuffer: openingDelayBuffer ?? this.openingDelayBuffer,
    );
  }

  @override
  List<Object?> get props => [openingDelayBuffer];
}
