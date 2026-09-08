import 'package:equatable/equatable.dart';

import '../../value_objects/money.dart';

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
  });

  /// Headcount from month 1 until the expansion.
  final int initialEmployeeCount;

  /// Headcount from [expansionMonth] onwards.
  final int expandedEmployeeCount;

  /// First month that runs on the expanded headcount.
  final int expansionMonth;

  final Money monthlySalaryPerEmployee;
  final Money monthlyIncentivePerEmployee;

  StaffingModel copyWith({
    int? initialEmployeeCount,
    int? expandedEmployeeCount,
    int? expansionMonth,
    Money? monthlySalaryPerEmployee,
    Money? monthlyIncentivePerEmployee,
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
    );
  }

  @override
  List<Object?> get props => [
    initialEmployeeCount,
    expandedEmployeeCount,
    expansionMonth,
    monthlySalaryPerEmployee,
    monthlyIncentivePerEmployee,
  ];
}
