import '../entities/results/roi_result.dart';
import '../value_objects/money.dart';
import '../value_objects/percentage.dart';

/// Return on investment, using the source study's definition.
///
/// Year-1 operating profit divided by the initial investment. This is not an
/// annualised or discounted return and must always be labelled as the study's
/// definition; replacing it with a different convention would change what the
/// feasibility study says.
class RoiCalculator {
  const RoiCalculator();

  RoiResult calculate({
    required Money yearOneProfit,
    required Money initialInvestment,
  }) {
    final ratio = yearOneProfit.ratioTo(initialInvestment);
    return RoiResult(
      yearOneProfit: yearOneProfit,
      initialInvestment: initialInvestment,
      yearOneRoi: ratio == null ? null : Percentage.fromFraction(ratio),
    );
  }
}
