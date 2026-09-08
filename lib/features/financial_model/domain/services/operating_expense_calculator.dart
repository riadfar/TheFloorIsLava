import '../entities/scenario/operating_expense_model.dart';
import '../value_objects/money.dart';

/// The monthly cost base.
///
/// Every category stays separate. They are added here and nowhere else.
class OperatingExpenseCalculator {
  const OperatingExpenseCalculator();

  /// Everything except payroll: the flat monthly cost of keeping the doors
  /// open.
  Money otherOperatingExpenses(OperatingExpenseModel expenses) {
    return Money.sum([
      expenses.rent,
      expenses.mallSharedServices,
      expenses.electricity,
      expenses.maintenanceAndConsumables,
      expenses.continuousMarketing,
      ...expenses.additionalExpenses.map((item) => item.amount),
    ]);
  }

  Money totalOperatingExpenses({
    required Money payroll,
    required Money otherOperatingExpenses,
  }) {
    return payroll + otherOperatingExpenses;
  }
}
