import '../../domain/entities/scenario/assumption_status.dart';
import '../../domain/entities/scenario/actuals_ledger.dart';
import '../../domain/entities/scenario/bonus_configuration.dart';
import '../../domain/entities/scenario/cost_item.dart';
import '../../domain/entities/scenario/employee_roster.dart';
import '../../domain/entities/scenario/financial_scenario.dart';
import '../../domain/entities/scenario/debt_assumptions.dart';
import '../../domain/entities/scenario/funding_assumptions.dart';
import '../../domain/entities/scenario/investment_assumptions.dart';
import '../../domain/entities/scenario/marketing_assumptions.dart';
import '../../domain/entities/scenario/operating_expense_model.dart';
import '../../domain/entities/scenario/payment_assumptions.dart';
import '../../domain/entities/scenario/payroll_configuration.dart';
import '../../domain/entities/scenario/projection_settings.dart';
import '../../domain/entities/scenario/revenue_model.dart';
import '../../domain/entities/scenario/scenario_metadata.dart';
import '../../domain/entities/scenario/sensitivity_settings.dart';
import '../../domain/entities/scenario/seasonality_model.dart';
import '../../domain/entities/scenario/staffing_model.dart';
import '../../domain/entities/scenario/startup_cost_model.dart';
import '../../domain/entities/scenario/stress_assumptions.dart';
import '../../domain/entities/scenario/tax_assumptions.dart';
import '../../domain/entities/scenario/working_capital_model.dart';
import '../../domain/entities/scenario/equipment_lifecycle_assumptions.dart';
import '../../domain/value_objects/minutes.dart';
import '../../domain/value_objects/money.dart';
import '../../domain/value_objects/percentage.dart';

/// Converts a scenario to and from JSON.
///
/// Reading is deliberately strict: anything that is not the shape we expect
/// raises a [FormatException] naming the offending field, which the repository
/// turns into a typed failure. Half-parsed scenarios are worse than none,
/// because they would quietly change the numbers.
///
/// Money crosses the boundary as whole micros, so a saved scenario reloads to
/// exactly the value it had - no decimal string round-tripping.
abstract final class ScenarioMapper {
  /// Version of the stored *shape*, independent of the calculation model
  /// version. Bumped when this file's JSON layout changes.
  static const int schemaVersion = 3;

  static Map<String, dynamic> toJson(FinancialScenario scenario) {
    return {
      'schemaVersion': schemaVersion,
      'modelVersion': scenario.metadata.calculationModelVersion,
      'metadata': _metadataToJson(scenario.metadata),
      'revenue': _revenueToJson(scenario.revenue),
      'staffing': _staffingToJson(scenario.staffing),
      'operatingExpenses': _expensesToJson(scenario.operatingExpenses),
      'startupCosts': _startupToJson(scenario.startupCosts),
      'projection': {'projectionMonths': scenario.projection.projectionMonths},
      'investmentAssumptions': {
        'annualDiscountRateFraction':
            scenario.investmentAssumptions.annualDiscountRate.fraction,
      },
      'marketingAssumptions': _marketingToJson(scenario.marketingAssumptions),
      'workingCapital': _workingCapitalToJson(scenario.workingCapital),
      'fundingAssumptions': {
        'openingDelayBufferMicros':
            scenario.fundingAssumptions.openingDelayBuffer.micros,
      },
      'seasonality': _seasonalityToJson(scenario.seasonality),
      'stressAssumptions': {
        'criticalFailureEnabled':
            scenario.stressAssumptions.criticalFailureEnabled,
        'failureStartMonth': scenario.stressAssumptions.failureStartMonth,
        'downtimeDays': scenario.stressAssumptions.downtimeDays,
      },
      'paymentAssumptions': {
        'digitalPaymentShareFraction':
            scenario.paymentAssumptions.digitalPaymentShare.fraction,
        'digitalPaymentFeeRateFraction':
            scenario.paymentAssumptions.digitalPaymentFeeRate.fraction,
      },
      'taxAssumptions': {
        'vatRateFraction': scenario.taxAssumptions.vatRate.fraction,
        'pricesIncludeVat': scenario.taxAssumptions.pricesIncludeVat,
      },
      'debtAssumptions': _debtToJson(scenario.debtAssumptions),
      'actuals': _actualsToJson(scenario.actuals),
      'sensitivity': _sensitivityToJson(scenario.sensitivity),
      'annotations': _annotationsToJson(scenario.annotations),
    };
  }

