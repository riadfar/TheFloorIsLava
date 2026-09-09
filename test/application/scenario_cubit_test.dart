import 'package:flutter_test/flutter_test.dart';
import 'package:the_floor_is_lava/core/error/failures.dart';
import 'package:the_floor_is_lava/features/financial_model/application/state/scenario_cubit.dart';
import 'package:the_floor_is_lava/features/financial_model/application/state/scenario_state.dart';
import 'package:the_floor_is_lava/features/financial_model/application/use_cases/load_scenario.dart';
import 'package:the_floor_is_lava/features/financial_model/application/use_cases/reset_scenario.dart';
import 'package:the_floor_is_lava/features/financial_model/application/use_cases/save_scenario.dart';
import 'package:the_floor_is_lava/features/financial_model/domain/entities/scenario/assumption_status.dart';
import 'package:the_floor_is_lava/features/financial_model/domain/entities/scenario/cost_item.dart';
import 'package:the_floor_is_lava/features/financial_model/domain/value_objects/money.dart';

import 'package:the_floor_is_lava/features/financial_model/domain/validation/validation_issue.dart';

import '../fixtures/fake_repositories.dart';
import '../fixtures/scenario_fixtures.dart';

ScenarioCubit buildCubit(
  FakeScenarioRepository repository, {
  Duration autosaveDelay = const Duration(milliseconds: 10),
}) {
  return ScenarioCubit(
    loadScenario: LoadScenario(repository),
    saveScenario: SaveScenario(repository),
    resetScenario: ResetScenario(repository),
    autosaveDelay: autosaveDelay,
  );
}

