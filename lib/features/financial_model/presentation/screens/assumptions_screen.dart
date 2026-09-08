import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/theme/app_theme.dart';
import '../../../../core/formatting/value_formatter.dart';
import '../../../../core/responsive/responsive_grid.dart';
import '../../../../core/responsive/responsive_layout.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../application/state/scenario_cubit.dart';
import '../../domain/entities/results/financial_projection.dart';
import '../../domain/entities/scenario/assumption_status.dart';
import '../../domain/entities/scenario/financial_scenario.dart';
import '../../domain/entities/scenario/scenario_fields.dart';
import '../../domain/entities/scenario/startup_cost_model.dart';
import '../../domain/services/staffing_calculator.dart';
import '../../domain/validation/validation_issue.dart';
import '../l10n/model_labels.dart';
import '../widgets/assumption_field.dart';
import '../widgets/formatting_scope.dart';
import '../widgets/metric_card.dart';
import '../widgets/notice_banner.dart';
import '../widgets/scenario_builder.dart';
import '../widgets/screen_scaffold.dart';
import '../widgets/section_card.dart';

/// Everything the model can be told.
///
/// The screen is built from the domain's own field registry rather than from a
/// hand-written form, so an input cannot exist in the model without appearing
/// here, and cannot be edited here under different rules than the domain
/// applies. Each section closes with the values it feeds, which makes the
/// dependency chain visible where the user is actually working.
class AssumptionsScreen extends StatelessWidget {
  const AssumptionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return ScenarioBuilder(
      builder: (context, scenario, projection, state) {
        final layout = context.layout;
        final cubit = context.read<ScenarioCubit>();

        return ScreenScaffold(
          title: l10n.assumptionsTitle,
          subtitle: scenario.metadata.name,
          body: ListView(
            key: const PageStorageKey('assumptions-scroll'),
            padding: layout.pagePadding,
            children: [
              ScreenSection(
                child: NoticeBanner(
                  tone: NoticeTone.info,
                  message: l10n.assumptionsIntro,
                ),
              ),
              for (final section in _sections)
                ScreenSection(
                  child: _AssumptionSection(
                    section: section,
                    scenario: scenario,
                    projection: projection,
                    validation: state.validation,
                    cubit: cubit,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

/// A group of related inputs, with the figures they produce.
class _SectionSpec {
  const _SectionSpec({
    required this.id,
    required this.keys,
    this.includesEquipmentPicker = false,
  });

  final _SectionId id;
  final List<AssumptionKey> keys;

  /// The equipment section additionally offers a choice of package.
  final bool includesEquipmentPicker;
}

enum _SectionId {
  sessionPricing,
  occupancy,
  staffing,
  operatingExpenses,
  property,
  equipment,
  fitOut,
  preOpening,
  projection,
  sensitivity,
}

const List<_SectionSpec> _sections = [
  _SectionSpec(
    id: _SectionId.sessionPricing,
    keys: [
      AssumptionKey.roundDuration,
      AssumptionKey.turnaroundTime,
      AssumptionKey.ticketPrice,
      AssumptionKey.averagePlayersPerRound,
      AssumptionKey.maximumPlayersPerRound,
      AssumptionKey.operatingHoursPerDay,
      AssumptionKey.operatingDaysPerWeek,
      AssumptionKey.operatingDaysPerMonth,
    ],
  ),
  _SectionSpec(
    id: _SectionId.occupancy,
    keys: [
      AssumptionKey.occupancyMonth1,
      AssumptionKey.occupancyMonth2,
      AssumptionKey.occupancyMonth3,
      AssumptionKey.stableOccupancy,
    ],
  ),
  _SectionSpec(
    id: _SectionId.staffing,
    keys: [
      AssumptionKey.initialEmployeeCount,
      AssumptionKey.expandedEmployeeCount,
      AssumptionKey.expansionMonth,
      AssumptionKey.monthlySalaryPerEmployee,
      AssumptionKey.monthlyIncentivePerEmployee,
    ],
  ),
  _SectionSpec(
    id: _SectionId.operatingExpenses,
    keys: [
      AssumptionKey.rent,
      AssumptionKey.mallSharedServices,
      AssumptionKey.electricity,
      AssumptionKey.maintenance,
      AssumptionKey.continuousMarketing,
    ],
  ),
  _SectionSpec(
    id: _SectionId.property,
    keys: [AssumptionKey.mallDeposit, AssumptionKey.contractDurationMonths],
  ),
  _SectionSpec(
    id: _SectionId.equipment,
    keys: [AssumptionKey.shippingRate, AssumptionKey.customsRate],
    includesEquipmentPicker: true,
  ),
  _SectionSpec(
    id: _SectionId.fitOut,
    keys: [
      AssumptionKey.fitOutFurniture,
      AssumptionKey.fitOutPainting,
      AssumptionKey.fitOutSignage,
      AssumptionKey.fitOutHvac,
      AssumptionKey.fitOutInstallationLabour,
    ],
  ),
  _SectionSpec(
    id: _SectionId.preOpening,
    keys: [
      AssumptionKey.licensing,
      AssumptionKey.openingMarketing,
      AssumptionKey.contingencyRate,
      AssumptionKey.maximumSetupDays,
    ],
  ),
  _SectionSpec(
    id: _SectionId.projection,
    keys: [AssumptionKey.projectionMonths],
  ),
  _SectionSpec(
    id: _SectionId.sensitivity,
    keys: [
      AssumptionKey.conservativeOccupancy,
      AssumptionKey.optimisticOccupancy,
    ],
  ),
];

class _AssumptionSection extends StatelessWidget {
  const _AssumptionSection({
    required this.section,
    required this.scenario,
    required this.projection,
    required this.validation,
    required this.cubit,
  });

  final _SectionSpec section;
  final FinancialScenario scenario;
  final FinancialProjection projection;
  final ValidationReport validation;
  final ScenarioCubit cubit;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final formatter = context.formatter;
    final layout = context.layout;

    final fields = <Widget>[
      for (final key in section.keys)
        if (ScenarioFields.read(scenario, key) case final value?)
          _buildField(context, key, value, l10n, formatter),
    ];

    final derived = _derivedRows(context, l10n, formatter);

    return SectionCard(
      title: _title(l10n),
      subtitle: _subtitle(l10n),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (section.includesEquipmentPicker) ...[
            _EquipmentPicker(
              equipment: scenario.startupCosts.equipment,
              onSelect: cubit.selectEquipmentPackage,
              onCostChanged: cubit.updateEquipmentPackageCost,
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
          ResponsiveGrid(
            minTileWidth: 260,
            maxColumns: layout.supportsTwoColumns ? 3 : 2,
            runSpacing: AppSpacing.lg,
            children: fields,
          ),
          if (section.id == _SectionId.staffing) ...[
            const SizedBox(height: AppSpacing.lg),
            NoticeBanner(
              tone: NoticeTone.info,
              message:
                  '${l10n.staffingReferenceTitle}. '
                  '${l10n.staffingReferenceBody}',
            ),
          ],
          if (derived.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.lg),
            const Divider(),
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.sm),
              child: Text(
                l10n.calculatedSectionTitle,
                style: Theme.of(context).textTheme.labelSmall
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            ...derived,
          ],
        ],
      ),
    );
  }

  Widget _buildField(
    BuildContext context,
    AssumptionKey key,
    num value,
    AppLocalizations l10n,
    ValueFormatter formatter,
  ) {
    String describeLimit(num limit) =>
        formatter.number(limit.toDouble(), decimals: 1);

    final error = validation.firstErrorFor(key);
    final warning = validation
        .forKey(key)
        .where((issue) => !issue.isError)
        .firstOrNull;

    return AssumptionField(
      key: ValueKey(key),
      field: ScenarioFields.descriptors[key]!,
      value: value,
      status: scenario.annotations.statusOf(key),
      onStatusChanged: (status) => cubit.setAssumptionStatus(key, status),
      onChanged: (updated) => cubit.updateField(key, updated),
      currencyPrefix: formatter.currencySymbol,
      errorText: error == null
          ? null
          : l10n.validationMessage(error, describeLimit),
      helpText: warning != null
          ? l10n.validationMessage(warning, describeLimit)
          : l10n.assumptionHelp(key),
    );
  }

  String _title(AppLocalizations l10n) => switch (section.id) {
    _SectionId.sessionPricing => l10n.sectionSessionPricing,
    _SectionId.occupancy => l10n.sectionOccupancy,
    _SectionId.staffing => l10n.sectionStaffing,
    _SectionId.operatingExpenses => l10n.sectionOperatingExpenses,
    _SectionId.property => l10n.sectionProperty,
    _SectionId.equipment => l10n.sectionEquipment,
    _SectionId.fitOut => l10n.sectionFitOut,
    _SectionId.preOpening => l10n.sectionPreOpening,
    _SectionId.projection => l10n.sectionProjection,
    _SectionId.sensitivity => l10n.sectionSensitivityInputs,
  };

  String? _subtitle(AppLocalizations l10n) => switch (section.id) {
    _SectionId.occupancy => l10n.helpOccupancy,
    _SectionId.sensitivity => l10n.helpSensitivity,
    _ => null,
  };

  /// The figures this section feeds, read straight out of the projection.
  List<Widget> _derivedRows(
    BuildContext context,
    AppLocalizations l10n,
    ValueFormatter formatter,
  ) {
    final capacity = projection.capacity;
    final startup = projection.startupCosts;
    final steadyState = projection.steadyStateMonth;

    return switch (section.id) {
      _SectionId.sessionPricing => [
        MetricRow(
          label: l10n.termTotalRoundTime,
          value:
              '${formatter.minutes(capacity.totalRoundTime)} '
              '${l10n.unitMinutes}',
        ),
        MetricRow(
          label: l10n.termMaximumRounds,
          value:
              '${formatter.count(capacity.maximumRoundsPerDay)}'
              '${l10n.perDay}',
          emphasised: true,
        ),
      ],
      _SectionId.occupancy => [
        if (steadyState != null) ...[
          MetricRow(
            label: l10n.termActualRounds,
            value:
                '${formatter.number(steadyState.actualRoundsPerDay)}'
                '${l10n.perDay}',
          ),
          MetricRow(
            label: l10n.termMonthlyRevenue,
            value: formatter.money(steadyState.monthlyRevenue),
            emphasised: true,
          ),
        ],
      ],
      _SectionId.staffing => [
        MetricRow(
          label: l10n.termCostPerEmployee,
          // Through the domain service, so salary + incentive is defined in
          // exactly one place.
          value: formatter.money(
            const StaffingCalculator().costPerEmployee(scenario.staffing),
          ),
        ),
        if (steadyState != null)
          MetricRow(
            label: l10n.termPayroll,
            value: formatter.money(steadyState.payroll),
            caption: l10n.normalMonth(steadyState.monthNumber),
            emphasised: true,
          ),
      ],
      _SectionId.operatingExpenses => [
        if (steadyState != null) ...[
          MetricRow(
            label: l10n.termOtherExpenses,
            value: formatter.money(steadyState.otherOperatingExpenses),
          ),
          MetricRow(
            label: l10n.termTotalExpenses,
            value: formatter.money(steadyState.totalOperatingExpenses),
            caption: l10n.normalMonth(steadyState.monthNumber),
            emphasised: true,
          ),
        ],
      ],
      _SectionId.property => [
        MetricRow(
          label: l10n.termFirstMonthRent,
          value: formatter.money(scenario.operatingExpenses.rent),
          caption: l10n.helpRent,
        ),
        MetricRow(
          label: l10n.termProperty,
          value: formatter.money(startup.property.total),
          emphasised: true,
        ),
      ],
      _SectionId.equipment => [
        MetricRow(
          label: l10n.calculatedShipping,
          value: formatter.money(startup.shipping),
        ),
        MetricRow(
          label: l10n.calculatedCustoms,
          value: formatter.money(startup.customs),
        ),
        MetricRow(
          label: l10n.termDeliveredEquipment,
          value: formatter.money(startup.deliveredEquipment.total),
          emphasised: true,
        ),
      ],
      _SectionId.fitOut => [
        MetricRow(
          label: l10n.termFitOut,
          value: formatter.money(startup.fitOut.total),
          emphasised: true,
        ),
      ],
      _SectionId.preOpening => [
        MetricRow(
          label: l10n.termPreOpening,
          value: formatter.money(startup.preOpening.total),
        ),
        MetricRow(
          label: l10n.termSubtotal,
          value: formatter.money(startup.subtotal),
        ),
        MetricRow(
          label: l10n.termContingency,
          value: formatter.money(startup.contingency),
        ),
        MetricRow(
          label: l10n.termInitialInvestment,
          value: formatter.money(startup.total),
          emphasised: true,
        ),
      ],
      _SectionId.projection => [
        MetricRow(
          label: l10n.projectionTableTitle,
          value: l10n.projectionShowsMonths(projection.projectionMonths),
        ),
      ],
      _SectionId.sensitivity => [
        for (final result in projection.sensitivityResults)
          MetricRow(
            label: l10n.sensitivityScenarioLabel(result.definition),
            value: formatter.signedMoney(result.monthlyProfit),
            caption: formatter.percentage(result.occupancy),
            tone: result.monthlyProfit.isNegative
                ? MetricTone.negative
                : MetricTone.positive,
          ),
      ],
    };
  }
}

/// Choose the equipment option the project is costed against, and correct its
/// price if a quote changes.
class _EquipmentPicker extends StatelessWidget {
  const _EquipmentPicker({
    required this.equipment,
    required this.onSelect,
    required this.onCostChanged,
  });

  final EquipmentModel equipment;
  final ValueChanged<String> onSelect;
  final void Function(String packageId, num cost) onCostChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.financialColors;
    final l10n = AppLocalizations.of(context);
    final formatter = context.formatter;

    return RadioGroup<String>(
      groupValue: equipment.selectedPackageId,
      onChanged: (value) {
        if (value != null) onSelect(value);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final package in equipment.packages)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: InkWell(
                onTap: () => onSelect(package.id),
                borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
                    border: Border.all(
                      color: package.id == equipment.selectedPackageId
                          ? theme.colorScheme.primary
                          : colors.border,
                      width: package.id == equipment.selectedPackageId ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Radio<String>(value: package.id),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              package.name,
                              style: theme.textTheme.titleSmall,
                            ),
                            Text(
                              package.description,
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Text(
                        formatter.money(package.cost),
                        style: AppTheme.tabular(theme.textTheme.titleSmall!),
                      ),
                      IconButton(
                        tooltip: l10n.equipmentCostLabel,
                        icon: const Icon(Icons.edit_outlined, size: 18),
                        onPressed: () => _editCost(context, package),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _editCost(BuildContext context, EquipmentPackage package) async {
    final l10n = AppLocalizations.of(context);
    final formatter = context.formatter;
    final controller = TextEditingController(
      text: formatter.forEditing(package.cost.amount),
    );

    final result = await showDialog<num>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(package.name),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(labelText: l10n.equipmentCostLabel),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.of(context)
                    .pop(formatter.parseNumber(controller.text)),
            child: Text(l10n.save),
          ),
        ],
      ),
    );

    controller.dispose();
    if (result != null && result >= 0) onCostChanged(package.id, result);
  }
}
