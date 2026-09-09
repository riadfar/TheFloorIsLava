import '../entities/scenario/funding_assumptions.dart';
import '../value_objects/money.dart';

class FundingCalculator {
  const FundingCalculator();

  /// Startup total already includes contingency, so it is counted once.
  Money requiredFunding({
    required Money startupInvestment,
    required Money workingCapital,
    required FundingAssumptions assumptions,
  }) {
    return startupInvestment + workingCapital + assumptions.openingDelayBuffer;
  }
}