  /// Throws [FormatException] if [json] does not describe a scenario.
  static FinancialScenario fromJson(Map<String, dynamic> json) {
    final version = _int(json, 'schemaVersion');
    if (version > schemaVersion) {
      throw FormatException(
        'Scenario schema version $version is newer than supported '
        '($schemaVersion)',
      );
    }

    return FinancialScenario(
      metadata: _metadataFromJson(_map(json, 'metadata')),
      revenue: _revenueFromJson(_map(json, 'revenue')),
      staffing: _staffingFromJson(_map(json, 'staffing')),
      operatingExpenses: _expensesFromJson(_map(json, 'operatingExpenses')),
      startupCosts: _startupFromJson(_map(json, 'startupCosts')),
      projection: ProjectionSettings(
        projectionMonths: _int(_map(json, 'projection'), 'projectionMonths'),
      ),
      investmentAssumptions: _investmentAssumptionsFromJson(
        json['investmentAssumptions'],
      ),
      marketingAssumptions: _marketingFromJson(json['marketingAssumptions']),
      workingCapital: _workingCapitalFromJson(json['workingCapital']),
      fundingAssumptions: _fundingAssumptionsFromJson(
        json['fundingAssumptions'],
      ),
      seasonality: _seasonalityFromJson(json['seasonality']),
      stressAssumptions: _stressAssumptionsFromJson(json['stressAssumptions']),
      paymentAssumptions: _paymentAssumptionsFromJson(
        json['paymentAssumptions'],
      ),
      taxAssumptions: _taxAssumptionsFromJson(json['taxAssumptions']),
      debtAssumptions: _debtFromJson(json['debtAssumptions']),
      actuals: _actualsFromJson(json['actuals']),
      sensitivity: _sensitivityFromJson(_map(json, 'sensitivity')),
      annotations: _annotationsFromJson(json['annotations']),
    );
  }

  static Map<String, dynamic> _marketingToJson(MarketingAssumptions model) => {
    'mode': model.mode.name,
    'monthlyMarketingBudgetMicros': model.monthlyMarketingBudget.micros,
    'reach': model.reach,
    'conversionRateFraction': model.conversionRate.fraction,
    'averageRoundsPerConvertedCustomer':
        model.averageRoundsPerConvertedCustomer,
  };

  static MarketingAssumptions _marketingFromJson(Object? raw) {
    if (raw == null) return const MarketingAssumptions();
    final json = _asMap(raw, 'marketingAssumptions');
    return MarketingAssumptions(
      mode:
          _enumByNameOrNull(MarketingForecastMode.values, json['mode']) ??
          MarketingForecastMode.occupancyDriven,
      monthlyMarketingBudget: _money(json, 'monthlyMarketingBudgetMicros'),
      reach: _double(json, 'reach'),
      conversionRate: Percentage.fromFraction(
        _double(json, 'conversionRateFraction'),
      ),
      averageRoundsPerConvertedCustomer: _double(
        json,
        'averageRoundsPerConvertedCustomer',
      ),
    );
  }

  static InvestmentAssumptions _investmentAssumptionsFromJson(Object? raw) {
    if (raw == null) {
      return const InvestmentAssumptions(
        annualDiscountRate: Percentage.fromPercent(10),
      );
    }
    final json = _asMap(raw, 'investmentAssumptions');
    return InvestmentAssumptions(
      annualDiscountRate: Percentage.fromFraction(
        _double(json, 'annualDiscountRateFraction'),
      ),
    );
  }

  static Map<String, dynamic> _workingCapitalToJson(
    WorkingCapitalModel model,
  ) => {
    'method': model.method.name,
    'fixedAmountMicros': model.fixedAmount.micros,
    'percentOfStartupFraction': model.percentOfStartup.fraction,
    'monthsOfOpex': model.monthsOfOpex,
  };

  static WorkingCapitalModel _workingCapitalFromJson(Object? raw) {
    if (raw == null) return const WorkingCapitalModel();
    final json = _asMap(raw, 'workingCapital');
    return WorkingCapitalModel(
      method:
          _enumByNameOrNull(WorkingCapitalMethod.values, json['method']) ??
          WorkingCapitalMethod.fixedAmount,
      fixedAmount: _money(json, 'fixedAmountMicros'),
      percentOfStartup: Percentage.fromFraction(
        _double(json, 'percentOfStartupFraction'),
      ),
      monthsOfOpex: _double(json, 'monthsOfOpex'),
    );
  }

  static FundingAssumptions _fundingAssumptionsFromJson(Object? raw) {
    if (raw == null) return const FundingAssumptions();
    final json = _asMap(raw, 'fundingAssumptions');
    return FundingAssumptions(
      openingDelayBuffer: _money(json, 'openingDelayBufferMicros'),
    );
  }

  static Map<String, dynamic> _seasonalityToJson(SeasonalityModel model) => {
    'enabled': model.enabled,
    'dayOfWeekFactors': {
      for (final entry in model.dayOfWeekFactors.entries)
        entry.key.toString(): entry.value,
    },
    'monthFactors': {
      for (final entry in model.monthFactors.entries)
        entry.key.toString(): entry.value,
    },
    'events': [
      for (final event in model.events)
        {
          'id': event.id,
          'name': event.name,
          'startMonth': event.startMonth,
          'endMonth': event.endMonth,
          'factor': event.factor,
          'active': event.active,
        },
    ],
    'weatherFactor': model.weatherFactor,
    'marketingDemandFactor': model.marketingDemandFactor,
  };

