import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/entities/results/startup_cost_breakdown.dart';
import '../../domain/entities/scenario/assumption_status.dart';
import '../../domain/entities/scenario/scenario_fields.dart';
import '../../domain/entities/scenario/sensitivity_settings.dart';
import '../../domain/services/metric_explanation_service.dart';
import '../../domain/validation/validation_issue.dart';

/// Wording for the domain's identifiers.
///
/// The domain deals in enums; this is the only place those enums become words.
/// Keeping the mapping here means the calculation engine never carries display
/// text, and a new language is a new ARB file rather than a code change.
extension ModelLabels on AppLocalizations {
  String assumptionLabel(AssumptionKey key) => switch (key) {
    AssumptionKey.roundDuration => fieldRoundDuration,
    AssumptionKey.turnaroundTime => fieldTurnaroundTime,
    AssumptionKey.ticketPrice => fieldTicketPrice,
    AssumptionKey.averagePlayersPerRound => fieldAveragePlayers,
    AssumptionKey.maximumPlayersPerRound => fieldMaximumPlayers,
    AssumptionKey.operatingHoursPerDay => fieldOperatingHours,
    AssumptionKey.operatingDaysPerWeek => fieldOperatingDaysPerWeek,
    AssumptionKey.operatingDaysPerMonth => fieldOperatingDaysPerMonth,
    AssumptionKey.occupancyMonth1 => fieldOccupancyMonth1,
    AssumptionKey.occupancyMonth2 => fieldOccupancyMonth2,
    AssumptionKey.occupancyMonth3 => fieldOccupancyMonth3,
    AssumptionKey.stableOccupancy => fieldStableOccupancy,
    AssumptionKey.initialEmployeeCount => fieldInitialEmployees,
    AssumptionKey.expandedEmployeeCount => fieldExpandedEmployees,
    AssumptionKey.expansionMonth => fieldExpansionMonth,
    AssumptionKey.monthlySalaryPerEmployee => fieldSalary,
    AssumptionKey.monthlyIncentivePerEmployee => fieldIncentive,
    AssumptionKey.rent => fieldRent,
    AssumptionKey.mallSharedServices => fieldMallServices,
    AssumptionKey.electricity => fieldElectricity,
    AssumptionKey.maintenance => fieldMaintenance,
    AssumptionKey.continuousMarketing => fieldMarketing,
    AssumptionKey.mallDeposit => fieldMallDeposit,
    AssumptionKey.contractDurationMonths => fieldContractDuration,
    AssumptionKey.selectedEquipmentPackage => fieldEquipmentPackage,
    AssumptionKey.shippingRate => fieldShippingRate,
    AssumptionKey.customsRate => fieldCustomsRate,
    AssumptionKey.fitOutFurniture => fieldFitOutFurniture,
    AssumptionKey.fitOutPainting => fieldFitOutPainting,
    AssumptionKey.fitOutSignage => fieldFitOutSignage,
    AssumptionKey.fitOutHvac => fieldFitOutHvac,
    AssumptionKey.fitOutInstallationLabour => fieldFitOutLabour,
    AssumptionKey.licensing => fieldLicensing,
    AssumptionKey.openingMarketing => fieldOpeningMarketing,
    AssumptionKey.contingencyRate => fieldContingency,
    AssumptionKey.maximumSetupDays => fieldSetupDays,
    AssumptionKey.projectionMonths => fieldProjectionMonths,
    AssumptionKey.conservativeOccupancy => fieldConservativeOccupancy,
    AssumptionKey.optimisticOccupancy => fieldOptimisticOccupancy,
    AssumptionKey.annualDiscountRate => fieldAnnualDiscountRate,
    AssumptionKey.workingCapitalFixed => fieldWorkingCapitalFixed,
    AssumptionKey.openingDelayBuffer => fieldOpeningDelayBuffer,
    AssumptionKey.criticalFailureStartMonth => fieldCriticalFailureStartMonth,
    AssumptionKey.criticalFailureDowntimeDays =>
      fieldCriticalFailureDowntimeDays,
  };

