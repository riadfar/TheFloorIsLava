import 'dart:math' as math;

import '../value_objects/money.dart';
import '../value_objects/percentage.dart';

/// Calculates net present value from monthly cash flows.
///
/// The first item is month 0 and is therefore undiscounted. Later cash flows
/// use `CF_t / (1 + r)^t`, where the transparent planning-model convention is
/// `r = annual nominal discount rate / 12`.
class NpvCalculator {
  const NpvCalculator();

  Money calculate({
    required List<Money> monthlyCashFlows,
    required Percentage annualDiscountRate,
  }) {
    final monthlyRate = annualDiscountRate.fraction / 12;
    if (!monthlyRate.isFinite || monthlyRate <= -1) {
      throw ArgumentError.value(
        annualDiscountRate,
        'annualDiscountRate',
        'must produce a finite monthly rate greater than -100%',
      );
    }

    var npvMicros = 0.0;
    for (var month = 0; month < monthlyCashFlows.length; month++) {
      npvMicros +=
          monthlyCashFlows[month].micros / math.pow(1 + monthlyRate, month);
    }
    return Money.fromMicros(npvMicros.round());
  }
}