  static SeasonalityModel _seasonalityFromJson(Object? raw) {
    if (raw == null) return const SeasonalityModel();
    final json = _asMap(raw, 'seasonality');
    return SeasonalityModel(
      enabled: _bool(json, 'enabled'),
      dayOfWeekFactors: _integerDoubleMap(
        json,
        'dayOfWeekFactors',
        minimum: 1,
        maximum: 7,
      ),
      monthFactors: _integerDoubleMap(
        json,
        'monthFactors',
        minimum: 1,
        maximum: 12,
      ),
      events: [
        for (final rawEvent in _list(json, 'events'))
          () {
            final event = _asMap(rawEvent, 'events');
            return CalendarEventFactor(
              id: _string(event, 'id'),
              name: _string(event, 'name'),
              startMonth: _int(event, 'startMonth'),
              endMonth: _int(event, 'endMonth'),
              factor: _double(event, 'factor'),
              active: _bool(event, 'active'),
            );
          }(),
      ],
      weatherFactor: _double(json, 'weatherFactor'),
      marketingDemandFactor: _double(json, 'marketingDemandFactor'),
    );
  }

  static StressAssumptions _stressAssumptionsFromJson(Object? raw) {
    if (raw == null) return const StressAssumptions();
    final json = _asMap(raw, 'stressAssumptions');
    return StressAssumptions(
      criticalFailureEnabled: _bool(json, 'criticalFailureEnabled'),
      failureStartMonth: _int(json, 'failureStartMonth'),
      downtimeDays: _int(json, 'downtimeDays'),
    );
  }

  static PaymentAssumptions _paymentAssumptionsFromJson(Object? raw) {
    if (raw == null) return const PaymentAssumptions();
    final json = _asMap(raw, 'paymentAssumptions');
    return PaymentAssumptions(
      digitalPaymentShare: Percentage.fromFraction(
        _double(json, 'digitalPaymentShareFraction'),
      ),
      digitalPaymentFeeRate: Percentage.fromFraction(
        _double(json, 'digitalPaymentFeeRateFraction'),
      ),
    );
  }

  static TaxAssumptions _taxAssumptionsFromJson(Object? raw) {
    if (raw == null) return const TaxAssumptions();
    final json = _asMap(raw, 'taxAssumptions');
    return TaxAssumptions(
      vatRate: Percentage.fromFraction(_double(json, 'vatRateFraction')),
      pricesIncludeVat: _bool(json, 'pricesIncludeVat'),
    );
  }

  static Map<String, dynamic> _debtToJson(DebtAssumptions model) => {
    'enabled': model.enabled,
    'principalMicros': model.principal.micros,
    'annualInterestRateFraction': model.annualInterestRate.fraction,
    'termMonths': model.termMonths,
    'disbursementMonth': model.disbursementMonth,
    'firstPaymentMonth': model.firstPaymentMonth,
    'kind': model.kind.name,
  };

  static DebtAssumptions _debtFromJson(Object? raw) {
    if (raw == null) return const DebtAssumptions();
    final json = _asMap(raw, 'debtAssumptions');
    return DebtAssumptions(
      enabled: _bool(json, 'enabled'),
      principal: _money(json, 'principalMicros'),
      annualInterestRate: Percentage.fromFraction(
        _double(json, 'annualInterestRateFraction'),
      ),
      termMonths: _int(json, 'termMonths'),
      disbursementMonth: _int(json, 'disbursementMonth'),
      firstPaymentMonth: _int(json, 'firstPaymentMonth'),
      kind:
          _enumByNameOrNull(DebtAmortizationKind.values, json['kind']) ??
          DebtAmortizationKind.annuity,
    );
  }

  static List<Map<String, dynamic>> _actualsToJson(ActualsLedger ledger) => [
    for (final actual in ledger.months)
      {
        'monthNumber': actual.monthNumber,
        'revenueMicros': actual.revenue?.micros,
        'operatingExpensesMicros': actual.operatingExpenses?.micros,
        'occupancyFraction': actual.occupancy?.fraction,
      },
  ];

  static ActualsLedger _actualsFromJson(Object? raw) {
    if (raw == null) return const ActualsLedger();
    if (raw is! List) {
      throw const FormatException('Field "actuals" must be a list');
    }
    final ledger = ActualsLedger(
      months: [
        for (final entry in raw)
          () {
            final json = _asMap(entry, 'actuals');
            final monthNumber = _int(json, 'monthNumber');
            if (monthNumber < 1) {
              throw const FormatException(
                'Field "actuals.monthNumber" must be at least 1',
              );
            }
            return MonthlyActuals(
              monthNumber: monthNumber,
              revenue: json['revenueMicros'] == null
                  ? null
                  : _money(json, 'revenueMicros'),
              operatingExpenses: json['operatingExpensesMicros'] == null
                  ? null
                  : _money(json, 'operatingExpensesMicros'),
              occupancy: json['occupancyFraction'] == null
                  ? null
                  : Percentage.fromFraction(_double(json, 'occupancyFraction')),
            );
          }(),
      ],
    );
    var normalized = const ActualsLedger();
    for (final actual in ledger.months) {
      normalized = normalized.upsert(actual);
    }
    return normalized;
  }

