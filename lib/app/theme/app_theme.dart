import 'package:flutter/material.dart';

/// Spacing scale. One ladder, used everywhere, so rhythm stays consistent.
abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;

  /// Corner radius, applied consistently to cards, fields and sheets.
  static const double radius = 12;
  static const double radiusSmall = 8;

  static const BorderRadius cardRadius = BorderRadius.all(
    Radius.circular(radius),
  );
}

/// Colours that carry meaning rather than decoration.
///
/// Widgets ask for `positive` or `unverified`, never for "green" or "amber", so
/// the palette can be retuned without touching a single screen - and so the
/// same meaning always looks the same.
@immutable
class FinancialColors extends ThemeExtension<FinancialColors> {
  const FinancialColors({
    required this.positive,
    required this.positiveSurface,
    required this.negative,
    required this.negativeSurface,
    required this.warning,
    required this.warningSurface,
    required this.info,
    required this.infoSurface,
    required this.border,
    required this.mutedText,
    required this.editableAccent,
    required this.chartGrid,
  });

  /// Money coming in, profit, recovery.
  final Color positive;
  final Color positiveSurface;

  /// Money going out, losses, shortfalls.
  final Color negative;
  final Color negativeSurface;

  /// Something that needs checking - an estimate, an odd input.
  final Color warning;
  final Color warningSurface;

  /// Neutral emphasis, used for verified-but-not-contractual values.
  final Color info;
  final Color infoSurface;

  /// Hairlines around cards, tables and fields.
  final Color border;

  /// Secondary text: units, captions, help.
  final Color mutedText;

  /// Marks a value the user can change.
  final Color editableAccent;

  final Color chartGrid;

  static const FinancialColors light = FinancialColors(
    positive: Color(0xFF15803D),
    positiveSurface: Color(0xFFE8F5EC),
    negative: Color(0xFFB3261E),
    negativeSurface: Color(0xFFFCEAE8),
    warning: Color(0xFF9A6400),
    warningSurface: Color(0xFFFDF3E2),
    info: Color(0xFF1B5FA8),
    infoSurface: Color(0xFFE9F1FB),
    border: Color(0xFFE1E5EB),
    mutedText: Color(0xFF5C6672),
    editableAccent: Color(0xFF0F4C81),
    chartGrid: Color(0xFFECEFF3),
  );

  static const FinancialColors dark = FinancialColors(
    positive: Color(0xFF4ADE80),
    positiveSurface: Color(0xFF16301F),
    negative: Color(0xFFFF8A80),
    negativeSurface: Color(0xFF3A1D1A),
    warning: Color(0xFFFFB74D),
    warningSurface: Color(0xFF352713),
    info: Color(0xFF8AB8ED),
    infoSurface: Color(0xFF17273A),
    border: Color(0xFF2C323B),
    mutedText: Color(0xFF9AA3B0),
    editableAccent: Color(0xFF8AB8ED),
    chartGrid: Color(0xFF262B33),
  );

  /// The colour a monetary value should be drawn in. Colour is only ever a
  /// reinforcement here - every such value is also shown with its sign.
  Color forAmount({required bool isNegative}) =>
      isNegative ? negative : positive;

  @override
  FinancialColors copyWith({
    Color? positive,
    Color? positiveSurface,
    Color? negative,
    Color? negativeSurface,
    Color? warning,
    Color? warningSurface,
    Color? info,
    Color? infoSurface,
    Color? border,
    Color? mutedText,
    Color? editableAccent,
    Color? chartGrid,
  }) {
    return FinancialColors(
      positive: positive ?? this.positive,
      positiveSurface: positiveSurface ?? this.positiveSurface,
      negative: negative ?? this.negative,
      negativeSurface: negativeSurface ?? this.negativeSurface,
      warning: warning ?? this.warning,
      warningSurface: warningSurface ?? this.warningSurface,
      info: info ?? this.info,
      infoSurface: infoSurface ?? this.infoSurface,
      border: border ?? this.border,
      mutedText: mutedText ?? this.mutedText,
      editableAccent: editableAccent ?? this.editableAccent,
      chartGrid: chartGrid ?? this.chartGrid,
    );
  }