void main() {
  group('ScenarioCubit - start-up', () {
    test('falls back to the study baseline when nothing is stored', () async {
      final repository = FakeScenarioRepository();
      final cubit = buildCubit(repository);

      await cubit.initialise();

      expect(cubit.state.status, ScenarioStatus.ready);
      expect(cubit.state.isReady, isTrue);
      expect(cubit.state.scenario!.metadata.id, 'floor-is-lava-base');
      expect(
        cubit.state.projection!.startupCosts.total.amount,
        closeTo(16411.89, 1e-6),
      );
      await cubit.close();
    });

    test('restores what was stored', () async {
      final stored = baseline().copyWith(
        metadata: baseline().metadata.copyWith(name: 'Mall B'),
      );
      final cubit = buildCubit(FakeScenarioRepository(stored: stored));

      await cubit.initialise();

      expect(cubit.state.scenario!.metadata.name, 'Mall B');
      await cubit.close();
    });

    test('still opens on the baseline when storage is unreadable', () async {
      final repository = FakeScenarioRepository(
        loadFailure: const PersistenceFailure(PersistenceFailureKind.corrupted),
      );
      final cubit = buildCubit(repository);

      await cubit.initialise();

      expect(cubit.state.isReady, isTrue);
      expect(cubit.state.failure, isA<PersistenceFailure>());
      await cubit.close();
    });
  });

  group('ScenarioCubit - editing', () {
    test('an edit recalculates every dependent figure', () async {
      final cubit = buildCubit(FakeScenarioRepository());
      await cubit.initialise();

      final before = cubit.state.projection!;
      cubit.updateField(AssumptionKey.ticketPrice, 8);
      final after = cubit.state.projection!;

      expect(
        after.steadyStateMonth!.monthlyRevenue.micros,
        before.steadyStateMonth!.monthlyRevenue.micros * 2,
      );
      expect(
        after.roi.yearOneRoi!.fraction,
        greaterThan(before.roi.yearOneRoi!.fraction),
      );
      expect(cubit.state.hasUnsavedChanges, isTrue);
      await cubit.close();
    });

    test('an edit that changes nothing does not touch the state', () async {
      final cubit = buildCubit(FakeScenarioRepository());
      await cubit.initialise();

      final before = cubit.state;
      cubit.updateField(AssumptionKey.ticketPrice, 4);

      expect(identical(cubit.state, before), isTrue);
      await cubit.close();
    });

    test('an invalid value is applied but reported', () async {
      final cubit = buildCubit(FakeScenarioRepository());
      await cubit.initialise();

      cubit.updateField(AssumptionKey.roundDuration, 0);

      expect(cubit.state.validation.isValid, isFalse);
      expect(
        cubit.state.validation.firstErrorFor(AssumptionKey.roundDuration),
        isNotNull,
      );
      // The model still produces a result, rather than leaving a blank screen.
      // A zero-length round with a five minute turnaround is still a five
      // minute slot, so capacity is high rather than undefined.
      expect(cubit.state.projection, isNotNull);
      expect(cubit.state.projection!.capacity.maximumRoundsPerDay, 156);

      // Only a slot that consumes no time at all collapses capacity to zero.
      cubit.updateField(AssumptionKey.turnaroundTime, 0);
      expect(cubit.state.projection!.capacity.maximumRoundsPerDay, 0);
      expect(
        cubit.state.validation.errors.map((issue) => issue.code),
        contains(ValidationCode.roundTimeNotPositive),
      );
      await cubit.close();
    });

    test('recording an assumption status leaves the numbers alone', () async {
      final cubit = buildCubit(FakeScenarioRepository());
      await cubit.initialise();

      final before = cubit.state.projection!.startupCosts.total;
      cubit.setAssumptionStatus(AssumptionKey.rent, AssumptionStatus.confirmed);

      expect(cubit.state.projection!.startupCosts.total, before);
      expect(
        cubit.state.scenario!.annotations.statusOf(AssumptionKey.rent),
        AssumptionStatus.confirmed,
      );
      await cubit.close();
    });

    test('choosing the other equipment package re-costs the project', () async {
      final cubit = buildCubit(FakeScenarioRepository());
      await cubit.initialise();

      cubit.selectEquipmentPackage('grid-room-complete');

      expect(cubit.state.projection!.startupCosts.equipmentCost.amount, 10285);
      await cubit.close();
    });

    test('custom expense is added and included in monthly costs', () async {
      final cubit = buildCubit(FakeScenarioRepository());
      await cubit.initialise();
      final before =
          cubit.state.projection!.steadyStateMonth!.otherOperatingExpenses;

      cubit.addAdditionalExpense(
        const CostItem(
          id: 'insurance',
          label: 'Insurance',
          amount: Money.units(250),
        ),
      );

      expect(
        cubit.state.scenario!.operatingExpenses.additionalExpenses,
        hasLength(1),
      );
      expect(
        cubit.state.projection!.steadyStateMonth!.otherOperatingExpenses,
        before + const Money.units(250),
      );
      await cubit.close();
    });

    test('enabled seasonality factors change the projection', () async {
      final cubit = buildCubit(FakeScenarioRepository());
      await cubit.initialise();
      final before = cubit.state.projection!.steadyStateMonth!.monthlyRevenue;

      cubit.setSeasonalityWeatherFactor(0.5);
      expect(
        cubit.state.projection!.steadyStateMonth!.monthlyRevenue,
        before,
        reason: 'disabled seasonality must preserve the baseline',
      );

      cubit.setSeasonalityEnabled(true);
      expect(
        cubit.state.projection!.steadyStateMonth!.monthlyRevenue,
        lessThan(before),
      );
      await cubit.close();
    });
  });

  group('ScenarioCubit - persistence', () {
    test('edits are saved after the autosave delay', () async {
      final repository = FakeScenarioRepository();
      final cubit = buildCubit(repository);
      await cubit.initialise();

      cubit.updateField(AssumptionKey.rent, 2500);
      await Future<void>.delayed(const Duration(milliseconds: 60));

      expect(repository.saveCount, 1);
      expect(repository.stored!.operatingExpenses.rent.amount, 2500);
      expect(cubit.state.hasUnsavedChanges, isFalse);
      await cubit.close();
    });

    test('a burst of edits results in a single save', () async {
      final repository = FakeScenarioRepository();
      final cubit = buildCubit(
        repository,
        autosaveDelay: const Duration(milliseconds: 40),
      );
      await cubit.initialise();

      cubit.updateField(AssumptionKey.rent, 2500);
      cubit.updateField(AssumptionKey.rent, 2600);
      cubit.updateField(AssumptionKey.rent, 2700);
      await Future<void>.delayed(const Duration(milliseconds: 100));

      expect(repository.saveCount, 1);
      expect(repository.stored!.operatingExpenses.rent.amount, 2700);
      await cubit.close();
    });

    test('an invalid scenario is not persisted', () async {
      final repository = FakeScenarioRepository();
      final cubit = buildCubit(repository);
      await cubit.initialise();

      cubit.updateField(AssumptionKey.operatingHoursPerDay, 0);
      await Future<void>.delayed(const Duration(milliseconds: 60));

      expect(repository.saveCount, 0);
      expect(cubit.state.hasUnsavedChanges, isTrue);
      await cubit.close();
    });

    test('a save failure is surfaced and the change stays unsaved', () async {
      final repository = FakeScenarioRepository(
        saveFailure: const PersistenceFailure(
          PersistenceFailureKind.unavailable,
        ),
      );
      final cubit = buildCubit(repository);
      await cubit.initialise();

      cubit.updateField(AssumptionKey.rent, 2500);
      await cubit.saveNow();

      expect(cubit.state.failure, isA<PersistenceFailure>());
      expect(cubit.state.hasUnsavedChanges, isTrue);
      await cubit.close();
    });

    test('resetting clears storage and restores the study values', () async {
      final repository = FakeScenarioRepository();
      final cubit = buildCubit(repository);
      await cubit.initialise();

      cubit.updateField(AssumptionKey.rent, 9999);
      await cubit.resetToBaseline();

      expect(repository.clearCount, 1);
      expect(cubit.state.scenario!.operatingExpenses.rent.amount, 3000);
      expect(cubit.state.hasUnsavedChanges, isFalse);
      await cubit.close();
    });

    test('a pending autosave is dropped when the cubit closes', () async {
      final repository = FakeScenarioRepository();
      final cubit = buildCubit(
        repository,
        autosaveDelay: const Duration(milliseconds: 200),
      );
      await cubit.initialise();

      cubit.updateField(AssumptionKey.rent, 2500);
      await cubit.close();
      await Future<void>.delayed(const Duration(milliseconds: 250));

      expect(repository.saveCount, 0);
    });
  });

  group('ScenarioCubit - scenario management', () {
    test('duplicates, selects, and deletes complete scenarios', () async {
      final repository = FakeScenarioRepository();
      final cubit = buildCubit(repository);
      await cubit.initialise();
      final baseId = cubit.state.scenario!.metadata.id;

      await cubit.duplicateActiveScenario();
      final copyId = cubit.state.scenario!.metadata.id;
      expect(copyId, isNot(baseId));
      expect(cubit.state.scenario!.metadata.name, endsWith(' (copy)'));
      expect(cubit.state.availableScenarios, hasLength(2));

      await cubit.selectScenario(baseId);
      expect(cubit.state.scenario!.metadata.id, baseId);

      await cubit.deleteScenario(copyId);
      expect(cubit.state.availableScenarios, hasLength(1));
      expect(cubit.state.scenario!.metadata.id, baseId);
      await cubit.close();
    });

    test('comparison reflects worst-case stress', () async {
      final repository = FakeScenarioRepository();
      final cubit = buildCubit(repository);
      await cubit.initialise();
      final baseId = cubit.state.scenario!.metadata.id;
      await cubit.createWorstCaseScenario();
      final worstId = cubit.state.scenario!.metadata.id;

      final comparison = await cubit.compareScenarios([baseId, worstId]);

      expect(comparison, hasLength(2));
      expect(
        comparison[worstId]!.monthlyResults[6].monthlyRevenue,
        lessThan(comparison[baseId]!.monthlyResults[6].monthlyRevenue),
      );
      await cubit.close();
    });
  });
}