  // --- metadata ---

  static Map<String, dynamic> _metadataToJson(ScenarioMetadata metadata) => {
    'id': metadata.id,
    'name': metadata.name,
    'description': metadata.description,
    'currencyCode': metadata.currencyCode,
    'createdAt': metadata.createdAt.toUtc().toIso8601String(),
    'updatedAt': metadata.updatedAt.toUtc().toIso8601String(),
    'calculationModelVersion': metadata.calculationModelVersion,
  };

  static ScenarioMetadata _metadataFromJson(Map<String, dynamic> json) {
    return ScenarioMetadata(
      id: _string(json, 'id'),
      name: _string(json, 'name'),
      description: _string(json, 'description'),
      currencyCode: _string(json, 'currencyCode'),
      createdAt: _dateTime(json, 'createdAt'),
      updatedAt: _dateTime(json, 'updatedAt'),
      calculationModelVersion: _string(json, 'calculationModelVersion'),
    );
  }

  // --- revenue ---

  static Map<String, dynamic> _revenueToJson(RevenueModel revenue) => {
    'pricing': {
      'ticketPricePerPlayerMicros': revenue.pricing.ticketPricePerPlayer.micros,
      'averagePlayersPerRound': revenue.pricing.averagePlayersPerRound,
    },
    'capacity': {
      'roundDurationMinutes': revenue.capacity.roundDuration.value,
      'turnaroundTimeMinutes': revenue.capacity.turnaroundTime.value,
      'maximumPlayersPerRound': revenue.capacity.maximumPlayersPerRound,
    },
    'schedule': {
      'hoursPerDay': revenue.schedule.hoursPerDay,
      'daysPerWeek': revenue.schedule.daysPerWeek,
      'daysPerMonth': revenue.schedule.daysPerMonth,
      if (revenue.schedule.weeklyProfile.isEnabled)
        'weeklyProfile': {
          'days': [
            for (final day in revenue.schedule.weeklyProfile.days)
              {'weekday': day.weekday, 'hours': day.hours},
          ],
        },
    },
    'occupancy': {
      'rampUpFractions': [
        for (final step in revenue.occupancy.rampUp) step.fraction,
      ],
      'stableFraction': revenue.occupancy.stable.fraction,
    },
  };

  static RevenueModel _revenueFromJson(Map<String, dynamic> json) {
    final pricing = _map(json, 'pricing');
    final capacity = _map(json, 'capacity');
    final schedule = _map(json, 'schedule');
    final occupancy = _map(json, 'occupancy');

    return RevenueModel(
      pricing: PricingModel(
        ticketPricePerPlayer: _money(pricing, 'ticketPricePerPlayerMicros'),
        averagePlayersPerRound: _double(pricing, 'averagePlayersPerRound'),
      ),
      capacity: CapacityModel(
        roundDuration: Minutes(_double(capacity, 'roundDurationMinutes')),
        turnaroundTime: Minutes(_double(capacity, 'turnaroundTimeMinutes')),
        maximumPlayersPerRound: _int(capacity, 'maximumPlayersPerRound'),
      ),
      schedule: OperatingSchedule(
        hoursPerDay: _double(schedule, 'hoursPerDay'),
        daysPerWeek: _int(schedule, 'daysPerWeek'),
        daysPerMonth: _double(schedule, 'daysPerMonth'),
        weeklyProfile: _weeklyOperatingProfileFromJson(
          schedule['weeklyProfile'],
        ),
      ),
      occupancy: OccupancySchedule(
        rampUp: [
          for (final value in _list(occupancy, 'rampUpFractions'))
            Percentage.fromFraction(_asDouble(value, 'rampUpFractions')),
        ],
        stable: Percentage.fromFraction(_double(occupancy, 'stableFraction')),
      ),
    );
  }

  static WeeklyOperatingProfile _weeklyOperatingProfileFromJson(Object? raw) {
    if (raw == null) return const WeeklyOperatingProfile();
    final json = _asMap(raw, 'weeklyProfile');
    return WeeklyOperatingProfile(
      days: [
        for (final rawDay in _list(json, 'days'))
          () {
            final day = _asMap(rawDay, 'weeklyProfile.days');
            final weekday = _int(day, 'weekday');
            final hours = _double(day, 'hours');
            if (weekday < DateTime.monday || weekday > DateTime.sunday) {
              throw FormatException(
                'weeklyProfile.days.weekday must be between 1 and 7',
              );
            }
            if (hours < 0 || hours > 24) {
              throw FormatException(
                'weeklyProfile.days.hours must be between 0 and 24',
              );
            }
            return DayOperatingHours(weekday: weekday, hours: hours);
          }(),
      ],
    );
  }

