import 'package:flutter/material.dart';

import '../../../../app/theme/app_theme.dart';
import '../../../../core/responsive/responsive_grid.dart';
import '../../../../core/responsive/responsive_layout.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/entities/results/sensitivity_result.dart';
import '../l10n/model_labels.dart';
import '../widgets/formatting_scope.dart';
import '../widgets/metric_card.dart';
import '../widgets/notice_banner.dart';
import '../widgets/scenario_builder.dart';
import '../widgets/screen_scaffold.dart';
import '../widgets/section_card.dart';

/// The same business at different demand levels.
///
/// Each case is a normal month repriced at another occupancy. A case that does
/// not turn a profit reports that the investment is simply not recoverable,
/// rather than a negative or infinite number of months.
class SensitivityScreen extends StatelessWidget {
  const SensitivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return ScenarioBuilder(
      builder: (context, scenario, projection, state) {
        final layout = context.layout;
        final formatter = context.formatter;
        final results = projection.sensitivityResults;
        final costBase = results.isEmpty
            ? null
            : results.first.monthlyOperatingExpenses;

        return ScreenScaffold(
          title: l10n.sensitivityTitle,
          subtitle: l10n.helpSensitivity,
          body: ListView(
            key: const PageStorageKey('sensitivity-scroll'),
            padding: layout.pagePadding,
            children: [
              if (costBase != null)
                ScreenSection(
                  child: NoticeBanner(
                    tone: NoticeTone.info,
                    message: l10n.sensitivityCostBaseNote(
                      formatter.money(costBase),
                    ),
                  ),
                ),
              ResponsiveGrid(
                minTileWidth: 280,
                runSpacing: AppSpacing.lg,
                children: [
                  for (final result in results)
                    _SensitivityCard(result: result),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SensitivityCard extends StatelessWidget {
  const _SensitivityCard({required this.result});

  final SensitivityResult result;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final formatter = context.formatter;
    final isProfitable = result.monthlyProfit.isPositive;

    return SectionCard(
      title: l10n.sensitivityScenarioLabel(result.definition),
      subtitle: result.definition.usesBaseOccupancy
          ? l10n.scenarioBaseTracksStable
          : null,
      child: Column(
        children: [
          MetricRow(
            label: l10n.termOccupancy,
            value: formatter.percentage(result.occupancy),
            emphasised: true,
          ),
          MetricRow(
            label: l10n.termActualRounds,
            value:
                '${formatter.number(result.actualRoundsPerDay)}${l10n.perDay}',
          ),
          const Divider(),
          MetricRow(
            label: l10n.termMonthlyRevenue,
            value: formatter.money(result.monthlyRevenue),
          ),
          MetricRow(
            label: l10n.termTotalExpenses,
            value: formatter.money(result.monthlyOperatingExpenses),
          ),
          MetricRow(
            label: l10n.termOperatingProfit,
            value: formatter.signedMoney(result.monthlyProfit),
            tone: result.monthlyProfit.isNegative
                ? MetricTone.negative
                : MetricTone.positive,
            emphasised: true,
          ),
          const Divider(),
          MetricRow(
            label: l10n.sensitivityApproxPayback,
            value: result.isRecoverable
                ? l10n.sensitivityMonths(
                    formatter.number(result.approximatePaybackMonths!),
                  )
                : l10n.sensitivityNotRecoverable,
            tone: isProfitable ? MetricTone.positive : MetricTone.warning,
            emphasised: true,
          ),
        ],
      ),
    );
  }
}
