import '../entities/scenario/working_capital_model.dart';
import '../value_objects/money.dart';

class WorkingCapitalCalculator {
  const WorkingCapitalCalculator();

  Money calculate({
    required WorkingCapitalModel model,
    required Money startupInvestment,
    required Money monthlyOperatingExpenses,
  }) {
    return switch (model.method) {
      WorkingCapitalMethod.fixedAmount => model.fixedAmount,
      WorkingCapitalMethod.percentOfStartup =>
        startupInvestment * model.percentOfStartup.fraction,
      WorkingCapitalMethod.monthsOfOpex =>
        monthlyOperatingExpenses * model.monthsOfOpex,
    };
  }
}