  // --- staffing ---

  static Map<String, dynamic> _staffingToJson(StaffingModel staffing) => {
    'initialEmployeeCount': staffing.initialEmployeeCount,
    'expandedEmployeeCount': staffing.expandedEmployeeCount,
    'expansionMonth': staffing.expansionMonth,
    'monthlySalaryPerEmployeeMicros': staffing.monthlySalaryPerEmployee.micros,
    'monthlyIncentivePerEmployeeMicros':
        staffing.monthlyIncentivePerEmployee.micros,
    'headcountRule': staffing.headcountRule.name,
    'regularHoursPerMonthCap': staffing.regularHoursPerMonthCap,
    'payroll': {
      'mode': staffing.payroll.mode.name,
      'sharedMonthlyPayrollBudgetMicros':
          staffing.payroll.sharedMonthlyPayrollBudget?.micros,
      'overtimeMultiplier': staffing.payroll.overtimeMultiplier,
      'staffingExpansionOccupancyThresholdFraction':
          staffing.payroll.staffingExpansionOccupancyThreshold.fraction,
      'bonus': {
        'mode': staffing.payroll.bonus.mode.name,
        'percentageOfExcessFraction':
            staffing.payroll.bonus.percentageOfExcess?.fraction,
        'revenueTargetMicros': staffing.payroll.bonus.revenueTarget?.micros,
        'thresholdMultiplierFraction':
            staffing.payroll.bonus.thresholdMultiplier?.fraction,
        'fixedBonusAmountMicros':
            staffing.payroll.bonus.fixedBonusAmount?.micros,
      },
    },
    'roster': [
      for (final employee in staffing.roster.employees)
        {
          'id': employee.id,
          'name': employee.name,
          'fixedMonthlySalaryMicros': employee.fixedMonthlySalary?.micros,
          'isFounder': employee.isFounder,
          'weeklyShifts': [
            for (final shift in employee.weeklyShifts)
              {
                'weekday': shift.weekday,
                'startHour': shift.startHour,
                'endHour': shift.endHour,
                'breakHours': shift.breakHours,
              },
          ],
        },
    ],
  };

  static StaffingModel _staffingFromJson(Map<String, dynamic> json) {
    final payroll = json['payroll'] is Map
        ? Map<String, dynamic>.from(json['payroll'] as Map)
        : null;
    final bonus = payroll?['bonus'] is Map
        ? Map<String, dynamic>.from(payroll!['bonus'] as Map)
        : null;
    return StaffingModel(
      initialEmployeeCount: _int(json, 'initialEmployeeCount'),
      expandedEmployeeCount: _int(json, 'expandedEmployeeCount'),
      expansionMonth: _int(json, 'expansionMonth'),
      monthlySalaryPerEmployee: _money(json, 'monthlySalaryPerEmployeeMicros'),
      monthlyIncentivePerEmployee: _money(
        json,
        'monthlyIncentivePerEmployeeMicros',
      ),
      headcountRule:
          _enumByNameOrNull(
            StaffingHeadcountRule.values,
            json['headcountRule'],
          ) ??
          StaffingHeadcountRule.byMonth,
      regularHoursPerMonthCap: json['regularHoursPerMonthCap'] == null
          ? null
          : _int(json, 'regularHoursPerMonthCap'),
      payroll: payroll == null
          ? const PayrollConfiguration()
          : PayrollConfiguration(
              mode:
                  _enumByNameOrNull(
                    PayrollAllocationMode.values,
                    payroll['mode'],
                  ) ??
                  PayrollAllocationMode.fixedPerEmployee,
              sharedMonthlyPayrollBudget:
                  payroll['sharedMonthlyPayrollBudgetMicros'] == null
                  ? null
                  : _money(payroll, 'sharedMonthlyPayrollBudgetMicros'),
              overtimeMultiplier: payroll['overtimeMultiplier'] == null
                  ? 1.5
                  : _double(payroll, 'overtimeMultiplier'),
              staffingExpansionOccupancyThreshold:
                  payroll['staffingExpansionOccupancyThresholdFraction'] == null
                  ? const Percentage.fromPercent(40)
                  : Percentage.fromFraction(
                      _double(
                        payroll,
                        'staffingExpansionOccupancyThresholdFraction',
                      ),
                    ),
              bonus: bonus == null
                  ? const BonusConfiguration()
                  : BonusConfiguration(
                      mode:
                          _enumByNameOrNull(BonusMode.values, bonus['mode']) ??
                          BonusMode.disabled,
                      percentageOfExcess:
                          bonus['percentageOfExcessFraction'] == null
                          ? null
                          : Percentage.fromFraction(
                              _double(bonus, 'percentageOfExcessFraction'),
                            ),
                      revenueTarget: bonus['revenueTargetMicros'] == null
                          ? null
                          : _money(bonus, 'revenueTargetMicros'),
                      thresholdMultiplier:
                          bonus['thresholdMultiplierFraction'] == null
                          ? null
                          : Percentage.fromFraction(
                              _double(bonus, 'thresholdMultiplierFraction'),
                            ),
                      fixedBonusAmount: bonus['fixedBonusAmountMicros'] == null
                          ? null
                          : _money(bonus, 'fixedBonusAmountMicros'),
                    ),
            ),
      roster: EmployeeRoster(
        employees: json['roster'] == null
            ? const []
            : [
                for (final raw in _list(json, 'roster'))
                  _employeeFromJson(_asMap(raw, 'roster')),
              ],
      ),
    );
  }

