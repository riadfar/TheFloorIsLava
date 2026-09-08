import 'package:the_floor_is_lava/core/error/failures.dart';
import 'package:the_floor_is_lava/core/error/result.dart';
import 'package:the_floor_is_lava/features/financial_model/domain/entities/scenario/financial_scenario.dart';
import 'package:the_floor_is_lava/features/financial_model/domain/repositories/scenario_repository.dart';
import 'package:the_floor_is_lava/features/settings/domain/app_settings.dart';
import 'package:the_floor_is_lava/features/settings/domain/settings_repository.dart';

/// An in-memory stand-in for real storage.
class FakeScenarioRepository implements ScenarioRepository {
  FakeScenarioRepository({this.stored, this.loadFailure, this.saveFailure});

  FinancialScenario? stored;
  Failure? loadFailure;
  Failure? saveFailure;

  int saveCount = 0;
  int clearCount = 0;

  @override
  Future<Result<FinancialScenario?>> loadActiveScenario() async {
    if (loadFailure != null) return Failed(loadFailure!);
    return Success(stored);
  }

  @override
  Future<Result<void>> saveActiveScenario(FinancialScenario scenario) async {
    saveCount++;
    if (saveFailure != null) return Failed(saveFailure!);
    stored = scenario;
    return const Success(null);
  }

  @override
  Future<Result<void>> clearActiveScenario() async {
    clearCount++;
    stored = null;
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
