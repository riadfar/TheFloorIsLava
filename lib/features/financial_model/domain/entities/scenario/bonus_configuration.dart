import 'package:equatable/equatable.dart';

import '../../value_objects/money.dart';
import '../../value_objects/percentage.dart';

enum BonusMode { disabled, percentageOfExcessRevenue, fixedAmountAtThreshold }

/// Optional monthly employee bonus rules.
class BonusConfiguration extends Equatable {
  const BonusConfiguration({
    this.mode = BonusMode.disabled,
    this.percentageOfExcess,
    this.revenueTarget,
    this.thresholdMultiplier,
    this.fixedBonusAmount,
  });

  final BonusMode mode;
  final Percentage? percentageOfExcess;
  final Money? revenueTarget;
  final Percentage? thresholdMultiplier;
  final Money? fixedBonusAmount;

  static const _unchanged = Object();

  BonusConfiguration copyWith({
    BonusMode? mode,
    Object? percentageOfExcess = _unchanged,
    Object? revenueTarget = _unchanged,
    Object? thresholdMultiplier = _unchanged,
    Object? fixedBonusAmount = _unchanged,
  }) {
    return BonusConfiguration(
      mode: mode ?? this.mode,
      percentageOfExcess: identical(percentageOfExcess, _unchanged)
          ? this.percentageOfExcess
          : percentageOfExcess as Percentage?,
      revenueTarget: identical(revenueTarget, _unchanged)
          ? this.revenueTarget
          : revenueTarget as Money?,
      thresholdMultiplier: identical(thresholdMultiplier, _unchanged)
          ? this.thresholdMultiplier
          : thresholdMultiplier as Percentage?,
      fixedBonusAmount: identical(fixedBonusAmount, _unchanged)
          ? this.fixedBonusAmount
          : fixedBonusAmount as Money?,
    );
  }

  @override
  List<Object?> get props => [
    mode,
    percentageOfExcess,
    revenueTarget,
    thresholdMultiplier,
    fixedBonusAmount,
  ];
}
