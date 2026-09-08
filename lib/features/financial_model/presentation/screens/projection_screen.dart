import 'package:flutter/material.dart';

import '../../../../app/theme/app_theme.dart';
import '../../../../core/formatting/value_formatter.dart';
import '../../../../core/responsive/responsive_layout.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/entities/results/financial_projection.dart';
import '../../domain/entities/results/monthly_financial_result.dart';
import '../../domain/services/metric_explanation_service.dart';
import '../widgets/calculation_explanation.dart';
import '../widgets/formatting_scope.dart';
import '../widgets/metric_card.dart';
import '../widgets/scenario_builder.dart';
import '../widgets/screen_scaffold.dart';
import '../widgets/section_card.dart';

/// The month-by-month projection.
///
/// The same numbers are presented two ways: a real data grid where there is
/// width for one, and expandable month cards where there is not. A phone gets a
/// list it can actually read rather than a table squeezed sideways.
class ProjectionScreen extends StatelessWidget {
  const ProjectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return ScenarioBuilder(
      builder: (context, scenario, projection, state) {
        final layout = context.layout;

        return ScreenScaffold(
          title: l10n.projectionTitle,
          subtitle: l10n.projectionShowsMonths(projection.projectionMonths),
          body: layout.useDataTable
              ? _ProjectionTable(projection: projection)
              : _ProjectionCards(projection: projection),
        );
      },
    );
  }
}

class _ProjectionCards extends StatelessWidget {
  const _ProjectionCards({required this.projection});

  final FinancialProjection projection;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final layout = context.layout;

    return ListView.separated(
      key: const PageStorageKey('projection-cards'),
      padding: layout.pagePadding,
      itemCount: projection.monthlyResults.length + 1,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Text(
              l10n.projectionExpandHint,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          );
        }
        return _MonthCard(
          month: projection.monthlyResults[index - 1],
          projection: projection,
        );
      },
    );
  }
}

class _MonthCard extends StatelessWidget {
  const _MonthCard({required this.month, required this.projection});

  final MonthlyFinancialResult month;
  final FinancialProjection projection;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.financialColors;
    final l10n = AppLocalizations.of(context);
    final formatter = context.formatter;

    final headlineValue = month.isInvestmentMonth
        ? formatter.signedMoney(month.netCashFlow)
        : formatter.signedMoney(month.operatingProfit);
    final isNegative = month.isInvestmentMonth
        ? month.netCashFlow.isNegative
        : month.operatingProfit.isNegative;