  /// Extra guidance, where an input genuinely needs it. Most do not.
  String? assumptionHelp(AssumptionKey key) => switch (key) {
    AssumptionKey.turnaroundTime => helpTurnaround,
    AssumptionKey.averagePlayersPerRound => helpAveragePlayers,
    AssumptionKey.maximumPlayersPerRound => helpMaximumPlayers,
    AssumptionKey.operatingDaysPerWeek => helpOperatingDaysPerWeek,
    AssumptionKey.operatingDaysPerMonth => helpOperatingDaysPerMonth,
    AssumptionKey.rent => helpRent,
    AssumptionKey.contractDurationMonths => helpContractDuration,
    AssumptionKey.maximumSetupDays => helpSetupDays,
    AssumptionKey.shippingRate || AssumptionKey.customsRate => helpShipping,
    AssumptionKey.contingencyRate => helpContingency,
    AssumptionKey.annualDiscountRate => helpAnnualDiscountRate,
    AssumptionKey.workingCapitalFixed => helpWorkingCapitalFixed,
    AssumptionKey.criticalFailureStartMonth ||
    AssumptionKey.criticalFailureDowntimeDays => helpCriticalFailure,
    _ => null,
  };

  String assumptionStatusLabel(AssumptionStatus status) => switch (status) {
    AssumptionStatus.estimated => statusEstimated,
    AssumptionStatus.verified => statusVerified,
    AssumptionStatus.confirmed => statusConfirmed,
    AssumptionStatus.userDefined => statusUserDefined,
    AssumptionStatus.imported => statusImported,
  };

  /// The suffix shown after a value, e.g. "min" or "%".
  String? unitLabel(FieldUnit unit) => switch (unit) {
    FieldUnit.money => null,
    FieldUnit.percent => unitPercent,
    FieldUnit.minutes => unitMinutes,
    FieldUnit.hours => unitHours,
    FieldUnit.days => unitDays,
    FieldUnit.months => unitMonths,
    FieldUnit.count => unitPeople,
    FieldUnit.players => unitPlayers,
  };

  String validationMessage(ValidationIssue issue, String Function(num) format) {
    final limit = issue.limit == null ? '' : format(issue.limit!);
    return switch (issue.code) {
      ValidationCode.mustBeGreaterThan => validationMustBeGreaterThan(limit),
      ValidationCode.mustBeAtLeast => validationMustBeAtLeast(limit),
      ValidationCode.mustNotExceed => validationMustNotExceed(limit),
      ValidationCode.averagePlayersExceedCapacity =>
        validationPlayersExceedCapacity(limit),
      ValidationCode.roundTimeNotPositive => validationRoundTimeNotPositive,
      ValidationCode.contingencyAboveOneHundredPercent =>
        validationContingencyAboveHundred,
      ValidationCode.optimisticOccupancyBelowBase =>
        validationOptimisticBelowBase(limit),
      ValidationCode.conservativeOccupancyAboveBase =>
        validationConservativeAboveBase(limit),
      ValidationCode.expandedHeadcountBelowInitial =>
        validationExpandedBelowInitial,
    };
  }

  String metricTitle(MetricId metric) => switch (metric) {
    MetricId.maximumRoundsPerDay => termMaximumRounds,
    MetricId.actualRoundsPerDay => termActualRounds,
    MetricId.dailyRevenue => termDailyRevenue,
    MetricId.monthlyRevenue => termMonthlyRevenue,
    MetricId.payroll => termPayroll,
    MetricId.totalOperatingExpenses => termTotalExpenses,
    MetricId.operatingProfit => termOperatingProfit,
    MetricId.profitMargin => termProfitMargin,
    MetricId.deliveredEquipment => termDeliveredEquipment,
    MetricId.contingency => termContingency,
    MetricId.initialInvestment => termInitialInvestment,
    MetricId.cumulativeCashFlow => termCumulativeCashFlow,
    MetricId.yearOneProfit => termYearOneProfit,
    MetricId.yearOneRoi => metricYearOneRoi,
    MetricId.payback => metricPayback,
  };

  String metricFormula(MetricId metric) => switch (metric) {
    MetricId.maximumRoundsPerDay => formulaMaximumRounds,
    MetricId.actualRoundsPerDay => formulaActualRounds,
    MetricId.dailyRevenue => formulaDailyRevenue,
    MetricId.monthlyRevenue => formulaMonthlyRevenue,
    MetricId.payroll => formulaPayroll,
    MetricId.totalOperatingExpenses => formulaTotalExpenses,
    MetricId.operatingProfit => formulaOperatingProfit,
    MetricId.profitMargin => formulaProfitMargin,
    MetricId.deliveredEquipment => formulaDeliveredEquipment,
    MetricId.contingency => formulaContingency,
    MetricId.initialInvestment => formulaInitialInvestment,
    MetricId.cumulativeCashFlow => formulaCumulativeCashFlow,
    MetricId.yearOneProfit => formulaYearOneProfit,
    MetricId.yearOneRoi => formulaYearOneRoi,
    MetricId.payback => formulaPayback,
  };

