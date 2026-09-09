import 'package:equatable/equatable.dart';

import '../../value_objects/money.dart';
import '../../value_objects/percentage.dart';
import 'bonus_configuration.dart';

enum PayrollAllocationMode { fixedPerEmployee, proportionalHours }

/// Controls how monthly cash payroll is allocated.
class PayrollConfiguration extends Equatable {
  const PayrollConfiguration({
    this.mode = PayrollAllocationMode.fixedPerEmployee,
    this.sharedMonthlyPayrollBudget,
    this.overtimeMultiplier = 1.5,
    this.bonus = const BonusConfiguration(),
    this.staffingExpansionOccupancyThreshold = const Percentage.fromPercent(40),
  });

  final PayrollAllocationMode mode;

  /// Used only by [PayrollAllocationMode.proportionalHours].
  final Money? sharedMonthlyPayrollBudget;

  /// Rate paid for overtime hours, e.g. 1.5 means time-and-a-half.
  final double overtimeMultiplier;
  final BonusConfiguration bonus;
  final Percentage staffingExpansionOccupancyThreshold;

  static const _unchanged = Object();

  PayrollConfiguration copyWith({
    PayrollAllocationMode? mode,
    Object? sharedMonthlyPayrollBudget = _unchanged,
    double? overtimeMultiplier,
    BonusConfiguration? bonus,
    Percentage? staffingExpansionOccupancyThreshold,
  }) {
    return PayrollConfiguration(
      mode: mode ?? this.mode,
      sharedMonthlyPayrollBudget:
          identical(sharedMonthlyPayrollBudget, _unchanged)
          ? this.sharedMonthlyPayrollBudget
          : sharedMonthlyPayrollBudget as Money?,
      overtimeMultiplier: overtimeMultiplier ?? this.overtimeMultiplier,
      bonus: bonus ?? this.bonus,
      staffingExpansionOccupancyThreshold:
          staffingExpansionOccupancyThreshold ??
          this.staffingExpansionOccupancyThreshold,
    );
  }

  @override
  List<Object?> get props => [
    mode,
    sharedMonthlyPayrollBudget,
    overtimeMultiplier,
    bonus,
    staffingExpansionOccupancyThreshold,
  ];
}