  @override
  FinancialColors lerp(ThemeExtension<FinancialColors>? other, double t) {
    if (other is! FinancialColors) return this;
    return FinancialColors(
      positive: Color.lerp(positive, other.positive, t)!,
      positiveSurface: Color.lerp(positiveSurface, other.positiveSurface, t)!,
      negative: Color.lerp(negative, other.negative, t)!,
      negativeSurface: Color.lerp(negativeSurface, other.negativeSurface, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      warningSurface: Color.lerp(warningSurface, other.warningSurface, t)!,
      info: Color.lerp(info, other.info, t)!,
      infoSurface: Color.lerp(infoSurface, other.infoSurface, t)!,
      border: Color.lerp(border, other.border, t)!,
      mutedText: Color.lerp(mutedText, other.mutedText, t)!,
      editableAccent: Color.lerp(editableAccent, other.editableAccent, t)!,
      chartGrid: Color.lerp(chartGrid, other.chartGrid, t)!,
    );
  }
}

/// Convenience access to the semantic palette.
extension FinancialColorsContext on BuildContext {
  FinancialColors get financialColors =>
      Theme.of(this).extension<FinancialColors>() ?? FinancialColors.light;
}

/// The application theme.
///
/// Restrained on purpose: flat surfaces, hairline borders instead of shadows,
/// and a single accent. The numbers are meant to be the loudest thing on
/// screen.
abstract final class AppTheme {
  /// A measured, neutral blue - the colour of a spreadsheet that has grown up.
  static const Color _seed = Color(0xFF0F4C81);

  static ThemeData light() => _build(Brightness.light, FinancialColors.light);

  static ThemeData dark() => _build(Brightness.dark, FinancialColors.dark);

  static ThemeData _build(Brightness brightness, FinancialColors financial) {
    final scheme = ColorScheme.fromSeed(
      seedColor: _seed,
      brightness: brightness,
    );
    final isLight = brightness == Brightness.light;
    final base = ThemeData(colorScheme: scheme, useMaterial3: true);

    return base.copyWith(
      scaffoldBackgroundColor: isLight
          ? const Color(0xFFF6F7F9)
          : const Color(0xFF101215),
      extensions: [financial],
      textTheme: _textTheme(base.textTheme, financial),
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        shape: Border(bottom: BorderSide(color: financial.border, width: 1)),
        titleTextStyle: base.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: scheme.onSurface,
        ),
      ),
      cardTheme: CardThemeData(
        color: scheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: AppSpacing.cardRadius,
          side: BorderSide(color: financial.border),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: financial.border,
        space: 1,
        thickness: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        isDense: true,
        filled: true,
        fillColor: isLight ? const Color(0xFFF9FAFB) : const Color(0xFF1B1F25),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
          borderSide: BorderSide(color: financial.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
          borderSide: BorderSide(color: financial.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
          borderSide: BorderSide(color: financial.negative),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
          borderSide: BorderSide(color: financial.negative, width: 2),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        height: 68,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: scheme.surface,
        elevation: 0,
        useIndicator: true,
      ),
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
        ),
      ),
      chipTheme: base.chipTheme.copyWith(
        side: BorderSide(color: financial.border),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
        ),
      ),
    );
  }

  /// Tight, legible, and clearly hierarchical. Figures use tabular figures so
  /// columns of numbers line up.
  static TextTheme _textTheme(TextTheme base, FinancialColors financial) {
    return base.copyWith(
      displaySmall: base.displaySmall?.copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: -0.5,
      ),
      headlineSmall: base.headlineSmall?.copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: -0.3,
      ),
      titleLarge: base.titleLarge?.copyWith(fontWeight: FontWeight.w600),
      titleMedium: base.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      titleSmall: base.titleSmall?.copyWith(fontWeight: FontWeight.w600),
      labelSmall: base.labelSmall?.copyWith(
        color: financial.mutedText,
        letterSpacing: 0.4,
      ),
      bodySmall: base.bodySmall?.copyWith(color: financial.mutedText),
    );
  }

  /// Style for figures that sit in columns and should align digit for digit.
  static TextStyle tabular(TextStyle style) =>
      style.copyWith(fontFeatures: const [FontFeature.tabularFigures()]);
}