  static Employee _employeeFromJson(Map<String, dynamic> json) {
    return Employee(
      id: _string(json, 'id'),
      name: _string(json, 'name'),
      fixedMonthlySalary: json['fixedMonthlySalaryMicros'] == null
          ? null
          : _money(json, 'fixedMonthlySalaryMicros'),
      isFounder: json['isFounder'] is bool ? json['isFounder'] as bool : false,
      weeklyShifts: [
        for (final raw
            in json['weeklyShifts'] == null
                ? const <Object?>[]
                : _list(json, 'weeklyShifts'))
          () {
            final shift = _asMap(raw, 'weeklyShifts');
            return ShiftAssignment(
              weekday: _int(shift, 'weekday'),
              startHour: _double(shift, 'startHour'),
              endHour: _double(shift, 'endHour'),
              breakHours: shift['breakHours'] == null
                  ? 0
                  : _double(shift, 'breakHours'),
            );
          }(),
      ],
    );
  }

  // --- operating expenses ---

  static Map<String, dynamic> _expensesToJson(OperatingExpenseModel model) => {
    'rentMicros': model.rent.micros,
    'mallSharedServicesMicros': model.mallSharedServices.micros,
    'electricityMicros': model.electricity.micros,
    'maintenanceAndConsumablesMicros': model.maintenanceAndConsumables.micros,
    'continuousMarketingMicros': model.continuousMarketing.micros,
    'additionalExpenses': [
      for (final item in model.additionalExpenses) _costItemToJson(item),
    ],
  };

  static OperatingExpenseModel _expensesFromJson(Map<String, dynamic> json) {
    return OperatingExpenseModel(
      rent: _money(json, 'rentMicros'),
      mallSharedServices: _money(json, 'mallSharedServicesMicros'),
      electricity: _money(json, 'electricityMicros'),
      maintenanceAndConsumables: _money(
        json,
        'maintenanceAndConsumablesMicros',
      ),
      continuousMarketing: _money(json, 'continuousMarketingMicros'),
      additionalExpenses: _costItems(json, 'additionalExpenses'),
    );
  }

  // --- start-up costs ---

  static Map<String, dynamic> _startupToJson(StartupCostModel startup) => {
    'equipment': {
      'packages': [
        for (final package in startup.equipment.packages)
          {
            'id': package.id,
            'name': package.name,
            'description': package.description,
            'costMicros': package.cost.micros,
          },
      ],
      'selectedPackageId': startup.equipment.selectedPackageId,
      'shippingRateFraction': startup.equipment.shippingRate.fraction,
      'customsRateFraction': startup.equipment.customsRate.fraction,
    },
    'fitOut': {
      'receptionFurnitureMicros': startup.fitOut.receptionFurniture.micros,
      'paintingAndGraphicsMicros': startup.fitOut.paintingAndGraphics.micros,
      'signageMicros': startup.fitOut.signage.micros,
      'hvacMicros': startup.fitOut.hvac.micros,
      'installationLabourMicros': startup.fitOut.installationLabour.micros,
      'additionalItems': [
        for (final item in startup.fitOut.additionalItems)
          _costItemToJson(item),
      ],
    },
    'property': {
      'mallDepositMicros': startup.property.mallDeposit.micros,
      'contractDurationMonths': startup.property.contractDurationMonths,
    },
    'preOpening': {
      'registrationAndLicensingMicros':
          startup.preOpening.registrationAndLicensing.micros,
      'openingMarketingCampaignMicros':
          startup.preOpening.openingMarketingCampaign.micros,
      'contingencyRateFraction': startup.preOpening.contingencyRate.fraction,
      'maximumSetupDays': startup.preOpening.maximumSetupDays,
      'additionalItems': [
        for (final item in startup.preOpening.additionalItems)
          _costItemToJson(item),
      ],
    },
    'equipmentLifecycle': {
      'usefulLifeMonths': startup.equipmentLifecycle.usefulLifeMonths,
      'replacementCostMicros':
          startup.equipmentLifecycle.replacementCost.micros,
      'includeReplacementInProjection':
          startup.equipmentLifecycle.includeReplacementInProjection,
      'monthlyMaintenanceReserveMicros':
          startup.equipmentLifecycle.monthlyMaintenanceReserve.micros,
      'sparePartsReserveMonthlyMicros':
          startup.equipmentLifecycle.sparePartsReserveMonthly.micros,
    },
  };

