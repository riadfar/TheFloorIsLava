import 'dart:math' as math;

import '../entities/results/calculation_outcome.dart';
import '../value_objects/money.dart';
import '../value_objects/percentage.dart';

/// Finds when discounted cumulative monthly cash flow becomes non-negative.
class DiscountedPaybackCalculator {
  const DiscountedPaybackCalculator();

  /// Uses the same nominal monthly convention as NPV:
  /// `monthlyRate = annualDiscountRate / 12`.
  MetricResult<int> calculate({
    required List<Money> monthlyCashFlows,
    required Percentage annualDiscountRate,
  }) {
    if (monthlyCashFlows.isEmpty) {
      return const MetricResult<int>.insufficientData(
        'discounted_payback_requires_cash_flows',
      );
    }

    final monthlyRate = annualDiscountRate.fraction / 12;
    if (!monthlyRate.isFinite || monthlyRate <= -1) {
      return const MetricResult<int>.invalid('discount_rate_out_of_range');
    }

    var cumulativeMicros = 0.0;
    for (var month = 0; month < monthlyCashFlows.length; month++) {
      cumulativeMicros +=
          monthlyCashFlows[month].micros / math.pow(1 + monthlyRate, month);
      if (cumulativeMicros >= 0) return MetricResult<int>.valid(month);
    }
    return const MetricResult<int>.noSolution('discounted_payback_not_reached');
  }
}
