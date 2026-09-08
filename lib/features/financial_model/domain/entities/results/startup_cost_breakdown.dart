import 'package:equatable/equatable.dart';

import '../../value_objects/money.dart';
import '../../value_objects/percentage.dart';

/// The four reported groups of start-up spending.
enum StartupCostGroupId { deliveredEquipment, fitOut, property, preOpening }

/// A single component inside a group. [custom] lines carry their own label.
enum StartupCostLineId {
  equipment,
  shipping,
  customs,
  fitOutFurniture,
  fitOutPainting,
  fitOutSignage,
  fitOutHvac,
  fitOutInstallationLabour,
  mallDeposit,
  firstMonthRent,
  licensing,
  openingMarketing,
  custom,
}

class StartupCostLine extends Equatable {
  const StartupCostLine({
    required this.id,
    required this.amount,
    this.customLabel,
  });

  final StartupCostLineId id;
  final Money amount;

  /// Label for user-created lines; `null` for the study's named lines, whose
  /// wording belongs to the presentation layer.
  final String? customLabel;

  @override
  List<Object?> get props => [id, amount, customLabel];
}

class StartupCostGroup extends Equatable {
  const StartupCostGroup({
    required this.id,
    required this.lines,
    required this.total,
  });

  final StartupCostGroupId id;
  final List<StartupCostLine> lines;
  final Money total;

  @override
  List<Object?> get props => [id, lines, total];
}

/// The full derivation of the initial investment, kept in the shape the
/// start-up screen needs so no screen has to re-add the components itself.
class StartupCostBreakdown extends Equatable {
  const StartupCostBreakdown({
    required this.equipmentCost,
    required this.shipping,
    required this.customs,
    required this.deliveredEquipment,
    required this.fitOut,
    required this.property,
    required this.preOpening,
    required this.subtotal,
    required this.contingencyRate,
    required this.contingency,
    required this.total,
  });

  final Money equipmentCost;
  final Money shipping;
  final Money customs;

  final StartupCostGroup deliveredEquipment;
  final StartupCostGroup fitOut;
  final StartupCostGroup property;
  final StartupCostGroup preOpening;

  /// Sum of the four groups, before contingency.
  final Money subtotal;
  final Percentage contingencyRate;
  final Money contingency;

  /// The total initial investment.
  final Money total;

  List<StartupCostGroup> get groups => [
    deliveredEquipment,
    fitOut,
    property,
    preOpening,
  ];

  @override
  List<Object?> get props => [
    equipmentCost,
    shipping,
    customs,
    deliveredEquipment,
    fitOut,
    property,
    preOpening,
    subtotal,
    contingencyRate,
    contingency,
    total,
  ];
}