  static StartupCostModel _startupFromJson(Map<String, dynamic> json) {
    final equipment = _map(json, 'equipment');
    final fitOut = _map(json, 'fitOut');
    final property = _map(json, 'property');
    final preOpening = _map(json, 'preOpening');

    final packages = [
      for (final raw in _list(equipment, 'packages'))
        _equipmentPackageFromJson(_asMap(raw, 'packages')),
    ];
    if (packages.isEmpty) {
      throw const FormatException(
        'A scenario needs at least one equipment package',
      );
    }

    return StartupCostModel(
      equipment: EquipmentModel(
        packages: packages,
        selectedPackageId: _string(equipment, 'selectedPackageId'),
        shippingRate: Percentage.fromFraction(
          _double(equipment, 'shippingRateFraction'),
        ),
        customsRate: Percentage.fromFraction(
          _double(equipment, 'customsRateFraction'),
        ),
      ),
      fitOut: FitOutModel(
        receptionFurniture: _money(fitOut, 'receptionFurnitureMicros'),
        paintingAndGraphics: _money(fitOut, 'paintingAndGraphicsMicros'),
        signage: _money(fitOut, 'signageMicros'),
        hvac: _money(fitOut, 'hvacMicros'),
        installationLabour: _money(fitOut, 'installationLabourMicros'),
        additionalItems: _costItems(fitOut, 'additionalItems'),
      ),
      property: PropertyModel(
        mallDeposit: _money(property, 'mallDepositMicros'),
        contractDurationMonths: _int(property, 'contractDurationMonths'),
      ),
      preOpening: PreOpeningModel(
        registrationAndLicensing: _money(
          preOpening,
          'registrationAndLicensingMicros',
        ),
        openingMarketingCampaign: _money(
          preOpening,
          'openingMarketingCampaignMicros',
        ),
        contingencyRate: Percentage.fromFraction(
          _double(preOpening, 'contingencyRateFraction'),
        ),
        maximumSetupDays: _int(preOpening, 'maximumSetupDays'),
        additionalItems: _costItems(preOpening, 'additionalItems'),
      ),
      equipmentLifecycle: _equipmentLifecycleFromJson(
        json['equipmentLifecycle'],
      ),
    );
  }

  static EquipmentLifecycleAssumptions _equipmentLifecycleFromJson(
    Object? raw,
  ) {
    if (raw == null) return const EquipmentLifecycleAssumptions();
    final json = _asMap(raw, 'equipmentLifecycle');
    return EquipmentLifecycleAssumptions(
      usefulLifeMonths: _double(json, 'usefulLifeMonths'),
      replacementCost: _money(json, 'replacementCostMicros'),
      includeReplacementInProjection: _bool(
        json,
        'includeReplacementInProjection',
      ),
      monthlyMaintenanceReserve: _money(
        json,
        'monthlyMaintenanceReserveMicros',
      ),
      sparePartsReserveMonthly: _money(json, 'sparePartsReserveMonthlyMicros'),
    );
  }

  static EquipmentPackage _equipmentPackageFromJson(Map<String, dynamic> json) {
    return EquipmentPackage(
      id: _string(json, 'id'),
      name: _string(json, 'name'),
      description: _string(json, 'description'),
      cost: _money(json, 'costMicros'),
    );
  }

  // --- sensitivity ---

  static Map<String, dynamic> _sensitivityToJson(SensitivitySettings model) => {
    'scenarios': [
      for (final scenario in model.scenarios)
        {
          'id': scenario.id,
          'kind': scenario.kind.name,
          'occupancyFraction': scenario.occupancy?.fraction,
          'customName': scenario.customName,
        },
    ],
  };

  static SensitivitySettings _sensitivityFromJson(Map<String, dynamic> json) {
    return SensitivitySettings(
      scenarios: [
        for (final raw in _list(json, 'scenarios'))
          _sensitivityScenarioFromJson(_asMap(raw, 'scenarios')),
      ],
    );
  }

  static SensitivityScenarioDefinition _sensitivityScenarioFromJson(
    Map<String, dynamic> json,
  ) {
    final occupancy = json['occupancyFraction'];
    return SensitivityScenarioDefinition(
      id: _string(json, 'id'),
      kind: _enumByName(
        SensitivityScenarioKind.values,
        _string(json, 'kind'),
        SensitivityScenarioKind.custom,
      ),
      occupancy: occupancy == null
          ? null
          : Percentage.fromFraction(_asDouble(occupancy, 'occupancyFraction')),
      customName: json['customName'] as String?,
    );
  }

