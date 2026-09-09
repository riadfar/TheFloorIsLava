import '../value_objects/money.dart';

/// Cash movements, month by month.
///
/// The study treats operating profit as the month's operating cash flow - there
/// is no working-capital or accrual timing in the model - and applies the whole
/// investment in month 0. That is preserved exactly.
class CashFlowCalculator {
  const CashFlowCalculator();

  Money netCashFlow({
    required Money operatingProfit,
    required Money investmentOutflow,
    Money debtInflow = Money.zero,
    Money debtService = Money.zero,
  }) {
    return operatingProfit - investmentOutflow + debtInflow - debtService;
  }

  Money cumulativeCashFlow({
    required Money previousCumulative,
    required Money netCashFlow,
  }) {
    return previousCumulative + netCashFlow;
  }
}
