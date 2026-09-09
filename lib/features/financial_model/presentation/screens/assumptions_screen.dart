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
import '../../domain/entities/scenario/cost_item.dart';
import '../../domain/entities/scenario/debt_assumptions.dart';
import '../../domain/entities/scenario/financial_scenario.dart';
import '../../domain/entities/scenario/marketing_assumptions.dart';
import '../../domain/entities/scenario/revenue_model.dart';
import '../../domain/entities/scenario/scenario_fields.dart';
import '../../domain/entities/scenario/startup_cost_model.dart';
import '../../domain/value_objects/money.dart';
import '../../domain/value_objects/percentage.dart';
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
              ScreenSection(
                child: _DebtFinancingEditor(scenario: scenario, cubit: cubit),
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
  funding,
  investment,
  stress,
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
    id: _SectionId.funding,
    keys: [AssumptionKey.workingCapitalFixed, AssumptionKey.openingDelayBuffer],
  ),
  _SectionSpec(
    id: _SectionId.investment,
    keys: [AssumptionKey.annualDiscountRate],
  ),
  _SectionSpec(
    id: _SectionId.stress,
    keys: [
      AssumptionKey.criticalFailureStartMonth,
      AssumptionKey.criticalFailureDowntimeDays,
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
        if (!(section.id == _SectionId.sessionPricing &&
            key == AssumptionKey.operatingHoursPerDay &&
            scenario.revenue.schedule.weeklyProfile.isEnabled))
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
          if (section.id == _SectionId.sessionPricing) ...[
            const SizedBox(height: AppSpacing.lg),
            _WeeklyHoursEditor(scenario: scenario, cubit: cubit),
          ],
          if (section.id == _SectionId.occupancy) ...[
            const SizedBox(height: AppSpacing.lg),
            const Divider(),
            _MarketingForecastEditor(scenario: scenario, cubit: cubit),
          ],
          if (section.id == _SectionId.operatingExpenses) ...[
            const SizedBox(height: AppSpacing.lg),
            _AdditionalExpenses(
              expenses: scenario.operatingExpenses.additionalExpenses,
              cubit: cubit,
            ),
          ],
          if (section.id == _SectionId.stress) ...[
            const SizedBox(height: AppSpacing.sm),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.enableCriticalFailure),
              subtitle: Text(l10n.helpCriticalFailure),
              value: scenario.stressAssumptions.criticalFailureEnabled,
              onChanged: cubit.setCriticalFailureEnabled,
            ),
          ],
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
    _SectionId.funding => l10n.sectionFunding,
    _SectionId.investment => l10n.sectionInvestment,
    _SectionId.stress => l10n.sectionStress,
    _SectionId.projection => l10n.sectionProjection,
    _SectionId.sensitivity => l10n.sectionSensitivityInputs,
  };

  String? _subtitle(AppLocalizations l10n) => switch (section.id) {
    _SectionId.occupancy => l10n.helpOccupancy,
    _SectionId.sensitivity => l10n.helpSensitivity,
    _SectionId.funding => l10n.helpWorkingCapitalFixed,
    _SectionId.investment => l10n.helpAnnualDiscountRate,
    _SectionId.stress => l10n.helpCriticalFailure,
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
      _SectionId.funding => [
        MetricRow(
          label: l10n.metricWorkingCapital,
          value: formatter.money(projection.workingCapitalRequirement),
        ),
        MetricRow(
          label: l10n.metricRequiredFunding,
          value: formatter.money(projection.requiredFunding),
          emphasised: true,
        ),
        MetricRow(
          label: l10n.metricFundingGap,
          value: formatter.money(projection.fundingGap),
          emphasised: projection.fundingGap.isPositive,
        ),
        MetricRow(
          label: l10n.metricMinimumCash,
          value: formatter.money(projection.minimumEndingCash),
        ),
      ],
      _SectionId.investment => [
        MetricRow(
          label: l10n.metricNpv,
          value: projection.investmentReturns.npv.isValid
              ? formatter.signedMoney(projection.investmentReturns.npv.value!)
              : l10n.metricUnavailable,
        ),
        MetricRow(
          label: l10n.metricIrr,
          value: projection.investmentReturns.irr.isValid
              ? formatter.percentage(projection.investmentReturns.irr.value!)
              : l10n.irrUnavailable,
        ),
        MetricRow(
          label: l10n.metricDiscountedPayback,
          value: projection.investmentReturns.discountedPaybackMonth.isValid
              ? l10n.paybackDuringMonth(
                  projection.investmentReturns.discountedPaybackMonth.value!,
                )
              : l10n.notAvailable,
        ),
        MetricRow(
          label: l10n.metricBreakEvenOccupancy,
          value: projection.breakEven.breakEvenOccupancy.isValid
              ? formatter.percentage(
                  projection.breakEven.breakEvenOccupancy.value!,
                )
              : l10n.metricUnavailable,
          emphasised: true,
        ),
      ],
      _SectionId.stress => [
        MetricRow(
          label: l10n.sectionStress,
          value: scenario.stressAssumptions.criticalFailureEnabled
              ? l10n.paybackDuringMonth(
                  scenario.stressAssumptions.failureStartMonth,
                )
              : l10n.scenarioBase,
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

class _WeeklyHoursEditor extends StatelessWidget {
  const _WeeklyHoursEditor({required this.scenario, required this.cubit});

  final FinancialScenario scenario;
  final ScenarioCubit cubit;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final profile = scenario.revenue.schedule.weeklyProfile;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.useWeeklyOperatingHours),
          subtitle: Text(l10n.weeklyOperatingHoursHint),
          value: profile.isEnabled,
          onChanged: (enabled) => enabled
              ? cubit.enableWeeklyOperatingProfile()
              : cubit.clearWeeklyOperatingProfile(),
        ),
        if (profile.isEnabled)
          ResponsiveGrid(
            minTileWidth: 150,
            maxColumns: 4,
            children: [
              for (
                var weekday = DateTime.monday;
                weekday <= DateTime.sunday;
                weekday++
              )
                _NumericInput(
                  key: ValueKey('weekday-$weekday'),
                  label: _weekdayLabel(l10n, weekday),
                  value: profile.days
                      .firstWhere(
                        (day) => day.weekday == weekday,
                        orElse: () => DayOperatingHours(
                          weekday: weekday,
                          hours: scenario.revenue.schedule.hoursPerDay,
                        ),
                      )
                      .hours,
                  suffix: l10n.unitHours,
                  onChanged: (value) =>
                      cubit.setDayOperatingHours(weekday, value),
                ),
            ],
          ),
      ],
    );
  }

  String _weekdayLabel(AppLocalizations l10n, int weekday) => switch (weekday) {
    DateTime.monday => l10n.monday,
    DateTime.tuesday => l10n.tuesday,
    DateTime.wednesday => l10n.wednesday,
    DateTime.thursday => l10n.thursday,
    DateTime.friday => l10n.friday,
    DateTime.saturday => l10n.saturday,
    _ => l10n.sunday,
  };
}

