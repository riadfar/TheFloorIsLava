import 'dart:math' as math;

import '../entities/scenario/employee_roster.dart';

class EmployeeHoursCalculator {
  const EmployeeHoursCalculator();

  double hoursForShift(ShiftAssignment shift) =>
      math.max(0, shift.endHour - shift.startHour - shift.breakHours);

  double weeklyHours(Employee employee) =>
      employee.weeklyShifts.fold(0, (total, shift) {
        return total + hoursForShift(shift);
      });

  /// Converts the recurring weekly schedule using the operating-calendar
  /// convention requested by the model: weekly hours × days/month ÷ days/week.
  double monthlyHours({
    required Employee employee,
    required double daysPerMonth,
    required int daysPerWeek,
  }) {
    if (daysPerWeek <= 0) return 0;
    return weeklyHours(employee) * (daysPerMonth / daysPerWeek);
  }
}
