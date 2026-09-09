import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_theme.dart';
import '../../../../core/responsive/responsive_layout.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../application/state/scenario_cubit.dart';
import '../../application/state/scenario_state.dart';
import '../../domain/entities/results/financial_projection.dart';
import '../../domain/entities/scenario/scenario_summary.dart';
import '../widgets/formatting_scope.dart';
import '../widgets/screen_scaffold.dart';
import '../widgets/section_card.dart';

class ScenariosScreen extends StatefulWidget {
  const ScenariosScreen({super.key});

  @override
  State<ScenariosScreen> createState() => _ScenariosScreenState();
}

class _ScenariosScreenState extends State<ScenariosScreen> {
  final Set<String> _selectedForComparison = {};
  bool _comparing = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocBuilder<ScenarioCubit, ScenarioState>(
      builder: (context, state) {
        return ScreenScaffold(
          title: l10n.scenariosTitle,
          subtitle: l10n.scenariosSubtitle,
          body: ListView(
            key: const PageStorageKey('scenarios-scroll'),
            padding: context.layout.pagePadding,
            children: [
              ScreenSection(
                child: Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    FilledButton.icon(
                      onPressed: () => context
                          .read<ScenarioCubit>()
                          .createBaselineScenario(),
                      icon: const Icon(Icons.add),
                      label: Text(l10n.scenariosCreateBase),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => context
                          .read<ScenarioCubit>()
                          .createWorstCaseScenario(),
                      icon: const Icon(Icons.warning_amber),
                      label: Text(l10n.scenariosCreateWorst),
                    ),
                  ],
                ),
              ),
              ScreenSection(
                child: SectionCard(
                  title: l10n.scenariosSaved,
                  child: Column(
                    children: [
                      for (final summary in state.availableScenarios)
                        _ScenarioTile(
                          summary: summary,
                          selectedForComparison: _selectedForComparison
                              .contains(summary.id),
                          onComparisonChanged: (selected) {
                            setState(() {
                              if (selected &&
                                  _selectedForComparison.length < 4) {
                                _selectedForComparison.add(summary.id);
                              } else if (!selected) {
                                _selectedForComparison.remove(summary.id);
                              }
                            });
                          },
                          onOpen: summary.isActive
                              ? null
                              : () => context
                                    .read<ScenarioCubit>()
                                    .selectScenario(summary.id),
                          onDuplicate: () async {
                            final cubit = context.read<ScenarioCubit>();
                            if (!summary.isActive) {
                              await cubit.selectScenario(summary.id);
                            }
                            await cubit.duplicateActiveScenario();
                          },
                          onDelete: () => _confirmDelete(summary),
                        ),
                    ],
                  ),
                ),
              ),
              ScreenSection(
                child: SectionCard(
                  title: l10n.scenariosCompare,
                  subtitle: l10n.scenariosCompareHint,
                  child: Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: FilledButton.icon(
                      onPressed: _selectedForComparison.length < 2 || _comparing
                          ? null
                          : _showComparison,
                      icon: _comparing
                          ? const SizedBox.square(
                              dimension: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.compare_arrows),
                      label: Text(l10n.scenariosCompareSelected),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _confirmDelete(ScenarioSummary summary) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.scenariosDeleteTitle),
        content: Text(
          summary.isBuiltinRecoverable
              ? l10n.scenariosResetBuiltinBody
              : l10n.scenariosDeleteBody(summary.name),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              summary.isBuiltinRecoverable ? l10n.reset : l10n.scenariosDelete,
            ),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await context.read<ScenarioCubit>().deleteScenario(summary.id);
    }
  }

  Future<void> _showComparison() async {
    setState(() => _comparing = true);
    final projections = await context.read<ScenarioCubit>().compareScenarios(
      _selectedForComparison,
    );
    if (!mounted) return;
    setState(() => _comparing = false);
    await showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000, maxHeight: 700),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  AppLocalizations.of(context).scenariosComparisonTitle,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: AppSpacing.md),
                Expanded(
                  child: SingleChildScrollView(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: _ComparisonTable(projections: projections),
                    ),
                  ),
                ),
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(AppLocalizations.of(context).close),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ScenarioTile extends StatelessWidget {
  const _ScenarioTile({
    required this.summary,
    required this.selectedForComparison,
    required this.onComparisonChanged,
    required this.onOpen,
    required this.onDuplicate,
    required this.onDelete,
  });

  final ScenarioSummary summary;
  final bool selectedForComparison;
  final ValueChanged<bool> onComparisonChanged;
  final VoidCallback? onOpen;
  final VoidCallback onDuplicate;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final date = DateFormat.yMMMd(Localizations.localeOf(context).toString())
        .add_jm()
        .format(summary.updatedAt);
    return ListTile(
      onTap: onOpen,
      contentPadding: EdgeInsets.zero,
      leading: Checkbox(
        value: selectedForComparison,
        onChanged: (value) => onComparisonChanged(value ?? false),
      ),
      title: Row(
        children: [
          Flexible(child: Text(summary.name)),
          if (summary.isActive) ...[
            const SizedBox(width: AppSpacing.sm),
            Chip(
              visualDensity: VisualDensity.compact,
              label: Text(l10n.active),
            ),
          ],
        ],
      ),
      subtitle: Text(l10n.scenariosUpdated(date)),
      trailing: PopupMenuButton<String>(
        onSelected: (action) {
          if (action == 'duplicate') onDuplicate();
          if (action == 'delete') onDelete();
        },
        itemBuilder: (context) => [
          PopupMenuItem(
            value: 'duplicate',
            child: Text(l10n.scenariosDuplicate),
          ),
          PopupMenuItem(
            value: 'delete',
            child: Text(
              summary.isBuiltinRecoverable ? l10n.reset : l10n.scenariosDelete,
            ),
          ),
        ],
      ),
    );
  }
}

class _ComparisonTable extends StatelessWidget {
  const _ComparisonTable({required this.projections});

