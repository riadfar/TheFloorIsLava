import 'package:equatable/equatable.dart';

import '../entities/scenario/employee_roster.dart';
import '../entities/scenario/payroll_configuration.dart';
import '../entities/scenario/staffing_model.dart';
import '../value_objects/money.dart';
import 'employee_hours_calculator.dart';
import 'overtime_calculator.dart';
import 'staffing_calculator.dart';

class PayrollResult extends Equatable {
  const PayrollResult({
    required this.total,
    this.employeePay = const {},
    this.error,
  });

  final Money total;
  final Map<String, Money> employeePay;
  final String? error;

  bool get isValid => error == null;

  @override
  List<Object?> get props => [total, employeePay, error];
}

/// Roster-aware payroll engine. The empty-roster fixed mode delegates directly
/// to [StaffingCalculator], preserving the feasibility study calculation.
class PayrollCalculator {
  const PayrollCalculator({
    this.staffingCalculator = const StaffingCalculator(),
    this.hoursCalculator = const EmployeeHoursCalculator(),
    this.overtimeCalculator = const OvertimeCalculator(),
  });

  final StaffingCalculator staffingCalculator;
  final EmployeeHoursCalculator hoursCalculator;
  final OvertimeCalculator overtimeCalculator;

  PayrollResult calculate({
    required StaffingModel staffing,
    required int employeeCount,
    required double daysPerMonth,
    required int daysPerWeek,
  }) {
    if (staffing.roster.isEmpty &&
        staffing.payroll.mode == PayrollAllocationMode.fixedPerEmployee) {
      return PayrollResult(
        total: staffingCalculator.payroll(staffing, employeeCount),
      );
    }

    final hours = <Employee, double>{
      for (final employee in staffing.roster.employees)
        employee: hoursCalculator.monthlyHours(
          employee: employee,
          daysPerMonth: daysPerMonth,
          daysPerWeek: daysPerWeek,
        ),
    };

    return switch (staffing.payroll.mode) {
      PayrollAllocationMode.fixedPerEmployee => _fixedPayroll(staffing, hours),
      PayrollAllocationMode.proportionalHours => _proportionalPayroll(
        staffing,
        hours,
      ),
    };
  }

  PayrollResult calculateForMonth({
    required StaffingModel staffing,
    required int month,
    required double daysPerMonth,
    required int daysPerWeek,
  }) {
    return calculate(
      staffing: staffing,
      employeeCount: staffingCalculator.employeeCountForMonth(staffing, month),
      daysPerMonth: daysPerMonth,
      daysPerWeek: daysPerWeek,
    );
  }

  PayrollResult _fixedPayroll(
    StaffingModel staffing,
    Map<Employee, double> hours,
  ) {
    final pay = <String, Money>{};
    for (final entry in hours.entries) {
      final employee = entry.key;
      if (employee.isFounder) {
        pay[employee.id] = Money.zero;
        continue;
      }

      final monthlyPay =
          employee.fixedMonthlySalary ??
          staffingCalculator.costPerEmployee(staffing);
      final cap = staffing.regularHoursPerMonthCap;
      if (cap == null || cap <= 0) {
        pay[employee.id] = monthlyPay;
        continue;
      }

      final hourly = monthlyPay / cap;
      pay[employee.id] = overtimeCalculator
          .calculate(
            hours: entry.value,
            baseHourly: hourly,
            regularHoursCap: cap,
            overtimeMultiplier: staffing.payroll.overtimeMultiplier,
          )
          .totalCost;
    }
    return PayrollResult(total: Money.sum(pay.values), employeePay: pay);
  }

  PayrollResult _proportionalPayroll(
    StaffingModel staffing,
    Map<Employee, double> hours,
  ) {
    final budget = staffing.payroll.sharedMonthlyPayrollBudget;
    if (budget == null) {
      return const PayrollResult(
        total: Money.zero,
        error: 'A shared monthly payroll budget is required.',
      );
    }

    final totalHours = hours.values.fold<double>(
      0,
      (sum, value) => sum + value,
    );
    if (totalHours <= 0) {
      return const PayrollResult(
        total: Money.zero,
        error:
            'Payroll cannot be allocated because total worked hours is zero.',
      );
    }

    final baseHourly = budget / totalHours;
    final pay = <String, Money>{};
    for (final entry in hours.entries) {
      if (entry.key.isFounder) {
        pay[entry.key.id] = Money.zero;
      } else if (staffing.regularHoursPerMonthCap == null) {
        // Allocate from the original budget so intermediate hourly rounding
        // cannot distort the requested proportional split.
        pay[entry.key.id] = budget * (entry.value / totalHours);
      } else {
        pay[entry.key.id] = overtimeCalculator
            .calculate(
              hours: entry.value,
              baseHourly: baseHourly,
              regularHoursCap: staffing.regularHoursPerMonthCap,
              overtimeMultiplier: staffing.payroll.overtimeMultiplier,
            )
            .totalCost;
      }
    }
    return PayrollResult(total: Money.sum(pay.values), employeePay: pay);
  }
}
