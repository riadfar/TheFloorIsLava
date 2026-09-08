import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Raw local storage for the scenario document.
///
/// Deals in JSON maps, not domain objects, so the storage technology can be
/// swapped without touching mapping or business code.
abstract interface class ScenarioLocalDataSource {
  Future<Map<String, dynamic>?> read();
  Future<void> write(Map<String, dynamic> document);
  Future<void> clear();
}

/// Key-value backed implementation.
class SharedPreferencesScenarioDataSource implements ScenarioLocalDataSource {
  SharedPreferencesScenarioDataSource({SharedPreferencesAsync? preferences})
    : _preferences = preferences ?? SharedPreferencesAsync();

  static const String _key = 'active_scenario_v1';

  final SharedPreferencesAsync _preferences;

  @override
  Future<Map<String, dynamic>?> read() async {
    final raw = await _preferences.getString(_key);
    if (raw == null || raw.isEmpty) return null;

    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Stored scenario is not a JSON object');
    }
    return decoded;
  }

  @override
  Future<void> write(Map<String, dynamic> document) =>
      _preferences.setString(_key, jsonEncode(document));

  @override
  Future<void> clear() => _preferences.remove(_key);
}
