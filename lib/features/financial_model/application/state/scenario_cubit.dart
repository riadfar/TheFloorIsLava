import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/logging/app_logger.dart';
import '../../domain/entities/scenario/assumption_status.dart';
import '../../domain/entities/scenario/financial_scenario.dart';
import '../../domain/entities/scenario/scenario_fields.dart';
import '../../domain/value_objects/money.dart';
import '../use_cases/calculate_financial_model.dart';
import '../use_cases/load_scenario.dart';
import '../use_cases/reset_scenario.dart';
import '../use_cases/save_scenario.dart';
import 'scenario_state.dart';

/// Orchestrates the loop the whole application runs on:
///
///     user input -> validate -> update scenario -> calculate -> results -> UI
///
/// It owns no formulas. Every number in [ScenarioState] comes from the domain;
/// this class decides only *when* the domain is asked and *what* is stored.
class ScenarioCubit extends Cubit<ScenarioState> {
  ScenarioCubit({
    required this.loadScenario,
    required this.saveScenario,
    required this.resetScenario,
    this.calculateFinancialModel = const CalculateFinancialModel(),
    this.autosaveDelay = const Duration(milliseconds: 700),
  }) : super(const ScenarioState());

  final LoadScenario loadScenario;
  final SaveScenario saveScenario;
  final ResetScenario resetScenario;
  final CalculateFinancialModel calculateFinancialModel;

  /// Typing should not hit storage on every keystroke.
  final Duration autosaveDelay;
  Timer? _autosaveTimer;

  Future<void> initialise() async {
    if (state.status != ScenarioStatus.initial) return;
    emit(state.copyWith(status: ScenarioStatus.loading));

    final loaded = await loadScenario();
    AppLogger.info(
      'Application started on scenario "${loaded.scenario.metadata.id}" '
      '(${loaded.isFromStorage ? 'restored' : 'baseline'})',
    );

    final output = calculateFinancialModel(loaded.scenario);
    emit(
      ScenarioState(
        status: ScenarioStatus.ready,
        scenario: loaded.scenario,
        projection: output.projection,
        validation: output.validation,
        failure: loaded.failure,
      ),
    );
  }

  /// Changes one named input.
  void updateField(AssumptionKey key, num value) {
    _mutate((scenario) => ScenarioFields.write(scenario, key, value));
  }

  void selectEquipmentPackage(String packageId) {
    _mutate(
      (scenario) => ScenarioFields.selectEquipmentPackage(scenario, packageId),
    );
  }

  void updateEquipmentPackageCost(String packageId, num cost) {
    _mutate(
      (scenario) => ScenarioFields.setEquipmentPackageCost(
        scenario,
        packageId,
        Money.of(cost),
      ),
    );
  }

  /// Records how much the user trusts an assumption. Does not change any
  /// number, only how it is presented.
  void setAssumptionStatus(AssumptionKey key, AssumptionStatus status) {
    _mutate(
      (scenario) => scenario.copyWith(
        annotations: scenario.annotations.withStatus(key, status),
      ),
    );
  }

  void renameScenario(String name) {
    _mutate(
      (scenario) =>
          scenario.copyWith(metadata: scenario.metadata.copyWith(name: name)),
    );
  }

  void setCurrency(String currencyCode) {
    _mutate(
      (scenario) => scenario.copyWith(
        metadata: scenario.metadata.copyWith(currencyCode: currencyCode),
      ),
    );
  }

  /// Throws the user's edits away and goes back to the study's own values.
  Future<void> resetToBaseline() async {
    _autosaveTimer?.cancel();
    final baseline = await resetScenario();
    final output = calculateFinancialModel(baseline);
    AppLogger.info('Scenario reset to the study baseline');

    emit(
      ScenarioState(
        status: ScenarioStatus.ready,
        scenario: baseline,
        projection: output.projection,
        validation: output.validation,
      ),
    );
  }

  /// Writes the current scenario to storage now, cancelling any pending
  /// autosave.
  Future<void> saveNow() async {
    _autosaveTimer?.cancel();
    final scenario = state.scenario;
    if (scenario == null) return;

    final failure = await saveScenario(scenario);
    if (isClosed) return;
    emit(
      state.copyWith(
        hasUnsavedChanges: failure != null,
        failure: failure,
        clearFailure: failure == null,
      ),
    );
  }

  /// Marks the current failure as dealt with, so it is not shown twice.
  void acknowledgeFailure() {
    if (state.failure == null) return;
    emit(state.copyWith(clearFailure: true));
  }

  /// The one path by which the scenario changes: transform, validate,
  /// recalculate, publish, then schedule a save.
  void _mutate(FinancialScenario Function(FinancialScenario) transform) {
    final current = state.scenario;
    if (current == null) return;

    final updated = transform(current);
    if (updated == current) return;

    final output = calculateFinancialModel(updated);
    emit(
      state.copyWith(
        scenario: updated,
        projection: output.projection,
        validation: output.validation,
        hasUnsavedChanges: true,
        clearFailure: true,
      ),
    );

    _scheduleAutosave();
  }

  void _scheduleAutosave() {
    _autosaveTimer?.cancel();
    _autosaveTimer = Timer(autosaveDelay, () {
      // A scenario that is not a coherent business is not worth persisting;
      // it stays on screen, flagged, until the user fixes it.
      if (!state.validation.isValid) return;
      unawaited(saveNow());
    });
  }

  @override
  Future<void> close() {
    _autosaveTimer?.cancel();
    return super.close();
  }
}
