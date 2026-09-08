import '../../domain/entities/scenario/assumption_status.dart';
import '../../domain/entities/scenario/cost_item.dart';
import '../../domain/entities/scenario/financial_scenario.dart';
import '../../domain/entities/scenario/operating_expense_model.dart';
import '../../domain/entities/scenario/projection_settings.dart';
import '../../domain/entities/scenario/revenue_model.dart';
import '../../domain/entities/scenario/scenario_metadata.dart';
import '../../domain/entities/scenario/sensitivity_settings.dart';
import '../../domain/entities/scenario/staffing_model.dart';
import '../../domain/entities/scenario/startup_cost_model.dart';
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
  static const int schemaVersion = 1;

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
      sensitivity: _sensitivityFromJson(_map(json, 'sensitivity')),
      annotations: _annotationsFromJson(json['annotations']),
    );
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

  // --- staffing ---

  static Map<String, dynamic> _staffingToJson(StaffingModel staffing) => {
    'initialEmployeeCount': staffing.initialEmployeeCount,
    'expandedEmployeeCount': staffing.expandedEmployeeCount,
    'expansionMonth': staffing.expansionMonth,
    'monthlySalaryPerEmployeeMicros': staffing.monthlySalaryPerEmployee.micros,
    'monthlyIncentivePerEmployeeMicros':
        staffing.monthlyIncentivePerEmployee.micros,
  };

  static StaffingModel _staffingFromJson(Map<String, dynamic> json) {
    return StaffingModel(
      initialEmployeeCount: _int(json, 'initialEmployeeCount'),
      expandedEmployeeCount: _int(json, 'expandedEmployeeCount'),
      expansionMonth: _int(json, 'expansionMonth'),
      monthlySalaryPerEmployee: _money(json, 'monthlySalaryPerEmployeeMicros'),
      monthlyIncentivePerEmployee: _money(
        json,
        'monthlyIncentivePerEmployeeMicros',
      ),
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
