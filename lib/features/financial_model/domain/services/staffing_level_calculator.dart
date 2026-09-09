import '../entities/scenario/staffing_model.dart';
import '../value_objects/percentage.dart';
import 'staffing_calculator.dart';

/// Optional occupancy-driven headcount rule.
///
/// The baseline engine continues to use [StaffingCalculator]'s month rule.
class StaffingLevelCalculator {
  const StaffingLevelCalculator({
    this.staffingCalculator = const StaffingCalculator(),
  });

  final StaffingCalculator staffingCalculator;

  int employeeCount({
    required StaffingModel staffing,
    required Percentage occupancy,
  }) {
    return occupancy < staffing.payroll.staffingExpansionOccupancyThreshold
        ? staffing.initialEmployeeCount
        : staffing.expandedEmployeeCount;
  }

  /// Applies the explicitly selected rule. Month-based staffing remains the
  /// default and delegates to the original study calculator.
  int employeeCountForMonth({
    required StaffingModel staffing,
    required int month,
    required Percentage occupancy,
  }) {
    return switch (staffing.headcountRule) {
      StaffingHeadcountRule.byMonth => staffingCalculator.employeeCountForMonth(
        staffing,
        month,
      ),
      StaffingHeadcountRule.byOccupancyThreshold => employeeCount(
        staffing: staffing,
        occupancy: occupancy,
      ),
    };
  }
}