  String operandLabel(OperandId operand) => switch (operand) {
    OperandId.roundDuration => fieldRoundDuration,
    OperandId.turnaroundTime => fieldTurnaroundTime,
    OperandId.totalRoundTime => termTotalRoundTime,
    OperandId.operatingHoursPerDay => fieldOperatingHours,
    OperandId.operatingMinutesPerDay => termOperatingMinutes,
    OperandId.maximumRoundsPerDay => termMaximumRounds,
    OperandId.occupancy => termOccupancy,
    OperandId.actualRoundsPerDay => termActualRounds,
    OperandId.averagePlayersPerRound => fieldAveragePlayers,
    OperandId.ticketPrice => fieldTicketPrice,
    OperandId.dailyRevenue => termDailyRevenue,
    OperandId.operatingDaysPerMonth => fieldOperatingDaysPerMonth,
    OperandId.monthlyRevenue => termMonthlyRevenue,
    OperandId.employeeCount => termEmployees,
    OperandId.salaryPerEmployee => fieldSalary,
    OperandId.incentivePerEmployee => fieldIncentive,
    OperandId.costPerEmployee => termCostPerEmployee,
    OperandId.payroll => termPayroll,
    OperandId.otherOperatingExpenses => termOtherExpenses,
    OperandId.totalOperatingExpenses => termTotalExpenses,
    OperandId.operatingProfit => termOperatingProfit,
    OperandId.equipmentCost => termEquipment,
    OperandId.shippingRate => fieldShippingRate,
    OperandId.shipping => termShipping,
    OperandId.customsRate => fieldCustomsRate,
    OperandId.customs => termCustoms,
    OperandId.deliveredEquipment => termDeliveredEquipment,
    OperandId.fitOutTotal => termFitOut,
    OperandId.propertyTotal => termProperty,
    OperandId.preOpeningTotal => termPreOpening,
    OperandId.startupSubtotal => termSubtotal,
    OperandId.contingencyRate => fieldContingency,
    OperandId.contingency => termContingency,
    OperandId.initialInvestment => termInitialInvestment,
    OperandId.previousCumulativeCashFlow => termPreviousCumulativeCashFlow,
    OperandId.netCashFlow => termNetCashFlow,
    OperandId.cumulativeCashFlow => termCumulativeCashFlow,
    OperandId.yearOneProfit => termYearOneProfit,
    OperandId.lastNegativeMonth => termLastNegativeMonth,
    OperandId.shortfallAtLastNegativeMonth => termShortfall,
  };

  String startupGroupLabel(StartupCostGroupId group) => switch (group) {
    StartupCostGroupId.deliveredEquipment => startupGroupEquipment,
    StartupCostGroupId.fitOut => startupGroupFitOut,
    StartupCostGroupId.property => startupGroupProperty,
    StartupCostGroupId.preOpening => startupGroupPreOpening,
  };

  /// [customLabel] is used for user-created lines, which carry their own name.
  String startupLineLabel(StartupCostLine line) => switch (line.id) {
    StartupCostLineId.equipment => termEquipment,
    StartupCostLineId.shipping => termShipping,
    StartupCostLineId.customs => termCustoms,
    StartupCostLineId.fitOutFurniture => fieldFitOutFurniture,
    StartupCostLineId.fitOutPainting => fieldFitOutPainting,
    StartupCostLineId.fitOutSignage => fieldFitOutSignage,
    StartupCostLineId.fitOutHvac => fieldFitOutHvac,
    StartupCostLineId.fitOutInstallationLabour => fieldFitOutLabour,
    StartupCostLineId.mallDeposit => termMallDeposit,
    StartupCostLineId.firstMonthRent => termFirstMonthRent,
    StartupCostLineId.licensing => termLicensing,
    StartupCostLineId.openingMarketing => termOpeningMarketing,
    StartupCostLineId.custom => line.customLabel ?? calculatedValue,
  };

  String sensitivityScenarioLabel(SensitivityScenarioDefinition definition) =>
      switch (definition.kind) {
        SensitivityScenarioKind.conservative => scenarioConservative,
        SensitivityScenarioKind.base => scenarioBase,
        SensitivityScenarioKind.optimistic => scenarioOptimistic,
        SensitivityScenarioKind.custom =>
          definition.customName ?? scenarioCustom,
      };
}
