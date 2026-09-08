import 'dart:math' as math;

import '../entities/results/financial_projection.dart';
import '../entities/results/monthly_financial_result.dart';
import '../entities/results/startup_cost_breakdown.dart';
import '../entities/scenario/financial_scenario.dart';
import '../value_objects/money.dart';
import '../value_objects/percentage.dart';
import 'annual_results_calculator.dart';
import 'capacity_calculator.dart';
import 'cash_flow_calculator.dart';
import 'operating_expense_calculator.dart';
import 'payback_calculator.dart';
import 'profit_calculator.dart';
import 'revenue_calculator.dart';
import 'roi_calculator.dart';
import 'sensitivity_calculator.dart';
import 'staffing_calculator.dart';
import 'startup_cost_calculator.dart';

/// The single entry point to the financial model.
///
/// Give it a scenario, get back a complete projection. The call is pure and
/// deterministic: the same scenario always produces the same result, and no
/// part of it depends on Flutter, storage or presentation state.
class FinancialModelCalculator {
  const FinancialModelCalculator({
    this.capacityCalculator = const CapacityCalculator(),
    this.revenueCalculator = const RevenueCalculator(),
    this.staffingCalculator = const StaffingCalculator(),
    this.operatingExpenseCalculator = const OperatingExpenseCalculator(),
    this.profitCalculator = const ProfitCalculator(),
    this.startupCostCalculator = const StartupCostCalculator(),
    this.cashFlowCalculator = const CashFlowCalculator(),
    this.paybackCalculator = const PaybackCalculator(),
    this.roiCalculator = const RoiCalculator(),
    this.annualResultsCalculator = const AnnualResultsCalculator(),
    this.sensitivityCalculator = const SensitivityCalculator(),
  });

  final CapacityCalculator capacityCalculator;
  final RevenueCalculator revenueCalculator;
  final StaffingCalculator staffingCalculator;
  final OperatingExpenseCalculator operatingExpenseCalculator;
  final ProfitCalculator profitCalculator;
  final StartupCostCalculator startupCostCalculator;
  final CashFlowCalculator cashFlowCalculator;
  final PaybackCalculator paybackCalculator;
  final RoiCalculator roiCalculator;
  final AnnualResultsCalculator annualResultsCalculator;
  final SensitivityCalculator sensitivityCalculator;

  FinancialProjection calculate(FinancialScenario scenario) {
    final capacity = capacityCalculator.summarise(scenario.revenue);
    final startupCosts = startupCostCalculator.calculate(scenario);

    final monthlyResults = _buildMonthlyResults(
      scenario: scenario,
      maximumRoundsPerDay: capacity.maximumRoundsPerDay,
      startupCosts: startupCosts,
    );

    final annualResults = annualResultsCalculator.calculate(monthlyResults);
    final yearOne = annualResults.isEmpty ? null : annualResults.first;
    final steadyStateMonthNumber = _steadyStateMonthNumber(scenario);

    return FinancialProjection(
      scenario: scenario,
      capacity: capacity,
      startupCosts: startupCosts,
      monthlyResults: monthlyResults,
      annualResults: annualResults,
      payback: paybackCalculator.calculate(monthlyResults),
      roi: roiCalculator.calculate(
        yearOneProfit: yearOne?.operatingProfit ?? Money.zero,
        initialInvestment: startupCosts.total,
      ),
      sensitivityResults: sensitivityCalculator.calculate(
        scenario: scenario,
        maximumRoundsPerDay: capacity.maximumRoundsPerDay,
        steadyStateOperatingExpenses: steadyStateOperatingExpenses(
          scenario,
          steadyStateMonthNumber,
        ),
        initialInvestment: startupCosts.total,
      ),
      steadyStateMonthNumber: steadyStateMonthNumber,
    );
  }

