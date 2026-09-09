import 'dart:math' as math;

import '../entities/results/financial_projection.dart';
import '../entities/results/calculation_outcome.dart';
import '../entities/results/investment_returns_result.dart';
import '../entities/results/monthly_cash_position.dart';
import '../entities/results/monthly_financial_result.dart';
import '../entities/results/startup_cost_breakdown.dart';
import '../entities/scenario/financial_scenario.dart';
import '../entities/scenario/marketing_assumptions.dart';
import '../value_objects/money.dart';
import '../value_objects/percentage.dart';
import 'annual_results_calculator.dart';
import 'bonus_calculator.dart';
import 'break_even_calculator.dart';
import 'capacity_calculator.dart';
import 'cash_flow_calculator.dart';
import 'debt_calculator.dart';
import 'discounted_payback_calculator.dart';
import 'irr_calculator.dart';
import 'npv_calculator.dart';
import 'operating_expense_calculator.dart';
import 'funding_calculator.dart';
import 'payback_calculator.dart';
import 'payroll_calculator.dart';
import 'profit_calculator.dart';
import 'revenue_calculator.dart';
import 'roi_calculator.dart';
import 'sensitivity_calculator.dart';
import 'seasonality_calculator.dart';
import 'staffing_calculator.dart';
import 'startup_cost_calculator.dart';
import 'working_capital_calculator.dart';
import 'variance_calculator.dart';

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
    this.payrollCalculator = const PayrollCalculator(),
    this.bonusCalculator = const BonusCalculator(),
    this.operatingExpenseCalculator = const OperatingExpenseCalculator(),
    this.profitCalculator = const ProfitCalculator(),
    this.startupCostCalculator = const StartupCostCalculator(),
    this.cashFlowCalculator = const CashFlowCalculator(),
    this.paybackCalculator = const PaybackCalculator(),
    this.roiCalculator = const RoiCalculator(),
    this.annualResultsCalculator = const AnnualResultsCalculator(),
    this.sensitivityCalculator = const SensitivityCalculator(),
    this.breakEvenCalculator = const BreakEvenCalculator(),
    this.npvCalculator = const NpvCalculator(),
    this.irrCalculator = const IrrCalculator(),
    this.discountedPaybackCalculator = const DiscountedPaybackCalculator(),
    this.seasonalityCalculator = const SeasonalityCalculator(),
    this.workingCapitalCalculator = const WorkingCapitalCalculator(),
    this.fundingCalculator = const FundingCalculator(),
    this.debtCalculator = const DebtCalculator(),
    this.varianceCalculator = const VarianceCalculator(),
  });

  final CapacityCalculator capacityCalculator;
  final RevenueCalculator revenueCalculator;
  final StaffingCalculator staffingCalculator;
  final PayrollCalculator payrollCalculator;
  final BonusCalculator bonusCalculator;
  final OperatingExpenseCalculator operatingExpenseCalculator;
  final ProfitCalculator profitCalculator;
  final StartupCostCalculator startupCostCalculator;
  final CashFlowCalculator cashFlowCalculator;
  final PaybackCalculator paybackCalculator;
  final RoiCalculator roiCalculator;
  final AnnualResultsCalculator annualResultsCalculator;
  final SensitivityCalculator sensitivityCalculator;
  final BreakEvenCalculator breakEvenCalculator;
  final NpvCalculator npvCalculator;
  final IrrCalculator irrCalculator;
  final DiscountedPaybackCalculator discountedPaybackCalculator;
  final SeasonalityCalculator seasonalityCalculator;
  final WorkingCapitalCalculator workingCapitalCalculator;
  final FundingCalculator fundingCalculator;
  final DebtCalculator debtCalculator;
  final VarianceCalculator varianceCalculator;

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
    final steadyStateOpex = steadyStateOperatingExpenses(
      scenario,
      steadyStateMonthNumber,
    );
    final workingCapitalRequirement = workingCapitalCalculator.calculate(
      model: scenario.workingCapital,
      startupInvestment: startupCosts.total,
      monthlyOperatingExpenses: steadyStateOpex,
    );
    final requiredFunding = fundingCalculator.requiredFunding(
      startupInvestment: startupCosts.total,
      workingCapital: workingCapitalRequirement,
      assumptions: scenario.fundingAssumptions,
    );
    final cashPositions = _buildCashPositions(
      monthlyResults: monthlyResults,
      requiredFunding: requiredFunding,
    );
    final minimumEndingCash = cashPositions
        .map((position) => position.endingCash)
        .reduce((left, right) => left <= right ? left : right);
    final fundingGap = minimumEndingCash.isNegative
        ? -minimumEndingCash
        : Money.zero;
    final cashFlows = [for (final month in monthlyResults) month.netCashFlow];
    final discountRate = scenario.investmentAssumptions.annualDiscountRate;
    final validDiscountRate =
        discountRate.fraction.isFinite && discountRate.fraction / 12 > -1;
    final npv = validDiscountRate
        ? MetricResult<Money>.valid(
            npvCalculator.calculate(
              monthlyCashFlows: cashFlows,
              annualDiscountRate: discountRate,
            ),
          )
        : const MetricResult<Money>.invalid('discount_rate_out_of_range');
    final discountedPayback = discountedPaybackCalculator.calculate(
      monthlyCashFlows: cashFlows,
      annualDiscountRate: discountRate,
    );
    final irr = irrCalculator
        .calculate(cashFlows)
        .map((rates) => rates.annualized);

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
      breakEven: breakEvenCalculator.calculate(
        steadyStateMonthlyOpex: steadyStateOpex,
        maximumRoundsPerDay: capacity.maximumRoundsPerDay,
        averagePlayersPerRound: scenario.revenue.pricing.averagePlayersPerRound,
        ticketPrice: scenario.revenue.pricing.ticketPricePerPlayer,
        daysPerMonth: scenario.revenue.schedule.daysPerMonth,
      ),
      investmentReturns: InvestmentReturnsResult(
        npv: npv,
        irr: irr,
        discountedPaybackMonth: discountedPayback,
        discountRateUsed: discountRate,
      ),
      sensitivityResults: sensitivityCalculator.calculate(
        scenario: scenario,
        maximumRoundsPerDay: capacity.maximumRoundsPerDay,
        steadyStateOperatingExpenses: steadyStateOpex,
        initialInvestment: startupCosts.total,
      ),
      steadyStateMonthNumber: steadyStateMonthNumber,
      workingCapitalRequirement: workingCapitalRequirement,
      requiredFunding: requiredFunding,
      minimumEndingCash: minimumEndingCash,
      fundingGap: fundingGap,
      cashPositions: cashPositions,
      variances: varianceCalculator.calculate(
        forecasts: monthlyResults,
        actuals: scenario.actuals,
      ),
    );
  }

  List<MonthlyFinancialResult> _buildMonthlyResults({
    required FinancialScenario scenario,
    required int maximumRoundsPerDay,
    required StartupCostBreakdown startupCosts,
  }) {
    // Flat for the whole projection, so it is computed once.
    final otherOperatingExpenses =
        operatingExpenseCalculator.otherOperatingExpenses(
          scenario.operatingExpenses,
        ) +
        scenario.startupCosts.equipmentLifecycle.monthlyMaintenanceReserve +
        scenario.startupCosts.equipmentLifecycle.sparePartsReserveMonthly;
    final steadyStateExpectedRevenue = _steadyStateExpectedRevenue(
      scenario,
      maximumRoundsPerDay,
    );
    final debtPayments = {
      for (final payment in debtCalculator.calculate(scenario.debtAssumptions))
        payment.monthNumber: payment,
    };

    final results = <MonthlyFinancialResult>[
      _investmentMonth(
        maximumRoundsPerDay: maximumRoundsPerDay,
        initialInvestment: startupCosts.total,
        debtInflow:
            scenario.debtAssumptions.enabled &&
                scenario.debtAssumptions.disbursementMonth == 0
            ? scenario.debtAssumptions.principal
            : Money.zero,
        debtService: debtPayments[0]?.totalPayment ?? Money.zero,
      ),
    ];

    var cumulativeRevenue = Money.zero;
    var cumulativeCashFlow = results.first.cumulativeCashFlow;

    final lastMonth = scenario.projection.projectionMonths;
    for (var monthNumber = 1; monthNumber <= lastMonth; monthNumber++) {
      final baseOccupancy = _baseOccupancy(
        scenario,
        monthNumber,
        maximumRoundsPerDay,
      );
      final occupancy = seasonalityCalculator.effectiveOccupancy(
        baseOccupancy: baseOccupancy,
        projectionMonth: monthNumber,
        model: scenario.seasonality,
      );
      final actualRoundsPerDay = capacityCalculator.actualRoundsPerDay(
        maximumRoundsPerDay,
        occupancy,
      );
      final dailyRevenue = revenueCalculator.dailyRevenue(
        actualRoundsPerDay: actualRoundsPerDay,
        pricing: scenario.revenue.pricing,
      );
      var monthlyRevenue = revenueCalculator.monthlyRevenue(
        dailyRevenue: dailyRevenue,
        operatingDaysPerMonth: scenario.revenue.schedule.daysPerMonth,
      );
      final stress = scenario.stressAssumptions;
      if (stress.criticalFailureEnabled &&
          stress.failureStartMonth == monthNumber) {
        final availableDayFraction = math.max(
          0,
          1 - stress.downtimeDays / scenario.revenue.schedule.daysPerMonth,
        );
        monthlyRevenue *= availableDayFraction;
      }
      cumulativeRevenue += monthlyRevenue;

      final employeeCount = staffingCalculator.employeeCountForMonth(
        scenario.staffing,
        monthNumber,
      );
      final payrollResult = payrollCalculator.calculateForMonth(
        staffing: scenario.staffing,
        month: monthNumber,
        daysPerMonth: scenario.revenue.schedule.daysPerMonth,
        daysPerWeek: scenario.revenue.schedule.daysPerWeek,
      );
      final payroll = payrollResult.isValid ? payrollResult.total : Money.zero;
      final bonus = bonusCalculator.calculate(
        configuration: scenario.staffing.payroll.bonus,
        revenue: monthlyRevenue,
        expectedRevenue: steadyStateExpectedRevenue,
      );
      // MonthlyFinancialResult has no separate bonus line, so employee bonuses
      // are included in the stored payroll amount.
      final payrollWithBonus = payroll + bonus;
      final paymentFees =
          monthlyRevenue *
          scenario.paymentAssumptions.digitalPaymentShare.fraction *
          scenario.paymentAssumptions.digitalPaymentFeeRate.fraction;
      final vatRate = scenario.taxAssumptions.vatRate.fraction;
      final vatOutflow = vatRate == 0
          ? Money.zero
          : scenario.taxAssumptions.pricesIncludeVat
          ? monthlyRevenue * (vatRate / (1 + vatRate))
          : monthlyRevenue * vatRate;
      final monthlyOtherOperatingExpenses =
          otherOperatingExpenses + paymentFees + vatOutflow;
      final totalOperatingExpenses = operatingExpenseCalculator
          .totalOperatingExpenses(
            payroll: payrollWithBonus,
            otherOperatingExpenses: monthlyOtherOperatingExpenses,
          );

      final operatingProfit = profitCalculator.operatingProfit(
        revenue: monthlyRevenue,
        totalOperatingExpenses: totalOperatingExpenses,
      );
      final profitMargin = profitCalculator.profitMargin(
        operatingProfit: operatingProfit,
        revenue: monthlyRevenue,
      );

      final lifecycle = scenario.startupCosts.equipmentLifecycle;
      final isPlannedReplacement =
          lifecycle.includeReplacementInProjection &&
          lifecycle.usefulLifeMonths > 0 &&
          monthNumber == lifecycle.usefulLifeMonths.round();
      final replacementOutflow = isPlannedReplacement
          ? (lifecycle.replacementCost.isZero
                ? scenario.startupCosts.equipment.selectedPackage.cost
                : lifecycle.replacementCost)
          : Money.zero;
      final debtInflow =
          scenario.debtAssumptions.enabled &&
              scenario.debtAssumptions.disbursementMonth == monthNumber
          ? scenario.debtAssumptions.principal
          : Money.zero;
      final debtService = debtPayments[monthNumber]?.totalPayment ?? Money.zero;
      final netCashFlow = cashFlowCalculator.netCashFlow(
        operatingProfit: operatingProfit,
        investmentOutflow: replacementOutflow,
        debtInflow: debtInflow,
        debtService: debtService,
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
          payroll: payrollWithBonus,
          otherOperatingExpenses: monthlyOtherOperatingExpenses,
          totalOperatingExpenses: totalOperatingExpenses,
          operatingProfit: operatingProfit,
          profitMargin: profitMargin ?? Percentage.zero,
          isProfitMarginDefined: profitMargin != null,
          investmentOutflow: replacementOutflow,
          debtInflow: debtInflow,
          debtService: debtService,
          netCashFlow: netCashFlow,
          cumulativeCashFlow: cumulativeCashFlow,
        ),
      );
    }

    return List.unmodifiable(results);
  }

  /// Builds a balance track without changing payback's cumulative cash flow.
  ///
  /// Month 0 opens with all required funding and applies the existing
  /// `-initialInvestment` net cash flow, leaving working capital plus any delay
  /// buffer. Later months roll the balance forward using their existing flows.
  List<MonthlyCashPosition> _buildCashPositions({
    required List<MonthlyFinancialResult> monthlyResults,
    required Money requiredFunding,
  }) {
    final positions = <MonthlyCashPosition>[];
    var openingCash = requiredFunding;
    for (final month in monthlyResults) {
      final endingCash = openingCash + month.netCashFlow;
      positions.add(
        MonthlyCashPosition(
          monthNumber: month.monthNumber,
          openingCash: openingCash,
          endingCash: endingCash,
          fundingGapThisMonth: endingCash.isNegative ? -endingCash : Money.zero,
        ),
      );
      openingCash = endingCash;
    }
    return List.unmodifiable(positions);
  }

  /// Month 0: the investment is paid and nothing trades.
  MonthlyFinancialResult _investmentMonth({
    required int maximumRoundsPerDay,
    required Money initialInvestment,
    required Money debtInflow,
    required Money debtService,
  }) {
    final netCashFlow = cashFlowCalculator.netCashFlow(
      operatingProfit: Money.zero,
      investmentOutflow: initialInvestment,
      debtInflow: debtInflow,
      debtService: debtService,
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
      debtInflow: debtInflow,
      debtService: debtService,
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
    final maximumRoundsPerDay = capacityCalculator
        .summarise(scenario.revenue)
        .maximumRoundsPerDay;
    final expectedRevenue = _steadyStateExpectedRevenue(
      scenario,
      maximumRoundsPerDay,
    );
    final payroll = payrollCalculator
        .calculateForMonth(
          staffing: scenario.staffing,
          month: steadyStateMonthNumber,
          daysPerMonth: scenario.revenue.schedule.daysPerMonth,
          daysPerWeek: scenario.revenue.schedule.daysPerWeek,
        )
        .total;
    final bonus = bonusCalculator.calculate(
      configuration: scenario.staffing.payroll.bonus,
      revenue: expectedRevenue,
      expectedRevenue: expectedRevenue,
    );
    return operatingExpenseCalculator.totalOperatingExpenses(
      payroll: payroll + bonus,
      otherOperatingExpenses:
          operatingExpenseCalculator.otherOperatingExpenses(
            scenario.operatingExpenses,
          ) +
          scenario.startupCosts.equipmentLifecycle.monthlyMaintenanceReserve +
          scenario.startupCosts.equipmentLifecycle.sparePartsReserveMonthly,
    );
  }

  Money _steadyStateExpectedRevenue(
    FinancialScenario scenario,
    int maximumRoundsPerDay,
  ) {
    final rounds = capacityCalculator.actualRoundsPerDay(
      maximumRoundsPerDay,
      scenario.revenue.occupancy.stable,
    );
    final dailyRevenue = revenueCalculator.dailyRevenue(
      actualRoundsPerDay: rounds,
      pricing: scenario.revenue.pricing,
    );
    return revenueCalculator.monthlyRevenue(
      dailyRevenue: dailyRevenue,
      operatingDaysPerMonth: scenario.revenue.schedule.daysPerMonth,
    );
  }

  Percentage _baseOccupancy(
    FinancialScenario scenario,
    int monthNumber,
    int maximumRoundsPerDay,
  ) {
    final marketing = scenario.marketingAssumptions;
    if (marketing.mode == MarketingForecastMode.marketingDriven &&
        marketing.estimatedRounds > 0 &&
        maximumRoundsPerDay > 0 &&
        scenario.revenue.schedule.daysPerMonth > 0) {
      final maximumMonthlyRounds =
          maximumRoundsPerDay * scenario.revenue.schedule.daysPerMonth;
      final playedRounds = math.min(
        maximumMonthlyRounds,
        marketing.estimatedRounds,
      );
      return Percentage.fromFraction(
        (playedRounds / maximumMonthlyRounds).clamp(0, 1),
      );
    }
    return scenario.revenue.occupancy.occupancyForMonth(monthNumber);
  }
}
