import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:the_floor_is_lava/app/app.dart';
import 'package:the_floor_is_lava/features/financial_model/application/state/scenario_cubit.dart';
import 'package:the_floor_is_lava/features/financial_model/application/use_cases/load_scenario.dart';
import 'package:the_floor_is_lava/features/financial_model/application/use_cases/reset_scenario.dart';
import 'package:the_floor_is_lava/features/financial_model/application/use_cases/save_scenario.dart';
import 'package:the_floor_is_lava/features/financial_model/domain/entities/scenario/assumption_status.dart';
import 'package:the_floor_is_lava/features/settings/application/settings_cubit.dart';

import '../fixtures/fake_repositories.dart';
import 'responsive_layout_test.dart'
    show
        largePhoneLandscape,
        largeTabletLandscape,
        smallPhonePortrait,
        tabletLandscape,
        tabletPortrait;

/// Builds the real application over in-memory storage.
({Widget app, ScenarioCubit scenario, FakeScenarioRepository repository})
buildApp() {
  final repository = FakeScenarioRepository();
  final scenarioCubit = ScenarioCubit(
    loadScenario: LoadScenario(repository),
    saveScenario: SaveScenario(repository),
    resetScenario: ResetScenario(repository),
    autosaveDelay: const Duration(milliseconds: 10),
  );
  final settingsCubit = SettingsCubit(FakeSettingsRepository());

  scenarioCubit.initialise();
  settingsCubit.initialise();

  return (
    app: FloorIsLavaApp(
      scenarioCubit: scenarioCubit,
      settingsCubit: settingsCubit,
    ),
    scenario: scenarioCubit,
    repository: repository,
  );
}

/// Scrolls an assumption field into view and returns its text box.
///
/// Fields are looked up by their domain key rather than by their label, so the
/// tests stay valid if the wording changes.
Future<Finder> assumptionInput(WidgetTester tester, AssumptionKey key) async {
  final field = find.byKey(ValueKey(key));
  await tester.scrollUntilVisible(
    field,
    240,
    // First match: the list's own scrollable, ahead of the ones inside the
    // text fields it contains.
    scrollable: find
        .descendant(
          of: find.byKey(const PageStorageKey('assumptions-scroll')),
          matching: find.byType(Scrollable),
        )
        .first,
  );
  await tester.pumpAndSettle();
  return find.descendant(of: field, matching: find.byType(TextField));
}

Future<void> setScreen(WidgetTester tester, Size size) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.reset);
  await tester.pumpAndSettle();
}

