import 'package:equatable/equatable.dart';

import '../../value_objects/money.dart';

/// Planning assumptions for maintaining and eventually replacing equipment.
/// A planned replacement is not a prediction of forced equipment failure.
class EquipmentLifecycleAssumptions extends Equatable {
  const EquipmentLifecycleAssumptions({
    this.usefulLifeMonths = 24,
    this.replacementCost = Money.zero,
    this.includeReplacementInProjection = false,
    this.monthlyMaintenanceReserve = Money.zero,
    this.sparePartsReserveMonthly = Money.zero,
  });

  final double usefulLifeMonths;
  final Money replacementCost;
  final bool includeReplacementInProjection;
  final Money monthlyMaintenanceReserve;
  final Money sparePartsReserveMonthly;

  EquipmentLifecycleAssumptions copyWith({
    double? usefulLifeMonths,
    Money? replacementCost,
    bool? includeReplacementInProjection,
    Money? monthlyMaintenanceReserve,
    Money? sparePartsReserveMonthly,
  }) => EquipmentLifecycleAssumptions(
    usefulLifeMonths: usefulLifeMonths ?? this.usefulLifeMonths,
    replacementCost: replacementCost ?? this.replacementCost,
    includeReplacementInProjection:
        includeReplacementInProjection ?? this.includeReplacementInProjection,
    monthlyMaintenanceReserve:
        monthlyMaintenanceReserve ?? this.monthlyMaintenanceReserve,
    sparePartsReserveMonthly:
        sparePartsReserveMonthly ?? this.sparePartsReserveMonthly,
  );

  @override
  List<Object?> get props => [
    usefulLifeMonths,
    replacementCost,
    includeReplacementInProjection,
    monthlyMaintenanceReserve,
    sparePartsReserveMonthly,
  ];
}
