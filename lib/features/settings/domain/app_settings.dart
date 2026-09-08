import 'package:equatable/equatable.dart';

/// Theme preference, expressed without depending on Flutter so the settings
/// model stays as portable as the financial one.
enum AppThemeMode { system, light, dark }

/// User preferences that affect presentation only.
///
/// Nothing here can change a calculated number - display precision is applied
/// when formatting, never before.
class AppSettings extends Equatable {
  const AppSettings({
    this.themeMode = AppThemeMode.system,
    this.decimalPrecision = 2,
    this.languageCode,
  });

  final AppThemeMode themeMode;

  /// Decimal places shown for currency amounts.
  final int decimalPrecision;

  /// `null` follows the device language.
  final String? languageCode;

  static const int minimumDecimalPrecision = 0;
  static const int maximumDecimalPrecision = 4;

  AppSettings copyWith({
    AppThemeMode? themeMode,
    int? decimalPrecision,
    String? languageCode,
    bool clearLanguage = false,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      decimalPrecision: decimalPrecision ?? this.decimalPrecision,
      languageCode: clearLanguage ? null : (languageCode ?? this.languageCode),
    );
  }

  @override
  List<Object?> get props => [themeMode, decimalPrecision, languageCode];
}
