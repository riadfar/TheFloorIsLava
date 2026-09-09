import 'package:equatable/equatable.dart';

import '../../value_objects/money.dart';
import 'employee_roster.dart';
import 'payroll_configuration.dart';

enum StaffingHeadcountRule { byMonth, byOccupancyThreshold }

/// The headcount plan and what each head costs.
///
/// The study uses a single step: a starting headcount that grows once, from a
/// given month. That rule is kept exactly as-is; a richer schedule of staffing
/// phases is a future extension and would replace this class without touching
/// the expense calculator's contract.
class StaffingModel extends Equatable {
  const StaffingModel({
    required this.initialEmployeeCount,
    required this.expandedEmployeeCount,
    required this.expansionMonth,
    required this.monthlySalaryPerEmployee,
    required this.monthlyIncentivePerEmployee,
    this.payroll = const PayrollConfiguration(),
    this.roster = const EmployeeRoster(),
    this.regularHoursPerMonthCap,
    this.headcountRule = StaffingHeadcountRule.byMonth,
  });

  /// Headcount from month 1 until the expansion.
  final int initialEmployeeCount;

  /// Headcount from [expansionMonth] onwards.
  final int expandedEmployeeCount;

  /// First month that runs on the expanded headcount.
  final int expansionMonth;

  final Money monthlySalaryPerEmployee;
  final Money monthlyIncentivePerEmployee;
  final PayrollConfiguration payroll;
  final EmployeeRoster roster;
  final int? regularHoursPerMonthCap;
  final StaffingHeadcountRule headcountRule;

  static const _unchanged = Object();

  StaffingModel copyWith({
    int? initialEmployeeCount,
    int? expandedEmployeeCount,
    int? expansionMonth,
    Money? monthlySalaryPerEmployee,
    Money? monthlyIncentivePerEmployee,
    PayrollConfiguration? payroll,
    EmployeeRoster? roster,
    Object? regularHoursPerMonthCap = _unchanged,
    StaffingHeadcountRule? headcountRule,
  }) {
    return StaffingModel(
      initialEmployeeCount: initialEmployeeCount ?? this.initialEmployeeCount,
      expandedEmployeeCount:
          expandedEmployeeCount ?? this.expandedEmployeeCount,
      expansionMonth: expansionMonth ?? this.expansionMonth,
      monthlySalaryPerEmployee:
          monthlySalaryPerEmployee ?? this.monthlySalaryPerEmployee,
      monthlyIncentivePerEmployee:
          monthlyIncentivePerEmployee ?? this.monthlyIncentivePerEmployee,
      payroll: payroll ?? this.payroll,
      roster: roster ?? this.roster,
      regularHoursPerMonthCap: identical(regularHoursPerMonthCap, _unchanged)
          ? this.regularHoursPerMonthCap
          : regularHoursPerMonthCap as int?,
      headcountRule: headcountRule ?? this.headcountRule,
    );
  }

  @override
  List<Object?> get props => [
    initialEmployeeCount,
    expandedEmployeeCount,
    expansionMonth,
    monthlySalaryPerEmployee,
    monthlyIncentivePerEmployee,
    payroll,
    roster,
    regularHoursPerMonthCap,
    headcountRule,
  ];
}
