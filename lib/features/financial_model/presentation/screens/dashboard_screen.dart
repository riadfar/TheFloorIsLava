import 'package:flutter/material.dart';

import '../../../../app/theme/app_theme.dart';
import '../../../../core/formatting/value_formatter.dart';
import '../../../../core/responsive/responsive_grid.dart';
import '../../../../core/responsive/responsive_layout.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/entities/results/financial_projection.dart';
import '../../domain/entities/results/monthly_financial_result.dart';
import '../../domain/services/metric_explanation_service.dart';
import '../../domain/validation/validation_issue.dart';
import '../l10n/model_labels.dart';
import '../widgets/calculation_explanation.dart';
import '../widgets/financial_charts.dart';
import '../widgets/formatting_scope.dart';
import '../widgets/metric_card.dart';
import '../widgets/notice_banner.dart';
import '../widgets/scenario_builder.dart';
import '../widgets/screen_scaffold.dart';
import '../widgets/section_card.dart';

/// The state of the business at a glance.
///
/// Headline figures describe a *normal* month - the first month at full
/// occupancy and final headcount - because a ramp-up month would understate the
/// business and the final month would ignore how it got there.
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  static const MetricExplanationService _explanations =
      MetricExplanationService();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return ScenarioBuilder(
      builder: (context, scenario, projection, state) {
        final layout = context.layout;
        final steadyState = projection.steadyStateMonth;

        return ScreenScaffold(
          title: l10n.dashboardTitle,
          subtitle: scenario.metadata.name,
          body: ListView(
            key: const PageStorageKey('dashboard-scroll'),
            padding: layout.pagePadding,
            children: [
              if (state.validation.issues.isNotEmpty)
                ScreenSection(
                  child: _ValidationSummary(report: state.validation),
                ),
              ScreenSection(
                child: _MetricGrid(
                  projection: projection,
                  steadyState: steadyState,
                  onExplain: (metric, month) => showCalculationExplanation(
                    context,
                    _explanations.explain(
                      metric: metric,
                      projection: projection,
                      month: month,
                    ),
                  ),
                ),
              ),
              ScreenSection(
                child: _Charts(projection: projection, layout: layout),
              ),
              if (steadyState != null)
                ScreenSection(
                  child: _NormalMonthCard(
                    month: steadyState,
                    projection: projection,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _MetricGrid extends StatelessWidget {
  const _MetricGrid({
    required this.projection,
    required this.steadyState,
    required this.onExplain,
  });

  final FinancialProjection projection;
  final MonthlyFinancialResult? steadyState;
  final void Function(MetricId metric, MonthlyFinancialResult? month) onExplain;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final formatter = context.formatter;
    final layout = context.layout;

    final profit = steadyState?.operatingProfit;
    final payback = projection.payback;
    final roi = projection.roi;
    final yearOne = projection.yearOne;

    return ResponsiveGrid(
      minTileWidth: layout.metricTileMinWidth,
      children: [
        MetricCard(
          label: l10n.metricInitialInvestment,
          value: formatter.moneyWhole(projection.initialInvestment),
          caption: l10n.startupContingencyAt(
            formatter.percentage(projection.startupCosts.contingencyRate),
          ),
          onExplain: () => onExplain(MetricId.initialInvestment, null),
        ),
        MetricCard(
          label: l10n.metricMonthlyRevenue,
          value: steadyState == null
              ? l10n.notAvailable
              : formatter.moneyWhole(steadyState!.monthlyRevenue),
          caption: steadyState == null
              ? null
              : l10n.normalMonth(steadyState!.monthNumber),
          onExplain: () => onExplain(MetricId.monthlyRevenue, steadyState),
        ),
        MetricCard(
          label: l10n.metricMonthlyExpenses,
          value: steadyState == null
              ? l10n.notAvailable
              : formatter.moneyWhole(steadyState!.totalOperatingExpenses),
          caption: steadyState == null
              ? null
              : '${l10n.termEmployees}: '
                    '${formatter.count(steadyState!.employeeCount)}',
          onExplain: () =>
              onExplain(MetricId.totalOperatingExpenses, steadyState),
        ),
        MetricCard(
          label: l10n.metricMonthlyProfit,
          value: profit == null
              ? l10n.notAvailable
              : formatter.signedMoney(profit),
          tone: profit == null
              ? MetricTone.neutral
              : profit.isNegative
              ? MetricTone.negative
              : MetricTone.positive,
          caption: steadyState != null && steadyState!.isProfitMarginDefined
              ? '${l10n.termProfitMargin} '
                    '${formatter.percentage(steadyState!.profitMargin)}'
              : null,
          onExplain: () => onExplain(MetricId.operatingProfit, steadyState),
        ),
        MetricCard(
          label: l10n.metricPayback,
          value: payback.paybackMonth == null
              ? l10n.paybackNotRecovered
              : l10n.paybackDuringMonth(payback.paybackMonth!),
          tone: payback.isRecovered ? MetricTone.positive : MetricTone.warning,
          caption: payback.interpolatedMonths == null
              ? l10n.paybackNotRecoveredWithin(projection.projectionMonths)
              : l10n.paybackPrecise(
                  formatter.number(payback.interpolatedMonths!, decimals: 1),
                ),
          onExplain: payback.isRecovered
              ? () => onExplain(MetricId.payback, null)
              : null,
        ),
        MetricCard(
          label: l10n.metricYearOneProfit,
          value: yearOne == null
              ? l10n.notAvailable
              : formatter.signedMoney(yearOne.operatingProfit),
          tone: yearOne == null
              ? MetricTone.neutral
              : yearOne.operatingProfit.isNegative
              ? MetricTone.negative
              : MetricTone.positive,
          caption: yearOne != null && !yearOne.isComplete
              ? l10n.yearPartial(yearOne.yearNumber)
              : null,
          onExplain: () => onExplain(MetricId.yearOneProfit, null),
        ),
        MetricCard(
          label: l10n.metricYearOneRoi,
          value: roi.isDefined
              ? formatter.percentage(roi.yearOneRoi!)
              : l10n.notAvailable,
          tone: roi.isDefined && roi.yearOneRoi!.fraction < 0
              ? MetricTone.negative
              : MetricTone.neutral,
          caption: l10n.roiStudyDefinition,
          onExplain: roi.isDefined
              ? () => onExplain(MetricId.yearOneRoi, null)
              : null,
        ),
        MetricCard(
          label: l10n.metricOccupancy,
          value: formatter.percentage(
            projection.scenario.revenue.occupancy.stable,
          ),
          caption:
              '${formatter.count(projection.capacity.maximumRoundsPerDay)} '
              '${l10n.termMaximumRounds.toLowerCase()}${l10n.perDay}',
          onExplain: () => onExplain(MetricId.actualRoundsPerDay, steadyState),
        ),
      ],
    );
  }
}

class _Charts extends StatelessWidget {
  const _Charts({required this.projection, required this.layout});

  final FinancialProjection projection;
  final ResponsiveLayout layout;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final formatter = context.formatter;

    final revenue = SectionCard(
      title: l10n.chartRevenueTitle,
      subtitle: l10n.chartRevenueSubtitle,
      child: MonthlyBarChart(
        height: layout.chartHeight,
        points: [
          for (final month in projection.tradingMonths)
            ChartPoint(
              month: month.monthNumber,
              value: month.monthlyRevenue.amount,
            ),
        ],
        labelForValue: formatter.moneyCompactAmount,
        labelForMonth: l10n.monthShort,
        semanticsLabel: _revenueSummary(l10n, formatter),
      ),
    );

    final cashFlow = SectionCard(
      title: l10n.chartCashFlowTitle,
      subtitle: l10n.chartCashFlowSubtitle,
      child: CumulativeLineChart(
        height: layout.chartHeight,
        points: [
          for (final month in projection.monthlyResults)
            ChartPoint(
              month: month.monthNumber,
              value: month.cumulativeCashFlow.amount,
            ),
        ],
        labelForValue: formatter.moneyCompactAmount,
        labelForMonth: l10n.monthShort,
        semanticsLabel: _cashFlowSummary(l10n, formatter),
      ),
    );

    if (!layout.supportsTwoColumns) {
      return Column(
        children: [
          revenue,
          const SizedBox(height: AppSpacing.lg),
          cashFlow,
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: revenue),
        const SizedBox(width: AppSpacing.lg),
        Expanded(child: cashFlow),
      ],
    );
  }

  String _revenueSummary(AppLocalizations l10n, ValueFormatter formatter) {
    final steadyState = projection.steadyStateMonth;
    if (steadyState == null) return l10n.chartRevenueTitle;
    return '${l10n.chartRevenueTitle}. '
        '${l10n.normalMonth(steadyState.monthNumber)}: '
        '${formatter.money(steadyState.monthlyRevenue)}.';
  }

  String _cashFlowSummary(AppLocalizations l10n, ValueFormatter formatter) {
    final payback = projection.payback;
    final last = projection.monthlyResults.last;
    final ending =
        '${l10n.termCumulativeCashFlow}: '
        '${formatter.signedMoney(last.cumulativeCashFlow)}';
    if (!payback.isRecovered) {
      return '${l10n.chartCashFlowTitle}. ${l10n.paybackNotRecovered}. $ending';
    }
    return '${l10n.chartCashFlowTitle}. '
        '${l10n.paybackDuringMonth(payback.paybackMonth!)}. $ending';
  }
}

class _NormalMonthCard extends StatelessWidget {
  const _NormalMonthCard({required this.month, required this.projection});

  final MonthlyFinancialResult month;
  final FinancialProjection projection;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final formatter = context.formatter;

    return SectionCard(
      title: l10n.normalMonth(month.monthNumber),
      subtitle: l10n.calculatedSectionTitle,
      child: Column(
        children: [
          MetricRow(
            label: l10n.termActualRounds,
            value:
                '${formatter.number(month.actualRoundsPerDay)}${l10n.perDay}',
          ),
          const Divider(),
          MetricRow(
            label: l10n.termDailyRevenue,
            value: formatter.money(month.dailyRevenue),
          ),
          MetricRow(
            label: l10n.termMonthlyRevenue,
            value: formatter.money(month.monthlyRevenue),
          ),
          const Divider(),
          MetricRow(
            label: l10n.termPayroll,
            value: formatter.money(month.payroll),
            caption:
                '${formatter.count(month.employeeCount)} '
                '${l10n.unitPeople}',
          ),
          MetricRow(
            label: l10n.termOtherExpenses,
            value: formatter.money(month.otherOperatingExpenses),
          ),
          MetricRow(
            label: l10n.termTotalExpenses,
            value: formatter.money(month.totalOperatingExpenses),
            emphasised: true,
          ),
          const Divider(),
          MetricRow(
            label: l10n.termOperatingProfit,
            value: formatter.signedMoney(month.operatingProfit),
            tone: month.operatingProfit.isNegative
                ? MetricTone.negative
                : MetricTone.positive,
            emphasised: true,
          ),
          MetricRow(
            label: l10n.termProfitMargin,
            value: month.isProfitMarginDefined
                ? formatter.percentage(month.profitMargin)
                : l10n.notAvailable,
          ),
        ],
      ),
    );
  }
}

class _ValidationSummary extends StatelessWidget {
  const _ValidationSummary({required this.report});

  final ValidationReport report;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final formatter = context.formatter;
    final errors = report.errors;
    final warnings = report.warnings;

    return Column(
      children: [
        if (errors.isNotEmpty)
          NoticeBanner(
            tone: NoticeTone.error,
            message:
                '${l10n.validationSummaryErrors(errors.length)}. '
                '${l10n.validationBlocksSaving}',
          ),
        if (errors.isNotEmpty && warnings.isNotEmpty)
          const SizedBox(height: AppSpacing.sm),
        if (warnings.isNotEmpty)
          NoticeBanner(
            message: warnings
                .map(
                  (issue) => l10n.validationMessage(
                    issue,
                    (limit) => formatter.number(limit.toDouble(), decimals: 1),
                  ),
                )
                .join('\n'),
          ),
      ],
    );
  }
}
