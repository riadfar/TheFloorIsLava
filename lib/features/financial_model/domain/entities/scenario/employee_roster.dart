import 'package:equatable/equatable.dart';

import '../../value_objects/money.dart';

class ShiftAssignment extends Equatable {
  const ShiftAssignment({
    required this.weekday,
    required this.startHour,
    required this.endHour,
    this.breakHours = 0,
  }) : assert(weekday >= DateTime.monday && weekday <= DateTime.sunday),
       assert(startHour >= 0 && startHour <= 24),
       assert(endHour >= 0 && endHour <= 24),
       assert(endHour > startHour),
       assert(breakHours >= 0);

  /// ISO weekday, matching [DateTime.weekday] (Monday 1 through Sunday 7).
  final int weekday;
  final double startHour;
  final double endHour;
  final double breakHours;

  ShiftAssignment copyWith({
    int? weekday,
    double? startHour,
    double? endHour,
    double? breakHours,
  }) {
    return ShiftAssignment(
      weekday: weekday ?? this.weekday,
      startHour: startHour ?? this.startHour,
      endHour: endHour ?? this.endHour,
      breakHours: breakHours ?? this.breakHours,
    );
  }

  @override
  List<Object?> get props => [weekday, startHour, endHour, breakHours];
}

class Employee extends Equatable {
  const Employee({
    required this.id,
    required this.name,
    this.weeklyShifts = const [],
    this.fixedMonthlySalary,
    this.isFounder = false,
  });

  final String id;
  final String name;
  final List<ShiftAssignment> weeklyShifts;
  final Money? fixedMonthlySalary;

  /// Founders participate in schedules but receive no cash salary.
  final bool isFounder;

  static const _unchanged = Object();

  Employee copyWith({
    String? id,
    String? name,
    List<ShiftAssignment>? weeklyShifts,
    Object? fixedMonthlySalary = _unchanged,
    bool? isFounder,
  }) {
    return Employee(
      id: id ?? this.id,
      name: name ?? this.name,
      weeklyShifts: weeklyShifts ?? this.weeklyShifts,
      fixedMonthlySalary: identical(fixedMonthlySalary, _unchanged)
          ? this.fixedMonthlySalary
          : fixedMonthlySalary as Money?,
      isFounder: isFounder ?? this.isFounder,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    weeklyShifts,
    fixedMonthlySalary,
    isFounder,
  ];
}

class EmployeeRoster extends Equatable {
  const EmployeeRoster({this.employees = const []});

  final List<Employee> employees;

  bool get isEmpty => employees.isEmpty;

  EmployeeRoster copyWith({List<Employee>? employees}) =>
      EmployeeRoster(employees: employees ?? this.employees);

  @override
  List<Object?> get props => [employees];
}
