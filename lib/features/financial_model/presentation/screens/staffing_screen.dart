import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/theme/app_theme.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../application/state/scenario_cubit.dart';
import '../../domain/entities/scenario/bonus_configuration.dart';
import '../../domain/entities/scenario/employee_roster.dart';
import '../../domain/entities/scenario/payroll_configuration.dart';
import '../../domain/value_objects/money.dart';
import '../../domain/value_objects/percentage.dart';
import '../widgets/formatting_scope.dart';
import '../widgets/metric_card.dart';
import '../widgets/scenario_builder.dart';
import '../widgets/screen_scaffold.dart';
import '../widgets/section_card.dart';

class StaffingScreen extends StatelessWidget {
  const StaffingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ScenarioBuilder(
      builder: (context, scenario, projection, state) {
        final cubit = context.read<ScenarioCubit>();
        final staffing = scenario.staffing;
        final payroll = staffing.payroll;
        final formatter = context.formatter;
        return ScreenScaffold(
          title: l10n.staffingTitle,
          subtitle: scenario.metadata.name,
          actions: [
            FilledButton.icon(
              onPressed: () => _showEmployeeDialog(context),
              icon: const Icon(Icons.person_add_outlined),
              label: Text(l10n.addEmployee),
            ),
          ],
          body: ListView(
            key: const PageStorageKey('staffing-scroll'),
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              ScreenSection(
                child: SectionCard(
                  title: l10n.employeeRoster,
                  child: staffing.roster.isEmpty
                      ? Text(l10n.noEmployees)
                      : Column(
                          children: [
                            for (final employee in staffing.roster.employees)
                              ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: Icon(
                                  employee.isFounder
                                      ? Icons.workspace_premium_outlined
                                      : Icons.person_outline,
                                ),
                                title: Text(employee.name),
                                subtitle: Text(
                                  _employeeSummary(
                                    employee,
                                    formatter.money,
                                    l10n,
                                  ),
                                ),
                                trailing: Wrap(
                                  spacing: AppSpacing.xs,
                                  children: [
                                    IconButton(
                                      tooltip: l10n.editEmployee,
                                      onPressed: () => _showEmployeeDialog(
                                        context,
                                        employee: employee,
                                      ),
                                      icon: const Icon(Icons.edit_outlined),
                                    ),
                                    IconButton(
                                      tooltip: l10n.deleteEmployee,
                                      onPressed: () =>
                                          cubit.removeEmployee(employee.id),
                                      icon: const Icon(Icons.delete_outline),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                ),
              ),
              ScreenSection(
                child: SectionCard(
                  title: l10n.payrollConfiguration,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      DropdownButtonFormField<PayrollAllocationMode>(
                        isExpanded: true,
                        initialValue: payroll.mode,
                        decoration: InputDecoration(
                          labelText: l10n.payrollMode,
                        ),
                        items: [
                          DropdownMenuItem(
                            value: PayrollAllocationMode.fixedPerEmployee,
                            child: Text(l10n.payrollFixed),
                          ),
                          DropdownMenuItem(
                            value: PayrollAllocationMode.proportionalHours,
                            child: Text(l10n.payrollProportional),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) cubit.setPayrollMode(value);
                        },
                      ),
                      if (payroll.mode ==
                          PayrollAllocationMode.proportionalHours) ...[
                        const SizedBox(height: AppSpacing.md),
                        _NumberField(
                          key: const ValueKey('shared-payroll-budget'),
                          label: l10n.sharedPayrollBudget,
                          value: payroll.sharedMonthlyPayrollBudget?.amount,
                          prefix: formatter.currencySymbol,
                          onChanged: (value) => cubit.setSharedPayrollBudget(
                            value == null ? null : Money.of(value),
                          ),
                        ),
                      ],
                      const SizedBox(height: AppSpacing.md),
                      _NumberField(
                        label: l10n.overtimeMultiplier,
                        value: payroll.overtimeMultiplier,
                        onChanged: (value) {
                          if (value != null && value > 0) {
                            cubit.setOvertimeMultiplier(value);
                          }
                        },
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _NumberField(
                        label: l10n.regularHoursCap,
                        value: staffing.regularHoursPerMonthCap,
                        onChanged: (value) =>
                            cubit.setRegularHoursCap(value?.round()),
                      ),
                    ],
                  ),
                ),
              ),
              ScreenSection(child: _BonusCard(configuration: payroll.bonus)),
              SectionCard(
                title: l10n.calculatedSectionTitle,
                child: Column(
                  children: [
                    MetricRow(
                      label: l10n.termEmployees,
                      value: formatter.count(
                        projection.steadyStateMonth?.employeeCount ??
                            staffing.roster.employees.length,
                      ),
                    ),
                    if (projection.steadyStateMonth case final month?)
                      MetricRow(
                        label: l10n.termPayroll,
                        value: formatter.money(month.payroll),
                        caption: l10n.normalMonth(month.monthNumber),
                        emphasised: true,
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _employeeSummary(
    Employee employee,
    String Function(Money) formatMoney,
    AppLocalizations l10n,
  ) {
    final hours = employee.weeklyShifts.fold<double>(
      0,
      (sum, shift) => sum + shift.endHour - shift.startHour - shift.breakHours,
    );
    final salary = employee.fixedMonthlySalary == null
        ? ''
        : ' · ${formatMoney(employee.fixedMonthlySalary!)}';
    return '${employee.weeklyShifts.length} ${l10n.shifts} · '
        '${hours.toStringAsFixed(1)} ${l10n.unitHours}$salary';
  }

  Future<void> _showEmployeeDialog(
    BuildContext context, {
    Employee? employee,
  }) async {
    final cubit = context.read<ScenarioCubit>();
    final result = await showDialog<Employee>(
      context: context,
      builder: (_) => _EmployeeDialog(
        employee: employee ?? Employee(id: cubit.createEmployeeId(), name: ''),
      ),
    );
    if (result != null) cubit.upsertEmployee(result);
  }
}

class _BonusCard extends StatelessWidget {
  const _BonusCard({required this.configuration});

  final BonusConfiguration configuration;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<ScenarioCubit>();
    final formatter = context.formatter;
    void update(BonusConfiguration value) => cubit.setBonusConfiguration(value);

    return SectionCard(
      title: l10n.bonusConfiguration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DropdownButtonFormField<BonusMode>(
            isExpanded: true,
            initialValue: configuration.mode,
            decoration: InputDecoration(labelText: l10n.bonusMode),
            items: [
              DropdownMenuItem(
                value: BonusMode.disabled,
                child: Text(l10n.bonusDisabled),
              ),
              DropdownMenuItem(
                value: BonusMode.percentageOfExcessRevenue,
                child: Text(l10n.bonusExcessRevenue),
              ),
              DropdownMenuItem(
                value: BonusMode.fixedAmountAtThreshold,
                child: Text(l10n.bonusFixedThreshold),
              ),
            ],
            onChanged: (value) {
              if (value != null) update(configuration.copyWith(mode: value));
            },
          ),
          if (configuration.mode != BonusMode.disabled) ...[
            const SizedBox(height: AppSpacing.md),
            _NumberField(
              label: l10n.revenueTarget,
              value: configuration.revenueTarget?.amount,
              prefix: formatter.currencySymbol,
              onChanged: (value) => update(
                configuration.copyWith(
                  revenueTarget: value == null ? null : Money.of(value),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            _NumberField(
              label: l10n.thresholdMultiplier,
              value: configuration.thresholdMultiplier?.percent,
              suffix: '%',
              onChanged: (value) => update(
                configuration.copyWith(
                  thresholdMultiplier: value == null
                      ? null
                      : Percentage.fromPercent(value),
                ),
              ),
            ),
          ],
          if (configuration.mode == BonusMode.percentageOfExcessRevenue) ...[
            const SizedBox(height: AppSpacing.md),
            _NumberField(
              label: l10n.percentageOfExcess,
              value: configuration.percentageOfExcess?.percent,
              suffix: '%',
              onChanged: (value) => update(
                configuration.copyWith(
                  percentageOfExcess: value == null
                      ? null
                      : Percentage.fromPercent(value),
                ),
              ),
            ),
          ],
          if (configuration.mode == BonusMode.fixedAmountAtThreshold) ...[
            const SizedBox(height: AppSpacing.md),
            _NumberField(
              label: l10n.fixedBonusAmount,
              value: configuration.fixedBonusAmount?.amount,
              prefix: formatter.currencySymbol,
              onChanged: (value) => update(
                configuration.copyWith(
                  fixedBonusAmount: value == null ? null : Money.of(value),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _EmployeeDialog extends StatefulWidget {
  const _EmployeeDialog({required this.employee});

  final Employee employee;

  @override
  State<_EmployeeDialog> createState() => _EmployeeDialogState();
}

class _EmployeeDialogState extends State<_EmployeeDialog> {
  late final TextEditingController _name;
  late final TextEditingController _salary;
  late bool _founder;
  late List<ShiftAssignment> _shifts;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.employee.name);
    _salary = TextEditingController(
      text: widget.employee.fixedMonthlySalary?.amount.toString() ?? '',
    );
    _founder = widget.employee.isFounder;
    _shifts = [...widget.employee.weeklyShifts];
  }

  @override
  void dispose() {
    _name.dispose();
    _salary.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(
        widget.employee.name.isEmpty ? l10n.addEmployee : l10n.editEmployee,
      ),
      content: SizedBox(
        width: 520,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _name,
                decoration: InputDecoration(labelText: l10n.employeeName),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.founder),
                value: _founder,
                onChanged: (value) => setState(() => _founder = value),
              ),
              TextField(
                controller: _salary,
                enabled: !_founder,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(labelText: l10n.fixedMonthlySalary),
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.weeklyShifts,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _addShift,
                    icon: const Icon(Icons.add),
                    label: Text(l10n.addShift),
                  ),
                ],
              ),
              for (var i = 0; i < _shifts.length; i++)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(_weekday(l10n, _shifts[i].weekday)),
                  subtitle: Text(
                    '${_shifts[i].startHour.toStringAsFixed(1)}–'
                    '${_shifts[i].endHour.toStringAsFixed(1)} · '
                    '${l10n.breakHours}: '
                    '${_shifts[i].breakHours.toStringAsFixed(1)}',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => setState(() => _shifts.removeAt(i)),
                  ),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: () {
            final salary = double.tryParse(_salary.text);
            Navigator.pop(
              context,
              widget.employee.copyWith(
                name: _name.text.trim(),
                isFounder: _founder,
                fixedMonthlySalary: _founder || salary == null
                    ? null
                    : Money.of(salary),
                weeklyShifts: _shifts,
              ),
            );
          },
          child: Text(l10n.save),
        ),
      ],
    );
  }

  Future<void> _addShift() async {
    final shift = await showDialog<ShiftAssignment>(
      context: context,
      builder: (_) => const _ShiftDialog(),
    );
    if (shift != null) setState(() => _shifts.add(shift));
  }
}

class _ShiftDialog extends StatefulWidget {
  const _ShiftDialog();

  @override
  State<_ShiftDialog> createState() => _ShiftDialogState();
}

class _ShiftDialogState extends State<_ShiftDialog> {
  int weekday = DateTime.monday;
  final start = TextEditingController(text: '9');
  final end = TextEditingController(text: '17');
  final breakHours = TextEditingController(text: '1');

  @override
  void dispose() {
    start.dispose();
    end.dispose();
    breakHours.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.addShift),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<int>(
            initialValue: weekday,
            decoration: InputDecoration(labelText: l10n.weekday),
            items: [
              for (var day = 1; day <= 7; day++)
                DropdownMenuItem(value: day, child: Text(_weekday(l10n, day))),
            ],
            onChanged: (value) => weekday = value ?? weekday,
          ),
          _DialogNumberField(controller: start, label: l10n.startHour),
          _DialogNumberField(controller: end, label: l10n.endHour),
          _DialogNumberField(controller: breakHours, label: l10n.breakHours),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: () {
            final startValue = double.tryParse(start.text);
            final endValue = double.tryParse(end.text);
            final breakValue = double.tryParse(breakHours.text) ?? 0;
            if (startValue != null &&
                endValue != null &&
                endValue > startValue &&
                breakValue >= 0 &&
                breakValue < endValue - startValue) {
              Navigator.pop(
                context,
                ShiftAssignment(
                  weekday: weekday,
                  startHour: startValue,
                  endHour: endValue,
                  breakHours: breakValue,
                ),
              );
            }
          },
          child: Text(l10n.save),
        ),
      ],
    );
  }
}

class _DialogNumberField extends StatelessWidget {
  const _DialogNumberField({required this.controller, required this.label});
  final TextEditingController controller;
  final String label;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: AppSpacing.sm),
    child: TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(labelText: label),
    ),
  );
}

class _NumberField extends StatelessWidget {
  const _NumberField({
    required this.label,
    required this.value,
    required this.onChanged,
    this.prefix,
    this.suffix,
    super.key,
  });

  final String label;
  final num? value;
  final ValueChanged<double?> onChanged;
  final String? prefix;
  final String? suffix;

  @override
  Widget build(BuildContext context) => TextFormField(
    initialValue: value?.toString(),
    keyboardType: const TextInputType.numberWithOptions(decimal: true),
    decoration: InputDecoration(
      labelText: label,
      prefixText: prefix,
      suffixText: suffix,
    ),
    onFieldSubmitted: (text) =>
        onChanged(text.trim().isEmpty ? null : double.tryParse(text)),
  );
}

String _weekday(AppLocalizations l10n, int weekday) => [
  l10n.monday,
  l10n.tuesday,
  l10n.wednesday,
  l10n.thursday,
  l10n.friday,
  l10n.saturday,
  l10n.sunday,
][weekday - 1];