  final Map<String, FinancialProjection> projections;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final formatter = context.formatter;
    final items = projections.values.toList();
    String metricValue(FinancialProjection projection, int row) {
      final steady = projection.steadyStateMonth;
      return switch (row) {
        0 =>
          steady == null
              ? l10n.notAvailable
              : formatter.money(steady.monthlyRevenue),
        1 =>
          steady == null
              ? l10n.notAvailable
              : formatter.signedMoney(steady.operatingProfit),
        2 =>
          projection.payback.interpolatedMonths == null
              ? l10n.notAvailable
              : l10n.sensitivityMonths(
                  formatter.number(projection.payback.interpolatedMonths!),
                ),
        3 =>
          projection.roi.yearOneRoi == null
              ? l10n.notAvailable
              : formatter.percentage(projection.roi.yearOneRoi!),
        4 =>
          projection.investmentReturns.npv.value == null
              ? l10n.notAvailable
              : formatter.money(projection.investmentReturns.npv.value!),
        5 =>
          projection.investmentReturns.irr.value == null
              ? l10n.notAvailable
              : formatter.percentage(projection.investmentReturns.irr.value!),
        6 =>
          projection.breakEven.breakEvenOccupancy.value == null
              ? l10n.notAvailable
              : formatter.percentage(
                  projection.breakEven.breakEvenOccupancy.value!,
                ),
        _ => formatter.money(projection.requiredFunding),
      };
    }

    final labels = [
      l10n.metricMonthlyRevenue,
      l10n.metricMonthlyProfit,
      l10n.metricPayback,
      l10n.metricYearOneRoi,
      l10n.metricNpv,
      l10n.metricIrr,
      l10n.metricBreakEvenOccupancy,
      l10n.metricRequiredFunding,
    ];
    return DataTable(
      columns: [
        DataColumn(label: Text(l10n.scenariosMetric)),
        for (final projection in items)
          DataColumn(label: Text(projection.scenario.metadata.name)),
      ],
      rows: [
        for (var row = 0; row < labels.length; row++)
          DataRow(
            cells: [
              DataCell(Text(labels[row])),
              for (final projection in items)
                DataCell(Text(metricValue(projection, row))),
            ],
          ),
      ],
    );
  }
}
