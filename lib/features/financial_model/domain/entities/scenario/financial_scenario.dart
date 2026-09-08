import 'package:equatable/equatable.dart';

import 'assumption_status.dart';
import 'operating_expense_model.dart';
import 'projection_settings.dart';
import 'revenue_model.dart';
import 'scenario_metadata.dart';
import 'sensitivity_settings.dart';
import 'staffing_model.dart';
import 'startup_cost_model.dart';

/// The complete set of inputs the calculation engine needs.
///
/// A scenario holds *only* assumptions. Nothing derived is stored here: every
/// number a user could compute from these fields is produced by the engine, so
/// the two can never drift apart.
class FinancialScenario extends Equatable {
  const FinancialScenario({
    required this.metadata,
    required this.revenue,
    required this.staffing,
    required this.operatingExpenses,
    required this.startupCosts,
    required this.projection,
    required this.sensitivity,
    this.annotations = const AssumptionAnnotations(),
  });

  /// Version tag written into every scenario this build produces. A future
  /// change to any formula must introduce a new version rather than reinterpret
  /// scenarios saved under this one.
  static const String currentCalculationModelVersion = 'financial_model_v1';

  final ScenarioMetadata metadata;
  final RevenueModel revenue;
  final StaffingModel staffing;
  final OperatingExpenseModel operatingExpenses;
  final StartupCostModel startupCosts;
  final ProjectionSettings projection;
  final SensitivitySettings sensitivity;

  /// Confidence status per named input.
  final AssumptionAnnotations annotations;

  FinancialScenario copyWith({
    ScenarioMetadata? metadata,
    RevenueModel? revenue,
    StaffingModel? staffing,
    OperatingExpenseModel? operatingExpenses,
    StartupCostModel? startupCosts,
    ProjectionSettings? projection,
    SensitivitySettings? sensitivity,
    AssumptionAnnotations? annotations,
  }) {
    return FinancialScenario(
      metadata: metadata ?? this.metadata,
      revenue: revenue ?? this.revenue,
      staffing: staffing ?? this.staffing,
      operatingExpenses: operatingExpenses ?? this.operatingExpenses,
      startupCosts: startupCosts ?? this.startupCosts,
      projection: projection ?? this.projection,
      sensitivity: sensitivity ?? this.sensitivity,
      annotations: annotations ?? this.annotations,
    );
  }

  @override
  List<Object?> get props => [
    metadata,
    revenue,
    staffing,
    operatingExpenses,
    startupCosts,
    projection,
    sensitivity,
    annotations,
  ];
}
