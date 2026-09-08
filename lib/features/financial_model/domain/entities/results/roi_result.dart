import 'package:equatable/equatable.dart';

import '../../value_objects/money.dart';
import '../../value_objects/percentage.dart';

/// Return on investment as the source study defines it: first-year operating
/// profit divided by the initial investment.
///
/// This is a simple payback-style ratio, not an annualised or discounted
/// return. The definition is preserved deliberately and must be labelled as the
/// study's definition wherever it is shown.
class RoiResult extends Equatable {
  const RoiResult({
    required this.yearOneProfit,
    required this.initialInvestment,
    required this.yearOneRoi,
  });

  final Money yearOneProfit;
  final Money initialInvestment;

  /// The ratio, or `null` when there is no investment to divide by.
  final Percentage? yearOneRoi;

  bool get isDefined => yearOneRoi != null;

  @override
  List<Object?> get props => [yearOneProfit, initialInvestment, yearOneRoi];
}
