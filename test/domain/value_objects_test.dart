import 'package:flutter_test/flutter_test.dart';
import 'package:the_floor_is_lava/features/financial_model/domain/value_objects/minutes.dart';
import 'package:the_floor_is_lava/features/financial_model/domain/value_objects/money.dart';
import 'package:the_floor_is_lava/features/financial_model/domain/value_objects/percentage.dart';

void main() {
  group('Money', () {
    test('keeps a fixed-precision amount rather than a drifting double', () {
      var total = Money.zero;
      for (var i = 0; i < 10; i++) {
        total += Money.of(0.1);
      }
      expect(total, Money.units(1));
      expect(total.micros, 1000000);
    });

    test('a whole amount survives a round trip exactly', () {
      expect(Money.of(4).amount, 4.0);
      expect(Money.of(4).micros, 4000000);
    });

    test('scales by a rate', () {
      expect(Money.units(5270) * 0.12, Money.of(632.40));
      expect(Money.units(5270) * 0.25, Money.of(1317.50));
    });

    test('adds and subtracts exactly', () {
      expect(Money.of(11878.28928) - Money.units(4120), Money.of(7758.28928));
    });

    test('sums a list', () {
      expect(
        Money.sum([Money.units(300), Money.units(200), Money.units(100)]),
        Money.units(600),
      );
    });

    test('a ratio against zero is undefined rather than infinite', () {
      expect(Money.units(10).ratioTo(Money.zero), isNull);
      expect(Money.units(10).ratioTo(Money.units(4)), 2.5);
    });

    test('compares and reports sign', () {
      expect(Money.units(-5).isNegative, isTrue);
      expect(Money.units(-5).abs, Money.units(5));
      expect(Money.units(3) > Money.units(2), isTrue);
      expect(-Money.units(3), Money.units(-3));
    });
  });

  group('Percentage', () {
    test('holds a fraction internally and percent for display', () {
      const value = Percentage.fromPercent(69);
      expect(value.fraction, closeTo(0.69, 1e-12));
      expect(value.percent, closeTo(69, 1e-12));
    });

    test('round trips through either constructor', () {
      expect(
        const Percentage.fromFraction(0.12).percent,
        closeTo(const Percentage.fromPercent(12).percent, 1e-12),
      );
    });
  });

  group('Minutes', () {
    test('converts from hours', () {
      expect(Minutes.fromHours(13).value, 780);
      expect(const Minutes(90).inHours, 1.5);
    });

    test('adds', () {
      expect(const Minutes(15) + const Minutes(5), const Minutes(20));
    });
  });
}
