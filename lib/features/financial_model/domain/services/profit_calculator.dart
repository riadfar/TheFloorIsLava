import '../value_objects/money.dart';
import '../value_objects/percentage.dart';

/// Operating profit and margin.
class ProfitCalculator {
  const ProfitCalculator();

  Money operatingProfit({
    required Money revenue,
    required Money totalOperatingExpenses,
  }) {
    return revenue - totalOperatingExpenses;
  }

  /// Operating profit over revenue.
  ///
  /// Returns `null` when there is no revenue: the ratio is genuinely undefined
  /// rather than zero, and callers decide whether to present it as 0% or N/A.
  Percentage? profitMargin({
    required Money operatingProfit,
    required Money revenue,
  }) {
    final ratio = operatingProfit.ratioTo(revenue);
    return ratio == null ? null : Percentage.fromFraction(ratio);
  }
}
