import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Raw local storage for the scenario document.
///
/// Deals in JSON maps, not domain objects, so the storage technology can be
/// swapped without touching mapping or business code.
abstract interface class ScenarioLocalDataSource {
  Future<Map<String, dynamic>?> readLegacy();
  Future<void> clearLegacy();
  Future<Map<String, dynamic>?> readIndex();
  Future<void> writeIndex(Map<String, dynamic> index);
  Future<Map<String, dynamic>?> readScenario(String id);
  Future<void> writeScenario(String id, Map<String, dynamic> document);
  Future<void> deleteScenario(String id);
  Future<void> clearCollection(Iterable<String> ids);
}

/// Key-value backed implementation.
class SharedPreferencesScenarioDataSource implements ScenarioLocalDataSource {
  SharedPreferencesScenarioDataSource({SharedPreferencesAsync? preferences})
    : _preferences = preferences ?? SharedPreferencesAsync();

  static const String legacyKey = 'active_scenario_v1';
  static const String indexKey = 'scenarios_index_v1';
  static const String scenarioKeyPrefix = 'scenario_v1_';

  final SharedPreferencesAsync _preferences;

  Future<Map<String, dynamic>?> _readObject(String key) async {
    final raw = await _preferences.getString(key);
    if (raw == null || raw.isEmpty) return null;

    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Stored scenario is not a JSON object');
    }
    return decoded;
  }

  @override
  Future<Map<String, dynamic>?> readLegacy() => _readObject(legacyKey);

  @override
  Future<void> clearLegacy() => _preferences.remove(legacyKey);

  @override
  Future<Map<String, dynamic>?> readIndex() => _readObject(indexKey);

  @override
  Future<void> writeIndex(Map<String, dynamic> index) =>
      _preferences.setString(indexKey, jsonEncode(index));

  @override
  Future<Map<String, dynamic>?> readScenario(String id) =>
      _readObject('$scenarioKeyPrefix$id');

  @override
  Future<void> writeScenario(String id, Map<String, dynamic> document) =>
      _preferences.setString('$scenarioKeyPrefix$id', jsonEncode(document));

  @override
  Future<void> deleteScenario(String id) =>
      _preferences.remove('$scenarioKeyPrefix$id');

  @override
  Future<void> clearCollection(Iterable<String> ids) async {
    for (final id in ids) {
      await deleteScenario(id);
    }
    await _preferences.remove(indexKey);
  }
}
