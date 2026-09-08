import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/logging/app_logger.dart';
import '../domain/app_settings.dart';
import '../domain/settings_repository.dart';

/// Key-value backed preferences.
///
/// Preferences are cosmetic, so a read failure falls back to the defaults
/// rather than surfacing an error: the app is still perfectly usable.
class SettingsRepositoryImpl implements SettingsRepository {
  SettingsRepositoryImpl({SharedPreferencesAsync? preferences})
    : _preferences = preferences ?? SharedPreferencesAsync();

  static const String _themeKey = 'settings_theme_mode';
  static const String _precisionKey = 'settings_decimal_precision';
  static const String _languageKey = 'settings_language_code';

  final SharedPreferencesAsync _preferences;

  @override
  Future<AppSettings> load() async {
    try {
      final theme = await _preferences.getString(_themeKey);
      final precision = await _preferences.getInt(_precisionKey);
      final language = await _preferences.getString(_languageKey);

      return AppSettings(
        themeMode:
            AppThemeMode.values
                .where((mode) => mode.name == theme)
                .firstOrNull ??
            AppThemeMode.system,
        decimalPrecision:
            precision?.clamp(
              AppSettings.minimumDecimalPrecision,
              AppSettings.maximumDecimalPrecision,
            ) ??
            2,
        languageCode: (language == null || language.isEmpty) ? null : language,
      );
    } catch (error) {
      AppLogger.warning('Could not read settings; using defaults', error);
      return const AppSettings();
    }
  }

  @override
  Future<void> save(AppSettings settings) async {
    try {
      await _preferences.setString(_themeKey, settings.themeMode.name);
      await _preferences.setInt(_precisionKey, settings.decimalPrecision);
      await _preferences.setString(_languageKey, settings.languageCode ?? '');
    } catch (error) {
      AppLogger.warning('Could not save settings', error);
    }
  }
}
