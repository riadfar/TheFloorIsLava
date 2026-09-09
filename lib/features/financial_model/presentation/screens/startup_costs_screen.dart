import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/theme/app_theme.dart';
import '../../../../core/responsive/responsive_layout.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/entities/results/financial_projection.dart';
import '../../domain/entities/results/startup_cost_breakdown.dart';
import '../../application/state/scenario_cubit.dart';
import '../../domain/entities/scenario/equipment_lifecycle_assumptions.dart';
import '../../domain/value_objects/money.dart';
import '../../domain/services/metric_explanation_service.dart';
import '../l10n/model_labels.dart';
import '../widgets/calculation_explanation.dart';
import '../widgets/formatting_scope.dart';
import '../widgets/metric_card.dart';
import '../widgets/scenario_builder.dart';
import '../widgets/screen_scaffold.dart';
import '../widgets/section_card.dart';

/// What it costs to open the doors.
///
/// Each group can be opened to show the lines it is made of, so a total is
/// never just asserted. The bottom of the screen reconciles the groups to the
/// investment figure the rest of the app uses.
class StartupCostsScreen extends StatelessWidget {
  const StartupCostsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return ScenarioBuilder(
      builder: (context, scenario, projection, state) {
        final layout = context.layout;
        final formatter = context.formatter;
        final startup = projection.startupCosts;

        return ScreenScaffold(
          title: l10n.startupTitle,
          subtitle: l10n.startupExpandHint,
          body: ListView(
            key: const PageStorageKey('startup-scroll'),
            padding: layout.pagePadding,
            children: [
              ScreenSection(
                child: SectionCard(
                  child: Column(
                    children: [
                      for (final group in startup.groups)
                        _CostGroupTile(group: group),
                      const Divider(),
                      MetricRow(
                        label: l10n.termSubtotal,
                        value: formatter.money(startup.subtotal),
                        emphasised: true,
                      ),
                      MetricRow(
                        label: l10n.termContingency,
                        value: formatter.money(startup.contingency),
                        caption: l10n.startupContingencyAt(
                          formatter.percentage(startup.contingencyRate),
                        ),
                      ),
                      const Divider(),
                      _TotalRow(total: startup, projection: projection),
                    ],
                  ),
                ),
              ),
              ScreenSection(
                child: _EquipmentLifecycleCard(
                  lifecycle: scenario.startupCosts.equipmentLifecycle,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _EquipmentLifecycleCard extends StatelessWidget {
  const _EquipmentLifecycleCard({required this.lifecycle});

  final EquipmentLifecycleAssumptions lifecycle;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final formatter = context.formatter;
    final cubit = context.read<ScenarioCubit>();
    void update(EquipmentLifecycleAssumptions value) =>
        cubit.setEquipmentLifecycle(value);

    return SectionCard(
      title: l10n.equipmentLifecycle,
      subtitle: l10n.equipmentLifecycleHint,
      child: Column(
        children: [
          TextFormField(
            key: const ValueKey('useful-life'),
            initialValue: formatter.forEditing(lifecycle.usefulLifeMonths),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: l10n.usefulLifeMonths,
              suffixText: l10n.unitMonths,
            ),
            onChanged: (text) {
              final value = formatter.parseNumber(text);
              if (value != null && value >= 0) {
                update(lifecycle.copyWith(usefulLifeMonths: value));
              }
            },
          ),
          const SizedBox(height: AppSpacing.md),
          TextFormField(
            key: const ValueKey('replacement-cost'),
            initialValue: formatter.forEditing(
              lifecycle.replacementCost.amount,
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: l10n.replacementCost,
              prefixText: formatter.currencySymbol,
              helperText: l10n.replacementCostHint,
            ),
            onChanged: (text) {
              final value = formatter.parseNumber(text);
              if (value != null && value >= 0) {
                update(lifecycle.copyWith(replacementCost: Money.of(value)));
              }
            },
          ),
          const SizedBox(height: AppSpacing.md),
          TextFormField(
            key: const ValueKey('maintenance-reserve'),
            initialValue: formatter.forEditing(
              lifecycle.monthlyMaintenanceReserve.amount,
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: l10n.monthlyMaintenanceReserve,
              prefixText: formatter.currencySymbol,
            ),
            onChanged: (text) {
              final value = formatter.parseNumber(text);
              if (value != null && value >= 0) {
                update(
                  lifecycle.copyWith(
                    monthlyMaintenanceReserve: Money.of(value),
                  ),
                );
              }
            },
          ),
          const SizedBox(height: AppSpacing.md),
          TextFormField(
            key: const ValueKey('parts-reserve'),
            initialValue: formatter.forEditing(
              lifecycle.sparePartsReserveMonthly.amount,
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: l10n.sparePartsReserve,
              prefixText: formatter.currencySymbol,
            ),
            onChanged: (text) {
              final value = formatter.parseNumber(text);
              if (value != null && value >= 0) {
                update(
                  lifecycle.copyWith(sparePartsReserveMonthly: Money.of(value)),
                );
              }
            },
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.includePlannedReplacement),
            subtitle: Text(l10n.plannedReplacementHint),
            value: lifecycle.includeReplacementInProjection,
            onChanged: (value) => update(
              lifecycle.copyWith(includeReplacementInProjection: value),
            ),
          ),
        ],
      ),
    );
  }
}

class _CostGroupTile extends StatelessWidget {
  const _CostGroupTile({required this.group});

  final StartupCostGroup group;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final formatter = context.formatter;

    return Theme(
      data: theme.copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        key: PageStorageKey('startup-group-${group.id.name}'),
        tilePadding: EdgeInsets.zero,
        childrenPadding: const EdgeInsets.only(bottom: AppSpacing.sm),
        title: Text(
          l10n.startupGroupLabel(group.id),
          style: theme.textTheme.titleSmall,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              formatter.money(group.total),
              style: AppTheme.tabular(theme.textTheme.titleSmall!),
            ),
            const Icon(Icons.expand_more, size: 20),
          ],
        ),
        children: [
          for (final line in group.lines)
            MetricRow(
              label: l10n.startupLineLabel(line),
              value: formatter.money(line.amount),
              indented: true,
            ),
        ],
      ),
    );
  }
}

class _TotalRow extends StatelessWidget {
  const _TotalRow({required this.total, required this.projection});

  final StartupCostBreakdown total;
  final FinancialProjection projection;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final formatter = context.formatter;

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      child: Row(
        children: [
          Expanded(
            child: Text(l10n.startupTotal, style: theme.textTheme.titleMedium),
          ),
          Text(
            formatter.money(total.total),
            style: AppTheme.tabular(theme.textTheme.titleLarge!)
                .copyWith(color: theme.colorScheme.primary),
          ),
          IconButton(
            tooltip: l10n.howIsThisCalculated,
            icon: const Icon(Icons.info_outline, size: 18),
            onPressed: () => showCalculationExplanation(
              context,
              const MetricExplanationService().explain(
                metric: MetricId.initialInvestment,
                projection: projection,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
