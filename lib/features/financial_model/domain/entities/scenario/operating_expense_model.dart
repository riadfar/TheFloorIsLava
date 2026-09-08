import 'package:equatable/equatable.dart';

import '../../value_objects/money.dart';
import 'cost_item.dart';

/// The recurring monthly cost base, excluding payroll.
///
/// Payroll lives in [StaffingModel] because it varies by month; everything here
/// is flat for the whole projection. The five study categories stay separate on
/// purpose - merging them would destroy the auditability of the original model.
class OperatingExpenseModel extends Equatable {
  const OperatingExpenseModel({
    required this.rent,
    required this.mallSharedServices,
    required this.electricity,
    required this.maintenanceAndConsumables,
    required this.continuousMarketing,
    this.additionalExpenses = const [],
  });

  /// Monthly rent. Also feeds the first-month rent inside the start-up
  /// property cost, exactly as the source study does.
  final Money rent;

  final Money mallSharedServices;
  final Money electricity;
  final Money maintenanceAndConsumables;
  final Money continuousMarketing;

  /// Extra recurring categories added by the user.
  final List<CostItem> additionalExpenses;

  OperatingExpenseModel copyWith({
    Money? rent,
    Money? mallSharedServices,
    Money? electricity,
    Money? maintenanceAndConsumables,
    Money? continuousMarketing,
    List<CostItem>? additionalExpenses,
  }) {
    return OperatingExpenseModel(
      rent: rent ?? this.rent,
      mallSharedServices: mallSharedServices ?? this.mallSharedServices,
      electricity: electricity ?? this.electricity,
      maintenanceAndConsumables:
          maintenanceAndConsumables ?? this.maintenanceAndConsumables,
      continuousMarketing: continuousMarketing ?? this.continuousMarketing,
      additionalExpenses: additionalExpenses ?? this.additionalExpenses,
    );
  }

  @override
  List<Object?> get props => [
    rent,
    mallSharedServices,
    electricity,
    maintenanceAndConsumables,
    continuousMarketing,
    additionalExpenses,
  ];
}
