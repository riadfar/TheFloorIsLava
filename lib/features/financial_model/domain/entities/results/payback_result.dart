import 'package:equatable/equatable.dart';

/// When the initial investment is earned back.
///
/// Two answers are reported side by side: [paybackMonth] is the workbook's
/// answer - the first month whose cumulative cash flow is no longer negative -
/// and [interpolatedMonths] is the finer estimate the specification asks for.
/// The workbook-compatible figure is kept intact so the app can still be
/// reconciled against the original study.
class PaybackResult extends Equatable {
  const PaybackResult({
    required this.lastNegativeMonth,
    required this.firstNonNegativeMonth,
    required this.interpolatedMonths,
  });

  /// The last month that still ends in the red, or `null` if none does.
  final int? lastNegativeMonth;

  /// The first month whose cumulative cash flow reaches zero or better, or
  /// `null` if the projection never gets there.
  final int? firstNonNegativeMonth;

  /// Fractional payback in months, e.g. `4.95`. `null` when the investment is
  /// never recovered, or when the crossing month has no positive inflow to
  /// interpolate across.
  final double? interpolatedMonths;

  /// The workbook-compatible payback month.
  int? get paybackMonth => firstNonNegativeMonth;

  bool get isRecovered => firstNonNegativeMonth != null;

  const PaybackResult.notRecovered({required this.lastNegativeMonth})
    : firstNonNegativeMonth = null,
      interpolatedMonths = null;

  @override
  List<Object?> get props => [
    lastNegativeMonth,
    firstNonNegativeMonth,
    interpolatedMonths,
  ];
}
