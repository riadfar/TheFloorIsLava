import 'package:flutter_bloc/flutter_bloc.dart';

import '../domain/app_settings.dart';
import '../domain/settings_repository.dart';

/// Holds the user's display preferences and writes changes straight through.
class SettingsCubit extends Cubit<AppSettings> {
  SettingsCubit(this._repository) : super(const AppSettings());

  final SettingsRepository _repository;

  Future<void> initialise() async {
    emit(await _repository.load());
  }

  void setThemeMode(AppThemeMode mode) =>
      _update(state.copyWith(themeMode: mode));

  void setDecimalPrecision(int precision) => _update(
    state.copyWith(
      decimalPrecision: precision.clamp(
        AppSettings.minimumDecimalPrecision,
        AppSettings.maximumDecimalPrecision,
      ),
    ),
  );

  /// `null` follows the device language.
  void setLanguage(String? languageCode) => _update(
    languageCode == null
        ? state.copyWith(clearLanguage: true)
        : state.copyWith(languageCode: languageCode),
  );

  void _update(AppSettings settings) {
    if (settings == state) return;
    emit(settings);
    _repository.save(settings);
  }
}