    return Card(
      child: Theme(
        // The default divider on an expansion tile fights the card's own
        // border, so it is removed rather than doubled up.
        data: theme.copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          key: PageStorageKey('projection-month-${month.monthNumber}'),
          tilePadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          childrenPadding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            0,
            AppSpacing.lg,
            AppSpacing.sm,
          ),
          title: Text(
            month.isInvestmentMonth
                ? l10n.monthZeroLabel
                : l10n.monthLabel(month.monthNumber),
            style: theme.textTheme.titleSmall,
          ),
          subtitle: Text(
            month.isInvestmentMonth
                ? l10n.projectionInvestmentRow
                : '${l10n.termOccupancy} '
                      '${formatter.percentage(month.occupancy)} · '
                      '${formatter.moneyWhole(month.monthlyRevenue)}',
            style: theme.textTheme.bodySmall,
          ),
          trailing: Text(
            headlineValue,
            style: AppTheme.tabular(
              theme.textTheme.titleSmall!,
            ).copyWith(color: isNegative ? colors.negative : colors.positive),
          ),
          children: [
            if (!month.isInvestmentMonth) ...[
              MetricRow(
                label: l10n.termMaximumRounds,
                value: formatter.count(month.maximumRoundsPerDay),
              ),
              MetricRow(
                label: l10n.termActualRounds,
                value: formatter.number(month.actualRoundsPerDay),
              ),
              MetricRow(
                label: l10n.termDailyRevenue,
                value: formatter.money(month.dailyRevenue),
              ),
              MetricRow(
                label: l10n.termMonthlyRevenue,
                value: formatter.money(month.monthlyRevenue),
                emphasised: true,
              ),
              const Divider(),
              MetricRow(
                label: l10n.termEmployees,
                value: formatter.count(month.employeeCount),
              ),
              MetricRow(
                label: l10n.termPayroll,
                value: formatter.money(month.payroll),
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
              ),
              MetricRow(
                label: l10n.termProfitMargin,
                value: month.isProfitMarginDefined
                    ? formatter.percentage(month.profitMargin)
                    : l10n.notAvailable,
              ),
            ] else
              MetricRow(
                label: l10n.termInitialInvestment,
                value: formatter.money(month.investmentOutflow),
                emphasised: true,
              ),
            const Divider(),
            MetricRow(
              label: l10n.termNetCashFlow,
              value: formatter.signedMoney(month.netCashFlow),
              tone: month.netCashFlow.isNegative
                  ? MetricTone.negative
                  : MetricTone.positive,
            ),
            MetricRow(
              label: l10n.termCumulativeCashFlow,
              value: formatter.signedMoney(month.cumulativeCashFlow),
              tone: month.cumulativeCashFlow.isNegative
                  ? MetricTone.negative
                  : MetricTone.positive,
              emphasised: true,
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () => showCalculationExplanation(
                  context,
                  const MetricExplanationService().explain(
                    metric: MetricId.cumulativeCashFlow,
                    projection: projection,
                    month: month,
                  ),
                ),
                icon: const Icon(Icons.info_outline, size: 16),
                label: Text(l10n.howIsThisCalculated),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProjectionTable extends StatefulWidget {
  const _ProjectionTable({required this.projection});

  final FinancialProjection projection;

  @override
  State<_ProjectionTable> createState() => _ProjectionTableState();
}

class _ProjectionTableState extends State<_ProjectionTable> {
  final ScrollController _horizontal = ScrollController();

  @override
  void dispose() {
    _horizontal.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.financialColors;
    final l10n = AppLocalizations.of(context);
    final formatter = context.formatter;
    final layout = context.layout;

    return ListView(
      key: const PageStorageKey('projection-table'),
      padding: layout.pagePadding,
      children: [
        SectionCard(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Scrollbar(
            controller: _horizontal,
            thumbVisibility: true,
            child: SingleChildScrollView(
              controller: _horizontal,
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowHeight: 44,
                dataRowMinHeight: 40,
                dataRowMaxHeight: 46,
                columnSpacing: AppSpacing.xl,
                headingTextStyle: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
                columns: [
                  DataColumn(label: Text(l10n.columnMonth)),
                  DataColumn(label: Text(l10n.termOccupancy), numeric: true),
                  DataColumn(
                    label: Text(l10n.termMaximumRounds),
                    numeric: true,
                  ),
                  DataColumn(label: Text(l10n.termActualRounds), numeric: true),
                  DataColumn(label: Text(l10n.termDailyRevenue), numeric: true),
                  DataColumn(
                    label: Text(l10n.termMonthlyRevenue),
                    numeric: true,
                  ),
                  DataColumn(label: Text(l10n.termEmployees), numeric: true),
                  DataColumn(label: Text(l10n.termPayroll), numeric: true),
                  DataColumn(
                    label: Text(l10n.termOtherExpenses),
                    numeric: true,
                  ),
                  DataColumn(
                    label: Text(l10n.termTotalExpenses),
                    numeric: true,
                  ),
                  DataColumn(
                    label: Text(l10n.termOperatingProfit),
                    numeric: true,
                  ),
                  DataColumn(label: Text(l10n.termProfitMargin), numeric: true),
                  DataColumn(label: Text(l10n.termNetCashFlow), numeric: true),
                  DataColumn(
                    label: Text(l10n.termCumulativeCashFlow),
                    numeric: true,
                  ),
                ],
                rows: [
                  for (final month in widget.projection.monthlyResults)
                    _row(month, theme, colors, l10n, formatter),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  DataRow _row(
    MonthlyFinancialResult month,
    ThemeData theme,
    FinancialColors colors,
    AppLocalizations l10n,
    ValueFormatter formatter,
  ) {
    final numeric = AppTheme.tabular(theme.textTheme.bodySmall!)
        .copyWith(color: theme.colorScheme.onSurface);
    Widget cell(String text, {Color? color}) => Text(
      text,
      style: color == null ? numeric : numeric.copyWith(color: color),
    );

    final profitColour = colors.forAmount(
      isNegative: month.operatingProfit.isNegative,
    );
    final cumulativeColour = colors.forAmount(
      isNegative: month.cumulativeCashFlow.isNegative,
    );

    return DataRow(
      color: month.isInvestmentMonth
          ? WidgetStatePropertyAll(
              theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            )
          : null,
      cells: [
        DataCell(
          Text(
            l10n.monthShort(month.monthNumber),
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        DataCell(cell(formatter.percentage(month.occupancy))),
        DataCell(cell(formatter.count(month.maximumRoundsPerDay))),
        DataCell(cell(formatter.number(month.actualRoundsPerDay))),
        DataCell(cell(formatter.money(month.dailyRevenue))),
        DataCell(cell(formatter.money(month.monthlyRevenue))),
        DataCell(cell(formatter.count(month.employeeCount))),
        DataCell(cell(formatter.money(month.payroll))),
        DataCell(cell(formatter.money(month.otherOperatingExpenses))),
        DataCell(cell(formatter.money(month.totalOperatingExpenses))),
        DataCell(
          cell(
            formatter.signedMoney(month.operatingProfit),
            color: month.isInvestmentMonth ? null : profitColour,
          ),
        ),
        DataCell(
          cell(
            month.isProfitMarginDefined
                ? formatter.percentage(month.profitMargin)
                : l10n.notAvailable,
          ),
        ),
        DataCell(cell(formatter.signedMoney(month.netCashFlow))),
        DataCell(
          cell(
            formatter.signedMoney(month.cumulativeCashFlow),
            color: cumulativeColour,
          ),
        ),
      ],
    );
  }
}
