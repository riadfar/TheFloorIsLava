import 'package:flutter/material.dart';

import '../../core/responsive/responsive_layout.dart';
import '../../features/financial_model/presentation/screens/actuals_screen.dart';
import '../../features/financial_model/presentation/screens/assumptions_screen.dart';
import '../../features/financial_model/presentation/screens/dashboard_screen.dart';
import '../../features/financial_model/presentation/screens/projection_screen.dart';
import '../../features/financial_model/presentation/screens/scenarios_screen.dart';
import '../../features/financial_model/presentation/screens/seasonality_screen.dart';
import '../../features/financial_model/presentation/screens/sensitivity_screen.dart';
import '../../features/financial_model/presentation/screens/staffing_screen.dart';
import '../../features/financial_model/presentation/screens/startup_costs_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../l10n/generated/app_localizations.dart';
import '../theme/app_theme.dart';

/// The places the app can be.
enum AppDestination {
  dashboard,
  assumptions,
  staffing,
  seasonality,
  projection,
  startup,
  sensitivity,
  scenarios,
  actuals,
  settings,
}

extension AppDestinationView on AppDestination {
  IconData get icon => switch (this) {
    AppDestination.dashboard => Icons.dashboard_outlined,
    AppDestination.assumptions => Icons.tune_outlined,
    AppDestination.staffing => Icons.people_outline,
    AppDestination.seasonality => Icons.calendar_month_outlined,
    AppDestination.projection => Icons.table_chart_outlined,
    AppDestination.startup => Icons.receipt_long_outlined,
    AppDestination.sensitivity => Icons.insights_outlined,
    AppDestination.scenarios => Icons.layers_outlined,
    AppDestination.actuals => Icons.fact_check_outlined,
    AppDestination.settings => Icons.settings_outlined,
  };

  IconData get selectedIcon => switch (this) {
    AppDestination.dashboard => Icons.dashboard,
    AppDestination.assumptions => Icons.tune,
    AppDestination.staffing => Icons.people,
    AppDestination.seasonality => Icons.calendar_month,
    AppDestination.projection => Icons.table_chart,
    AppDestination.startup => Icons.receipt_long,
    AppDestination.sensitivity => Icons.insights,
    AppDestination.scenarios => Icons.layers,
    AppDestination.actuals => Icons.fact_check,
    AppDestination.settings => Icons.settings,
  };

  String label(AppLocalizations l10n) => switch (this) {
    AppDestination.dashboard => l10n.navDashboard,
    AppDestination.assumptions => l10n.navAssumptions,
    AppDestination.staffing => l10n.navStaffing,
    AppDestination.seasonality => l10n.navSeasonality,
    AppDestination.projection => l10n.navProjection,
    AppDestination.startup => l10n.navStartup,
    AppDestination.sensitivity => l10n.navSensitivity,
    AppDestination.scenarios => l10n.navScenarios,
    AppDestination.actuals => l10n.navActuals,
    AppDestination.settings => l10n.navSettings,
  };

  Widget get screen => switch (this) {
    AppDestination.dashboard => const DashboardScreen(),
    AppDestination.assumptions => const AssumptionsScreen(),
    AppDestination.staffing => const StaffingScreen(),
    AppDestination.seasonality => const SeasonalityScreen(),
    AppDestination.projection => const ProjectionScreen(),
    AppDestination.startup => const StartupCostsScreen(),
    AppDestination.sensitivity => const SensitivityScreen(),
    AppDestination.scenarios => const ScenariosScreen(),
    AppDestination.actuals => const ActualsScreen(),
    AppDestination.settings => const SettingsScreen(),
  };
}

/// The application frame.
///
/// Navigation adapts to the window: a bottom bar where a thumb has to reach it,
/// an icon rail when the window is wide but short, and a labelled rail when
/// there is width to spare. The screens themselves are held in an [IndexedStack]
/// so switching destinations - or rotating the device - keeps each screen's
/// scroll position and any half-finished edit exactly where it was.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  AppDestination _selected = AppDestination.dashboard;

  void _select(int index) {
    final destination = AppDestination.values[index];
    if (destination == _selected) return;
    setState(() => _selected = destination);
  }

  @override
  Widget build(BuildContext context) {
    final layout = context.layout;
    final l10n = AppLocalizations.of(context);
    final style = layout.navigationStyle;

    // Keyed so the screens keep their state when the rail appears or
    // disappears and this subtree changes position.
    final body = KeyedSubtree(
      key: const ValueKey('app-shell-body'),
      child: IndexedStack(
        index: _selected.index,
        children: [
          for (final destination in AppDestination.values)
            _DestinationView(destination: destination),
        ],
      ),
    );

    return Scaffold(
      body: SafeArea(
        child: style == NavigationStyle.bottomBar
            ? body
            : Row(
                key: const ValueKey('app-shell-row'),
                children: [
                  _Rail(
                    key: const ValueKey('app-shell-rail'),
                    destinations: AppDestination.values,
                    selectedIndex: _selected.index,
                    onSelected: _select,
                    extended: style == NavigationStyle.extendedRail,
                    l10n: l10n,
                  ),
                  Expanded(child: body),
                ],
              ),
      ),
      bottomNavigationBar: style == NavigationStyle.bottomBar
          ? NavigationBar(
              selectedIndex: _selected.index,
              onDestinationSelected: _select,
              destinations: [
                for (final destination in AppDestination.values)
                  NavigationDestination(
                    icon: Icon(destination.icon),
                    selectedIcon: Icon(destination.selectedIcon),
                    label: destination.label(l10n),
                  ),
              ],
            )
          : null,
    );
  }
}

/// Keeps each destination alive across switches, so returning to a screen does
/// not reset it.
class _DestinationView extends StatefulWidget {
  const _DestinationView({required this.destination});

  final AppDestination destination;

  @override
  State<_DestinationView> createState() => _DestinationViewState();
}

class _DestinationViewState extends State<_DestinationView>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.destination.screen;
  }
}

class _Rail extends StatelessWidget {
  const _Rail({
    required this.destinations,
    required this.selectedIndex,
    required this.onSelected,
    required this.extended,
    required this.l10n,
    super.key,
  });

  final List<AppDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final bool extended;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.financialColors;

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(right: BorderSide(color: colors.border)),
      ),
      child: SingleChildScrollView(
        child: IntrinsicHeight(
          child: NavigationRail(
            selectedIndex: selectedIndex,
            onDestinationSelected: onSelected,
            extended: extended,
            minExtendedWidth: 208,
            labelType: extended
                ? NavigationRailLabelType.none
                : NavigationRailLabelType.all,
            leading: Padding(
              padding: const EdgeInsets.only(
                top: AppSpacing.lg,
                bottom: AppSpacing.sm,
                left: AppSpacing.md,
                right: AppSpacing.md,
              ),
              child: extended
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.appTitle, style: theme.textTheme.titleMedium),
                        Text(
                          l10n.appSubtitle,
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    )
                  : Icon(
                      Icons.local_fire_department_outlined,
                      color: theme.colorScheme.primary,
                      semanticLabel: l10n.appTitle,
                    ),
            ),
            destinations: [
              for (final destination in destinations)
                NavigationRailDestination(
                  icon: Icon(destination.icon),
                  selectedIcon: Icon(destination.selectedIcon),
                  label: Text(destination.label(l10n)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
