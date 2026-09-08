import '../entities/scenario/staffing_model.dart';
import '../value_objects/money.dart';

/// Headcount over time and what it costs.
class StaffingCalculator {
  const StaffingCalculator();

  /// The study's staffing rule: a starting headcount until the expansion month,
  /// the expanded headcount from that month onwards.
  int employeeCountForMonth(StaffingModel staffing, int month) {
    return month >= staffing.expansionMonth
        ? staffing.expandedEmployeeCount
        : staffing.initialEmployeeCount;
  }

  /// Full monthly cost of one employee: salary plus incentive.
  Money costPerEmployee(StaffingModel staffing) =>
      staffing.monthlySalaryPerEmployee + staffing.monthlyIncentivePerEmployee;

  Money payroll(StaffingModel staffing, int employeeCount) =>
      costPerEmployee(staffing) * employeeCount;

  /// Payroll for a given projection month.
  Money payrollForMonth(StaffingModel staffing, int month) =>
      payroll(staffing, employeeCountForMonth(staffing, month));
}