  // --- annotations ---

  static Map<String, dynamic> _annotationsToJson(
    AssumptionAnnotations annotations,
  ) => {
    'defaultStatus': annotations.defaultStatus.name,
    'statuses': {
      for (final entry in annotations.statuses.entries)
        entry.key.name: entry.value.name,
    },
  };

  /// Unknown keys and statuses are dropped rather than rejected: a scenario
  /// saved by a build with more inputs must still open here.
  static AssumptionAnnotations _annotationsFromJson(Object? raw) {
    if (raw is! Map) return const AssumptionAnnotations();

    final statuses = <AssumptionKey, AssumptionStatus>{};
    final rawStatuses = raw['statuses'];
    if (rawStatuses is Map) {
      for (final entry in rawStatuses.entries) {
        final key = _enumByNameOrNull(AssumptionKey.values, entry.key);
        final status = _enumByNameOrNull(AssumptionStatus.values, entry.value);
        if (key != null && status != null) statuses[key] = status;
      }
    }

    return AssumptionAnnotations(
      statuses: statuses,
      defaultStatus:
          _enumByNameOrNull(AssumptionStatus.values, raw['defaultStatus']) ??
          AssumptionStatus.estimated,
    );
  }

  // --- shared pieces ---

  static Map<String, dynamic> _costItemToJson(CostItem item) => {
    'id': item.id,
    'label': item.label,
    'amountMicros': item.amount.micros,
    'status': item.status.name,
  };

  static List<CostItem> _costItems(Map<String, dynamic> json, String field) {
    final raw = json[field];
    if (raw == null) return const [];
    if (raw is! List) {
      throw FormatException('Field "$field" must be a list');
    }
    return [
      for (final entry in raw)
        () {
          final map = _asMap(entry, field);
          return CostItem(
            id: _string(map, 'id'),
            label: _string(map, 'label'),
            amount: _money(map, 'amountMicros'),
            status:
                _enumByNameOrNull(AssumptionStatus.values, map['status']) ??
                AssumptionStatus.userDefined,
          );
        }(),
    ];
  }

  static Map<int, double> _integerDoubleMap(
    Map<String, dynamic> json,
    String field, {
    required int minimum,
    required int maximum,
  }) {
    final raw = _map(json, field);
    final result = <int, double>{};
    for (final entry in raw.entries) {
      final key = int.tryParse(entry.key);
      if (key == null || key < minimum || key > maximum) {
        throw FormatException(
          'Field "$field" keys must be integers from $minimum to $maximum',
        );
      }
      result[key] = _asDouble(entry.value, field);
    }
    return result;
  }

  // --- strict readers ---

  static Map<String, dynamic> _map(Map<String, dynamic> json, String field) =>
      _asMap(json[field], field);

  static Map<String, dynamic> _asMap(Object? value, String field) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    throw FormatException('Field "$field" must be an object');
  }

  static List<Object?> _list(Map<String, dynamic> json, String field) {
    final value = json[field];
    if (value is List) return value;
    throw FormatException('Field "$field" must be a list');
  }

  static String _string(Map<String, dynamic> json, String field) {
    final value = json[field];
    if (value is String) return value;
    throw FormatException('Field "$field" must be a string');
  }

  static int _int(Map<String, dynamic> json, String field) {
    final value = json[field];
    if (value is int) return value;
    if (value is num && value == value.roundToDouble()) return value.toInt();
    throw FormatException('Field "$field" must be an integer');
  }

  static double _double(Map<String, dynamic> json, String field) =>
      _asDouble(json[field], field);

  static double _asDouble(Object? value, String field) {
    if (value is num) {
      if (value.isNaN || value.isInfinite) {
        throw FormatException('Field "$field" must be a finite number');
      }
      return value.toDouble();
    }
    throw FormatException('Field "$field" must be a number');
  }

  static bool _bool(Map<String, dynamic> json, String field) {
    final value = json[field];
    if (value is bool) return value;
    throw FormatException('Field "$field" must be a boolean');
  }

  static Money _money(Map<String, dynamic> json, String field) =>
      Money.fromMicros(_int(json, field));

  static DateTime _dateTime(Map<String, dynamic> json, String field) {
    final parsed = DateTime.tryParse(_string(json, field));
    if (parsed == null) {
      throw FormatException('Field "$field" must be an ISO-8601 timestamp');
    }
    return parsed;
  }

  static T _enumByName<T extends Enum>(
    List<T> values,
    String name,
    T fallback,
  ) {
    return _enumByNameOrNull(values, name) ?? fallback;
  }

  static T? _enumByNameOrNull<T extends Enum>(List<T> values, Object? name) {
    if (name is! String) return null;
    for (final value in values) {
      if (value.name == name) return value;
    }
    return null;
  }
}
