import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../../../../core/logging/app_logger.dart';
import '../export/scenario_export_service.dart';
import '../../domain/defaults/baseline_scenario.dart';
import '../../domain/entities/results/financial_projection.dart';
import '../../domain/entities/scenario/actuals_ledger.dart';
import '../../domain/entities/scenario/assumption_status.dart';
import '../../domain/entities/scenario/bonus_configuration.dart';
import '../../domain/entities/scenario/cost_item.dart';
import '../../domain/entities/scenario/debt_assumptions.dart';
import '../../domain/entities/scenario/employee_roster.dart';
import '../../domain/entities/scenario/financial_scenario.dart';
import '../../domain/entities/scenario/scenario_summary.dart';
import '../../domain/entities/scenario/marketing_assumptions.dart';
import '../../domain/entities/scenario/equipment_lifecycle_assumptions.dart';
import '../../domain/entities/scenario/payroll_configuration.dart';
import '../../domain/entities/scenario/revenue_model.dart';
import '../../domain/entities/scenario/scenario_fields.dart';
import '../../domain/entities/scenario/seasonality_model.dart';
import '../../domain/entities/scenario/staffing_model.dart';
import '../../domain/entities/scenario/working_capital_model.dart';
import '../../domain/value_objects/money.dart';
import '../../domain/value_objects/percentage.dart';
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
    this.exportService = const ScenarioExportService(),
    this.autosaveDelay = const Duration(milliseconds: 700),
  }) : super(const ScenarioState());

  final LoadScenario loadScenario;
  final SaveScenario saveScenario;
  final ResetScenario resetScenario;
  final CalculateFinancialModel calculateFinancialModel;
  final ScenarioExportService exportService;

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
    var summaries = await _loadSummaries();
    if (summaries.isEmpty) {
      await loadScenario.repository.saveScenario(loaded.scenario);
      await loadScenario.repository.setActiveScenarioId(
        loaded.scenario.metadata.id,
      );
      summaries = await _loadSummaries();
    }
    emit(
      ScenarioState(
        status: ScenarioStatus.ready,
        scenario: loaded.scenario,
        projection: output.projection,
        validation: output.validation,
        failure: loaded.failure,
        availableScenarios: summaries,
      ),
    );
  }

  Future<void> refreshScenarioList() async {
    final result = await loadScenario.repository.listScenarios();
    if (isClosed) return;
    result.fold(
      onSuccess: (summaries) =>
          emit(state.copyWith(availableScenarios: summaries)),
      onFailure: (failure) => emit(state.copyWith(failure: failure)),
    );
  }

  Future<void> selectScenario(String id) async {
    if (state.scenario?.metadata.id == id) return;
    if (state.hasUnsavedChanges && state.validation.isValid) await saveNow();

    final selected = await loadScenario.repository.setActiveScenarioId(id);
    if (selected case Failed<void>(:final failure)) {
      emit(state.copyWith(failure: failure));
      return;
    }
    final loaded = await loadScenario.repository.loadScenarioById(id);
    loaded.fold(
      onSuccess: (scenario) {
        if (scenario == null) return;
        final output = calculateFinancialModel(scenario);
        emit(
          state.copyWith(
            scenario: scenario,
            projection: output.projection,
            validation: output.validation,
            hasUnsavedChanges: false,
            clearFailure: true,
          ),
        );
      },
      onFailure: (failure) => emit(state.copyWith(failure: failure)),
    );
    await refreshScenarioList();
  }

  Future<void> duplicateActiveScenario() async {
    final current = state.scenario;
    if (current == null) return;
    final now = DateTime.now();
    final copy = current.copyWith(
      metadata: current.metadata.copyWith(
        id: _newScenarioId('copy'),
        name: '${current.metadata.name} (copy)',
        createdAt: now,
        updatedAt: now,
      ),
    );
    await _saveAndSelect(copy);
  }

  Future<void> createBaselineScenario() async {
    final now = DateTime.now();
    final baseline = BaselineScenario.build(now: now);
    await _saveAndSelect(
      baseline.copyWith(
        metadata: baseline.metadata.copyWith(
          id: _newScenarioId('base'),
          name: 'Base',
        ),
      ),
    );
  }

  Future<void> createWorstCaseScenario() async {
    final now = DateTime.now();
    final worst = BaselineScenario.worstCase(now: now);
    await _saveAndSelect(
      worst.copyWith(
        metadata: worst.metadata.copyWith(
          id: _newScenarioId('worst'),
          name: 'Worst Case',
        ),
      ),
    );
  }

  Future<void> deleteScenario(String id) async {
    _autosaveTimer?.cancel();
    final wasActive = state.scenario?.metadata.id == id;
    final result = await loadScenario.repository.deleteScenario(id);
    if (result case Failed<void>(:final failure)) {
      emit(state.copyWith(failure: failure));
      return;
    }
    if (wasActive) {
      final loaded = await loadScenario.repository.loadActiveScenario();
      loaded.fold(
        onSuccess: (scenario) {
          if (scenario == null) return;
          final output = calculateFinancialModel(scenario);
          emit(
            state.copyWith(
              scenario: scenario,
              projection: output.projection,
              validation: output.validation,
              hasUnsavedChanges: false,
              clearFailure: true,
            ),
          );
        },
        onFailure: (failure) => emit(state.copyWith(failure: failure)),
      );
    }
    await refreshScenarioList();
  }

  Future<Map<String, FinancialProjection>> compareScenarios(
    Iterable<String> ids,
  ) async {
    final comparisons = <String, FinancialProjection>{};
    for (final id in ids.take(4)) {
      final result = await loadScenario.repository.loadScenarioById(id);
      final scenario = result.valueOrNull;
      if (scenario != null) {
        comparisons[id] = calculateFinancialModel(scenario).projection;
      }
    }
    return comparisons;
  }

  String buildScenarioJsonExport() {
    final scenario = state.scenario;
    if (scenario == null) {
      throw StateError('A scenario must be loaded before it can be exported');
    }
    return exportService.exportScenarioJson(scenario);
  }

  String buildProjectionCsvExport() {
    final projection = state.projection;
    if (projection == null) {
      throw StateError(
        'A projection must be calculated before it can be exported',
      );
    }
    return exportService.exportProjectionCsv(projection);
  }

  /// Imports only fully parseable, valid scenarios. Malformed input is
  /// reported as an [ImportFailure] and never reaches persistence.
  Future<void> importScenarioFromJson(
    String raw, {
    bool asNewScenario = true,
  }) async {
    _autosaveTimer?.cancel();
    try {
      final imported = exportService.importScenarioJson(raw);
      final now = DateTime.now();
      final current = state.scenario;
      final scenario = imported.copyWith(
        metadata: imported.metadata.copyWith(
          id: asNewScenario || current == null
              ? _newScenarioId('import')
              : current.metadata.id,
          createdAt: asNewScenario || current == null
              ? now
              : current.metadata.createdAt,
          updatedAt: now,
        ),
      );
      final output = calculateFinancialModel(scenario);
      if (!output.validation.isValid) {
        emit(
          state.copyWith(
            failure: const ImportFailure(
              cause: FormatException('Imported scenario is invalid'),
            ),
          ),
        );
        return;
      }
      await _saveAndSelect(scenario);
    } on Object catch (error) {
      if (isClosed) return;
      emit(state.copyWith(failure: ImportFailure(cause: error)));
    }
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

  void setDayOperatingHours(int weekday, double hours) {
    if (weekday < DateTime.monday || weekday > DateTime.sunday) {
      throw RangeError.range(
        weekday,
        DateTime.monday,
        DateTime.sunday,
        'weekday',
      );
    }
    if (hours < 0 || hours > 24) {
      throw RangeError.range(hours, 0, 24, 'hours');
    }

    _mutate((scenario) {
      final schedule = scenario.revenue.schedule;
      final days = [
        for (final day in schedule.weeklyProfile.days)
          if (day.weekday != weekday) day,
        DayOperatingHours(weekday: weekday, hours: hours),
      ]..sort((left, right) => left.weekday.compareTo(right.weekday));
      return scenario.copyWith(
        revenue: scenario.revenue.copyWith(
          schedule: schedule.copyWith(
            weeklyProfile: WeeklyOperatingProfile(days: days),
          ),
        ),
      );
    });
  }

  void clearWeeklyOperatingProfile() {
    _mutate(
      (scenario) => scenario.copyWith(
        revenue: scenario.revenue.copyWith(
          schedule: scenario.revenue.schedule.copyWith(
            weeklyProfile: const WeeklyOperatingProfile(),
          ),
        ),
      ),
    );
  }

  void enableWeeklyOperatingProfile() {
    _mutate((scenario) {
      final schedule = scenario.revenue.schedule;
      return scenario.copyWith(
        revenue: scenario.revenue.copyWith(
          schedule: schedule.copyWith(
            weeklyProfile: WeeklyOperatingProfile(
              days: [
                for (
                  var weekday = DateTime.monday;
                  weekday <= DateTime.sunday;
                  weekday++
                )
                  DayOperatingHours(
                    weekday: weekday,
                    hours: schedule.hoursPerDay,
                  ),
              ],
            ),
          ),
        ),
      );
    });
  }

  void setMarketingMode(MarketingForecastMode mode) => _mutate(
    (scenario) => scenario.copyWith(
      marketingAssumptions: scenario.marketingAssumptions.copyWith(mode: mode),
    ),
  );

  void setMarketingBudget(Money value) => _updateMarketing(
    (model) => model.copyWith(monthlyMarketingBudget: value),
  );

  void setMarketingReach(double value) =>
      _updateMarketing((model) => model.copyWith(reach: value));

  void setMarketingConversionRate(Percentage value) =>
      _updateMarketing((model) => model.copyWith(conversionRate: value));

  void setAverageRoundsPerConvertedCustomer(double value) => _updateMarketing(
    (model) => model.copyWith(averageRoundsPerConvertedCustomer: value),
  );

  void setEquipmentLifecycle(EquipmentLifecycleAssumptions lifecycle) =>
      _mutate(
        (scenario) => scenario.copyWith(
          startupCosts: scenario.startupCosts.copyWith(
            equipmentLifecycle: lifecycle,
          ),
        ),
      );

  String createEmployeeId() => 'emp-${DateTime.now().microsecondsSinceEpoch}';

  void upsertEmployee(Employee employee) {
    _mutate((scenario) {
      final employees = [...scenario.staffing.roster.employees];
      final index = employees.indexWhere((item) => item.id == employee.id);
      if (index < 0) {
        employees.add(employee);
      } else {
        employees[index] = employee;
      }
      return scenario.copyWith(
        staffing: scenario.staffing.copyWith(
          roster: scenario.staffing.roster.copyWith(employees: employees),
        ),
      );
    });
  }

  void removeEmployee(String id) {
    _mutate(
      (scenario) => scenario.copyWith(
        staffing: scenario.staffing.copyWith(
          roster: scenario.staffing.roster.copyWith(
            employees: scenario.staffing.roster.employees
                .where((employee) => employee.id != id)
                .toList(),
          ),
        ),
      ),
    );
  }

  void setEmployeeShifts(String id, List<ShiftAssignment> shifts) {
    final employee = state.scenario?.staffing.roster.employees
        .where((employee) => employee.id == id)
        .firstOrNull;
    if (employee != null) {
      upsertEmployee(employee.copyWith(weeklyShifts: shifts));
    }
  }

  void setPayrollMode(PayrollAllocationMode mode) =>
      _updatePayroll((payroll) => payroll.copyWith(mode: mode));

  void setSharedPayrollBudget(Money? budget) => _updatePayroll(
    (payroll) => payroll.copyWith(sharedMonthlyPayrollBudget: budget),
  );

  void setOvertimeMultiplier(double multiplier) => _updatePayroll(
    (payroll) => payroll.copyWith(overtimeMultiplier: multiplier),
  );

  void setRegularHoursCap(int? hours) {
    _mutate(
      (scenario) => scenario.copyWith(
        staffing: scenario.staffing.copyWith(regularHoursPerMonthCap: hours),
      ),
    );
  }

  void setBonusConfiguration(BonusConfiguration bonus) =>
      _updatePayroll((payroll) => payroll.copyWith(bonus: bonus));

  void setStaffingOccupancyThreshold(Percentage threshold) => _updatePayroll(
    (payroll) =>
        payroll.copyWith(staffingExpansionOccupancyThreshold: threshold),
  );

  void setHeadcountRule(StaffingHeadcountRule rule) {
    _mutate(
      (scenario) => scenario.copyWith(
        staffing: scenario.staffing.copyWith(headcountRule: rule),
      ),
    );
  }

  void addAdditionalExpense(CostItem expense) {
    _mutate(
      (scenario) => scenario.copyWith(
        operatingExpenses: scenario.operatingExpenses.copyWith(
          additionalExpenses: [
            ...scenario.operatingExpenses.additionalExpenses,
            expense,
          ],
        ),
      ),
    );
  }

  void updateAdditionalExpense(CostItem expense) {
    _mutate(
      (scenario) => scenario.copyWith(
        operatingExpenses: scenario.operatingExpenses.copyWith(
          additionalExpenses: [
            for (final item in scenario.operatingExpenses.additionalExpenses)
              if (item.id == expense.id) expense else item,
          ],
        ),
      ),
    );
  }

  void removeAdditionalExpense(String id) {
    _mutate(
      (scenario) => scenario.copyWith(
        operatingExpenses: scenario.operatingExpenses.copyWith(
          additionalExpenses: scenario.operatingExpenses.additionalExpenses
              .where((item) => item.id != id)
              .toList(),
        ),
      ),
    );
  }

  void setSeasonalityEnabled(bool enabled) =>
      _updateSeasonality((model) => model.copyWith(enabled: enabled));

  void setSeasonalityMonthFactor(int month, double factor) =>
      _updateSeasonality(
        (model) => model.copyWith(
          monthFactors: {...model.monthFactors, month: factor},
        ),
      );

  void setSeasonalityDayFactor(int weekday, double factor) =>
      _updateSeasonality(
        (model) => model.copyWith(
          dayOfWeekFactors: {...model.dayOfWeekFactors, weekday: factor},
        ),
      );

  void setSeasonalityWeatherFactor(double factor) =>
      _updateSeasonality((model) => model.copyWith(weatherFactor: factor));

  void setSeasonalityMarketingFactor(double factor) => _updateSeasonality(
    (model) => model.copyWith(marketingDemandFactor: factor),
  );

  void upsertSeasonalityEvent(CalendarEventFactor event) {
    _updateSeasonality((model) {
      final events = [...model.events];
      final index = events.indexWhere((item) => item.id == event.id);
      if (index < 0) {
        events.add(event);
      } else {
        events[index] = event;
      }
      return model.copyWith(events: events);
    });
  }

  void removeSeasonalityEvent(String id) => _updateSeasonality(
    (model) => model.copyWith(
      events: model.events.where((event) => event.id != id).toList(),
    ),
  );

  void setCriticalFailureEnabled(bool enabled) {
    _mutate(
      (scenario) => scenario.copyWith(
        stressAssumptions: scenario.stressAssumptions.copyWith(
          criticalFailureEnabled: enabled,
        ),
      ),
    );
  }

  void setDebtAssumptions(DebtAssumptions assumptions) =>
      _mutate((scenario) => scenario.copyWith(debtAssumptions: assumptions));

  void setDebtEnabled(bool enabled) =>
      _updateDebt((debt) => debt.copyWith(enabled: enabled));

  void setDebtPrincipal(Money principal) =>
      _updateDebt((debt) => debt.copyWith(principal: principal));

  void setDebtAnnualInterestRate(Percentage rate) =>
      _updateDebt((debt) => debt.copyWith(annualInterestRate: rate));

  void setDebtTermMonths(int months) =>
      _updateDebt((debt) => debt.copyWith(termMonths: months));

  void setDebtFirstPaymentMonth(int month) =>
      _updateDebt((debt) => debt.copyWith(firstPaymentMonth: month));

  void setDebtDisbursementMonth(int month) =>
      _updateDebt((debt) => debt.copyWith(disbursementMonth: month));

  void setDebtKind(DebtAmortizationKind kind) =>
      _updateDebt((debt) => debt.copyWith(kind: kind));

  void upsertMonthlyActuals(MonthlyActuals actuals) => _mutate(
    (scenario) => scenario.copyWith(actuals: scenario.actuals.upsert(actuals)),
  );

  /// Removes one month's actuals, or clears the ledger when no month is given.
  void clearMonthlyActuals([int? monthNumber]) => _mutate(
    (scenario) => scenario.copyWith(
      actuals: monthNumber == null
          ? const ActualsLedger()
          : scenario.actuals.remove(monthNumber),
    ),
  );

  void setWorkingCapitalMethod(WorkingCapitalMethod method) =>
      _updateWorkingCapital((model) => model.copyWith(method: method));

  void setWorkingCapitalFixedAmount(Money amount) =>
      _updateWorkingCapital((model) => model.copyWith(fixedAmount: amount));

  void setWorkingCapitalPercent(Percentage percentage) => _updateWorkingCapital(
    (model) => model.copyWith(percentOfStartup: percentage),
  );

  void setWorkingCapitalMonthsOfOpex(double months) =>
      _updateWorkingCapital((model) => model.copyWith(monthsOfOpex: months));

  void _updatePayroll(
    PayrollConfiguration Function(PayrollConfiguration) transform,
  ) {
    _mutate(
      (scenario) => scenario.copyWith(
        staffing: scenario.staffing.copyWith(
          payroll: transform(scenario.staffing.payroll),
        ),
      ),
    );
  }

  void _updateMarketing(
    MarketingAssumptions Function(MarketingAssumptions) transform,
  ) {
    _mutate(
      (scenario) => scenario.copyWith(
        marketingAssumptions: transform(scenario.marketingAssumptions),
      ),
    );
  }

  void _updateSeasonality(
    SeasonalityModel Function(SeasonalityModel) transform,
  ) {
    _mutate(
      (scenario) =>
          scenario.copyWith(seasonality: transform(scenario.seasonality)),
    );
  }

  void _updateWorkingCapital(
    WorkingCapitalModel Function(WorkingCapitalModel) transform,
  ) {
    _mutate(
      (scenario) =>
          scenario.copyWith(workingCapital: transform(scenario.workingCapital)),
    );
  }

  void _updateDebt(DebtAssumptions Function(DebtAssumptions) transform) {
    _mutate(
      (scenario) => scenario.copyWith(
        debtAssumptions: transform(scenario.debtAssumptions),
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
    await loadScenario.repository.saveActiveScenario(baseline);
    final output = calculateFinancialModel(baseline);
    final summaries = await _loadSummaries();
    AppLogger.info('Scenario reset to the study baseline');

    emit(
      ScenarioState(
        status: ScenarioStatus.ready,
        scenario: baseline,
        projection: output.projection,
        validation: output.validation,
        availableScenarios: summaries,
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
    if (failure == null) await refreshScenarioList();
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
        availableScenarios: [
          for (final summary in state.availableScenarios)
            if (summary.id == updated.metadata.id)
              summary.copyWith(name: updated.metadata.name)
            else
              summary,
        ],
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

  Future<List<ScenarioSummary>> _loadSummaries() async {
    final result = await loadScenario.repository.listScenarios();
    return result.valueOrNull ?? const [];
  }

  Future<void> _saveAndSelect(FinancialScenario scenario) async {
    _autosaveTimer?.cancel();
    final saved = await loadScenario.repository.saveScenario(scenario);
    if (saved case Failed<void>(:final failure)) {
      emit(state.copyWith(failure: failure));
      return;
    }
    final selected = await loadScenario.repository.setActiveScenarioId(
      scenario.metadata.id,
    );
    if (selected case Failed<void>(:final failure)) {
      emit(state.copyWith(failure: failure));
      return;
    }
    final output = calculateFinancialModel(scenario);
    emit(
      state.copyWith(
        scenario: scenario,
        projection: output.projection,
        validation: output.validation,
        hasUnsavedChanges: false,
        clearFailure: true,
        availableScenarios: await _loadSummaries(),
      ),
    );
  }

  String _newScenarioId(String kind) =>
      '$kind-${DateTime.now().microsecondsSinceEpoch}';

  @override
  Future<void> close() {
    _autosaveTimer?.cancel();
    return super.close();
  }
}
