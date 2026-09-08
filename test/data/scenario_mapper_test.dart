import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:the_floor_is_lava/features/financial_model/data/models/scenario_mapper.dart';
import 'package:the_floor_is_lava/features/financial_model/domain/entities/scenario/assumption_status.dart';
import 'package:the_floor_is_lava/features/financial_model/domain/entities/scenario/cost_item.dart';
import 'package:the_floor_is_lava/features/financial_model/domain/services/financial_model_calculator.dart';
import 'package:the_floor_is_lava/features/financial_model/domain/value_objects/money.dart';

import '../fixtures/scenario_fixtures.dart';

void main() {
  group('ScenarioMapper', () {
    test('a scenario survives a JSON round trip unchanged', () {
      final original = baseline();
      final restored = ScenarioMapper.fromJson(ScenarioMapper.toJson(original));
      expect(restored, original);
    });

    test('the round trip survives encoding to text and back', () {
      final original = baseline();
      final encoded = jsonEncode(ScenarioMapper.toJson(original));
      final restored = ScenarioMapper.fromJson(
        jsonDecode(encoded) as Map<String, dynamic>,
      );
      expect(restored, original);
    });

    test('a restored scenario produces identical numbers', () {
      const calculator = FinancialModelCalculator();
      final original = baseline();
      final restored = ScenarioMapper.fromJson(
        jsonDecode(jsonEncode(ScenarioMapper.toJson(original)))
            as Map<String, dynamic>,
      );
      expect(
        calculator.calculate(restored).startupCosts.total,
        calculator.calculate(original).startupCosts.total,
      );
      expect(
        calculator.calculate(restored).yearOne!.operatingProfit,
        calculator.calculate(original).yearOne!.operatingProfit,
      );
    });

    test('fractional money keeps every micro across the boundary', () {
      final scenario = baseline();
      final odd = scenario.copyWith(
        operatingExpenses: scenario.operatingExpenses.copyWith(
          rent: Money.of(3000.123456),
        ),
      );
      final restored = ScenarioMapper.fromJson(ScenarioMapper.toJson(odd));
      expect(restored.operatingExpenses.rent.micros, 3000123456);
    });

    test('user-created cost items round trip', () {
      final scenario = baseline();
      final extended = scenario.copyWith(
        operatingExpenses: scenario.operatingExpenses.copyWith(
          additionalExpenses: [
            CostItem(
              id: 'insurance',
              label: 'Insurance',
              amount: Money.units(75),
              status: AssumptionStatus.verified,
            ),
          ],
        ),
      );
      final restored = ScenarioMapper.fromJson(ScenarioMapper.toJson(extended));
      expect(
        restored.operatingExpenses.additionalExpenses.single.label,
        'Insurance',
      );
      expect(
        restored.operatingExpenses.additionalExpenses.single.status,
        AssumptionStatus.verified,
      );
    });

    test('the stored document records both versions', () {
      final json = ScenarioMapper.toJson(baseline());
      expect(json['schemaVersion'], ScenarioMapper.schemaVersion);
      expect(json['modelVersion'], 'financial_model_v1');
    });

    test('a newer schema is refused rather than misread', () {
      final json = ScenarioMapper.toJson(baseline());
      json['schemaVersion'] = ScenarioMapper.schemaVersion + 1;
      expect(
        () => ScenarioMapper.fromJson(json),
        throwsA(isA<FormatException>()),
      );
    });

    test('a missing section is refused', () {
      final json = ScenarioMapper.toJson(baseline())..remove('revenue');
      expect(
        () => ScenarioMapper.fromJson(json),
        throwsA(isA<FormatException>()),
      );
    });

    test('a field of the wrong type is refused', () {
      final json = ScenarioMapper.toJson(baseline());
      (json['operatingExpenses'] as Map<String, dynamic>)['rentMicros'] =
          'three thousand';
      expect(
        () => ScenarioMapper.fromJson(json),
        throwsA(isA<FormatException>()),
      );
    });

    test('a non-finite number is refused', () {
      final json = ScenarioMapper.toJson(baseline());
      (json['revenue']
              as Map<String, dynamic>)['pricing']['averagePlayersPerRound'] =
          double.nan;
      expect(
        () => ScenarioMapper.fromJson(json),
        throwsA(isA<FormatException>()),
      );
    });

    test('a scenario without equipment options is refused', () {
      final json = ScenarioMapper.toJson(baseline());
      ((json['startupCosts'] as Map<String, dynamic>)['equipment']
              as Map<String, dynamic>)['packages'] =
          <Object?>[];
      expect(
        () => ScenarioMapper.fromJson(json),
        throwsA(isA<FormatException>()),
      );
    });

    test('unknown assumption keys are dropped, not rejected', () {
      final json = ScenarioMapper.toJson(baseline());
      ((json['annotations'] as Map<String, dynamic>)['statuses']
              as Map<String, dynamic>)['someFutureInput'] =
          'confirmed';
      final restored = ScenarioMapper.fromJson(json);
      expect(
        restored.annotations.statuses.containsKey(AssumptionKey.rent),
        isFalse,
      );
      expect(
        restored.annotations.statusOf(AssumptionKey.ticketPrice),
        AssumptionStatus.confirmed,
      );
    });

    test('missing annotations fall back to defaults', () {
      final json = ScenarioMapper.toJson(baseline())..remove('annotations');
      final restored = ScenarioMapper.fromJson(json);
      expect(
        restored.annotations.statusOf(AssumptionKey.rent),
        AssumptionStatus.estimated,
      );
    });
  });
}
