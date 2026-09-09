import 'package:flutter_test/flutter_test.dart';
import 'package:the_floor_is_lava/features/financial_model/data/datasources/scenario_local_data_source.dart';
import 'package:the_floor_is_lava/features/financial_model/data/models/scenario_mapper.dart';
import 'package:the_floor_is_lava/features/financial_model/data/repositories/scenario_repository_impl.dart';
import 'package:the_floor_is_lava/features/financial_model/domain/defaults/baseline_scenario.dart';

class MemoryScenarioDataSource implements ScenarioLocalDataSource {
  Map<String, dynamic>? legacy;
  Map<String, dynamic>? index;
  final Map<String, Map<String, dynamic>> scenarios = {};

  @override
  Future<void> clearCollection(Iterable<String> ids) async {
    for (final id in ids) {
      scenarios.remove(id);
    }
    index = null;
  }

  @override
  Future<void> clearLegacy() async => legacy = null;

  @override
  Future<void> deleteScenario(String id) async => scenarios.remove(id);

  @override
  Future<Map<String, dynamic>?> readIndex() async => index;

  @override
  Future<Map<String, dynamic>?> readLegacy() async => legacy;

  @override
  Future<Map<String, dynamic>?> readScenario(String id) async => scenarios[id];

  @override
  Future<void> writeIndex(Map<String, dynamic> value) async => index = value;

  @override
  Future<void> writeScenario(String id, Map<String, dynamic> document) async =>
      scenarios[id] = document;
}

void main() {
  test('migrates the legacy active scenario into the collection', () async {
    final source = MemoryScenarioDataSource();
    final legacy = BaselineScenario.build(now: DateTime.utc(2026)).copyWith(
      metadata: BaselineScenario.build(now: DateTime.utc(2026)).metadata
          .copyWith(name: 'Imported model'),
    );
    source.legacy = ScenarioMapper.toJson(legacy);
    final repository = ScenarioRepositoryImpl(source);

    final summaries = (await repository.listScenarios()).valueOrNull!;
    final active = (await repository.loadActiveScenario()).valueOrNull;

    expect(summaries, hasLength(1));
    expect(summaries.single.name, 'Imported model');
    expect(summaries.single.isActive, isTrue);
    expect(active!.metadata.id, legacy.metadata.id);
    expect(source.legacy, isNull);
    expect(source.index, isNotNull);
  });

  test(
    'upserts, selects, and deletes scenarios without leaving none',
    () async {
      final source = MemoryScenarioDataSource();
      final repository = ScenarioRepositoryImpl(source);
      await repository.listScenarios();
      final now = DateTime.utc(2026, 2);
      final custom = BaselineScenario.worstCase(now: now).copyWith(
        metadata: BaselineScenario.worstCase(now: now).metadata
            .copyWith(id: 'worst-custom', name: 'Worst Case'),
      );

      await repository.saveScenario(custom);
      await repository.setActiveScenarioId(custom.metadata.id);
      expect(
        (await repository.loadActiveScenario()).valueOrNull!.metadata.name,
        'Worst Case',
      );

      await repository.deleteScenario(custom.metadata.id);
      final summaries = (await repository.listScenarios()).valueOrNull!;
      expect(summaries, hasLength(1));
      expect(summaries.single.id, BaselineScenario.scenarioId);
      expect(summaries.single.isActive, isTrue);
    },
  );
}
