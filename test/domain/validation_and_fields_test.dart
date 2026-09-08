import 'package:flutter_test/flutter_test.dart';
import 'package:the_floor_is_lava/features/financial_model/domain/entities/scenario/assumption_status.dart';
import 'package:the_floor_is_lava/features/financial_model/domain/entities/scenario/scenario_fields.dart';
import 'package:the_floor_is_lava/features/financial_model/domain/validation/scenario_validator.dart';
import 'package:the_floor_is_lava/features/financial_model/domain/validation/validation_issue.dart';

import '../fixtures/scenario_fixtures.dart';

void main() {
  const validator = ScenarioValidator();

  group('ScenarioValidator - the study baseline', () {
    test('has no errors', () {
      final report = validator.validate(baseline());
      expect(report.errors, isEmpty);
      expect(report.isValid, isTrue);
    });

    test('warns that the study optimistic case sits below its own base', () {
      // The source workbook models an optimistic case at 60% while its own
      // stable occupancy is 69%. The numbers are preserved; the inconsistency
      // is surfaced rather than corrected.
      final report = validator.validate(baseline());
      expect(
        report.warnings.map((issue) => issue.code),
        contains(ValidationCode.optimisticOccupancyBelowBase),
      );
      expect(report.isValid, isTrue, reason: 'a warning must not block use');
    });
  });

  group('ScenarioValidator - rejections', () {
    ValidationIssue? issueFor(AssumptionKey key, num value) {
      final scenario = ScenarioFields.write(baseline(), key, value);
      return validator.validate(scenario).firstErrorFor(key);
    }

    test('a round must last longer than nothing', () {
      expect(issueFor(AssumptionKey.roundDuration, 0), isNotNull);
      expect(issueFor(AssumptionKey.roundDuration, -5), isNotNull);
      expect(issueFor(AssumptionKey.roundDuration, 1), isNull);
    });

    test('turnaround may be zero but not negative', () {
      expect(issueFor(AssumptionKey.turnaroundTime, 0), isNull);
      expect(issueFor(AssumptionKey.turnaroundTime, -1), isNotNull);
    });

    test('a ticket may be free but not cost a negative amount', () {
      expect(issueFor(AssumptionKey.ticketPrice, 0), isNull);
      expect(issueFor(AssumptionKey.ticketPrice, -1), isNotNull);
    });

    test('average players must be positive', () {
      expect(issueFor(AssumptionKey.averagePlayersPerRound, 0), isNotNull);
    });

    test('average players may not exceed the room capacity', () {
      final issue = issueFor(AssumptionKey.averagePlayersPerRound, 7);
      expect(issue?.code, ValidationCode.averagePlayersExceedCapacity);
      expect(issue?.limit, 6);
      expect(issueFor(AssumptionKey.averagePlayersPerRound, 6), isNull);
    });

    test('the room must hold at least one player', () {
      expect(issueFor(AssumptionKey.maximumPlayersPerRound, 0), isNotNull);
    });

    test('trading hours must fit inside a day', () {
      expect(issueFor(AssumptionKey.operatingHoursPerDay, 0), isNotNull);
      expect(issueFor(AssumptionKey.operatingHoursPerDay, 25), isNotNull);
      expect(issueFor(AssumptionKey.operatingHoursPerDay, 24), isNull);
    });

    test('occupancy is a share between nothing and everything', () {
      expect(issueFor(AssumptionKey.stableOccupancy, -1), isNotNull);
      expect(issueFor(AssumptionKey.stableOccupancy, 101), isNotNull);
      expect(issueFor(AssumptionKey.stableOccupancy, 0), isNull);
      expect(issueFor(AssumptionKey.stableOccupancy, 100), isNull);
      expect(issueFor(AssumptionKey.occupancyMonth1, 120), isNotNull);
    });

    test('headcount and pay cannot be negative', () {
      expect(issueFor(AssumptionKey.initialEmployeeCount, -1), isNotNull);
      expect(issueFor(AssumptionKey.initialEmployeeCount, 0), isNull);
      expect(issueFor(AssumptionKey.monthlySalaryPerEmployee, -1), isNotNull);
      expect(
        issueFor(AssumptionKey.monthlyIncentivePerEmployee, -1),
        isNotNull,
      );
    });

    test('operating expenses cannot be negative', () {
      expect(issueFor(AssumptionKey.rent, -1), isNotNull);
      expect(issueFor(AssumptionKey.electricity, -1), isNotNull);
      expect(issueFor(AssumptionKey.maintenance, -1), isNotNull);
      expect(issueFor(AssumptionKey.continuousMarketing, -1), isNotNull);
      expect(issueFor(AssumptionKey.mallSharedServices, -1), isNotNull);
    });

    test('contingency cannot be negative and is queried above 100%', () {
      expect(issueFor(AssumptionKey.contingencyRate, -1), isNotNull);
      expect(issueFor(AssumptionKey.contingencyRate, 150), isNull);

      final scenario = ScenarioFields.write(
        baseline(),
        AssumptionKey.contingencyRate,
        150,
      );
      expect(
        validator.validate(scenario).warnings.map((issue) => issue.code),
        contains(ValidationCode.contingencyAboveOneHundredPercent),
      );
    });

    test('the projection must cover at least one month', () {
      expect(issueFor(AssumptionKey.projectionMonths, 0), isNotNull);
    });

    test('a shrinking headcount is queried, not rejected', () {
      final scenario = ScenarioFields.write(
        baseline(),
        AssumptionKey.expandedEmployeeCount,
        1,
      );
      final report = validator.validate(scenario);
      expect(report.isValid, isTrue);
      expect(
        report.warnings.map((issue) => issue.code),
        contains(ValidationCode.expandedHeadcountBelowInitial),
      );
    });
  });

  group('ScenarioFields', () {
    test('every named input round trips through read and write', () {
      final scenario = baseline();
      for (final key in AssumptionKey.values) {
        final original = ScenarioFields.read(scenario, key);
        if (original == null) continue;

        final descriptor = ScenarioFields.descriptorFor(key);
        expect(descriptor, isNotNull, reason: '$key has no descriptor');

        final target = descriptor!.isInteger ? 7 : 7.5;
        final updated = ScenarioFields.write(scenario, key, target);
        expect(
          ScenarioFields.read(updated, key),
          closeTo(target, 1e-9),
          reason: '$key did not round trip',
        );

        // Writing one field must not disturb the others.
        for (final other in AssumptionKey.values) {
          if (other == key) continue;
          final before = ScenarioFields.read(scenario, other);
          final after = ScenarioFields.read(updated, other);
          if (before == null || after == null) continue;
          expect(after, before, reason: 'writing $key changed $other');
        }
      }
    });

    test('every key except the equipment choice is a readable number', () {
      final scenario = baseline();
      for (final key in AssumptionKey.values) {
        if (key == AssumptionKey.selectedEquipmentPackage) {
          expect(ScenarioFields.read(scenario, key), isNull);
          continue;
        }
        expect(
          ScenarioFields.read(scenario, key),
          isNotNull,
          reason: '$key is not readable',
        );
      }
    });

    test('writing a ramp-up month beyond the ramp extends it', () {
      final scenario = baseline();
      final shortRamp = ScenarioFields.write(
        scenario,
        AssumptionKey.occupancyMonth3,
        30,
      );
      expect(shortRamp.revenue.occupancy.rampUp.length, 3);
      expect(
        shortRamp.revenue.occupancy.occupancyForMonth(3).percent,
        closeTo(30, 1e-9),
      );
    });

    test('selecting an equipment package changes only the selection', () {
      final scenario = baseline();
      final switched = ScenarioFields.selectEquipmentPackage(
        scenario,
        'grid-room-complete',
      );
      expect(
        switched.startupCosts.equipment.selectedPackage.cost.amount,
        10285,
      );
      expect(
        switched.startupCosts.equipment.packages.length,
        scenario.startupCosts.equipment.packages.length,
      );
    });

    test('an assumption status can be recorded without touching a value', () {
      final scenario = baseline();
      final annotated = scenario.copyWith(
        annotations: scenario.annotations.withStatus(
          AssumptionKey.rent,
          AssumptionStatus.confirmed,
        ),
      );
      expect(
        annotated.annotations.statusOf(AssumptionKey.rent),
        AssumptionStatus.confirmed,
      );
      expect(annotated.operatingExpenses, scenario.operatingExpenses);
    });

    test('unlisted keys fall back to the default status', () {
      expect(
        baseline().annotations.statusOf(AssumptionKey.rent),
        AssumptionStatus.estimated,
      );
    });
  });
}
