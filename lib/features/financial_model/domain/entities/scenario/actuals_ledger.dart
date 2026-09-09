import 'package:equatable/equatable.dart';

import '../../value_objects/money.dart';
import '../../value_objects/percentage.dart';

class MonthlyActuals extends Equatable {
  const MonthlyActuals({
    required this.monthNumber,
    this.revenue,
    this.operatingExpenses,
    this.occupancy,
  }) : assert(monthNumber >= 1);

  final int monthNumber;
  final Money? revenue;
  final Money? operatingExpenses;
  final Percentage? occupancy;

  @override
  List<Object?> get props => [
    monthNumber,
    revenue,
    operatingExpenses,
    occupancy,
  ];
}

class ActualsLedger extends Equatable {
  const ActualsLedger({this.months = const []});

  final List<MonthlyActuals> months;

  MonthlyActuals? forMonth(int month) {
    for (final actuals in months) {
      if (actuals.monthNumber == month) return actuals;
    }
    return null;
  }

  ActualsLedger upsert(MonthlyActuals actuals) {
    final updated = [
      for (final existing in months)
        if (existing.monthNumber != actuals.monthNumber) existing,
      actuals,
    ]..sort((left, right) => left.monthNumber.compareTo(right.monthNumber));
    return ActualsLedger(months: List.unmodifiable(updated));
  }

  ActualsLedger remove(int month) => ActualsLedger(
    months: List.unmodifiable(
      months.where((actuals) => actuals.monthNumber != month),
    ),
  );

  @override
  List<Object?> get props => [months];
}
