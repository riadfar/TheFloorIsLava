import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../../../../core/logging/app_logger.dart';
import '../../domain/entities/scenario/financial_scenario.dart';
import '../../domain/repositories/scenario_repository.dart';
import '../datasources/scenario_local_data_source.dart';
import '../models/scenario_mapper.dart';

/// Maps stored JSON to scenarios and back, turning anything that goes wrong
/// into a typed failure.
///
/// Corrupt storage is survivable: the failure says so, and the application
/// falls back to the baseline rather than refusing to start.
class ScenarioRepositoryImpl implements ScenarioRepository {
  ScenarioRepositoryImpl(this._dataSource);

  final ScenarioLocalDataSource _dataSource;

  @override
  Future<Result<FinancialScenario?>> loadActiveScenario() async {
    try {
      final document = await _dataSource.read();
      if (document == null) {
        AppLogger.info('No stored scenario; starting from the baseline');
        return const Success(null);
      }
      final scenario = ScenarioMapper.fromJson(document);
      AppLogger.info(
        'Loaded scenario "${scenario.metadata.id}" '
        '(${scenario.metadata.calculationModelVersion})',
      );
      return Success(scenario);
    } on FormatException catch (error) {
      AppLogger.warning('Stored scenario could not be read', error);
      return const Failed(PersistenceFailure(PersistenceFailureKind.corrupted));
    } catch (error, stackTrace) {
      AppLogger.error('Scenario storage unavailable', error, stackTrace);
      return Failed(
        PersistenceFailure(PersistenceFailureKind.unavailable, cause: error),
      );
    }
  }

  @override
  Future<Result<void>> saveActiveScenario(FinancialScenario scenario) async {
    try {
      await _dataSource.write(ScenarioMapper.toJson(scenario));
      AppLogger.debug('Saved scenario "${scenario.metadata.id}"');
      return const Success(null);
    } catch (error, stackTrace) {
      AppLogger.error('Could not save scenario', error, stackTrace);
      return Failed(
        PersistenceFailure(PersistenceFailureKind.unavailable, cause: error),
      );
    }
  }

  @override
  Future<Result<void>> clearActiveScenario() async {
    try {
      await _dataSource.clear();
      AppLogger.info('Cleared stored scenario');
      return const Success(null);
    } catch (error, stackTrace) {
      AppLogger.error('Could not clear stored scenario', error, stackTrace);
      return Failed(
        PersistenceFailure(PersistenceFailureKind.unavailable, cause: error),
      );
    }
  }
}
