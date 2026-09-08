import 'package:intl/intl.dart';

import '../../features/financial_model/domain/value_objects/minutes.dart';
import '../../features/financial_model/domain/value_objects/money.dart';
import '../../features/financial_model/domain/value_objects/percentage.dart';

/// Turns domain values into display strings.
///
/// This is the only place display precision is decided. The model keeps far
/// more precision than is ever shown; rounding happens here and nowhere else,
/// so a rounded figure can never leak back into a calculation.
class ValueFormatter {
  ValueFormatter({
    required this.localeName,
    required this.currencyCode,
    required this.decimalPrecision,
  }) : _currency = NumberFormat.simpleCurrency(
         locale: localeName,
         name: currencyCode,
         decimalDigits: decimalPrecision,
       ),
       _currencyWhole = NumberFormat.simpleCurrency(
         locale: localeName,
         name: currencyCode,
         decimalDigits: 0,
       ),
       _compactCurrency = NumberFormat.compactSimpleCurrency(
         locale: localeName,
         name: currencyCode,
       ),
       _decimal = NumberFormat.decimalPattern(localeName),
       _integer = NumberFormat.decimalPattern(localeName)
         ..maximumFractionDigits = 0;

  final String localeName;
  final String currencyCode;

  /// Decimal places used for currency. A user preference, not a model concern.
  final int decimalPrecision;

  final NumberFormat _currency;
  final NumberFormat _currencyWhole;
  final NumberFormat _compactCurrency;
  final NumberFormat _decimal;
  final NumberFormat _integer;

  /// The symbol amounts are written with, e.g. `$`. Useful for showing the
  /// unit inside an input without hard-coding a currency.
  String get currencySymbol => _currency.currencySymbol;

  String money(Money value) => _currency.format(value.amount);

  /// Rounded to whole units - for headline figures and chart axes.
  String moneyWhole(Money value) => _currencyWhole.format(value.amount);

  /// Abbreviated, e.g. `$11.9K`, for tight spaces such as chart labels.
  String moneyCompact(Money value) => moneyCompactAmount(value.amount);

  /// Compact currency for a bare amount. Chart axes work in plain numbers, and
  /// this keeps their labels formatted by the same rules as everything else.
  String moneyCompactAmount(double amount) => _compactCurrency.format(amount);

  /// Signed, so a negative value reads as negative without relying on colour.
  String signedMoney(Money value) {
    final formatted = money(value.abs);
    if (value.isNegative) return '-$formatted';
    return value.isZero ? formatted : '+$formatted';
  }

  String percentage(Percentage value, {int decimals = 1}) {
    final formatter = NumberFormat.decimalPattern(localeName)
      ..minimumFractionDigits = 0
      ..maximumFractionDigits = decimals;
    return '${formatter.format(value.percent)}%';
  }

  String number(double value, {int decimals = 2}) {
    final formatter = NumberFormat.decimalPattern(localeName)
      ..minimumFractionDigits = 0
      ..maximumFractionDigits = decimals;
    return formatter.format(value);
  }

  String count(int value) => _integer.format(value);

  String minutes(Minutes value) => number(value.value, decimals: 0);

  /// Formats a number for editing: no grouping separators, no trailing zeros.
  String forEditing(num value, {int maxDecimals = 4}) {
    final formatter = NumberFormat.decimalPatternDigits(
      locale: localeName,
      decimalDigits: maxDecimals,
    )..turnOffGrouping();
    return _trimTrailingZeros(formatter.format(value));
  }

  String _trimTrailingZeros(String text) {
    final separator = _decimal.symbols.DECIMAL_SEP;
    if (!text.contains(separator)) return text;
    var trimmed = text;
    while (trimmed.endsWith('0')) {
      trimmed = trimmed.substring(0, trimmed.length - 1);
    }
    if (trimmed.endsWith(separator)) {
      trimmed = trimmed.substring(0, trimmed.length - 1);
    }
    return trimmed;
  }

  /// Parses a number the user typed, honouring the locale's decimal separator.
  /// Returns `null` when the text is not a number.
  double? parseNumber(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return null;
    final separator = _decimal.symbols.DECIMAL_SEP;
    final normalised = separator == '.'
        ? trimmed.replaceAll(',', '')
        : trimmed.replaceAll('.', '').replaceAll(separator, '.');
    return double.tryParse(normalised);
  }
}
