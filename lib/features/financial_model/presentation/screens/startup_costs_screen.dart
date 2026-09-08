import 'package:flutter/material.dart';

import '../../../../app/theme/app_theme.dart';
import '../../../../core/responsive/responsive_layout.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/entities/results/financial_projection.dart';
import '../../domain/entities/results/startup_cost_breakdown.dart';
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
            ],
          ),
        );
      },
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