class _MarketingForecastEditor extends StatelessWidget {
  const _MarketingForecastEditor({required this.scenario, required this.cubit});

  final FinancialScenario scenario;
  final ScenarioCubit cubit;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final formatter = context.formatter;
    final model = scenario.marketingAssumptions;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.forecastingMode,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: AppSpacing.sm),
        DropdownButtonFormField<MarketingForecastMode>(
          initialValue: model.mode,
          decoration: InputDecoration(labelText: l10n.forecastingMode),
          items: [
            DropdownMenuItem(
              value: MarketingForecastMode.occupancyDriven,
              child: Text(l10n.forecastingModeOccupancy),
            ),
            DropdownMenuItem(
              value: MarketingForecastMode.marketingDriven,
              child: Text(l10n.forecastingModeMarketing),
            ),
          ],
          onChanged: (value) {
            if (value != null) cubit.setMarketingMode(value);
          },
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(l10n.marketingForecastHint),
        if (model.mode == MarketingForecastMode.marketingDriven) ...[
          const SizedBox(height: AppSpacing.lg),
          ResponsiveGrid(
            minTileWidth: 210,
            maxColumns: 2,
            children: [
              _NumericInput(
                key: const ValueKey('marketing-budget'),
                label: l10n.monthlyMarketingBudget,
                value: model.monthlyMarketingBudget.amount,
                prefix: formatter.currencySymbol,
                onChanged: (value) => cubit.setMarketingBudget(Money.of(value)),
              ),
              _NumericInput(
                key: const ValueKey('marketing-reach'),
                label: l10n.marketingReach,
                value: model.reach,
                onChanged: cubit.setMarketingReach,
              ),
              _NumericInput(
                key: const ValueKey('marketing-conversion'),
                label: l10n.marketingConversionRate,
                value: model.conversionRate.percent,
                suffix: l10n.unitPercent,
                onChanged: (value) => cubit.setMarketingConversionRate(
                  Percentage.fromPercent(value),
                ),
              ),
              _NumericInput(
                key: const ValueKey('marketing-rounds'),
                label: l10n.averageRoundsPerCustomer,
                value: model.averageRoundsPerConvertedCustomer,
                onChanged: cubit.setAverageRoundsPerConvertedCustomer,
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _NumericInput extends StatelessWidget {
  const _NumericInput({
    required this.label,
    required this.value,
    required this.onChanged,
    this.prefix,
    this.suffix,
    super.key,
  });

  final String label;
  final double value;
  final ValueChanged<double> onChanged;
  final String? prefix;
  final String? suffix;

  @override
  Widget build(BuildContext context) {
    final formatter = context.formatter;
    return TextFormField(
      initialValue: formatter.forEditing(value),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        prefixText: prefix,
        suffixText: suffix,
      ),
      onChanged: (text) {
        final parsed = formatter.parseNumber(text);
        if (parsed != null && parsed >= 0) onChanged(parsed);
      },
    );
  }
}

class _AdditionalExpenses extends StatelessWidget {
  const _AdditionalExpenses({required this.expenses, required this.cubit});

  final List<CostItem> expenses;
  final ScenarioCubit cubit;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final formatter = context.formatter;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.additionalExpenses,
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            TextButton.icon(
              onPressed: () => _showDialog(context),
              icon: const Icon(Icons.add),
              label: Text(l10n.addExpense),
            ),
          ],
        ),
        if (expenses.isEmpty)
          Text(l10n.noAdditionalExpenses)
        else
          for (final expense in expenses)
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(expense.label),
              subtitle: Text(
                '${formatter.money(expense.amount)} ${l10n.perMonth}',
              ),
              trailing: IconButton(
                tooltip: l10n.removeExpense,
                icon: const Icon(Icons.delete_outline),
                onPressed: () => cubit.removeAdditionalExpense(expense.id),
              ),
            ),
      ],
    );
  }

  Future<void> _showDialog(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final label = TextEditingController();
    final amount = TextEditingController();
    final result = await showDialog<CostItem>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.addExpense),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: label,
              autofocus: true,
              decoration: InputDecoration(labelText: l10n.expenseName),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: amount,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(labelText: l10n.monthlyAmount),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              final value = double.tryParse(amount.text);
              if (label.text.trim().isNotEmpty && value != null && value >= 0) {
                Navigator.pop(
                  context,
                  CostItem(
                    id: 'expense-${DateTime.now().microsecondsSinceEpoch}',
                    label: label.text.trim(),
                    amount: Money.of(value),
                  ),
                );
              }
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    );
    label.dispose();
    amount.dispose();
    if (result != null) cubit.addAdditionalExpense(result);
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

