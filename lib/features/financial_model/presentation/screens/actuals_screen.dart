import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/theme/app_theme.dart';
import '../../../../core/formatting/value_formatter.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../application/state/scenario_cubit.dart';
import '../../domain/entities/scenario/actuals_ledger.dart';
import '../../domain/services/variance_calculator.dart';
import '../../domain/value_objects/money.dart';
import '../widgets/formatting_scope.dart';
import '../widgets/notice_banner.dart';
import '../widgets/scenario_builder.dart';
import '../widgets/screen_scaffold.dart';
import '../widgets/section_card.dart';

/// Recorded results versus the forecast projection.
class ActualsScreen extends StatelessWidget {
  const ActualsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return ScenarioBuilder(
      builder: (context, scenario, projection, state) {
        final cubit = context.read<ScenarioCubit>();
        final formatter = context.formatter;
        final actuals = scenario.actuals.months;
        final varianceByMonth = {
          for (final row in projection.variances) row.monthNumber: row,
        };

        return ScreenScaffold(
          title: l10n.actualsTitle,
          subtitle: scenario.metadata.name,
          body: ListView(
            key: const PageStorageKey('actuals-scroll'),
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              ScreenSection(
                child: NoticeBanner(
                  tone: NoticeTone.info,
                  message: l10n.actualsIntro,
                ),
              ),
              ScreenSection(
                child: SectionCard(
                  title: l10n.actualsTitle,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Wrap(
                        spacing: AppSpacing.md,
                        runSpacing: AppSpacing.md,
                        children: [
                          FilledButton.icon(
                            onPressed: () => _editMonth(
                              context,
                              cubit: cubit,
                              maxMonth: scenario.projection.projectionMonths,
                            ),
                            icon: const Icon(Icons.add),
                            label: Text(l10n.actualsAddMonth),
                          ),
                          if (actuals.isNotEmpty)
                            OutlinedButton.icon(
                              onPressed: () => cubit.clearMonthlyActuals(),
                              icon: const Icon(Icons.delete_outline),
                              label: Text(l10n.actualsClearAll),
                            ),
                        ],
                      ),
                      if (actuals.isEmpty) ...[
                        const SizedBox(height: AppSpacing.lg),
                        Text(l10n.actualsEmpty),
                      ] else ...[
                        const SizedBox(height: AppSpacing.lg),
                        for (final entry in actuals) ...[
                          _ActualMonthCard(
                            actuals: entry,
                            variance: varianceByMonth[entry.monthNumber],
                            formatter: formatter,
                            onEdit: () => _editMonth(
                              context,
                              cubit: cubit,
                              maxMonth: scenario.projection.projectionMonths,
                              existing: entry,
                            ),
                            onRemove: () =>
                                cubit.clearMonthlyActuals(entry.monthNumber),
                          ),
                          const SizedBox(height: AppSpacing.md),
                        ],
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _editMonth(
    BuildContext context, {
    required ScenarioCubit cubit,
    required int maxMonth,
    MonthlyActuals? existing,
  }) async {
    final l10n = AppLocalizations.of(context);
    final monthController = TextEditingController(
      text: '${existing?.monthNumber ?? 1}',
    );
    final revenueController = TextEditingController(
      text: existing?.revenue == null ? '' : '${existing!.revenue!.amount}',
    );
    final expensesController = TextEditingController(
      text: existing?.operatingExpenses == null
          ? ''
          : '${existing!.operatingExpenses!.amount}',
    );

    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            existing == null
                ? l10n.actualsAddMonth
                : l10n.actualsEditMonth(existing.monthNumber),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: monthController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: l10n.columnMonth),
                ),
                const SizedBox(height: AppSpacing.md),
                TextField(
                  controller: revenueController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(labelText: l10n.actualsRevenue),
                ),
                const SizedBox(height: AppSpacing.md),
                TextField(
                  controller: expensesController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(labelText: l10n.actualsExpenses),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(l10n.save),
            ),
          ],
        );
      },
    );

    if (saved != true) return;

    final month = int.tryParse(monthController.text.trim()) ?? 0;
    if (month < 1 || month > maxMonth) return;

    final revenueText = revenueController.text.trim();
    final expensesText = expensesController.text.trim();
    cubit.upsertMonthlyActuals(
      MonthlyActuals(
        monthNumber: month,
        revenue: revenueText.isEmpty ? null : Money.of(num.parse(revenueText)),
        operatingExpenses: expensesText.isEmpty
            ? null
            : Money.of(num.parse(expensesText)),
      ),
    );
  }
}

class _ActualMonthCard extends StatelessWidget {
  const _ActualMonthCard({
    required this.actuals,
    required this.variance,
    required this.formatter,
    required this.onEdit,
    required this.onRemove,
  });

  final MonthlyActuals actuals;
  final MonthlyVariance? variance;
  final ValueFormatter formatter;
  final VoidCallback onEdit;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.monthLabel(actuals.monthNumber),
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                IconButton(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined),
                  tooltip: l10n.save,
                ),
                IconButton(
                  onPressed: onRemove,
                  icon: const Icon(Icons.delete_outline),
                  tooltip: l10n.actualsClearMonth,
                ),
              ],
            ),
            if (variance != null) ...[
              _VarianceRow(
                label: l10n.termMonthlyRevenue,
                forecast: variance!.forecastRevenue,
                actual: variance!.actualRevenue,
                delta: variance!.revenueVariance,
                formatter: formatter,
              ),
              _VarianceRow(
                label: l10n.termTotalExpenses,
                forecast: variance!.forecastExpenses,
                actual: variance!.actualExpenses,
                delta: variance!.expenseVariance,
                formatter: formatter,
              ),
              _VarianceRow(
                label: l10n.termOperatingProfit,
                forecast: variance!.forecastProfit,
                actual: variance!.actualProfit,
                delta: variance!.profitVariance,
                formatter: formatter,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _VarianceRow extends StatelessWidget {
  const _VarianceRow({
    required this.label,
    required this.forecast,
    required this.actual,
    required this.delta,
    required this.formatter,
  });

  final String label;
  final Money forecast;
  final Money? actual;
  final Money? delta;
  final ValueFormatter formatter;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelLarge),
          Text('${l10n.actualsForecast}: ${formatter.money(forecast)}'),
          Text(
            '${l10n.actualsActual}: '
            '${actual == null ? l10n.notAvailable : formatter.money(actual!)}',
          ),
          Text(
            '${l10n.actualsVariance}: '
            '${delta == null ? l10n.notAvailable : formatter.signedMoney(delta!)}',
          ),
        ],
      ),
    );
  }
}
