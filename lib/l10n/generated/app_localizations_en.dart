// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Floor is Lava';

  @override
  String get appSubtitle => 'Financial feasibility model';

  @override
  String get navDashboard => 'Dashboard';

  @override
  String get navAssumptions => 'Assumptions';

  @override
  String get navStaffing => 'Staffing';

  @override
  String get navSeasonality => 'Seasonality';

  @override
  String get navProjection => 'Projection';

  @override
  String get navStartup => 'Start-up costs';

  @override
  String get navSensitivity => 'Sensitivity';

  @override
  String get navScenarios => 'Scenarios';

  @override
  String get navSettings => 'Settings';

  @override
  String get dashboardTitle => 'Dashboard';

  @override
  String get assumptionsTitle => 'Assumptions';

  @override
  String get staffingTitle => 'Staffing roster';

  @override
  String get seasonalityTitle => 'Seasonality';

  @override
  String get projectionTitle => 'Monthly projection';

  @override
  String get startupTitle => 'Start-up costs';

  @override
  String get sensitivityTitle => 'Sensitivity';

  @override
  String get scenariosTitle => 'Scenarios';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get loading => 'Loading';

  @override
  String get close => 'Close';

  @override
  String get cancel => 'Cancel';

  @override
  String get reset => 'Reset';

  @override
  String get save => 'Save';

  @override
  String get done => 'Done';

  @override
  String get notAvailable => 'N/A';

  @override
  String get howIsThisCalculated => 'How is this calculated?';

  @override
  String get calculationTitle => 'How this is calculated';

  @override
  String get formulaLabel => 'Formula';

  @override
  String get inputsLabel => 'Values used';

  @override
  String get resultLabel => 'Result';

  @override
  String normalMonth(int month) {
    return 'A normal month (month $month)';
  }

  @override
  String monthLabel(int month) {
    return 'Month $month';
  }

  @override
  String get monthZeroLabel => 'Month 0 - investment';

  @override
  String monthShort(int month) {
    return 'M$month';
  }

  @override
  String yearLabel(int year) {
    return 'Year $year';
  }

  @override
  String yearPartial(int year) {
    return 'Year $year (partial)';
  }

  @override
  String get metricInitialInvestment => 'Initial investment';

  @override
  String get metricMonthlyRevenue => 'Monthly revenue';

  @override
  String get metricMonthlyExpenses => 'Monthly expenses';

  @override
  String get metricMonthlyProfit => 'Monthly profit';

  @override
  String get metricProfitMargin => 'Profit margin';

  @override
  String get metricPayback => 'Payback';

  @override
  String get metricYearOneProfit => 'Year-1 profit';

  @override
  String get metricYearTwoProfit => 'Year-2 profit';

  @override
  String get metricYearOneRoi => 'Year-1 ROI';

  @override
  String get metricOccupancy => 'Stable occupancy';

  @override
  String get metricRoundsPerDay => 'Rounds per day';

  @override
  String get metricNpv => 'Net present value (NPV)';

  @override
  String get metricIrr => 'Internal rate of return (IRR)';

  @override
  String get metricDiscountedPayback => 'Discounted payback';

  @override
  String get metricBreakEvenOccupancy => 'Break-even occupancy';

  @override
  String get metricBreakEvenRevenue => 'Break-even revenue';

  @override
  String get metricRequiredFunding => 'Required funding';

  @override
  String get metricFundingGap => 'Funding gap';

  @override
  String get metricMinimumCash => 'Minimum cash balance';

  @override
  String get metricWorkingCapital => 'Working capital';

  @override
  String get irrUnavailable =>
      'IRR is unavailable because cash flows do not produce a unique result.';

  @override
  String get metricUnavailable => 'Unavailable for the current assumptions.';

  @override
  String get roiStudyDefinition =>
      'Year-1 profit divided by the initial investment, as the original study defines it.';

  @override
  String paybackDuringMonth(int month) {
    return 'During month $month';
  }

  @override
  String get paybackNotRecovered => 'Not recovered';

  @override
  String paybackNotRecoveredWithin(int months) {
    return 'Not recovered within $months months';
  }

  @override
  String paybackPrecise(String months) {
    return '$months months (interpolated)';
  }

  @override
  String paybackLastNegative(int month) {
    return 'Last month in deficit: month $month';
  }

  @override
  String paybackFirstPositive(int month) {
    return 'First month in surplus: month $month';
  }

  @override
  String get chartRevenueTitle => 'Monthly revenue';

  @override
  String get chartRevenueSubtitle => 'Revenue for each trading month';

  @override
  String get chartCashFlowTitle => 'Cumulative cash flow';

  @override
  String get chartCashFlowSubtitle => 'Investment recovery over time';

  @override
  String get chartBreakEvenLine => 'Break-even';

  @override
  String get chartNoData => 'Nothing to plot yet';

  @override
  String get sectionSessionPricing => 'Session and pricing';

  @override
  String get sectionOccupancy => 'Occupancy';

  @override
  String get sectionStaffing => 'Staffing';

  @override
  String get sectionOperatingExpenses => 'Monthly operating expenses';

  @override
  String get sectionProperty => 'Property';

  @override
  String get sectionEquipment => 'Equipment';

  @override
  String get sectionFitOut => 'Fit-out';

  @override
  String get sectionPreOpening => 'Pre-opening';

  @override
  String get sectionProjection => 'Projection';

  @override
  String get sectionSensitivityInputs => 'Sensitivity cases';

  @override
  String get fieldRoundDuration => 'Round duration';

  @override
  String get fieldTurnaroundTime => 'Turnaround time';

  @override
  String get fieldTicketPrice => 'Ticket price per player';

  @override
  String get fieldAveragePlayers => 'Average players per round';

  @override
  String get fieldMaximumPlayers => 'Maximum players per round';

  @override
  String get fieldOperatingHours => 'Operating hours per day';

  @override
  String get fieldOperatingDaysPerWeek => 'Operating days per week';

  @override
  String get fieldOperatingDaysPerMonth => 'Operating days per month';

  @override
  String get fieldOccupancyMonth1 => 'Month 1 occupancy';

  @override
  String get fieldOccupancyMonth2 => 'Month 2 occupancy';

  @override
  String get fieldOccupancyMonth3 => 'Month 3 occupancy';

  @override
  String get fieldStableOccupancy => 'Stable occupancy (month 4 onwards)';

  @override
  String get fieldInitialEmployees => 'Starting headcount';

  @override
  String get fieldExpandedEmployees => 'Expanded headcount';

  @override
  String get fieldExpansionMonth => 'Expansion begins in month';

  @override
  String get fieldSalary => 'Monthly salary per employee';

  @override
  String get fieldIncentive => 'Monthly incentive per employee';

  @override
  String get fieldRent => 'Rent';

  @override
  String get fieldMallServices => 'Mall shared services';

  @override
  String get fieldElectricity => 'Electricity';

  @override
  String get fieldMaintenance => 'Maintenance and consumables';

  @override
  String get fieldMarketing => 'Continuous marketing';

  @override
  String get fieldMallDeposit => 'Mall deposit / key money';

  @override
  String get fieldContractDuration => 'Contract duration';

  @override
  String get fieldEquipmentPackage => 'Equipment package';

  @override
  String get fieldShippingRate => 'Sea freight rate';

  @override
  String get fieldCustomsRate => 'Customs and clearance rate';

  @override
  String get fieldFitOutFurniture => 'Reception and cashier furniture';

  @override
  String get fieldFitOutPainting => 'Painting and wall graphics';

  @override
  String get fieldFitOutSignage => 'Signage';

  @override
  String get fieldFitOutHvac => 'HVAC';

  @override
  String get fieldFitOutLabour => 'Installation labour';

  @override
  String get fieldLicensing => 'Registration and licensing';

  @override
  String get fieldOpeningMarketing => 'Opening marketing campaign';

  @override
  String get fieldContingency => 'Contingency';

  @override
  String get fieldSetupDays => 'Maximum setup days after arrival';

  @override
  String get fieldProjectionMonths => 'Projection length';

  @override
  String get fieldConservativeOccupancy => 'Conservative occupancy';

  @override
  String get fieldOptimisticOccupancy => 'Optimistic occupancy';

  @override
  String get helpTurnaround =>
      'Reset time between rounds. It consumes trading time even though it is not sold.';

  @override
  String get helpAveragePlayers =>
      'An average, so a fractional value is expected. It cannot exceed the room\'s capacity.';

  @override
  String get helpOperatingDaysPerWeek =>
      'Recorded for planning. The monthly total below is what drives revenue.';

  @override
  String get helpOperatingDaysPerMonth =>
      'Trading days in an average month. The study uses 30.4.';

  @override
  String get helpOccupancy =>
      'The share of available rounds that actually sell. This is the single most influential assumption in the model.';

  @override
  String get helpRent =>
      'Also charged once as the first month\'s rent inside the start-up property cost, exactly as the original study does.';

  @override
  String get helpMaximumPlayers =>
      'The physical capacity of the room. It caps the average, but does not itself drive revenue.';

  @override
  String get helpContractDuration =>
      'Recorded for planning. It does not enter any formula in this model.';

  @override
  String get helpSetupDays =>
      'Recorded for planning. It does not enter any formula in this model.';

  @override
  String get helpShipping =>
      'Applied to the value of the selected equipment package.';

  @override
  String get helpContingency =>
      'A buffer applied to the whole start-up subtotal.';

  @override
  String get helpSensitivity =>
      'Each case reprices a normal month at a different occupancy, using the steady-state cost base.';

  @override
  String get calculatedShipping => 'Calculated freight';

  @override
  String get calculatedCustoms => 'Calculated customs';

  @override
  String get calculatedValue => 'Calculated';

  @override
  String get editableValue => 'Editable';

  @override
  String get unitMinutes => 'min';

  @override
  String get unitHours => 'h';

  @override
  String get unitDays => 'days';

  @override
  String get unitMonths => 'months';

  @override
  String get unitPercent => '%';

  @override
  String get unitPlayers => 'players';

  @override
  String get unitPeople => 'people';

  @override
  String get perMonth => '/ month';

  @override
  String get perDay => '/ day';

  @override
  String get perRound => '/ round';

  @override
  String get statusEstimated => 'Estimated';

  @override
  String get statusVerified => 'Verified';

  @override
  String get statusConfirmed => 'Confirmed';

  @override
  String get statusUserDefined => 'User-defined';

  @override
  String get statusImported => 'Imported';

  @override
  String get statusEstimatedHint => 'Estimated - verify before relying on it';

  @override
  String get statusSectionTitle => 'Confidence';

  @override
  String assumptionStatusChanged(String status) {
    return 'Marked as $status';
  }

  @override
  String validationMustBeGreaterThan(String limit) {
    return 'Must be greater than $limit';
  }

  @override
  String validationMustBeAtLeast(String limit) {
    return 'Must be at least $limit';
  }

  @override
  String validationMustNotExceed(String limit) {
    return 'Must not exceed $limit';
  }

  @override
  String validationPlayersExceedCapacity(String limit) {
    return 'Cannot exceed the room capacity of $limit';
  }

  @override
  String get validationRoundTimeNotPositive =>
      'A round and its turnaround must take some time';

  @override
  String get validationContingencyAboveHundred =>
      'A contingency above 100% doubles the project cost. Check this figure.';

  @override
  String validationOptimisticBelowBase(String limit) {
    return 'This optimistic case is below the stable occupancy of $limit%. The original study has the same inconsistency.';
  }

  @override
  String validationConservativeAboveBase(String limit) {
    return 'The conservative case is above the stable occupancy of $limit%.';
  }

  @override
  String get validationExpandedBelowInitial =>
      'The expanded headcount is smaller than the starting one.';

  @override
  String get validationNotANumber => 'Enter a number';

  @override
  String validationSummaryErrors(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count inputs need attention',
      one: '1 input needs attention',
    );
    return '$_temp0';
  }

  @override
  String validationSummaryWarnings(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count assumptions are worth checking',
      one: '1 assumption is worth checking',
    );
    return '$_temp0';
  }

  @override
  String get validationBlocksSaving =>
      'Changes are not saved while an input is invalid.';

  @override
  String get termTotalRoundTime => 'Total round time';

  @override
  String get termOperatingMinutes => 'Trading minutes per day';

  @override
  String get termMaximumRounds => 'Maximum rounds';

  @override
  String get termActualRounds => 'Actual rounds';

  @override
  String get termOccupancy => 'Occupancy';

  @override
  String get termDailyRevenue => 'Daily revenue';

  @override
  String get termMonthlyRevenue => 'Monthly revenue';

  @override
  String get termCumulativeRevenue => 'Cumulative revenue';

  @override
  String get termEmployees => 'Employees';

  @override
  String get termCostPerEmployee => 'Cost per employee';

  @override
  String get termPayroll => 'Payroll';

  @override
  String get termOtherExpenses => 'Other expenses';

  @override
  String get termTotalExpenses => 'Total expenses';

  @override
  String get termOperatingProfit => 'Operating profit';

  @override
  String get termProfitMargin => 'Profit margin';

  @override
  String get termNetCashFlow => 'Net cash flow';

  @override
  String get termCumulativeCashFlow => 'Cumulative cash flow';

  @override
  String get termPreviousCumulativeCashFlow => 'Previous cumulative cash flow';

  @override
  String get termEquipment => 'Equipment';

  @override
  String get termShipping => 'Sea freight';

  @override
  String get termCustoms => 'Customs and clearance';

  @override
  String get termDeliveredEquipment => 'Delivered equipment';

  @override
  String get termFitOut => 'Fit-out';

  @override
  String get termProperty => 'Property';

  @override
  String get termPreOpening => 'Pre-opening';

  @override
  String get termSubtotal => 'Subtotal';

  @override
  String get termContingency => 'Contingency';

  @override
  String get termInitialInvestment => 'Initial investment';

  @override
  String get termYearOneProfit => 'Year-1 profit';

  @override
  String get termLastNegativeMonth => 'Last month in deficit';

  @override
  String get termShortfall => 'Amount still to recover';

  @override
  String get termMonth => 'Month';

  @override
  String get termFirstMonthRent => 'First month\'s rent';

  @override
  String get termMallDeposit => 'Mall deposit';

  @override
  String get termLicensing => 'Registration and licensing';

  @override
  String get termOpeningMarketing => 'Opening campaign';

  @override
  String get formulaMaximumRounds =>
      'floor(trading minutes per day / total round time)';

  @override
  String get formulaActualRounds => 'maximum rounds x occupancy';

  @override
  String get formulaDailyRevenue =>
      'actual rounds x average players x ticket price';

  @override
  String get formulaMonthlyRevenue => 'daily revenue x trading days per month';

  @override
  String get formulaPayroll => 'employees x (salary + incentive)';

  @override
  String get formulaTotalExpenses =>
      'payroll + rent + mall services + electricity + maintenance + marketing';

  @override
  String get formulaOperatingProfit =>
      'monthly revenue - total operating expenses';

  @override
  String get formulaProfitMargin => 'operating profit / monthly revenue';

  @override
  String get formulaDeliveredEquipment => 'equipment + freight + customs';

  @override
  String get formulaContingency => 'start-up subtotal x contingency rate';

  @override
  String get formulaInitialInvestment =>
      'delivered equipment + fit-out + property + pre-opening + contingency';

  @override
  String get formulaCumulativeCashFlow =>
      'previous cumulative cash flow + net cash flow';

  @override
  String get formulaYearOneProfit => 'sum of operating profit, months 1 to 12';

  @override
  String get formulaYearOneRoi => 'year-1 profit / initial investment';

  @override
  String get formulaPayback =>
      'last month in deficit + (amount still to recover / that month\'s net cash flow)';

  @override
  String get projectionTableTitle => 'Monthly projection';

  @override
  String projectionShowsMonths(int count) {
    return 'Month 0 plus $count trading months';
  }

  @override
  String get projectionInvestmentRow => 'Initial investment paid';

  @override
  String get projectionExpandHint => 'Tap a month for its full breakdown';

  @override
  String get columnMonth => 'Month';

  @override
  String get startupGroupEquipment => 'Delivered equipment';

  @override
  String get startupGroupFitOut => 'Fit-out';

  @override
  String get startupGroupProperty => 'Property';

  @override
  String get startupGroupPreOpening => 'Pre-opening';

  @override
  String get startupTotal => 'Total initial investment';

  @override
  String get startupExpandHint => 'Tap a group to see what it contains';

  @override
  String startupContingencyAt(String rate) {
    return 'Contingency at $rate';
  }

  @override
  String get scenarioConservative => 'Conservative';

  @override
  String get scenarioBase => 'Base';

  @override
  String get scenarioOptimistic => 'Optimistic';

  @override
  String get scenarioCustom => 'Custom';

  @override
  String get scenarioBaseTracksStable =>
      'Tracks the scenario\'s stable occupancy';

  @override
  String get sensitivityApproxPayback => 'Approximate payback';

  @override
  String get sensitivityNotRecoverable => 'Not recoverable under this case';

  @override
  String sensitivityMonths(String months) {
    return '$months months';
  }

  @override
  String sensitivityCostBaseNote(String expenses) {
    return 'Every case is priced at the steady-state cost base of $expenses per month.';
  }

  @override
  String get scenariosSubtitle =>
      'Create, switch, duplicate, and compare complete financial models.';

  @override
  String get scenariosCreateBase => 'New from Base';

  @override
  String get scenariosCreateWorst => 'New Worst Case';

  @override
  String get scenariosSaved => 'Saved scenarios';

  @override
  String get scenariosCompare => 'Compare scenarios';

  @override
  String get scenariosCompareHint => 'Select 2 to 4 scenarios above.';

  @override
  String get scenariosCompareSelected => 'Compare selected';

  @override
  String get scenariosComparisonTitle => 'Scenario comparison';

  @override
  String scenariosUpdated(String date) {
    return 'Updated $date';
  }

  @override
  String get scenariosDuplicate => 'Duplicate';

  @override
  String get scenariosDelete => 'Delete';

  @override
  String get scenariosDeleteTitle => 'Delete scenario?';

  @override
  String scenariosDeleteBody(String name) {
    return 'Delete “$name”? This cannot be undone.';
  }

  @override
  String get scenariosResetBuiltinBody =>
      'Base is recoverable and cannot be removed. Reset it to the original study values?';

  @override
  String get scenariosMetric => 'Metric';

  @override
  String get settingsScenario => 'Scenario';

  @override
  String get settingsScenarioName => 'Name';

  @override
  String get settingsCurrency => 'Currency';

  @override
  String get settingsDecimalPrecision => 'Decimal places';

  @override
  String get settingsAppearance => 'Appearance';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get settingsThemeSystem => 'Follow system';

  @override
  String get settingsThemeLight => 'Light';

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsLanguageSystem => 'Follow system';

  @override
  String get settingsLanguageEnglish => 'English';

  @override
  String get settingsLanguageArabic => 'Arabic';

  @override
  String get settingsData => 'Data';

  @override
  String get settingsAutosaveNote =>
      'Changes are saved on this device automatically.';

  @override
  String get settingsExportScenario => 'Copy scenario (JSON)';

  @override
  String get settingsScenarioExported =>
      'Scenario JSON copied to the clipboard';

  @override
  String get settingsExportProjection =>
      'Copy projection (Excel-compatible CSV)';

  @override
  String get settingsProjectionExported =>
      'Projection CSV copied to the clipboard';

  @override
  String get settingsImportScenario => 'Import scenario (JSON)';

  @override
  String get settingsImportJsonHint =>
      'Paste a scenario JSON export below, then choose whether to create a new scenario or replace the active one.';

  @override
  String get settingsScenarioJson => 'Scenario JSON';

  @override
  String get settingsImportCreateNew => 'Create a new scenario';

  @override
  String get settingsImportReplace => 'Replace the active scenario';

  @override
  String get settingsImportAction => 'Import';

  @override
  String get settingsScenarioImported => 'Scenario imported successfully';

  @override
  String get settingsResetScenario => 'Reset to the study baseline';

  @override
  String get settingsResetDescription =>
      'Discards every change and restores the original figures.';

  @override
  String get settingsResetConfirmTitle => 'Reset the scenario?';

  @override
  String get settingsResetConfirmBody =>
      'Every change you have made will be discarded and the original study values restored. This cannot be undone.';

  @override
  String get settingsResetDone => 'Scenario reset to the study baseline';

  @override
  String get settingsAbout => 'About';

  @override
  String get settingsCalculationModel => 'Calculation model';

  @override
  String get settingsAboutBody =>
      'An interactive version of the Floor is Lava feasibility study. Every figure on screen is derived from the assumptions you can edit.';

  @override
  String get equipmentSelected => 'Selected';

  @override
  String get equipmentSelect => 'Use this package';

  @override
  String get equipmentCostLabel => 'Package cost';

  @override
  String get errorStorageUnavailable =>
      'Changes could not be saved on this device.';

  @override
  String get errorStorageCorrupted =>
      'The saved scenario could not be read, so the study baseline was loaded.';

  @override
  String get errorStorageUnsupported =>
      'The saved scenario was created by a newer version of the app.';

  @override
  String get errorImportInvalid => 'The pasted JSON is not a valid scenario.';

  @override
  String get errorGeneric => 'Something went wrong.';

  @override
  String get assumptionsIntro =>
      'Every figure in this app is derived from the values below. Change one and everything downstream recalculates.';

  @override
  String get staffingReferenceTitle => 'Recorded in the workbook';

  @override
  String get staffingReferenceBody =>
      'The source workbook also records staffing phases and weekly hours (employee 1: 54 h, employee 2: 42 h, founders: 13 h). Their definition is not stated, so they are kept here for reference and do not enter any calculation.';

  @override
  String get calculatedSectionTitle => 'Derived from these inputs';

  @override
  String get noResultsYet => 'No results yet';

  @override
  String get sectionInvestment => 'Investment analysis';

  @override
  String get sectionFunding => 'Working capital and funding';

  @override
  String get sectionStress => 'Stress / critical failure';

  @override
  String get fieldAnnualDiscountRate => 'Annual discount rate';

  @override
  String get fieldWorkingCapitalFixed => 'Working capital reserve';

  @override
  String get fieldOpeningDelayBuffer => 'Opening delay buffer';

  @override
  String get fieldCriticalFailureStartMonth => 'Critical failure start month';

  @override
  String get fieldCriticalFailureDowntimeDays =>
      'Critical failure downtime days';

  @override
  String get helpAnnualDiscountRate =>
      'Used for NPV and discounted payback. Monthly discounting uses this annual rate divided by 12.';

  @override
  String get helpWorkingCapitalFixed =>
      'Cash reserve held in addition to the start-up investment. Required funding is investment plus this reserve plus any opening delay buffer.';

  @override
  String get helpCriticalFailure =>
      'Critical failure is off in the base case. These fields configure a stress event.';

  @override
  String get enableCriticalFailure => 'Enable critical failure';

  @override
  String get additionalExpenses => 'Custom monthly expenses';

  @override
  String get addExpense => 'Add expense';

  @override
  String get removeExpense => 'Remove expense';

  @override
  String get noAdditionalExpenses => 'No custom expenses';

  @override
  String get expenseName => 'Expense name';

  @override
  String get monthlyAmount => 'Monthly amount';

  @override
  String get employeeRoster => 'Employee roster';

  @override
  String get addEmployee => 'Add employee';

  @override
  String get editEmployee => 'Edit employee';

  @override
  String get deleteEmployee => 'Delete employee';

  @override
  String get noEmployees => 'No roster employees yet';

  @override
  String get employeeName => 'Employee name';

  @override
  String get founder => 'Founder (unpaid)';

  @override
  String get fixedMonthlySalary => 'Fixed monthly salary (optional)';

  @override
  String get weeklyShifts => 'Weekly shifts';

  @override
  String get shifts => 'shifts';

  @override
  String get addShift => 'Add shift';

  @override
  String get weekday => 'Weekday';

  @override
  String get startHour => 'Start hour';

  @override
  String get endHour => 'End hour';

  @override
  String get breakHours => 'Break hours';

  @override
  String get monday => 'Monday';

  @override
  String get tuesday => 'Tuesday';

  @override
  String get wednesday => 'Wednesday';

  @override
  String get thursday => 'Thursday';

  @override
  String get friday => 'Friday';

  @override
  String get saturday => 'Saturday';

  @override
  String get sunday => 'Sunday';

  @override
  String get payrollConfiguration => 'Payroll configuration';

  @override
  String get payrollMode => 'Payroll mode';

  @override
  String get payrollFixed => 'Fixed per employee';

  @override
  String get payrollProportional => 'Proportional to hours';

  @override
  String get sharedPayrollBudget => 'Shared monthly payroll budget';

  @override
  String get overtimeMultiplier => 'Overtime multiplier';

  @override
  String get regularHoursCap => 'Regular monthly hours cap (optional)';

  @override
  String get bonusConfiguration => 'Bonus configuration';

  @override
  String get bonusMode => 'Bonus mode';

  @override
  String get bonusDisabled => 'Disabled';

  @override
  String get bonusExcessRevenue => 'Percentage of excess revenue';

  @override
  String get bonusFixedThreshold => 'Fixed amount at threshold';

  @override
  String get revenueTarget => 'Revenue target';

  @override
  String get thresholdMultiplier => 'Threshold multiplier (percent points)';

  @override
  String get percentageOfExcess => 'Percentage of excess';

  @override
  String get fixedBonusAmount => 'Fixed bonus amount';

  @override
  String get seasonalityNotice =>
      'Base occupancy still comes from the occupancy schedule. These factors multiply it only when seasonality is enabled.';

  @override
  String get seasonalityDemand => 'Demand factors';

  @override
  String get enableSeasonality => 'Enable seasonality';

  @override
  String get weatherFactor => 'Weather demand factor';

  @override
  String get marketingFactor => 'Marketing demand factor';

  @override
  String get monthFactors => 'Month factors';

  @override
  String get dayFactors => 'Day-of-week factors';

  @override
  String get seasonalityEvents => 'Calendar events';

  @override
  String get addEvent => 'Add event';

  @override
  String get editEvent => 'Edit event';

  @override
  String get noEvents => 'No calendar events';

  @override
  String get eventName => 'Event name';

  @override
  String get startMonth => 'Start month';

  @override
  String get endMonth => 'End month';

  @override
  String get demandFactor => 'Demand factor';

  @override
  String get active => 'Active';

  @override
  String get forecastingMode => 'Forecasting mode';

  @override
  String get forecastingModeOccupancy => 'Occupancy-driven';

  @override
  String get forecastingModeMarketing => 'Marketing-driven';

  @override
  String get marketingForecastHint =>
      'Marketing-driven mode replaces the occupancy schedule when its inputs produce demand. Seasonality still multiplies the resulting occupancy; zero demand inputs fall back to the occupancy schedule.';

  @override
  String get monthlyMarketingBudget => 'Monthly marketing budget';

  @override
  String get marketingReach => 'People reached per month';

  @override
  String get marketingConversionRate => 'Conversion rate';

  @override
  String get averageRoundsPerCustomer =>
      'Average rounds per converted customer';

  @override
  String get useWeeklyOperatingHours => 'Use weekly operating hours';

  @override
  String get weeklyOperatingHoursHint =>
      'Set hours for each day. Thursday, Friday, and Saturday can be longer.';

  @override
  String get equipmentLifecycle => 'Equipment lifecycle';

  @override
  String get equipmentLifecycleHint =>
      'Plan reserves and an optional replacement; this does not predict forced equipment failure.';

  @override
  String get usefulLifeMonths => 'Useful life';

  @override
  String get replacementCost => 'Planned replacement cost';

  @override
  String get replacementCostHint =>
      'Leave at zero to use the currently selected package cost.';

  @override
  String get monthlyMaintenanceReserve => 'Monthly maintenance reserve';

  @override
  String get sparePartsReserve => 'Monthly spare-parts reserve';

  @override
  String get includePlannedReplacement =>
      'Include planned replacement in projection';

  @override
  String get plannedReplacementHint =>
      'Adds a one-time investment outflow at the rounded useful-life month.';

  @override
  String get navActuals => 'Actuals';

  @override
  String get actualsTitle => 'Actual vs forecast';

  @override
  String get actualsIntro =>
      'Enter recorded results for trading months. Variance is actual minus forecast. Months without actuals stay blank.';

  @override
  String get actualsAddMonth => 'Add month actuals';

  @override
  String actualsEditMonth(Object month) {
    return 'Edit month $month';
  }

  @override
  String get actualsRevenue => 'Actual revenue';

  @override
  String get actualsExpenses => 'Actual operating expenses';

  @override
  String get actualsClearAll => 'Clear all actuals';

  @override
  String get actualsClearMonth => 'Remove';

  @override
  String get actualsEmpty => 'No actuals recorded yet.';

  @override
  String get actualsVariance => 'Variance';

  @override
  String get actualsForecast => 'Forecast';

  @override
  String get actualsActual => 'Actual';

  @override
  String get sectionDebt => 'Debt financing';

  @override
  String get enableDebt => 'Include debt financing';

  @override
  String get fieldDebtPrincipal => 'Loan principal';

  @override
  String get fieldDebtInterestRate => 'Annual interest rate';

  @override
  String get fieldDebtTermMonths => 'Term (months)';

  @override
  String get fieldDebtFirstPaymentMonth => 'First payment month';

  @override
  String get fieldDebtDisbursementMonth => 'Disbursement month';

  @override
  String get fieldDebtKind => 'Amortization';

  @override
  String get debtKindAnnuity => 'Annuity (amortizing)';

  @override
  String get debtKindInterestOnly => 'Interest-only (balloon principal)';

  @override
  String get debtHelp =>
      'Debt service changes cash flow, not operating profit. Disabled by default so the study baseline is unchanged.';
}
