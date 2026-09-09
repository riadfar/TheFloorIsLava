import 'package:the_floor_is_lava/core/error/failures.dart';
import 'package:the_floor_is_lava/core/error/result.dart';
import 'package:the_floor_is_lava/features/financial_model/domain/entities/scenario/financial_scenario.dart';
import 'package:the_floor_is_lava/features/financial_model/domain/entities/scenario/scenario_summary.dart';
import 'package:the_floor_is_lava/features/financial_model/domain/repositories/scenario_repository.dart';
import 'package:the_floor_is_lava/features/settings/domain/app_settings.dart';
import 'package:the_floor_is_lava/features/settings/domain/settings_repository.dart';

/// An in-memory stand-in for real storage.
class FakeScenarioRepository implements ScenarioRepository {
  FakeScenarioRepository({
    FinancialScenario? stored,
    this.loadFailure,
    this.saveFailure,
  }) : stored = stored {
    if (stored != null) {
      scenarios[stored.metadata.id] = stored;
      activeId = stored.metadata.id;
    }
  }

  FinancialScenario? stored;
  final Map<String, FinancialScenario> scenarios = {};
  String? activeId;
  Failure? loadFailure;
  Failure? saveFailure;

  int saveCount = 0;
  int clearCount = 0;

  @override
  Future<Result<FinancialScenario?>> loadActiveScenario() async {
    if (loadFailure != null) return Failed(loadFailure!);
    return Success(activeId == null ? stored : scenarios[activeId]);
  }

  @override
  Future<Result<void>> saveActiveScenario(FinancialScenario scenario) async {
    saveCount++;
    if (saveFailure != null) return Failed(saveFailure!);
    stored = scenario;
    scenarios[scenario.metadata.id] = scenario;
    activeId = scenario.metadata.id;
    return const Success(null);
  }

  @override
  Future<Result<void>> clearActiveScenario() async {
    clearCount++;
    stored = null;
    scenarios.clear();
    activeId = null;
    return const Success(null);
  }

  @override
  Future<Result<void>> deleteScenario(String id) async {
    scenarios.remove(id);
    if (activeId == id) activeId = scenarios.keys.firstOrNull;
    stored = activeId == null ? null : scenarios[activeId];
    return const Success(null);
  }

  @override
  Future<Result<List<ScenarioSummary>>> listScenarios() async => Success([
    for (final scenario in scenarios.values)
      ScenarioSummary(
        id: scenario.metadata.id,
        name: scenario.metadata.name,
        updatedAt: scenario.metadata.updatedAt,
        isActive: scenario.metadata.id == activeId,
        isBuiltinRecoverable: scenario.metadata.id == 'floor-is-lava-base',
      ),
  ]);

  @override
  Future<Result<FinancialScenario?>> loadScenarioById(String id) async =>
      Success(scenarios[id]);

  @override
  Future<Result<void>> saveScenario(FinancialScenario scenario) async {
    scenarios[scenario.metadata.id] = scenario;
    return const Success(null);
  }

  @override
  Future<Result<void>> setActiveScenarioId(String id) async {
    if (!scenarios.containsKey(id)) {
      return const Failed(PersistenceFailure(PersistenceFailureKind.corrupted));
    }
    activeId = id;
    stored = scenarios[id];
    return const Success(null);
  }
}

class FakeSettingsRepository implements SettingsRepository {
  FakeSettingsRepository([this.settings = const AppSettings()]);

  AppSettings settings;

  @override
  Future<AppSettings> load() async => settings;

  @override
  Future<void> save(AppSettings value) async => settings = value;
}
