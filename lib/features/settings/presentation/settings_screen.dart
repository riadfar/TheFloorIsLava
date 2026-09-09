import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';

import '../../../app/theme/app_theme.dart';
import '../../../core/responsive/responsive_layout.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../financial_model/application/state/scenario_cubit.dart';
import '../../financial_model/presentation/widgets/scenario_builder.dart';
import '../../financial_model/presentation/widgets/screen_scaffold.dart';
import '../../financial_model/presentation/widgets/section_card.dart';
import '../application/settings_cubit.dart';
import '../domain/app_settings.dart';

/// Preferences, scenario identity, and the one destructive action in the app.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  /// Currencies offered out of the box. The model itself is currency-agnostic,
  /// so this list only affects how amounts are written.
  static const List<String> _currencies = [
    'USD',
    'EUR',
    'GBP',
    'AED',
    'SAR',
    'TRY',
    'SYP',
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return ScenarioBuilder(
      builder: (context, scenario, projection, state) {
        final layout = context.layout;
        final settings = context.watch<SettingsCubit>().state;
        final settingsCubit = context.read<SettingsCubit>();
        final scenarioCubit = context.read<ScenarioCubit>();

        return ScreenScaffold(
          title: l10n.settingsTitle,
          body: ListView(
            key: const PageStorageKey('settings-scroll'),
            padding: layout.pagePadding,
            children: [
              ScreenSection(
                child: SectionCard(
                  title: l10n.settingsScenario,
                  child: Column(
                    children: [
                      _ScenarioNameField(
                        name: scenario.metadata.name,
                        onChanged: scenarioCubit.renameScenario,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      _DropdownRow<String>(
                        label: l10n.settingsCurrency,
                        value: scenario.metadata.currencyCode,
                        items: {for (final code in _currencies) code: code},
                        onChanged: scenarioCubit.setCurrency,
                      ),
                    ],
                  ),
                ),
              ),
              ScreenSection(
                child: SectionCard(
                  title: l10n.settingsAppearance,
                  child: Column(
                    children: [
                      _DropdownRow<AppThemeMode>(
                        label: l10n.settingsTheme,
                        value: settings.themeMode,
                        items: {
                          AppThemeMode.system: l10n.settingsThemeSystem,
                          AppThemeMode.light: l10n.settingsThemeLight,
                          AppThemeMode.dark: l10n.settingsThemeDark,
                        },
                        onChanged: settingsCubit.setThemeMode,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      _DropdownRow<int>(
                        label: l10n.settingsDecimalPrecision,
                        value: settings.decimalPrecision,
                        items: {
                          for (
                            var precision = AppSettings.minimumDecimalPrecision;
                            precision <= AppSettings.maximumDecimalPrecision;
                            precision++
                          )
                            precision: '$precision',
                        },
                        onChanged: settingsCubit.setDecimalPrecision,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      _DropdownRow<String>(
                        label: l10n.settingsLanguage,
                        value: settings.languageCode ?? '',
                        items: {
                          '': l10n.settingsLanguageSystem,
                          'en': l10n.settingsLanguageEnglish,
                          'ar': l10n.settingsLanguageArabic,
                        },
                        onChanged: (code) => settingsCubit.setLanguage(
                          code.isEmpty ? null : code,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              ScreenSection(
                child: SectionCard(
                  title: l10n.settingsData,
                  subtitle: l10n.settingsAutosaveNote,
                  child: Wrap(
                    spacing: AppSpacing.md,
                    runSpacing: AppSpacing.md,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () => _copyExport(
                          context,
                          scenarioCubit.buildScenarioJsonExport(),
                          l10n.settingsScenarioExported,
                        ),
                        icon: const Icon(Icons.content_copy),
                        label: Text(l10n.settingsExportScenario),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => _copyExport(
                          context,
                          scenarioCubit.buildProjectionCsvExport(),
                          l10n.settingsProjectionExported,
                        ),
                        icon: const Icon(Icons.table_view_outlined),
                        label: Text(l10n.settingsExportProjection),
                      ),
                      OutlinedButton.icon(
                        onPressed: () =>
                            _showImportDialog(context, scenarioCubit),
                        icon: const Icon(Icons.content_paste),
                        label: Text(l10n.settingsImportScenario),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => _confirmReset(context, scenarioCubit),
                        icon: const Icon(Icons.restart_alt),
                        label: Text(l10n.settingsResetScenario),
                      ),
                    ],
                  ),
                ),
              ),
              ScreenSection(
                child: SectionCard(
                  title: l10n.settingsAbout,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.settingsAboutBody,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      _InfoRow(
                        label: l10n.settingsCalculationModel,
                        value: scenario.metadata.calculationModelVersion,
                      ),
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

  Future<void> _copyExport(
    BuildContext context,
    String text,
    String confirmation,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    await Clipboard.setData(ClipboardData(text: text));
    messenger.showSnackBar(SnackBar(content: Text(confirmation)));
  }

  Future<void> _showImportDialog(
    BuildContext context,
    ScenarioCubit cubit,
  ) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final controller = TextEditingController();
    var mode = _ImportMode.createNew;

    final submitted = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(l10n.settingsImportScenario),
          content: SizedBox(
            width: 560,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(l10n.settingsImportJsonHint),
                  const SizedBox(height: AppSpacing.md),
                  TextField(
                    controller: controller,
                    minLines: 6,
                    maxLines: 12,
                    decoration: InputDecoration(
                      labelText: l10n.settingsScenarioJson,
                      alignLabelWithHint: true,
                    ),
                  ),
                  RadioGroup<_ImportMode>(
                    groupValue: mode,
                    onChanged: (value) {
                      if (value != null) setState(() => mode = value);
                    },
                    child: Column(
                      children: [
                        RadioListTile<_ImportMode>(
                          value: _ImportMode.createNew,
                          title: Text(l10n.settingsImportCreateNew),
                        ),
                        RadioListTile<_ImportMode>(
                          value: _ImportMode.replaceActive,
                          title: Text(l10n.settingsImportReplace),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () async {
                if (controller.text.trim().isEmpty) return;
                await cubit.importScenarioFromJson(
                  controller.text,
                  asNewScenario: mode == _ImportMode.createNew,
                );
                if (dialogContext.mounted) {
                  Navigator.of(dialogContext).pop(true);
                }
              },
              child: Text(l10n.settingsImportAction),
            ),
          ],
        ),
      ),
    );
    controller.dispose();

    if (submitted == true && cubit.state.failure == null) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.settingsScenarioImported)),
      );
    }
  }

  Future<void> _confirmReset(BuildContext context, ScenarioCubit cubit) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.settingsResetConfirmTitle),
        content: Text(l10n.settingsResetConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.reset),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    await cubit.resetToBaseline();
    messenger.showSnackBar(SnackBar(content: Text(l10n.settingsResetDone)));
  }
}

enum _ImportMode { createNew, replaceActive }

class _ScenarioNameField extends StatefulWidget {
  const _ScenarioNameField({required this.name, required this.onChanged});

  final String name;
  final ValueChanged<String> onChanged;

  @override
  State<_ScenarioNameField> createState() => _ScenarioNameFieldState();
}

class _ScenarioNameFieldState extends State<_ScenarioNameField> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.name,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return TextField(
      controller: _controller,
      decoration: InputDecoration(labelText: l10n.settingsScenarioName),
      textInputAction: TextInputAction.done,
      onChanged: (value) {
        final trimmed = value.trim();
        if (trimmed.isNotEmpty) widget.onChanged(trimmed);
      },
    );
  }
}

class _DropdownRow<T> extends StatelessWidget {
  const _DropdownRow({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final T value;
  final Map<T, String> items;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
        ),
        const SizedBox(width: AppSpacing.lg),
        DropdownButton<T>(
          value: value,
          underline: const SizedBox.shrink(),
          onChanged: (selected) {
            if (selected != null) onChanged(selected);
          },
          items: [
            for (final entry in items.entries)
              DropdownMenuItem(value: entry.key, child: Text(entry.value)),
          ],
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(child: Text(label, style: theme.textTheme.bodyMedium)),
        Text(value, style: AppTheme.tabular(theme.textTheme.bodySmall!)),
      ],
    );
  }
}
