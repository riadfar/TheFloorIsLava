import 'package:flutter_test/flutter_test.dart';
import 'package:the_floor_is_lava/features/financial_model/domain/value_objects/money.dart';

/// Matches a [Money] against a major-unit amount.
///
/// The comparison is exact at the model's internal precision (micros). Tests
/// assert on unrounded domain values, never on what the UI would display.
Matcher isMoney(num majorUnits) => _IsMoney(Money.of(majorUnits));

class _IsMoney extends Matcher {
  const _IsMoney(this.expected);

  final Money expected;

  @override
  bool matches(Object? item, Map<dynamic, dynamic> matchState) =>
      item is Money && item.micros == expected.micros;

  @override
  Description describe(Description description) =>
      description.add('Money ${expected.amount.toStringAsFixed(6)}');

  @override
  Description describeMismatch(
    Object? item,
    Description mismatchDescription,
    Map<dynamic, dynamic> matchState,
    bool verbose,
  ) {
    if (item is! Money) {
      return mismatchDescription.add('is not a Money value');
    }
    return mismatchDescription
        .add('was ${item.amount.toStringAsFixed(6)} ')
        .add(
          '(off by ${(item.micros - expected.micros) / Money.microsPerUnit})',
        );
  }
}
