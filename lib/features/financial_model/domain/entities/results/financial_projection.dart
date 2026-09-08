import 'package:equatable/equatable.dart';

import '../../value_objects/minutes.dart';
import '../../value_objects/money.dart';
import '../scenario/financial_scenario.dart';
import '../scenario/projection_settings.dart';
import 'annual_result.dart';
import 'monthly_financial_result.dart';
import 'payback_result.dart';
import 'roi_result.dart';
import 'sensitivity_result.dart';
import 'startup_cost_breakdown.dart';

/// How much the venue can physically sell, before demand is considered.
class CapacitySummary extends Equatable {
  const CapacitySummary({
    required this.totalRoundTime,
    required this.operatingMinutesPerDay,
    required this.maximumRoundsPerDay,
  });

  /// Playing time plus turnaround: the slot a single round really occupies.
  final Minutes totalRoundTime;

  final Minutes operatingMinutesPerDay;

  /// Whole rounds that fit in a trading day. Floored, because a part-sold round
  /// cannot be sold.
  final int maximumRoundsPerDay;

  @override
  List<Object?> get props => [
    totalRoundTime,
    operatingMinutesPerDay,
    maximumRoundsPerDay,
  ];
}

/// The complete, immutable output of the calculation engine.
///
/// Everything a screen needs is here, already derived. Screens read; they never
/// compute.
class FinancialProjection extends Equatable {
  const FinancialProjection({
    required this.scenario,
    required this.capacity,
    required this.startupCosts,
    required this.monthlyResults,
    required this.annualResults,
    required this.payback,
    required this.roi,
    required this.sensitivityResults,
    required this.steadyStateMonthNumber,
  });

  /// The exact inputs this projection was produced from, so a result can always
  /// be explained without guessing which scenario it came from.
  final FinancialScenario scenario;

  final CapacitySummary capacity;
  final StartupCostBreakdown startupCosts;

  /// Month 0 first, then one entry per trading month. The list index equals the
  /// month number.
  final List<MonthlyFinancialResult> monthlyResults;

  final List<AnnualResult> annualResults;
  final PaybackResult payback;
  final RoiResult roi;
  final List<SensitivityResult> sensitivityResults;

  /// The first month that runs at both stable occupancy and final headcount.
  /// This is the month that represents "a normal month" for headline figures.
  final int steadyStateMonthNumber;

  Money get initialInvestment => startupCosts.total;

  MonthlyFinancialResult get investmentMonth => monthlyResults.first;

  List<MonthlyFinancialResult> get tradingMonths =>
      monthlyResults.where((month) => !month.isInvestmentMonth).toList();

  /// The representative normal month, or `null` if the projection stops before
  /// the business reaches steady state.
  MonthlyFinancialResult? get steadyStateMonth =>
      steadyStateMonthNumber < monthlyResults.length
      ? monthlyResults[steadyStateMonthNumber]
      : null;

  AnnualResult? get yearOne => _yearOrNull(1);
  AnnualResult? get yearTwo => _yearOrNull(2);

  AnnualResult? _yearOrNull(int yearNumber) {
    for (final year in annualResults) {
      if (year.yearNumber == yearNumber) return year;
    }
    return null;
  }

  int get projectionMonths => scenario.projection.projectionMonths;

  /// Months grouped into one reported year.
  static const int monthsPerYear = ProjectionSettings.monthsPerYear;

  @override
  List<Object?> get props => [
    scenario,
    capacity,
    startupCosts,
    monthlyResults,
    annualResults,
    payback,
    roi,
    sensitivityResults,
    steadyStateMonthNumber,
  ];
}
