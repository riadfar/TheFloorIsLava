import 'package:equatable/equatable.dart';

import '../../value_objects/percentage.dart';
import 'actuals_ledger.dart';
import 'assumption_status.dart';
import 'debt_assumptions.dart';
import 'funding_assumptions.dart';
import 'investment_assumptions.dart';
import 'marketing_assumptions.dart';
import 'operating_expense_model.dart';
import 'payment_assumptions.dart';
import 'projection_settings.dart';
import 'revenue_model.dart';
import 'scenario_metadata.dart';
import 'sensitivity_settings.dart';
import 'seasonality_model.dart';
import 'staffing_model.dart';
import 'startup_cost_model.dart';
import 'stress_assumptions.dart';
import 'tax_assumptions.dart';
import 'working_capital_model.dart';

/// The complete set of inputs the calculation engine needs.
///
/// A scenario holds *only* assumptions. Nothing derived is stored here: every
/// number a user could compute from these fields is produced by the engine, so
/// the two can never drift apart.
class FinancialScenario extends Equatable {
  const FinancialScenario({
    required this.metadata,
    required this.revenue,
    required this.staffing,
    required this.operatingExpenses,
    required this.startupCosts,
    required this.projection,
    required this.sensitivity,
    this.investmentAssumptions = const InvestmentAssumptions(
      annualDiscountRate: Percentage.fromPercent(10),
    ),
    this.marketingAssumptions = const MarketingAssumptions(),
    this.workingCapital = const WorkingCapitalModel(),
    this.fundingAssumptions = const FundingAssumptions(),
    this.seasonality = const SeasonalityModel(),
    this.stressAssumptions = const StressAssumptions(),
    this.paymentAssumptions = const PaymentAssumptions(),
    this.taxAssumptions = const TaxAssumptions(),
    this.debtAssumptions = const DebtAssumptions(),
    this.actuals = const ActualsLedger(),
    this.annotations = const AssumptionAnnotations(),
  });

  /// Version tag written into every scenario this build produces. A future
  /// change to any formula must introduce a new version rather than reinterpret
  /// scenarios saved under this one.
  static const String currentCalculationModelVersion = 'financial_model_v1';

  final ScenarioMetadata metadata;
  final RevenueModel revenue;
  final StaffingModel staffing;
  final OperatingExpenseModel operatingExpenses;
  final StartupCostModel startupCosts;
  final ProjectionSettings projection;
  final SensitivitySettings sensitivity;
  final InvestmentAssumptions investmentAssumptions;
  final MarketingAssumptions marketingAssumptions;
  final WorkingCapitalModel workingCapital;
  final FundingAssumptions fundingAssumptions;
  final SeasonalityModel seasonality;
  final StressAssumptions stressAssumptions;
  final PaymentAssumptions paymentAssumptions;
  final TaxAssumptions taxAssumptions;
  final DebtAssumptions debtAssumptions;
  final ActualsLedger actuals;

  /// Confidence status per named input.
  final AssumptionAnnotations annotations;

  FinancialScenario copyWith({
    ScenarioMetadata? metadata,
    RevenueModel? revenue,
    StaffingModel? staffing,
    OperatingExpenseModel? operatingExpenses,
    StartupCostModel? startupCosts,
    ProjectionSettings? projection,
    SensitivitySettings? sensitivity,
    InvestmentAssumptions? investmentAssumptions,
    MarketingAssumptions? marketingAssumptions,
    WorkingCapitalModel? workingCapital,
    FundingAssumptions? fundingAssumptions,
    SeasonalityModel? seasonality,
    StressAssumptions? stressAssumptions,
    PaymentAssumptions? paymentAssumptions,
    TaxAssumptions? taxAssumptions,
    DebtAssumptions? debtAssumptions,
    ActualsLedger? actuals,
    AssumptionAnnotations? annotations,
  }) {
    return FinancialScenario(
      metadata: metadata ?? this.metadata,
      revenue: revenue ?? this.revenue,
      staffing: staffing ?? this.staffing,
      operatingExpenses: operatingExpenses ?? this.operatingExpenses,
      startupCosts: startupCosts ?? this.startupCosts,
      projection: projection ?? this.projection,
      sensitivity: sensitivity ?? this.sensitivity,
      investmentAssumptions:
          investmentAssumptions ?? this.investmentAssumptions,
      marketingAssumptions: marketingAssumptions ?? this.marketingAssumptions,
      workingCapital: workingCapital ?? this.workingCapital,
      fundingAssumptions: fundingAssumptions ?? this.fundingAssumptions,
      seasonality: seasonality ?? this.seasonality,
      stressAssumptions: stressAssumptions ?? this.stressAssumptions,
      paymentAssumptions: paymentAssumptions ?? this.paymentAssumptions,
      taxAssumptions: taxAssumptions ?? this.taxAssumptions,
      debtAssumptions: debtAssumptions ?? this.debtAssumptions,
      actuals: actuals ?? this.actuals,
      annotations: annotations ?? this.annotations,
    );
  }

  @override
  List<Object?> get props => [
    metadata,
    revenue,
    staffing,
    operatingExpenses,
    startupCosts,
    projection,
    sensitivity,
    investmentAssumptions,
    marketingAssumptions,
    workingCapital,
    fundingAssumptions,
    seasonality,
    stressAssumptions,
    paymentAssumptions,
    taxAssumptions,
    debtAssumptions,
    actuals,
    annotations,
  ];
}
