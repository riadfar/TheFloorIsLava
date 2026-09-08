import 'package:flutter/material.dart';

import 'app/app.dart';
import 'core/logging/app_logger.dart';
import 'features/financial_model/application/state/scenario_cubit.dart';
import 'features/financial_model/application/use_cases/load_scenario.dart';
import 'features/financial_model/application/use_cases/reset_scenario.dart';
import 'features/financial_model/application/use_cases/save_scenario.dart';
import 'features/financial_model/data/datasources/scenario_local_data_source.dart';
import 'features/financial_model/data/repositories/scenario_repository_impl.dart';
import 'features/settings/application/settings_cubit.dart';
import 'features/settings/data/settings_repository_impl.dart';

/// Composition root.
///
/// Everything is wired here, once. No other file reaches for a concrete
/// repository or data source, which is what keeps the layers swappable and the
/// domain testable without Flutter.
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  AppLogger.info('Starting Floor is Lava');

  final scenarioRepository = ScenarioRepositoryImpl(
    SharedPreferencesScenarioDataSource(),
  );
  final settingsRepository = SettingsRepositoryImpl();

  final scenarioCubit = ScenarioCubit(
    loadScenario: LoadScenario(scenarioRepository),
    saveScenario: SaveScenario(scenarioRepository),
    resetScenario: ResetScenario(scenarioRepository),
  );
  final settingsCubit = SettingsCubit(settingsRepository);

  // Both load in the background; the UI shows a spinner until the scenario is
  // ready, which on local storage is a single frame or two.
  scenarioCubit.initialise();
  settingsCubit.initialise();

  runApp(
    FloorIsLavaApp(scenarioCubit: scenarioCubit, settingsCubit: settingsCubit),
  );
}
