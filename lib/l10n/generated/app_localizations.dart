import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Floor is Lava'**
  String get appTitle;

  /// No description provided for @appSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Financial feasibility model'**
  String get appSubtitle;

  /// No description provided for @navDashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get navDashboard;

  /// No description provided for @navAssumptions.
  ///
  /// In en, this message translates to:
  /// **'Assumptions'**
  String get navAssumptions;

  /// No description provided for @navProjection.
  ///
  /// In en, this message translates to:
  /// **'Projection'**
  String get navProjection;

  /// No description provided for @navStartup.
  ///
  /// In en, this message translates to:
  /// **'Start-up costs'**
  String get navStartup;

  /// No description provided for @navSensitivity.
  ///
  /// In en, this message translates to:
  /// **'Sensitivity'**
  String get navSensitivity;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @dashboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboardTitle;

  /// No description provided for @assumptionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Assumptions'**
  String get assumptionsTitle;

  /// No description provided for @projectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Monthly projection'**
  String get projectionTitle;

  /// No description provided for @startupTitle.
  ///
  /// In en, this message translates to:
  /// **'Start-up costs'**
  String get startupTitle;

  /// No description provided for @sensitivityTitle.
  ///
  /// In en, this message translates to:
  /// **'Sensitivity'**
  String get sensitivityTitle;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading'**
  String get loading;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @notAvailable.
  ///
  /// In en, this message translates to:
  /// **'N/A'**
  String get notAvailable;

  /// No description provided for @howIsThisCalculated.
  ///
  /// In en, this message translates to:
  /// **'How is this calculated?'**
  String get howIsThisCalculated;

  /// No description provided for @calculationTitle.
  ///
  /// In en, this message translates to:
  /// **'How this is calculated'**
  String get calculationTitle;

  /// No description provided for @formulaLabel.
  ///
  /// In en, this message translates to:
  /// **'Formula'**
  String get formulaLabel;

  /// No description provided for @inputsLabel.
  ///
  /// In en, this message translates to:
  /// **'Values used'**
  String get inputsLabel;

  /// No description provided for @resultLabel.
  ///
  /// In en, this message translates to:
  /// **'Result'**
  String get resultLabel;

  /// No description provided for @normalMonth.
  ///
  /// In en, this message translates to:
  /// **'A normal month (month {month})'**
  String normalMonth(int month);

  /// No description provided for @monthLabel.
  ///
  /// In en, this message translates to:
  /// **'Month {month}'**
  String monthLabel(int month);

  /// No description provided for @monthZeroLabel.
  ///
  /// In en, this message translates to:
  /// **'Month 0 - investment'**
  String get monthZeroLabel;

  /// No description provided for @monthShort.
  ///
  /// In en, this message translates to:
  /// **'M{month}'**
  String monthShort(int month);

  /// No description provided for @yearLabel.
  ///
  /// In en, this message translates to:
  /// **'Year {year}'**
  String yearLabel(int year);

  /// No description provided for @yearPartial.
  ///
  /// In en, this message translates to:
  /// **'Year {year} (partial)'**
  String yearPartial(int year);

  /// No description provided for @metricInitialInvestment.
  ///
  /// In en, this message translates to:
  /// **'Initial investment'**
  String get metricInitialInvestment;

  /// No description provided for @metricMonthlyRevenue.
  ///
  /// In en, this message translates to:
  /// **'Monthly revenue'**
  String get metricMonthlyRevenue;

  /// No description provided for @metricMonthlyExpenses.
  ///
  /// In en, this message translates to:
  /// **'Monthly expenses'**
  String get metricMonthlyExpenses;

  /// No description provided for @metricMonthlyProfit.
  ///
  /// In en, this message translates to:
  /// **'Monthly profit'**
  String get metricMonthlyProfit;

  /// No description provided for @metricProfitMargin.
  ///
  /// In en, this message translates to:
  /// **'Profit margin'**
  String get metricProfitMargin;

  /// No description provided for @metricPayback.
  ///
  /// In en, this message translates to:
  /// **'Payback'**
  String get metricPayback;

  /// No description provided for @metricYearOneProfit.
  ///
  /// In en, this message translates to:
  /// **'Year-1 profit'**
  String get metricYearOneProfit;

  /// No description provided for @metricYearTwoProfit.
  ///
  /// In en, this message translates to:
  /// **'Year-2 profit'**
  String get metricYearTwoProfit;

  /// No description provided for @metricYearOneRoi.
  ///
  /// In en, this message translates to:
  /// **'Year-1 ROI'**
  String get metricYearOneRoi;

  /// No description provided for @metricOccupancy.
  ///
  /// In en, this message translates to:
  /// **'Stable occupancy'**
  String get metricOccupancy;

  /// No description provided for @metricRoundsPerDay.
  ///
  /// In en, this message translates to:
  /// **'Rounds per day'**
  String get metricRoundsPerDay;

  /// No description provided for @roiStudyDefinition.
  ///
  /// In en, this message translates to:
  /// **'Year-1 profit divided by the initial investment, as the original study defines it.'**
  String get roiStudyDefinition;

  /// No description provided for @paybackDuringMonth.
  ///
  /// In en, this message translates to:
  /// **'During month {month}'**
  String paybackDuringMonth(int month);

  /// No description provided for @paybackNotRecovered.
  ///
  /// In en, this message translates to:
  /// **'Not recovered'**
  String get paybackNotRecovered;

  /// No description provided for @paybackNotRecoveredWithin.
  ///
  /// In en, this message translates to:
  /// **'Not recovered within {months} months'**
  String paybackNotRecoveredWithin(int months);

  /// No description provided for @paybackPrecise.
  ///
  /// In en, this message translates to:
  /// **'{months} months (interpolated)'**
  String paybackPrecise(String months);

  /// No description provided for @paybackLastNegative.
  ///
  /// In en, this message translates to:
  /// **'Last month in deficit: month {month}'**
  String paybackLastNegative(int month);

  /// No description provided for @paybackFirstPositive.
  ///
  /// In en, this message translates to:
  /// **'First month in surplus: month {month}'**
  String paybackFirstPositive(int month);

  /// No description provided for @chartRevenueTitle.
  ///
  /// In en, this message translates to:
  /// **'Monthly revenue'**
  String get chartRevenueTitle;

  /// No description provided for @chartRevenueSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Revenue for each trading month'**
  String get chartRevenueSubtitle;

  /// No description provided for @chartCashFlowTitle.
  ///
  /// In en, this message translates to:
  /// **'Cumulative cash flow'**
  String get chartCashFlowTitle;

  /// No description provided for @chartCashFlowSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Investment recovery over time'**
  String get chartCashFlowSubtitle;

  /// No description provided for @chartBreakEvenLine.
  ///
  /// In en, this message translates to:
  /// **'Break-even'**
  String get chartBreakEvenLine;

  /// No description provided for @chartNoData.
  ///
  /// In en, this message translates to:
  /// **'Nothing to plot yet'**
  String get chartNoData;

  /// No description provided for @sectionSessionPricing.
  ///
  /// In en, this message translates to:
  /// **'Session and pricing'**
  String get sectionSessionPricing;

  /// No description provided for @sectionOccupancy.
  ///
  /// In en, this message translates to:
  /// **'Occupancy'**
  String get sectionOccupancy;

  /// No description provided for @sectionStaffing.
  ///
  /// In en, this message translates to:
  /// **'Staffing'**
  String get sectionStaffing;

  /// No description provided for @sectionOperatingExpenses.
  ///
  /// In en, this message translates to:
  /// **'Monthly operating expenses'**
  String get sectionOperatingExpenses;

  /// No description provided for @sectionProperty.
  ///
  /// In en, this message translates to:
  /// **'Property'**
  String get sectionProperty;

  /// No description provided for @sectionEquipment.
  ///
  /// In en, this message translates to:
  /// **'Equipment'**
  String get sectionEquipment;

  /// No description provided for @sectionFitOut.
  ///
  /// In en, this message translates to:
  /// **'Fit-out'**
  String get sectionFitOut;

  /// No description provided for @sectionPreOpening.
  ///
  /// In en, this message translates to:
  /// **'Pre-opening'**
  String get sectionPreOpening;

  /// No description provided for @sectionProjection.
  ///
  /// In en, this message translates to:
  /// **'Projection'**
  String get sectionProjection;

  /// No description provided for @sectionSensitivityInputs.
  ///
  /// In en, this message translates to:
  /// **'Sensitivity cases'**
  String get sectionSensitivityInputs;

  /// No description provided for @fieldRoundDuration.
  ///
  /// In en, this message translates to:
  /// **'Round duration'**
  String get fieldRoundDuration;

  /// No description provided for @fieldTurnaroundTime.
  ///
  /// In en, this message translates to:
  /// **'Turnaround time'**
  String get fieldTurnaroundTime;

  /// No description provided for @fieldTicketPrice.
  ///
  /// In en, this message translates to:
  /// **'Ticket price per player'**
  String get fieldTicketPrice;

  /// No description provided for @fieldAveragePlayers.
  ///
  /// In en, this message translates to:
  /// **'Average players per round'**
  String get fieldAveragePlayers;

  /// No description provided for @fieldMaximumPlayers.
  ///
  /// In en, this message translates to:
  /// **'Maximum players per round'**
  String get fieldMaximumPlayers;

  /// No description provided for @fieldOperatingHours.
  ///
  /// In en, this message translates to:
  /// **'Operating hours per day'**
  String get fieldOperatingHours;

  /// No description provided for @fieldOperatingDaysPerWeek.
  ///
  /// In en, this message translates to:
  /// **'Operating days per week'**
  String get fieldOperatingDaysPerWeek;

  /// No description provided for @fieldOperatingDaysPerMonth.
  ///
  /// In en, this message translates to:
  /// **'Operating days per month'**
  String get fieldOperatingDaysPerMonth;

  /// No description provided for @fieldOccupancyMonth1.
  ///
  /// In en, this message translates to:
  /// **'Month 1 occupancy'**
  String get fieldOccupancyMonth1;

  /// No description provided for @fieldOccupancyMonth2.
  ///
  /// In en, this message translates to:
  /// **'Month 2 occupancy'**
  String get fieldOccupancyMonth2;

  /// No description provided for @fieldOccupancyMonth3.
  ///
  /// In en, this message translates to:
  /// **'Month 3 occupancy'**
  String get fieldOccupancyMonth3;

  /// No description provided for @fieldStableOccupancy.
  ///
  /// In en, this message translates to:
  /// **'Stable occupancy (month 4 onwards)'**
  String get fieldStableOccupancy;

  /// No description provided for @fieldInitialEmployees.
  ///
  /// In en, this message translates to:
  /// **'Starting headcount'**
  String get fieldInitialEmployees;

  /// No description provided for @fieldExpandedEmployees.
  ///
  /// In en, this message translates to:
  /// **'Expanded headcount'**
  String get fieldExpandedEmployees;

  /// No description provided for @fieldExpansionMonth.
  ///
  /// In en, this message translates to:
  /// **'Expansion begins in month'**
  String get fieldExpansionMonth;

  /// No description provided for @fieldSalary.
  ///
  /// In en, this message translates to:
  /// **'Monthly salary per employee'**
  String get fieldSalary;

  /// No description provided for @fieldIncentive.
  ///
  /// In en, this message translates to:
  /// **'Monthly incentive per employee'**
  String get fieldIncentive;

  /// No description provided for @fieldRent.
  ///
  /// In en, this message translates to:
  /// **'Rent'**
  String get fieldRent;

  /// No description provided for @fieldMallServices.
  ///
  /// In en, this message translates to:
  /// **'Mall shared services'**
  String get fieldMallServices;

  /// No description provided for @fieldElectricity.
  ///
  /// In en, this message translates to:
  /// **'Electricity'**
  String get fieldElectricity;

  /// No description provided for @fieldMaintenance.
  ///
  /// In en, this message translates to:
  /// **'Maintenance and consumables'**
  String get fieldMaintenance;

  /// No description provided for @fieldMarketing.
  ///
  /// In en, this message translates to:
  /// **'Continuous marketing'**
  String get fieldMarketing;

  /// No description provided for @fieldMallDeposit.
  ///
  /// In en, this message translates to:
  /// **'Mall deposit / key money'**
  String get fieldMallDeposit;

  /// No description provided for @fieldContractDuration.
  ///
  /// In en, this message translates to:
  /// **'Contract duration'**
  String get fieldContractDuration;

  /// No description provided for @fieldEquipmentPackage.
  ///
  /// In en, this message translates to:
  /// **'Equipment package'**
  String get fieldEquipmentPackage;

  /// No description provided for @fieldShippingRate.
  ///
  /// In en, this message translates to:
  /// **'Sea freight rate'**
  String get fieldShippingRate;

  /// No description provided for @fieldCustomsRate.
  ///
  /// In en, this message translates to:
  /// **'Customs and clearance rate'**
  String get fieldCustomsRate;

  /// No description provided for @fieldFitOutFurniture.
  ///
  /// In en, this message translates to:
  /// **'Reception and cashier furniture'**
  String get fieldFitOutFurniture;

  /// No description provided for @fieldFitOutPainting.
  ///
  /// In en, this message translates to:
  /// **'Painting and wall graphics'**
  String get fieldFitOutPainting;

  /// No description provided for @fieldFitOutSignage.
  ///
  /// In en, this message translates to:
  /// **'Signage'**
  String get fieldFitOutSignage;

  /// No description provided for @fieldFitOutHvac.
  ///
  /// In en, this message translates to:
  /// **'HVAC'**
  String get fieldFitOutHvac;

  /// No description provided for @fieldFitOutLabour.
  ///
  /// In en, this message translates to:
  /// **'Installation labour'**
  String get fieldFitOutLabour;

  /// No description provided for @fieldLicensing.
  ///
  /// In en, this message translates to:
  /// **'Registration and licensing'**
  String get fieldLicensing;

  /// No description provided for @fieldOpeningMarketing.
  ///
  /// In en, this message translates to:
  /// **'Opening marketing campaign'**
  String get fieldOpeningMarketing;

  /// No description provided for @fieldContingency.
  ///
  /// In en, this message translates to:
  /// **'Contingency'**
  String get fieldContingency;

  /// No description provided for @fieldSetupDays.
  ///
  /// In en, this message translates to:
  /// **'Maximum setup days after arrival'**
  String get fieldSetupDays;

  /// No description provided for @fieldProjectionMonths.
  ///
  /// In en, this message translates to:
  /// **'Projection length'**
  String get fieldProjectionMonths;

  /// No description provided for @fieldConservativeOccupancy.
  ///
  /// In en, this message translates to:
  /// **'Conservative occupancy'**
  String get fieldConservativeOccupancy;

  /// No description provided for @fieldOptimisticOccupancy.
  ///
  /// In en, this message translates to:
  /// **'Optimistic occupancy'**
  String get fieldOptimisticOccupancy;

  /// No description provided for @helpTurnaround.
  ///
  /// In en, this message translates to:
  /// **'Reset time between rounds. It consumes trading time even though it is not sold.'**
  String get helpTurnaround;

  /// No description provided for @helpAveragePlayers.
  ///
  /// In en, this message translates to:
  /// **'An average, so a fractional value is expected. It cannot exceed the room\'s capacity.'**
  String get helpAveragePlayers;

  /// No description provided for @helpOperatingDaysPerWeek.
  ///
  /// In en, this message translates to:
  /// **'Recorded for planning. The monthly total below is what drives revenue.'**
  String get helpOperatingDaysPerWeek;

  /// No description provided for @helpOperatingDaysPerMonth.
  ///
  /// In en, this message translates to:
  /// **'Trading days in an average month. The study uses 30.4.'**
  String get helpOperatingDaysPerMonth;

  /// No description provided for @helpOccupancy.
  ///
  /// In en, this message translates to:
  /// **'The share of available rounds that actually sell. This is the single most influential assumption in the model.'**
  String get helpOccupancy;

  /// No description provided for @helpRent.
  ///
  /// In en, this message translates to:
  /// **'Also charged once as the first month\'s rent inside the start-up property cost, exactly as the original study does.'**
  String get helpRent;

  /// No description provided for @helpMaximumPlayers.
  ///
  /// In en, this message translates to:
  /// **'The physical capacity of the room. It caps the average, but does not itself drive revenue.'**
  String get helpMaximumPlayers;

  /// No description provided for @helpContractDuration.
  ///
  /// In en, this message translates to:
  /// **'Recorded for planning. It does not enter any formula in this model.'**
  String get helpContractDuration;

  /// No description provided for @helpSetupDays.
  ///
  /// In en, this message translates to:
  /// **'Recorded for planning. It does not enter any formula in this model.'**
  String get helpSetupDays;

  /// No description provided for @helpShipping.
  ///
  /// In en, this message translates to:
  /// **'Applied to the value of the selected equipment package.'**
  String get helpShipping;

  /// No description provided for @helpContingency.
  ///
  /// In en, this message translates to:
  /// **'A buffer applied to the whole start-up subtotal.'**
  String get helpContingency;

  /// No description provided for @helpSensitivity.
  ///
  /// In en, this message translates to:
  /// **'Each case reprices a normal month at a different occupancy, using the steady-state cost base.'**
  String get helpSensitivity;

  /// No description provided for @calculatedShipping.
  ///
  /// In en, this message translates to:
  /// **'Calculated freight'**
  String get calculatedShipping;

  /// No description provided for @calculatedCustoms.
  ///
  /// In en, this message translates to:
  /// **'Calculated customs'**
  String get calculatedCustoms;

  /// No description provided for @calculatedValue.
  ///
  /// In en, this message translates to:
  /// **'Calculated'**
  String get calculatedValue;

  /// No description provided for @editableValue.
  ///
  /// In en, this message translates to:
  /// **'Editable'**
  String get editableValue;

  /// No description provided for @unitMinutes.
  ///
  /// In en, this message translates to:
  /// **'min'**
  String get unitMinutes;

  /// No description provided for @unitHours.
  ///
  /// In en, this message translates to:
  /// **'h'**
  String get unitHours;

  /// No description provided for @unitDays.
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get unitDays;

  /// No description provided for @unitMonths.
  ///
  /// In en, this message translates to:
  /// **'months'**
  String get unitMonths;

  /// No description provided for @unitPercent.
  ///
  /// In en, this message translates to:
  /// **'%'**
  String get unitPercent;

  /// No description provided for @unitPlayers.
  ///
  /// In en, this message translates to:
  /// **'players'**
  String get unitPlayers;

  /// No description provided for @unitPeople.
  ///
  /// In en, this message translates to:
  /// **'people'**
  String get unitPeople;

  /// No description provided for @perMonth.
  ///
  /// In en, this message translates to:
  /// **'/ month'**
  String get perMonth;

  /// No description provided for @perDay.
  ///
  /// In en, this message translates to:
  /// **'/ day'**
  String get perDay;

  /// No description provided for @perRound.
  ///
  /// In en, this message translates to:
  /// **'/ round'**
  String get perRound;

  /// No description provided for @statusEstimated.
  ///
  /// In en, this message translates to:
  /// **'Estimated'**
  String get statusEstimated;

  /// No description provided for @statusVerified.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get statusVerified;

  /// No description provided for @statusConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get statusConfirmed;

  /// No description provided for @statusUserDefined.
  ///
  /// In en, this message translates to:
  /// **'User-defined'**
  String get statusUserDefined;

  /// No description provided for @statusImported.
  ///
  /// In en, this message translates to:
  /// **'Imported'**
  String get statusImported;

  /// No description provided for @statusEstimatedHint.
  ///
  /// In en, this message translates to:
  /// **'Estimated - verify before relying on it'**
  String get statusEstimatedHint;

  /// No description provided for @statusSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Confidence'**
  String get statusSectionTitle;

  /// No description provided for @assumptionStatusChanged.
  ///
  /// In en, this message translates to:
  /// **'Marked as {status}'**
  String assumptionStatusChanged(String status);

  /// No description provided for @validationMustBeGreaterThan.
  ///
  /// In en, this message translates to:
  /// **'Must be greater than {limit}'**
  String validationMustBeGreaterThan(String limit);

  /// No description provided for @validationMustBeAtLeast.
  ///
  /// In en, this message translates to:
  /// **'Must be at least {limit}'**
  String validationMustBeAtLeast(String limit);

  /// No description provided for @validationMustNotExceed.
  ///
  /// In en, this message translates to:
  /// **'Must not exceed {limit}'**
  String validationMustNotExceed(String limit);

  /// No description provided for @validationPlayersExceedCapacity.
  ///
  /// In en, this message translates to:
  /// **'Cannot exceed the room capacity of {limit}'**
  String validationPlayersExceedCapacity(String limit);

  /// No description provided for @validationRoundTimeNotPositive.
  ///
  /// In en, this message translates to:
  /// **'A round and its turnaround must take some time'**
  String get validationRoundTimeNotPositive;

  /// No description provided for @validationContingencyAboveHundred.
  ///
  /// In en, this message translates to:
  /// **'A contingency above 100% doubles the project cost. Check this figure.'**
  String get validationContingencyAboveHundred;

  /// No description provided for @validationOptimisticBelowBase.
  ///
  /// In en, this message translates to:
  /// **'This optimistic case is below the stable occupancy of {limit}%. The original study has the same inconsistency.'**
  String validationOptimisticBelowBase(String limit);

  /// No description provided for @validationConservativeAboveBase.
  ///
  /// In en, this message translates to:
  /// **'The conservative case is above the stable occupancy of {limit}%.'**
  String validationConservativeAboveBase(String limit);

  /// No description provided for @validationExpandedBelowInitial.
  ///
  /// In en, this message translates to:
  /// **'The expanded headcount is smaller than the starting one.'**
  String get validationExpandedBelowInitial;

  /// No description provided for @validationNotANumber.
  ///
  /// In en, this message translates to:
  /// **'Enter a number'**
  String get validationNotANumber;

  /// No description provided for @validationSummaryErrors.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 input needs attention} other{{count} inputs need attention}}'**
  String validationSummaryErrors(int count);

  /// No description provided for @validationSummaryWarnings.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 assumption is worth checking} other{{count} assumptions are worth checking}}'**
  String validationSummaryWarnings(int count);

  /// No description provided for @validationBlocksSaving.
  ///
  /// In en, this message translates to:
  /// **'Changes are not saved while an input is invalid.'**
  String get validationBlocksSaving;

  /// No description provided for @termTotalRoundTime.
  ///
  /// In en, this message translates to:
  /// **'Total round time'**
  String get termTotalRoundTime;

  /// No description provided for @termOperatingMinutes.
  ///
  /// In en, this message translates to:
  /// **'Trading minutes per day'**
  String get termOperatingMinutes;

  /// No description provided for @termMaximumRounds.
  ///
  /// In en, this message translates to:
  /// **'Maximum rounds'**
  String get termMaximumRounds;

  /// No description provided for @termActualRounds.
  ///
  /// In en, this message translates to:
  /// **'Actual rounds'**
  String get termActualRounds;

  /// No description provided for @termOccupancy.
  ///
  /// In en, this message translates to:
  /// **'Occupancy'**
  String get termOccupancy;

  /// No description provided for @termDailyRevenue.
  ///
  /// In en, this message translates to:
  /// **'Daily revenue'**
  String get termDailyRevenue;

  /// No description provided for @termMonthlyRevenue.
  ///
  /// In en, this message translates to:
  /// **'Monthly revenue'**
  String get termMonthlyRevenue;

  /// No description provided for @termCumulativeRevenue.
  ///
  /// In en, this message translates to:
  /// **'Cumulative revenue'**
  String get termCumulativeRevenue;

  /// No description provided for @termEmployees.
  ///
  /// In en, this message translates to:
  /// **'Employees'**
  String get termEmployees;

  /// No description provided for @termCostPerEmployee.
  ///
  /// In en, this message translates to:
  /// **'Cost per employee'**
  String get termCostPerEmployee;

  /// No description provided for @termPayroll.
  ///
  /// In en, this message translates to:
  /// **'Payroll'**
  String get termPayroll;

  /// No description provided for @termOtherExpenses.
  ///
  /// In en, this message translates to:
  /// **'Other expenses'**
  String get termOtherExpenses;

  /// No description provided for @termTotalExpenses.
  ///
  /// In en, this message translates to:
  /// **'Total expenses'**
  String get termTotalExpenses;

  /// No description provided for @termOperatingProfit.
  ///
  /// In en, this message translates to:
  /// **'Operating profit'**
  String get termOperatingProfit;

  /// No description provided for @termProfitMargin.
  ///
  /// In en, this message translates to:
  /// **'Profit margin'**
  String get termProfitMargin;

  /// No description provided for @termNetCashFlow.
  ///
  /// In en, this message translates to:
  /// **'Net cash flow'**
  String get termNetCashFlow;

  /// No description provided for @termCumulativeCashFlow.
  ///
  /// In en, this message translates to:
  /// **'Cumulative cash flow'**
  String get termCumulativeCashFlow;

  /// No description provided for @termPreviousCumulativeCashFlow.
  ///
  /// In en, this message translates to:
  /// **'Previous cumulative cash flow'**
  String get termPreviousCumulativeCashFlow;

  /// No description provided for @termEquipment.
  ///
  /// In en, this message translates to:
  /// **'Equipment'**
  String get termEquipment;

  /// No description provided for @termShipping.
  ///
  /// In en, this message translates to:
  /// **'Sea freight'**
  String get termShipping;

  /// No description provided for @termCustoms.
  ///
  /// In en, this message translates to:
  /// **'Customs and clearance'**
  String get termCustoms;

  /// No description provided for @termDeliveredEquipment.
  ///
  /// In en, this message translates to:
  /// **'Delivered equipment'**
  String get termDeliveredEquipment;

  /// No description provided for @termFitOut.
  ///
  /// In en, this message translates to:
  /// **'Fit-out'**
  String get termFitOut;

  /// No description provided for @termProperty.
  ///
  /// In en, this message translates to:
  /// **'Property'**
  String get termProperty;

  /// No description provided for @termPreOpening.
  ///
  /// In en, this message translates to:
  /// **'Pre-opening'**
  String get termPreOpening;

  /// No description provided for @termSubtotal.
  ///
  /// In en, this message translates to:
  /// **'Subtotal'**
  String get termSubtotal;

  /// No description provided for @termContingency.
  ///
  /// In en, this message translates to:
  /// **'Contingency'**
  String get termContingency;

  /// No description provided for @termInitialInvestment.
  ///
  /// In en, this message translates to:
  /// **'Initial investment'**
  String get termInitialInvestment;

  /// No description provided for @termYearOneProfit.
  ///
  /// In en, this message translates to:
  /// **'Year-1 profit'**
  String get termYearOneProfit;

  /// No description provided for @termLastNegativeMonth.
  ///
  /// In en, this message translates to:
  /// **'Last month in deficit'**
  String get termLastNegativeMonth;

  /// No description provided for @termShortfall.
  ///
  /// In en, this message translates to:
  /// **'Amount still to recover'**
  String get termShortfall;

  /// No description provided for @termMonth.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get termMonth;

  /// No description provided for @termFirstMonthRent.
  ///
  /// In en, this message translates to:
  /// **'First month\'s rent'**
  String get termFirstMonthRent;

  /// No description provided for @termMallDeposit.
  ///
  /// In en, this message translates to:
  /// **'Mall deposit'**
  String get termMallDeposit;

  /// No description provided for @termLicensing.
  ///
  /// In en, this message translates to:
  /// **'Registration and licensing'**
  String get termLicensing;

  /// No description provided for @termOpeningMarketing.
  ///
  /// In en, this message translates to:
  /// **'Opening campaign'**
  String get termOpeningMarketing;

  /// No description provided for @formulaMaximumRounds.
  ///
  /// In en, this message translates to:
  /// **'floor(trading minutes per day / total round time)'**
  String get formulaMaximumRounds;

  /// No description provided for @formulaActualRounds.
  ///
  /// In en, this message translates to:
  /// **'maximum rounds x occupancy'**
  String get formulaActualRounds;

  /// No description provided for @formulaDailyRevenue.
  ///
  /// In en, this message translates to:
  /// **'actual rounds x average players x ticket price'**
  String get formulaDailyRevenue;

  /// No description provided for @formulaMonthlyRevenue.
  ///
  /// In en, this message translates to:
  /// **'daily revenue x trading days per month'**
  String get formulaMonthlyRevenue;

  /// No description provided for @formulaPayroll.
  ///
  /// In en, this message translates to:
  /// **'employees x (salary + incentive)'**
  String get formulaPayroll;

  /// No description provided for @formulaTotalExpenses.
  ///
  /// In en, this message translates to:
  /// **'payroll + rent + mall services + electricity + maintenance + marketing'**
  String get formulaTotalExpenses;

  /// No description provided for @formulaOperatingProfit.
  ///
  /// In en, this message translates to:
  /// **'monthly revenue - total operating expenses'**
  String get formulaOperatingProfit;

  /// No description provided for @formulaProfitMargin.
  ///
  /// In en, this message translates to:
  /// **'operating profit / monthly revenue'**
  String get formulaProfitMargin;

  /// No description provided for @formulaDeliveredEquipment.
  ///
  /// In en, this message translates to:
  /// **'equipment + freight + customs'**
  String get formulaDeliveredEquipment;

  /// No description provided for @formulaContingency.
  ///
  /// In en, this message translates to:
  /// **'start-up subtotal x contingency rate'**
  String get formulaContingency;

  /// No description provided for @formulaInitialInvestment.
  ///
  /// In en, this message translates to:
  /// **'delivered equipment + fit-out + property + pre-opening + contingency'**
  String get formulaInitialInvestment;

  /// No description provided for @formulaCumulativeCashFlow.
  ///
  /// In en, this message translates to:
  /// **'previous cumulative cash flow + net cash flow'**
  String get formulaCumulativeCashFlow;

  /// No description provided for @formulaYearOneProfit.
  ///
  /// In en, this message translates to:
  /// **'sum of operating profit, months 1 to 12'**
  String get formulaYearOneProfit;

  /// No description provided for @formulaYearOneRoi.
  ///
  /// In en, this message translates to:
  /// **'year-1 profit / initial investment'**
  String get formulaYearOneRoi;

  /// No description provided for @formulaPayback.
  ///
  /// In en, this message translates to:
  /// **'last month in deficit + (amount still to recover / that month\'s net cash flow)'**
  String get formulaPayback;

  /// No description provided for @projectionTableTitle.
  ///
  /// In en, this message translates to:
  /// **'Monthly projection'**
  String get projectionTableTitle;

  /// No description provided for @projectionShowsMonths.
  ///
  /// In en, this message translates to:
  /// **'Month 0 plus {count} trading months'**
  String projectionShowsMonths(int count);

  /// No description provided for @projectionInvestmentRow.
  ///
  /// In en, this message translates to:
  /// **'Initial investment paid'**
  String get projectionInvestmentRow;

  /// No description provided for @projectionExpandHint.
  ///
  /// In en, this message translates to:
  /// **'Tap a month for its full breakdown'**
  String get projectionExpandHint;

  /// No description provided for @columnMonth.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get columnMonth;

  /// No description provided for @startupGroupEquipment.
  ///
  /// In en, this message translates to:
  /// **'Delivered equipment'**
  String get startupGroupEquipment;

  /// No description provided for @startupGroupFitOut.
  ///
  /// In en, this message translates to:
  /// **'Fit-out'**
  String get startupGroupFitOut;

  /// No description provided for @startupGroupProperty.
  ///
  /// In en, this message translates to:
  /// **'Property'**
  String get startupGroupProperty;

  /// No description provided for @startupGroupPreOpening.
  ///
  /// In en, this message translates to:
  /// **'Pre-opening'**
  String get startupGroupPreOpening;

  /// No description provided for @startupTotal.
  ///
  /// In en, this message translates to:
  /// **'Total initial investment'**
  String get startupTotal;

  /// No description provided for @startupExpandHint.
  ///
  /// In en, this message translates to:
  /// **'Tap a group to see what it contains'**
  String get startupExpandHint;

  /// No description provided for @startupContingencyAt.
  ///
  /// In en, this message translates to:
  /// **'Contingency at {rate}'**
  String startupContingencyAt(String rate);

  /// No description provided for @scenarioConservative.
  ///
  /// In en, this message translates to:
  /// **'Conservative'**
  String get scenarioConservative;

  /// No description provided for @scenarioBase.
  ///
  /// In en, this message translates to:
  /// **'Base'**
  String get scenarioBase;

  /// No description provided for @scenarioOptimistic.
  ///
  /// In en, this message translates to:
  /// **'Optimistic'**
  String get scenarioOptimistic;

  /// No description provided for @scenarioCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get scenarioCustom;

  /// No description provided for @scenarioBaseTracksStable.
  ///
  /// In en, this message translates to:
  /// **'Tracks the scenario\'s stable occupancy'**
  String get scenarioBaseTracksStable;

  /// No description provided for @sensitivityApproxPayback.
  ///
  /// In en, this message translates to:
  /// **'Approximate payback'**
  String get sensitivityApproxPayback;

  /// No description provided for @sensitivityNotRecoverable.
  ///
  /// In en, this message translates to:
  /// **'Not recoverable under this case'**
  String get sensitivityNotRecoverable;

  /// No description provided for @sensitivityMonths.
  ///
  /// In en, this message translates to:
  /// **'{months} months'**
  String sensitivityMonths(String months);

  /// No description provided for @sensitivityCostBaseNote.
  ///
  /// In en, this message translates to:
  /// **'Every case is priced at the steady-state cost base of {expenses} per month.'**
  String sensitivityCostBaseNote(String expenses);

  /// No description provided for @settingsScenario.
  ///
  /// In en, this message translates to:
  /// **'Scenario'**
  String get settingsScenario;

  /// No description provided for @settingsScenarioName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get settingsScenarioName;

  /// No description provided for @settingsCurrency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get settingsCurrency;

  /// No description provided for @settingsDecimalPrecision.
  ///
  /// In en, this message translates to:
  /// **'Decimal places'**
  String get settingsDecimalPrecision;

  /// No description provided for @settingsAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsAppearance;

  /// No description provided for @settingsTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsTheme;

  /// No description provided for @settingsThemeSystem.
  ///
  /// In en, this message translates to:
  /// **'Follow system'**
  String get settingsThemeSystem;

  /// No description provided for @settingsThemeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settingsThemeLight;

  /// No description provided for @settingsThemeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settingsThemeDark;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsLanguageSystem.
  ///
  /// In en, this message translates to:
  /// **'Follow system'**
  String get settingsLanguageSystem;

  /// No description provided for @settingsLanguageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get settingsLanguageEnglish;

  /// No description provided for @settingsData.
  ///
  /// In en, this message translates to:
  /// **'Data'**
  String get settingsData;

  /// No description provided for @settingsAutosaveNote.
  ///
  /// In en, this message translates to:
  /// **'Changes are saved on this device automatically.'**
  String get settingsAutosaveNote;

  /// No description provided for @settingsResetScenario.
  ///
  /// In en, this message translates to:
  /// **'Reset to the study baseline'**
  String get settingsResetScenario;

  /// No description provided for @settingsResetDescription.
  ///
  /// In en, this message translates to:
  /// **'Discards every change and restores the original figures.'**
  String get settingsResetDescription;

  /// No description provided for @settingsResetConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset the scenario?'**
  String get settingsResetConfirmTitle;

  /// No description provided for @settingsResetConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'Every change you have made will be discarded and the original study values restored. This cannot be undone.'**
  String get settingsResetConfirmBody;

  /// No description provided for @settingsResetDone.
  ///
  /// In en, this message translates to:
  /// **'Scenario reset to the study baseline'**
  String get settingsResetDone;

  /// No description provided for @settingsAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsAbout;

  /// No description provided for @settingsCalculationModel.
  ///
  /// In en, this message translates to:
  /// **'Calculation model'**
  String get settingsCalculationModel;

  /// No description provided for @settingsAboutBody.
  ///
  /// In en, this message translates to:
  /// **'An interactive version of the Floor is Lava feasibility study. Every figure on screen is derived from the assumptions you can edit.'**
  String get settingsAboutBody;

  /// No description provided for @equipmentSelected.
  ///
  /// In en, this message translates to:
  /// **'Selected'**
  String get equipmentSelected;

  /// No description provided for @equipmentSelect.
  ///
  /// In en, this message translates to:
  /// **'Use this package'**
  String get equipmentSelect;

  /// No description provided for @equipmentCostLabel.
  ///
  /// In en, this message translates to:
  /// **'Package cost'**
  String get equipmentCostLabel;

  /// No description provided for @errorStorageUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Changes could not be saved on this device.'**
  String get errorStorageUnavailable;

  /// No description provided for @errorStorageCorrupted.
  ///
  /// In en, this message translates to:
  /// **'The saved scenario could not be read, so the study baseline was loaded.'**
  String get errorStorageCorrupted;

  /// No description provided for @errorStorageUnsupported.
  ///
  /// In en, this message translates to:
  /// **'The saved scenario was created by a newer version of the app.'**
  String get errorStorageUnsupported;

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong.'**
  String get errorGeneric;

  /// No description provided for @assumptionsIntro.
  ///
  /// In en, this message translates to:
  /// **'Every figure in this app is derived from the values below. Change one and everything downstream recalculates.'**
  String get assumptionsIntro;

  /// No description provided for @staffingReferenceTitle.
  ///
  /// In en, this message translates to:
  /// **'Recorded in the workbook'**
  String get staffingReferenceTitle;

  /// No description provided for @staffingReferenceBody.
  ///
  /// In en, this message translates to:
  /// **'The source workbook also records staffing phases and weekly hours (employee 1: 54 h, employee 2: 42 h, founders: 13 h). Their definition is not stated, so they are kept here for reference and do not enter any calculation.'**
  String get staffingReferenceBody;

  /// No description provided for @calculatedSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Derived from these inputs'**
  String get calculatedSectionTitle;

  /// No description provided for @noResultsYet.
  ///
  /// In en, this message translates to:
  /// **'No results yet'**
  String get noResultsYet;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
