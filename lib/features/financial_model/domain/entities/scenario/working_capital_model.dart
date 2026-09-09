import 'package:equatable/equatable.dart';

import '../../value_objects/money.dart';
import '../../value_objects/percentage.dart';

enum WorkingCapitalMethod { fixedAmount, percentOfStartup, monthsOfOpex }

/// Reserve required in addition to the initial investment.
class WorkingCapitalModel extends Equatable {
  const WorkingCapitalModel({
    this.method = WorkingCapitalMethod.fixedAmount,
    this.fixedAmount = Money.zero,
    this.percentOfStartup = Percentage.zero,
    this.monthsOfOpex = 0,
  });

  final WorkingCapitalMethod method;
  final Money fixedAmount;
  final Percentage percentOfStartup;
  final double monthsOfOpex;

  WorkingCapitalModel copyWith({
    WorkingCapitalMethod? method,
    Money? fixedAmount,
    Percentage? percentOfStartup,
    double? monthsOfOpex,
  }) {
    return WorkingCapitalModel(
      method: method ?? this.method,
      fixedAmount: fixedAmount ?? this.fixedAmount,
      percentOfStartup: percentOfStartup ?? this.percentOfStartup,
      monthsOfOpex: monthsOfOpex ?? this.monthsOfOpex,
    );
  }

  @override
  List<Object?> get props => [
    method,
    fixedAmount,
    percentOfStartup,
    monthsOfOpex,
  ];
}
