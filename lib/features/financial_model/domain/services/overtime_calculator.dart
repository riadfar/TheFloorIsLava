import 'dart:math' as math;

import 'package:equatable/equatable.dart';

import '../value_objects/money.dart';

class OvertimeBreakdown extends Equatable {
  const OvertimeBreakdown({
    required this.regularHours,
    required this.overtimeHours,
    required this.regularCost,
    required this.overtimeCost,
  });

  final double regularHours;
  final double overtimeHours;
  final Money regularCost;
  final Money overtimeCost;

  Money get totalCost => regularCost + overtimeCost;

  @override
  List<Object?> get props => [
    regularHours,
    overtimeHours,
    regularCost,
    overtimeCost,
  ];
}

class OvertimeCalculator {
  const OvertimeCalculator();

  OvertimeBreakdown calculate({
    required double hours,
    required Money baseHourly,
    required int? regularHoursCap,
    double overtimeMultiplier = 1.5,
  }) {
    final workedHours = math.max(0.0, hours);
    final regularHours = regularHoursCap == null
        ? workedHours
        : math.min(workedHours, math.max(0, regularHoursCap).toDouble());
    final overtimeHours = workedHours - regularHours;
    return OvertimeBreakdown(
      regularHours: regularHours,
      overtimeHours: overtimeHours,
      regularCost: baseHourly * regularHours,
      overtimeCost: baseHourly * overtimeHours * overtimeMultiplier,
    );
  }
}
