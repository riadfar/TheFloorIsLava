import 'dart:math' as math;

import 'package:equatable/equatable.dart';

import '../entities/results/calculation_outcome.dart';
import '../value_objects/money.dart';
import '../value_objects/percentage.dart';

/// Successful monthly and annualized internal rates of return.
class IrrRates extends Equatable {
  const IrrRates({required this.monthly, required this.annualized});

  final Percentage monthly;
  final Percentage annualized;

  @override
  List<Object?> get props => [monthly, annualized];
}

/// Solves IRR on monthly cash flows without throwing or inventing a zero rate.
class IrrCalculator {
  const IrrCalculator();

  /// Uses bisection to solve `NPV(rate) = 0` for a monthly rate above -100%.
  ///
  /// The annualized result is effective: `(1 + monthlyRate)^12 - 1`.
  MetricResult<IrrRates> calculate(List<Money> monthlyCashFlows) {
    if (monthlyCashFlows.length < 2) {
      return const MetricResult<IrrRates>.insufficientData(
        'irr_requires_multiple_cash_flows',
      );
    }

    final hasPositive = monthlyCashFlows.any((flow) => flow.isPositive);
    final hasNegative = monthlyCashFlows.any((flow) => flow.isNegative);
    if (!hasPositive && !hasNegative) {
      return const MetricResult<IrrRates>.notMeaningful(
        'irr_all_cash_flows_zero',
      );
    }
    if (!hasPositive || !hasNegative) {
      return const MetricResult<IrrRates>.noSolution(
        'irr_requires_sign_change',
      );
    }

    const lower = -0.999999;
    var upper = 1.0;
    var lowerValue = _npv(monthlyCashFlows, lower);
    var upperValue = _npv(monthlyCashFlows, upper);

    while (_sameSign(lowerValue, upperValue) && upper < 1000000) {
      upper = upper * 2 + 1;
      upperValue = _npv(monthlyCashFlows, upper);
    }
    if (!lowerValue.isFinite ||
        !upperValue.isFinite ||
        _sameSign(lowerValue, upperValue)) {
      return const MetricResult<IrrRates>.noSolution('irr_root_not_bracketed');
    }

    var low = lower;
    var high = upper;
    for (var iteration = 0; iteration < 200; iteration++) {
      final midpoint = (low + high) / 2;
      final midpointValue = _npv(monthlyCashFlows, midpoint);
      if (!midpointValue.isFinite) {
        return const MetricResult<IrrRates>.noSolution('irr_solver_diverged');
      }
      if (midpointValue.abs() < 0.001 || (high - low).abs() < 1e-12) {
        return _valid(midpoint);
      }
      if (_sameSign(lowerValue, midpointValue)) {
        low = midpoint;
        lowerValue = midpointValue;
      } else {
        high = midpoint;
      }
    }

    return const MetricResult<IrrRates>.noSolution(
      'irr_solver_did_not_converge',
    );
  }

  MetricResult<IrrRates> _valid(double monthlyRate) {
    final annualRate = math.pow(1 + monthlyRate, 12).toDouble() - 1;
    if (!annualRate.isFinite) {
      return const MetricResult<IrrRates>.noSolution(
        'irr_annualization_overflow',
      );
    }
    return MetricResult<IrrRates>.valid(
      IrrRates(
        monthly: Percentage.fromFraction(monthlyRate),
        annualized: Percentage.fromFraction(annualRate),
      ),
    );
  }

  double _npv(List<Money> cashFlows, double rate) {
    var value = 0.0;
    for (var month = 0; month < cashFlows.length; month++) {
      value += cashFlows[month].amount / math.pow(1 + rate, month);
    }
    return value;
  }

  bool _sameSign(double left, double right) =>
      (left > 0 && right > 0) || (left < 0 && right < 0);
}
