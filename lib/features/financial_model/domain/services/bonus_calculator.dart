import '../entities/scenario/bonus_configuration.dart';
import '../value_objects/money.dart';

class BonusCalculator {
  const BonusCalculator();

  Money calculate({
    required BonusConfiguration configuration,
    required Money revenue,
    Money? expectedRevenue,
  }) {
    switch (configuration.mode) {
      case BonusMode.disabled:
        return Money.zero;
      case BonusMode.percentageOfExcessRevenue:
        final target = configuration.revenueTarget;
        final percentage = configuration.percentageOfExcess;
        if (target == null || percentage == null || revenue <= target) {
          return Money.zero;
        }
        return (revenue - target) * percentage.fraction;
      case BonusMode.fixedAmountAtThreshold:
        final amount = configuration.fixedBonusAmount;
        if (amount == null) return Money.zero;
        final trigger =
            configuration.revenueTarget ??
            (expectedRevenue == null ||
                    configuration.thresholdMultiplier == null
                ? null
                : expectedRevenue *
                      configuration.thresholdMultiplier!.fraction);
        return trigger != null && revenue >= trigger ? amount : Money.zero;
    }
  }
}
