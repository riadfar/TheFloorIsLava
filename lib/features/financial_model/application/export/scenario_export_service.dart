import 'dart:convert';

import '../../data/models/scenario_mapper.dart';
import '../../domain/entities/results/financial_projection.dart';
import '../../domain/entities/scenario/financial_scenario.dart';

/// Text-based interchange formats that do not require platform or spreadsheet
/// dependencies.
class ScenarioExportService {
  const ScenarioExportService();

  String exportScenarioJson(FinancialScenario scenario) =>
      jsonEncode(ScenarioMapper.toJson(scenario));

  /// Parses a scenario without changing its identity. The application layer
  /// decides whether an import replaces the active scenario or gets a new id.
  FinancialScenario importScenarioJson(String raw) {
    final decoded = jsonDecode(raw);
    if (decoded is! Map) {
      throw const FormatException('Scenario JSON must be an object');
    }
    return ScenarioMapper.fromJson(Map<String, dynamic>.from(decoded));
  }

  /// Produces an RFC 4180-style CSV that Excel and other spreadsheet programs
  /// can open directly. Numeric values always use a dot decimal separator.
  String exportProjectionCsv(FinancialProjection projection) {
    const header = [
      'Month',
      'Occupancy%',
      'MaxRounds',
      'ActualRounds',
      'DailyRevenue',
      'MonthlyRevenue',
      'Employees',
      'Payroll',
      'OtherExpenses',
      'TotalExpenses',
      'OperatingProfit',
      'ProfitMargin%',
      'NetCashFlow',
      'CumulativeCashFlow',
    ];

    final rows = <List<Object?>>[
      header,
      for (final month in projection.monthlyResults)
        [
          month.monthNumber,
          month.occupancy.percent,
          month.maximumRoundsPerDay,
          month.actualRoundsPerDay,
          month.dailyRevenue.amount,
          month.monthlyRevenue.amount,
          month.employeeCount,
          month.payroll.amount,
          month.otherOperatingExpenses.amount,
          month.totalOperatingExpenses.amount,
          month.operatingProfit.amount,
          month.isProfitMarginDefined ? month.profitMargin.percent : null,
          month.netCashFlow.amount,
          month.cumulativeCashFlow.amount,
        ],
    ];

    return rows.map(_encodeRow).join('\r\n');
  }

  String _encodeRow(List<Object?> values) =>
      values.map((value) => _escape(value?.toString() ?? '')).join(',');

  String _escape(String value) {
    if (!value.contains(RegExp('[",\r\n]'))) return value;
    return '"${value.replaceAll('"', '""')}"';
  }
}
