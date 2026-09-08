import 'app_settings.dart';

/// Storage for user preferences.
abstract interface class SettingsRepository {
  /// Returns the stored preferences, or the defaults if none are stored.
  Future<AppSettings> load();

  Future<void> save(AppSettings settings);
}
