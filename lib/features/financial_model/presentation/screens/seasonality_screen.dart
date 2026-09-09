import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/theme/app_theme.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../application/state/scenario_cubit.dart';
import '../../domain/entities/scenario/seasonality_model.dart';
import '../widgets/notice_banner.dart';
import '../widgets/scenario_builder.dart';
import '../widgets/screen_scaffold.dart';
import '../widgets/section_card.dart';

class SeasonalityScreen extends StatelessWidget {
  const SeasonalityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ScenarioBuilder(
      builder: (context, scenario, projection, state) {
        final model = scenario.seasonality;
        final cubit = context.read<ScenarioCubit>();
        return ScreenScaffold(
          title: l10n.seasonalityTitle,
          subtitle: scenario.metadata.name,
          body: ListView(
            key: const PageStorageKey('seasonality-scroll'),
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              ScreenSection(
                child: NoticeBanner(
                  tone: NoticeTone.info,
                  message: l10n.seasonalityNotice,
                ),
              ),
              ScreenSection(
                child: SectionCard(
                  title: l10n.seasonalityDemand,
                  child: Column(
                    children: [
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(l10n.enableSeasonality),
                        value: model.enabled,
                        onChanged: cubit.setSeasonalityEnabled,
                      ),
                      _FactorField(
                        label: l10n.weatherFactor,
                        value: model.weatherFactor,
                        onChanged: cubit.setSeasonalityWeatherFactor,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _FactorField(
                        label: l10n.marketingFactor,
                        value: model.marketingDemandFactor,
                        onChanged: cubit.setSeasonalityMarketingFactor,
                      ),
                    ],
                  ),
                ),
              ),
              ScreenSection(
                child: SectionCard(
                  title: l10n.monthFactors,
                  child: Wrap(
                    spacing: AppSpacing.md,
                    runSpacing: AppSpacing.md,
                    children: [
                      for (var month = 1; month <= 12; month++)
                        SizedBox(
                          width: 150,
                          child: _FactorField(
                            key: ValueKey('month-factor-$month'),
                            label: l10n.monthLabel(month),
                            value: model.monthFactors[month] ?? 1,
                            onChanged: (value) =>
                                cubit.setSeasonalityMonthFactor(month, value),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              ScreenSection(
                child: SectionCard(
                  title: l10n.dayFactors,
                  child: Wrap(
                    spacing: AppSpacing.md,
                    runSpacing: AppSpacing.md,
                    children: [
                      for (var day = 1; day <= 7; day++)
                        SizedBox(
                          width: 150,
                          child: _FactorField(
                            label: _weekday(l10n, day),
                            value: model.dayOfWeekFactors[day] ?? 1,
                            onChanged: (value) =>
                                cubit.setSeasonalityDayFactor(day, value),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              SectionCard(
                title: l10n.seasonalityEvents,
                trailing: TextButton.icon(
                  onPressed: () => _editEvent(context),
                  icon: const Icon(Icons.add),
                  label: Text(l10n.addEvent),
                ),
                child: model.events.isEmpty
                    ? Text(l10n.noEvents)
                    : Column(
                        children: [
                          for (final event in model.events)
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: Icon(
                                event.active
                                    ? Icons.event_available_outlined
                                    : Icons.event_busy_outlined,
                              ),
                              title: Text(event.name),
                              subtitle: Text(
                                '${l10n.monthLabel(event.startMonth)} – '
                                '${l10n.monthLabel(event.endMonth)} · '
                                '×${event.factor}',
                              ),
                              trailing: Wrap(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit_outlined),
                                    onPressed: () =>
                                        _editEvent(context, event: event),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline),
                                    onPressed: () =>
                                        cubit.removeSeasonalityEvent(event.id),
                                  ),
                                ],
                              ),
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

  Future<void> _editEvent(
    BuildContext context, {
    CalendarEventFactor? event,
  }) async {
    final cubit = context.read<ScenarioCubit>();
    final result = await showDialog<CalendarEventFactor>(
      context: context,
      builder: (_) => _EventDialog(
        event:
            event ??
            CalendarEventFactor(
              id: 'event-${DateTime.now().microsecondsSinceEpoch}',
              name: '',
              startMonth: 1,
              endMonth: 1,
              factor: 1,
            ),
      ),
    );
    if (result != null) cubit.upsertSeasonalityEvent(result);
  }
}

class _FactorField extends StatelessWidget {
  const _FactorField({
    required this.label,
    required this.value,
    required this.onChanged,
    super.key,
  });
  final String label;
  final double value;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) => TextFormField(
    initialValue: value.toString(),
    keyboardType: const TextInputType.numberWithOptions(decimal: true),
    decoration: InputDecoration(labelText: label, prefixText: '× '),
    onFieldSubmitted: (text) {
      final value = double.tryParse(text);
      if (value != null && value >= 0) onChanged(value);
    },
  );
}

class _EventDialog extends StatefulWidget {
  const _EventDialog({required this.event});
  final CalendarEventFactor event;

  @override
  State<_EventDialog> createState() => _EventDialogState();
}

class _EventDialogState extends State<_EventDialog> {
  late final TextEditingController name;
  late final TextEditingController factor;
  late int startMonth;
  late int endMonth;
  late bool active;

  @override
  void initState() {
    super.initState();
    name = TextEditingController(text: widget.event.name);
    factor = TextEditingController(text: widget.event.factor.toString());
    startMonth = widget.event.startMonth;
    endMonth = widget.event.endMonth;
    active = widget.event.active;
  }

  @override
  void dispose() {
    name.dispose();
    factor.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(widget.event.name.isEmpty ? l10n.addEvent : l10n.editEvent),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: name,
              decoration: InputDecoration(labelText: l10n.eventName),
            ),
            const SizedBox(height: AppSpacing.sm),
            DropdownButtonFormField<int>(
              initialValue: startMonth,
              decoration: InputDecoration(labelText: l10n.startMonth),
              items: _months(l10n),
              onChanged: (value) => startMonth = value ?? startMonth,
            ),
            const SizedBox(height: AppSpacing.sm),
            DropdownButtonFormField<int>(
              initialValue: endMonth,
              decoration: InputDecoration(labelText: l10n.endMonth),
              items: _months(l10n),
              onChanged: (value) => endMonth = value ?? endMonth,
            ),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: factor,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(labelText: l10n.demandFactor),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.active),
              value: active,
              onChanged: (value) => setState(() => active = value),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: () {
            final factorValue = double.tryParse(factor.text);
            if (name.text.trim().isNotEmpty &&
                factorValue != null &&
                factorValue >= 0 &&
                endMonth >= startMonth) {
              Navigator.pop(
                context,
                widget.event.copyWith(
                  name: name.text.trim(),
                  startMonth: startMonth,
                  endMonth: endMonth,
                  factor: factorValue,
                  active: active,
                ),
              );
            }
          },
          child: Text(l10n.save),
        ),
      ],
    );
  }

  List<DropdownMenuItem<int>> _months(AppLocalizations l10n) => [
    for (var month = 1; month <= 12; month++)
      DropdownMenuItem(value: month, child: Text(l10n.monthLabel(month))),
  ];
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