class _DebtFinancingEditor extends StatelessWidget {
  const _DebtFinancingEditor({required this.scenario, required this.cubit});

  final FinancialScenario scenario;
  final ScenarioCubit cubit;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final debt = scenario.debtAssumptions;
    final formatter = context.formatter;

    return SectionCard(
      title: l10n.sectionDebt,
      subtitle: l10n.debtHelp,
      child: Column(
        children: [
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.enableDebt),
            value: debt.enabled,
            onChanged: cubit.setDebtEnabled,
          ),
          if (debt.enabled) ...[
            const SizedBox(height: AppSpacing.md),
            DropdownButtonFormField<DebtAmortizationKind>(
              initialValue: debt.kind,
              decoration: InputDecoration(labelText: l10n.fieldDebtKind),
              items: [
                DropdownMenuItem(
                  value: DebtAmortizationKind.annuity,
                  child: Text(l10n.debtKindAnnuity),
                ),
                DropdownMenuItem(
                  value: DebtAmortizationKind.interestOnly,
                  child: Text(l10n.debtKindInterestOnly),
                ),
              ],
              onChanged: (kind) {
                if (kind != null) cubit.setDebtKind(kind);
              },
            ),
            const SizedBox(height: AppSpacing.md),
            _DebtNumberField(
              label: l10n.fieldDebtPrincipal,
              value: debt.principal.amount,
              onChanged: (value) => cubit.setDebtPrincipal(Money.of(value)),
            ),
            const SizedBox(height: AppSpacing.md),
            _DebtNumberField(
              label: l10n.fieldDebtInterestRate,
              value: debt.annualInterestRate.percent,
              onChanged: (value) => cubit.setDebtAnnualInterestRate(
                Percentage.fromPercent(value),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            _DebtNumberField(
              label: l10n.fieldDebtTermMonths,
              value: debt.termMonths.toDouble(),
              integer: true,
              onChanged: (value) => cubit.setDebtTermMonths(value.round()),
            ),
            const SizedBox(height: AppSpacing.md),
            _DebtNumberField(
              label: l10n.fieldDebtDisbursementMonth,
              value: debt.disbursementMonth.toDouble(),
              integer: true,
              onChanged: (value) =>
                  cubit.setDebtDisbursementMonth(value.round()),
            ),
            const SizedBox(height: AppSpacing.md),
            _DebtNumberField(
              label: l10n.fieldDebtFirstPaymentMonth,
              value: debt.firstPaymentMonth.toDouble(),
              integer: true,
              onChanged: (value) =>
                  cubit.setDebtFirstPaymentMonth(value.round()),
            ),
            const SizedBox(height: AppSpacing.sm),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                formatter.money(debt.principal),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DebtNumberField extends StatefulWidget {
  const _DebtNumberField({
    required this.label,
    required this.value,
    required this.onChanged,
    this.integer = false,
  });

  final String label;
  final double value;
  final ValueChanged<double> onChanged;
  final bool integer;

  @override
  State<_DebtNumberField> createState() => _DebtNumberFieldState();
}

class _DebtNumberFieldState extends State<_DebtNumberField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _format(widget.value));
  }

  @override
  void didUpdateWidget(covariant _DebtNumberField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      final next = _format(widget.value);
      if (_controller.text != next) {
        _controller.text = next;
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _format(double value) =>
      widget.integer ? value.round().toString() : value.toString();

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      keyboardType: TextInputType.numberWithOptions(decimal: !widget.integer),
      decoration: InputDecoration(labelText: widget.label),
      onChanged: (raw) {
        final parsed = double.tryParse(raw.trim());
        if (parsed != null && parsed >= 0) widget.onChanged(parsed);
      },
    );
  }
}
