import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../core/formatting/value_formatter.dart';
import '../features/financial_model/application/state/scenario_cubit.dart';
import '../features/financial_model/application/state/scenario_state.dart';
import '../features/financial_model/presentation/l10n/failure_messages.dart';
import '../features/financial_model/presentation/widgets/formatting_scope.dart';
import '../features/settings/application/settings_cubit.dart';
import '../features/settings/domain/app_settings.dart';
import '../l10n/generated/app_localizations.dart';
import 'router/app_shell.dart';
import 'theme/app_theme.dart';

/// The application root.
///
/// The two cubits are created above [MaterialApp], which is what makes the
/// specification's rule about orientation hold: rotating the device rebuilds
/// layout, never the financial state.
class FloorIsLavaApp extends StatelessWidget {
  const FloorIsLavaApp({
    required this.scenarioCubit,
    required this.settingsCubit,
    super.key,
  });

  final ScenarioCubit scenarioCubit;
  final SettingsCubit settingsCubit;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: scenarioCubit),
        BlocProvider.value(value: settingsCubit),
      ],
      child: BlocBuilder<SettingsCubit, AppSettings>(
        builder: (context, settings) {
          return MaterialApp(
            title: 'Floor is Lava',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: switch (settings.themeMode) {
              AppThemeMode.system => ThemeMode.system,
              AppThemeMode.light => ThemeMode.light,
              AppThemeMode.dark => ThemeMode.dark,
            },
            locale: settings.languageCode == null
                ? null
                : Locale(settings.languageCode!),
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            builder: (context, child) => _AppScope(child: child!),
            home: const AppShell(),
          );
        },
      ),
    );
  }
}

/// Wires the formatter to whatever the scenario and the preferences currently
/// say, and surfaces storage problems as they happen.
class _AppScope extends StatelessWidget {
  const _AppScope({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsCubit>().state;
    final currencyCode = context.select<ScenarioCubit, String>(
      (cubit) => cubit.state.scenario?.metadata.currencyCode ?? 'USD',
    );

    return FormattingScope(
      formatter: ValueFormatter(
        localeName: Localizations.localeOf(context).toString(),
        currencyCode: currencyCode,
        decimalPrecision: settings.decimalPrecision,
      ),
      child: BlocListener<ScenarioCubit, ScenarioState>(
        listenWhen: (previous, current) =>
            current.failure != null && previous.failure != current.failure,
        listener: (context, state) => _reportFailure(context, state),
        child: child,
      ),
    );
  }

  void _reportFailure(BuildContext context, ScenarioState state) {
    final failure = state.failure;
    if (failure == null) return;

    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(failureMessage(l10n, failure))));
    context.read<ScenarioCubit>().acknowledgeFailure();
  }
}