void main() {
  group('application shell', () {
    testWidgets('opens on the dashboard with the study figures', (
      tester,
    ) async {
      final harness = buildApp();
      await tester.pumpWidget(harness.app);
      await setScreen(tester, smallPhonePortrait);

      expect(find.text('Dashboard'), findsWidgets);
      expect(find.text('Initial investment'), findsOneWidget);
      // The workbook's headline figure, formatted for display.
      expect(find.text(r'$16,412'), findsOneWidget);
      expect(find.text('During month 5'), findsOneWidget);

      await harness.scenario.close();
    });

    testWidgets('a phone in portrait navigates with a bottom bar', (
      tester,
    ) async {
      final harness = buildApp();
      await tester.pumpWidget(harness.app);
      await setScreen(tester, smallPhonePortrait);

      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.byType(NavigationRail), findsNothing);

      await harness.scenario.close();
    });

    testWidgets('a tablet in landscape navigates with a rail', (tester) async {
      final harness = buildApp();
      await tester.pumpWidget(harness.app);
      await setScreen(tester, tabletLandscape);

      expect(find.byType(NavigationRail), findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing);

      await harness.scenario.close();
    });

    testWidgets('every supported shape renders without overflowing', (
      tester,
    ) async {
      final harness = buildApp();
      await tester.pumpWidget(harness.app);

      for (final size in [
        smallPhonePortrait,
        largePhoneLandscape,
        tabletPortrait,
        tabletLandscape,
        largeTabletLandscape,
      ]) {
        await setScreen(tester, size);
        expect(
          tester.takeException(),
          isNull,
          reason: 'dashboard failed at $size',
        );
      }

      await harness.scenario.close();
    });
  });

  group('navigating between destinations', () {
    testWidgets('each screen renders its own content', (tester) async {
      final harness = buildApp();
      await tester.pumpWidget(harness.app);
      await setScreen(tester, tabletLandscape);

      for (final destination in [
        'Assumptions',
        'Projection',
        'Start-up costs',
        'Sensitivity',
        'Settings',
      ]) {
        await tester.tap(find.text(destination).first);
        await tester.pumpAndSettle();
        expect(
          tester.takeException(),
          isNull,
          reason: '$destination failed to render',
        );
      }

      await harness.scenario.close();
    });

    testWidgets('the start-up screen reconciles to the investment', (
      tester,
    ) async {
      final harness = buildApp();
      await tester.pumpWidget(harness.app);
      await setScreen(tester, smallPhonePortrait);

      await tester.tap(find.text('Start-up costs').first);
      await tester.pumpAndSettle();

      expect(find.text('Total initial investment'), findsOneWidget);
      expect(find.text(r'$16,411.89'), findsOneWidget);

      await harness.scenario.close();
    });

    testWidgets('the sensitivity screen never shows a meaningless payback', (
      tester,
    ) async {
      final harness = buildApp();
      await tester.pumpWidget(harness.app);
      await setScreen(tester, tabletPortrait);

      await tester.tap(find.text('Sensitivity').first);
      await tester.pumpAndSettle();

      // The conservative case loses money in the study, so it must say so
      // rather than print a negative number of months.
      expect(find.text('Not recoverable under this case'), findsOneWidget);

      await harness.scenario.close();
    });
  });

  group('editing an assumption', () {
    testWidgets('flows through to the dashboard', (tester) async {
      final harness = buildApp();
      await tester.pumpWidget(harness.app);
      await setScreen(tester, tabletPortrait);

      await tester.tap(find.text('Assumptions').first);
      await tester.pumpAndSettle();

      final ticketPrice = await assumptionInput(
        tester,
        AssumptionKey.ticketPrice,
      );
      await tester.enterText(ticketPrice, '8');
      await tester.pumpAndSettle();

      expect(
        harness
            .scenario
            .state
            .scenario!
            .revenue
            .pricing
            .ticketPricePerPlayer
            .amount,
        8,
      );

      await tester.tap(find.text('Dashboard').first);
      await tester.pumpAndSettle();

      // Doubling the price doubles a normal month's revenue.
      expect(find.text(r'$23,757'), findsOneWidget);

      await harness.scenario.close();
    });

    testWidgets('an invalid entry is reported and does not crash', (
      tester,
    ) async {
      final harness = buildApp();
      await tester.pumpWidget(harness.app);
      await setScreen(tester, tabletPortrait);

      await tester.tap(find.text('Assumptions').first);
      await tester.pumpAndSettle();

      final hours = await assumptionInput(
        tester,
        AssumptionKey.operatingHoursPerDay,
      );
      await tester.enterText(hours, '0');
      await tester.pumpAndSettle();

      expect(harness.scenario.state.validation.isValid, isFalse);
      expect(tester.takeException(), isNull);

      await harness.scenario.close();
    });
  });

  group('orientation changes', () {
    testWidgets('keep the scenario, the results and the current screen', (
      tester,
    ) async {
      final harness = buildApp();
      await tester.pumpWidget(harness.app);
      await setScreen(tester, tabletPortrait);

      await tester.tap(find.text('Assumptions').first);
      await tester.pumpAndSettle();

      final rent = await assumptionInput(tester, AssumptionKey.rent);
      await tester.enterText(rent, '2500');
      await tester.pumpAndSettle();

      final before = harness.scenario.state.projection!.startupCosts.total;

      // Rotate.
      await setScreen(tester, tabletLandscape);

      expect(
        harness.scenario.state.scenario!.operatingExpenses.rent.amount,
        2500,
      );
      expect(harness.scenario.state.projection!.startupCosts.total, before);
      // Still on the same screen, and still scrolled to the same place.
      expect(find.text('Assumptions'), findsWidgets);
      expect(find.byKey(const ValueKey(AssumptionKey.rent)), findsOneWidget);

      // And back again.
      await setScreen(tester, tabletPortrait);
      expect(
        harness.scenario.state.scenario!.operatingExpenses.rent.amount,
        2500,
      );
      expect(tester.takeException(), isNull);

      await harness.scenario.close();
    });

    testWidgets('switch the projection between a table and cards', (
      tester,
    ) async {
      final harness = buildApp();
      await tester.pumpWidget(harness.app);
      await setScreen(tester, tabletLandscape);

      await tester.tap(find.text('Projection').first);
      await tester.pumpAndSettle();
      expect(find.byType(DataTable), findsOneWidget);

      await setScreen(tester, smallPhonePortrait);
      expect(find.byType(DataTable), findsNothing);
      expect(find.byType(ExpansionTile), findsWidgets);

      await harness.scenario.close();
    });
  });

  group('explanations', () {
    testWidgets('a metric can show how it was calculated', (tester) async {
      final harness = buildApp();
      await tester.pumpWidget(harness.app);
      await setScreen(tester, smallPhonePortrait);

      await tester.tap(find.text('Initial investment').first);
      await tester.pumpAndSettle();

      expect(find.text('FORMULA'), findsOneWidget);
      expect(find.text('Delivered equipment'), findsWidgets);
      expect(find.text('Result'), findsOneWidget);

      await harness.scenario.close();
    });
  });
}
