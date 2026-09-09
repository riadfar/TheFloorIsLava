import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/results/financial_projection.dart';
import '../../domain/entities/scenario/financial_scenario.dart';
import '../../domain/entities/scenario/scenario_summary.dart';
import '../../domain/validation/validation_issue.dart';

enum ScenarioStatus { initial, loading, ready }

/// Everything the UI needs to draw the application.
///
/// The scenario and its projection travel together and are replaced together,
/// so no screen can ever render a figure that does not belong to the inputs
/// shown next to it.
class ScenarioState extends Equatable {
  const ScenarioState({
    this.status = ScenarioStatus.initial,
    this.scenario,
    this.projection,
    this.validation = const ValidationReport.valid(),
    this.failure,
    this.hasUnsavedChanges = false,
    this.availableScenarios = const [],
  });

  final ScenarioStatus status;
  final FinancialScenario? scenario;

  /// The calculated model. Always derived from [scenario]; never edited.
  final FinancialProjection? projection;

  final ValidationReport validation;

  /// The last problem worth telling the user about, e.g. storage trouble.
  /// Cleared once shown.
  final Failure? failure;

  final bool hasUnsavedChanges;
  final List<ScenarioSummary> availableScenarios;

  bool get isReady =>
      status == ScenarioStatus.ready && scenario != null && projection != null;

  ScenarioState copyWith({
    ScenarioStatus? status,
    FinancialScenario? scenario,
    FinancialProjection? projection,
    ValidationReport? validation,
    bool? hasUnsavedChanges,
    bool clearFailure = false,
    Failure? failure,
    List<ScenarioSummary>? availableScenarios,
  }) {
    return ScenarioState(
      status: status ?? this.status,
      scenario: scenario ?? this.scenario,
      projection: projection ?? this.projection,
      validation: validation ?? this.validation,
      failure: clearFailure ? null : (failure ?? this.failure),
      hasUnsavedChanges: hasUnsavedChanges ?? this.hasUnsavedChanges,
      availableScenarios: availableScenarios ?? this.availableScenarios,
    );
  }

  @override
  List<Object?> get props => [
    status,
    scenario,
    projection,
    validation,
    failure,
    hasUnsavedChanges,
    availableScenarios,
  ];
}
