import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../../../../core/logging/app_logger.dart';
import '../../domain/defaults/baseline_scenario.dart';
import '../../domain/entities/scenario/financial_scenario.dart';
import '../../domain/entities/scenario/scenario_summary.dart';
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
  Future<Result<List<ScenarioSummary>>> listScenarios() => _guard(() async {
    final index = await _ensureIndex();
    final summaries = <ScenarioSummary>[];
    for (final id in index.ids) {
      final document = await _dataSource.readScenario(id);
      if (document == null) continue;
      final scenario = ScenarioMapper.fromJson(document);
      summaries.add(
        ScenarioSummary(
          id: id,
          name: scenario.metadata.name,
          updatedAt: scenario.metadata.updatedAt,
          isActive: id == index.activeId,
          isBuiltinRecoverable: id == BaselineScenario.scenarioId,
        ),
      );
    }
    summaries.sort((left, right) => right.updatedAt.compareTo(left.updatedAt));
    return summaries;
  });

  @override
  Future<Result<FinancialScenario?>> loadScenarioById(String id) =>
      _guard(() async {
        await _ensureIndex();
        final document = await _dataSource.readScenario(id);
        return document == null ? null : ScenarioMapper.fromJson(document);
      });

  @override
  Future<Result<void>> saveScenario(FinancialScenario scenario) =>
      _guard(() async {
        final index = await _ensureIndex();
        await _dataSource.writeScenario(
          scenario.metadata.id,
          ScenarioMapper.toJson(scenario),
        );
        if (!index.ids.contains(scenario.metadata.id)) {
          await _writeIndex(
            _ScenarioIndex(
              ids: [...index.ids, scenario.metadata.id],
              activeId: index.activeId,
            ),
          );
        }
        AppLogger.debug('Saved scenario "${scenario.metadata.id}"');
      });

  @override
  Future<Result<void>> setActiveScenarioId(String id) => _guard(() async {
    final index = await _ensureIndex();
    if (!index.ids.contains(id) || await _dataSource.readScenario(id) == null) {
      throw FormatException('Unknown scenario id "$id"');
    }
    await _writeIndex(_ScenarioIndex(ids: index.ids, activeId: id));
  });

  @override
  Future<Result<void>> deleteScenario(String id) => _guard(() async {
    var index = await _ensureIndex();

    if (id == BaselineScenario.scenarioId) {
      final baseline = BaselineScenario.build();
      await _dataSource.writeScenario(id, ScenarioMapper.toJson(baseline));
      return;
    }

    if (!index.ids.contains(id)) return;
    await _dataSource.deleteScenario(id);
    final remaining = index.ids.where((item) => item != id).toList();
    if (remaining.isEmpty) {
      final baseline = BaselineScenario.build();
      await _dataSource.writeScenario(
        baseline.metadata.id,
        ScenarioMapper.toJson(baseline),
      );
      index = _ScenarioIndex(
        ids: [baseline.metadata.id],
        activeId: baseline.metadata.id,
      );
    } else {
      index = _ScenarioIndex(
        ids: remaining,
        activeId: index.activeId == id ? remaining.first : index.activeId,
      );
    }
    await _writeIndex(index);
  });

  @override
  Future<Result<FinancialScenario?>> loadActiveScenario() async {
    final indexResult = await _guard(_ensureIndex);
    if (indexResult case Failed<_ScenarioIndex>(:final failure)) {
      return Failed(failure);
    }
    final index = (indexResult as Success<_ScenarioIndex>).value;
    return loadScenarioById(index.activeId);
  }

  @override
  Future<Result<void>> saveActiveScenario(FinancialScenario scenario) async {
    final saved = await saveScenario(scenario);
    if (saved is Failed<void>) return saved;
    return setActiveScenarioId(scenario.metadata.id);
  }

  @override
  Future<Result<void>> clearActiveScenario() async {
    return _guard(() async {
      final index = await _ensureIndex();
      await _dataSource.clearCollection(index.ids);
      await _dataSource.clearLegacy();
      AppLogger.info('Cleared stored scenario collection');
    });
  }

  Future<_ScenarioIndex> _ensureIndex() async {
    final document = await _dataSource.readIndex();
    if (document != null) {
      final index = _ScenarioIndex.fromJson(document);
      if (index.ids.isNotEmpty && index.ids.contains(index.activeId)) {
        return index;
      }
      throw const FormatException('Stored scenario index is invalid');
    }

    final legacyDocument = await _dataSource.readLegacy();
    final scenario = legacyDocument == null
        ? BaselineScenario.build()
        : ScenarioMapper.fromJson(legacyDocument);
    await _dataSource.writeScenario(
      scenario.metadata.id,
      ScenarioMapper.toJson(scenario),
    );
    final index = _ScenarioIndex(
      ids: [scenario.metadata.id],
      activeId: scenario.metadata.id,
    );
    await _writeIndex(index);
    if (legacyDocument != null) {
      await _dataSource.clearLegacy();
      AppLogger.info('Migrated legacy active scenario into collection');
    }
    return index;
  }

  Future<void> _writeIndex(_ScenarioIndex index) =>
      _dataSource.writeIndex(index.toJson());

  Future<Result<T>> _guard<T>(Future<T> Function() operation) async {
    try {
      return Success(await operation());
    } on FormatException catch (error) {
      AppLogger.warning('Stored scenarios could not be read', error);
      return const Failed(PersistenceFailure(PersistenceFailureKind.corrupted));
    } catch (error, stackTrace) {
      AppLogger.error('Scenario storage unavailable', error, stackTrace);
      return Failed(
        PersistenceFailure(PersistenceFailureKind.unavailable, cause: error),
      );
    }
  }
}

class _ScenarioIndex {
  const _ScenarioIndex({required this.ids, required this.activeId});

  factory _ScenarioIndex.fromJson(Map<String, dynamic> json) {
    final rawIds = json['ids'];
    final activeId = json['activeId'];
    if (rawIds is! List || activeId is! String) {
      throw const FormatException('Invalid scenario index');
    }
    return _ScenarioIndex(
      ids: rawIds.map((id) {
        if (id is! String) throw const FormatException('Invalid scenario id');
        return id;
      }).toList(),
      activeId: activeId,
    );
  }

  final List<String> ids;
  final String activeId;

  Map<String, dynamic> toJson() => {'ids': ids, 'activeId': activeId};
}