  List<MonthlyFinancialResult> _buildMonthlyResults({
    required FinancialScenario scenario,
    required int maximumRoundsPerDay,
    required StartupCostBreakdown startupCosts,
  }) {
    // Flat for the whole projection, so it is computed once.
    final otherOperatingExpenses = operatingExpenseCalculator
        .otherOperatingExpenses(scenario.operatingExpenses);

    final results = <MonthlyFinancialResult>[
      _investmentMonth(
        maximumRoundsPerDay: maximumRoundsPerDay,
        initialInvestment: startupCosts.total,
      ),
    ];

    var cumulativeRevenue = Money.zero;
    var cumulativeCashFlow = results.first.cumulativeCashFlow;

    final lastMonth = scenario.projection.projectionMonths;
    for (var monthNumber = 1; monthNumber <= lastMonth; monthNumber++) {
      final occupancy = scenario.revenue.occupancy.occupancyForMonth(
        monthNumber,
      );
      final actualRoundsPerDay = capacityCalculator.actualRoundsPerDay(
        maximumRoundsPerDay,
        occupancy,
      );
      final dailyRevenue = revenueCalculator.dailyRevenue(
        actualRoundsPerDay: actualRoundsPerDay,
        pricing: scenario.revenue.pricing,
      );
      final monthlyRevenue = revenueCalculator.monthlyRevenue(
        dailyRevenue: dailyRevenue,
        operatingDaysPerMonth: scenario.revenue.schedule.daysPerMonth,
      );
      cumulativeRevenue += monthlyRevenue;

      final employeeCount = staffingCalculator.employeeCountForMonth(
        scenario.staffing,
        monthNumber,
      );
      final payroll = staffingCalculator.payroll(
        scenario.staffing,
        employeeCount,
      );
      final totalOperatingExpenses = operatingExpenseCalculator
          .totalOperatingExpenses(
            payroll: payroll,
            otherOperatingExpenses: otherOperatingExpenses,
          );

      final operatingProfit = profitCalculator.operatingProfit(
        revenue: monthlyRevenue,
        totalOperatingExpenses: totalOperatingExpenses,
      );
      final profitMargin = profitCalculator.profitMargin(
        operatingProfit: operatingProfit,
        revenue: monthlyRevenue,
      );

      // The investment is spent in month 0, so a trading month's net cash flow
      // is exactly its operating profit.
      final netCashFlow = cashFlowCalculator.netCashFlow(
        operatingProfit: operatingProfit,
        investmentOutflow: Money.zero,
      );
      cumulativeCashFlow = cashFlowCalculator.cumulativeCashFlow(
        previousCumulative: cumulativeCashFlow,
        netCashFlow: netCashFlow,
      );

      results.add(
        MonthlyFinancialResult(
          monthNumber: monthNumber,
          occupancy: occupancy,
          maximumRoundsPerDay: maximumRoundsPerDay,
          actualRoundsPerDay: actualRoundsPerDay,
          dailyRevenue: dailyRevenue,
          monthlyRevenue: monthlyRevenue,
          cumulativeRevenue: cumulativeRevenue,
          employeeCount: employeeCount,
          payroll: payroll,
          otherOperatingExpenses: otherOperatingExpenses,
          totalOperatingExpenses: totalOperatingExpenses,
          operatingProfit: operatingProfit,
          profitMargin: profitMargin ?? Percentage.zero,
          isProfitMarginDefined: profitMargin != null,
          investmentOutflow: Money.zero,
          netCashFlow: netCashFlow,
          cumulativeCashFlow: cumulativeCashFlow,
        ),
      );
    }

    return List.unmodifiable(results);
  }

  /// Month 0: the investment is paid and nothing trades.
  MonthlyFinancialResult _investmentMonth({
    required int maximumRoundsPerDay,
    required Money initialInvestment,
  }) {
    final netCashFlow = cashFlowCalculator.netCashFlow(
      operatingProfit: Money.zero,
      investmentOutflow: initialInvestment,
    );
    return MonthlyFinancialResult(
      monthNumber: 0,
      occupancy: Percentage.zero,
      maximumRoundsPerDay: maximumRoundsPerDay,
      actualRoundsPerDay: 0,
      dailyRevenue: Money.zero,
      monthlyRevenue: Money.zero,
      cumulativeRevenue: Money.zero,
      employeeCount: 0,
      payroll: Money.zero,
      otherOperatingExpenses: Money.zero,
      totalOperatingExpenses: Money.zero,
      operatingProfit: Money.zero,
      profitMargin: Percentage.zero,
      isProfitMarginDefined: false,
      investmentOutflow: initialInvestment,
      netCashFlow: netCashFlow,
      cumulativeCashFlow: netCashFlow,
    );
  }

  /// The first month that runs at both stable occupancy and final headcount.
  ///
  /// This is the month that represents "a normal month" - what the headline
  /// figures describe and what sensitivity cases are costed against.
  int _steadyStateMonthNumber(FinancialScenario scenario) {
    return math.max(
      1,
      math.max(
        scenario.revenue.occupancy.firstStableMonth,
        scenario.staffing.expansionMonth,
      ),
    );
  }

  /// Cost base of a normal month.
  ///
  /// Derived from the staffing rule rather than read out of the projection, so
  /// that a projection shorter than the ramp-up cannot change what a normal
  /// month is understood to cost.
  Money steadyStateOperatingExpenses(
    FinancialScenario scenario,
    int steadyStateMonthNumber,
  ) {
    return operatingExpenseCalculator.totalOperatingExpenses(
      payroll: staffingCalculator.payrollForMonth(
        scenario.staffing,
        steadyStateMonthNumber,
      ),
      otherOperatingExpenses: operatingExpenseCalculator.otherOperatingExpenses(
        scenario.operatingExpenses,
      ),
    );
  }
}
