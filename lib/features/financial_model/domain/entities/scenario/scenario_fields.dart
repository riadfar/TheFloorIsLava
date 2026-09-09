import '../../value_objects/minutes.dart';
import '../../value_objects/money.dart';
import '../../value_objects/percentage.dart';
import 'assumption_status.dart';
import 'financial_scenario.dart';
import 'projection_settings.dart';
import 'revenue_model.dart';
import 'sensitivity_settings.dart';
import 'startup_cost_model.dart';
import 'working_capital_model.dart';

/// What a field measures, so the UI knows how to format and edit it without a
/// hand-written case for every input.
enum FieldUnit { money, percent, minutes, hours, days, months, count, players }

/// Everything generic code needs to know about one named input.
class ScenarioField {
  const ScenarioField({
    required this.key,
    required this.unit,
    this.decimals = 2,
  });

  final AssumptionKey key;
  final FieldUnit unit;

  /// Decimal places offered when editing. Whole-number fields use 0 so the
  /// keyboard and the value agree.
  final int decimals;

  bool get isInteger => decimals == 0;
}

/// Reads and writes the scenario's named numeric inputs by key.
///
/// One table maps each [AssumptionKey] to the place it lives in the scenario
/// tree. Validation, editing and display all go through it, so an input can
/// never be validated as one thing and written as another - and a new input is
/// added in one place rather than five.
///
/// Units are the ones a person would type: money in major units, percentages in
/// percentage points, durations in minutes.
abstract final class ScenarioFields {
  static const Map<AssumptionKey, ScenarioField> descriptors = {
    AssumptionKey.roundDuration: ScenarioField(
      key: AssumptionKey.roundDuration,
      unit: FieldUnit.minutes,
      decimals: 0,
    ),
    AssumptionKey.turnaroundTime: ScenarioField(
      key: AssumptionKey.turnaroundTime,
      unit: FieldUnit.minutes,
      decimals: 0,
    ),
    AssumptionKey.ticketPrice: ScenarioField(
      key: AssumptionKey.ticketPrice,
      unit: FieldUnit.money,
    ),
    AssumptionKey.averagePlayersPerRound: ScenarioField(
      key: AssumptionKey.averagePlayersPerRound,
      unit: FieldUnit.players,
    ),
    AssumptionKey.maximumPlayersPerRound: ScenarioField(
      key: AssumptionKey.maximumPlayersPerRound,
      unit: FieldUnit.count,
      decimals: 0,
    ),
    AssumptionKey.operatingHoursPerDay: ScenarioField(
      key: AssumptionKey.operatingHoursPerDay,
      unit: FieldUnit.hours,
      decimals: 1,
    ),
    AssumptionKey.operatingDaysPerWeek: ScenarioField(
      key: AssumptionKey.operatingDaysPerWeek,
      unit: FieldUnit.days,
      decimals: 0,
    ),
    AssumptionKey.operatingDaysPerMonth: ScenarioField(
      key: AssumptionKey.operatingDaysPerMonth,
      unit: FieldUnit.days,
      decimals: 1,
    ),
    AssumptionKey.occupancyMonth1: ScenarioField(
      key: AssumptionKey.occupancyMonth1,
      unit: FieldUnit.percent,
      decimals: 1,
    ),
    AssumptionKey.occupancyMonth2: ScenarioField(
      key: AssumptionKey.occupancyMonth2,
      unit: FieldUnit.percent,
      decimals: 1,
    ),
    AssumptionKey.occupancyMonth3: ScenarioField(
      key: AssumptionKey.occupancyMonth3,
      unit: FieldUnit.percent,
      decimals: 1,
    ),
    AssumptionKey.stableOccupancy: ScenarioField(
      key: AssumptionKey.stableOccupancy,
      unit: FieldUnit.percent,
      decimals: 1,
    ),
    AssumptionKey.initialEmployeeCount: ScenarioField(
      key: AssumptionKey.initialEmployeeCount,
      unit: FieldUnit.count,
      decimals: 0,
    ),
    AssumptionKey.expandedEmployeeCount: ScenarioField(
      key: AssumptionKey.expandedEmployeeCount,
      unit: FieldUnit.count,
      decimals: 0,
    ),
    AssumptionKey.expansionMonth: ScenarioField(
      key: AssumptionKey.expansionMonth,
      unit: FieldUnit.months,
      decimals: 0,
    ),
    AssumptionKey.monthlySalaryPerEmployee: ScenarioField(
      key: AssumptionKey.monthlySalaryPerEmployee,
      unit: FieldUnit.money,
    ),
    AssumptionKey.monthlyIncentivePerEmployee: ScenarioField(
      key: AssumptionKey.monthlyIncentivePerEmployee,
      unit: FieldUnit.money,
    ),
    AssumptionKey.rent: ScenarioField(
      key: AssumptionKey.rent,
      unit: FieldUnit.money,
    ),
    AssumptionKey.mallSharedServices: ScenarioField(
      key: AssumptionKey.mallSharedServices,
      unit: FieldUnit.money,
    ),
    AssumptionKey.electricity: ScenarioField(
      key: AssumptionKey.electricity,
      unit: FieldUnit.money,
    ),
    AssumptionKey.maintenance: ScenarioField(
      key: AssumptionKey.maintenance,
      unit: FieldUnit.money,
    ),
    AssumptionKey.continuousMarketing: ScenarioField(
      key: AssumptionKey.continuousMarketing,
      unit: FieldUnit.money,
    ),
    AssumptionKey.mallDeposit: ScenarioField(
      key: AssumptionKey.mallDeposit,
      unit: FieldUnit.money,
    ),
    AssumptionKey.contractDurationMonths: ScenarioField(
      key: AssumptionKey.contractDurationMonths,
      unit: FieldUnit.months,
      decimals: 0,
    ),
    AssumptionKey.shippingRate: ScenarioField(
      key: AssumptionKey.shippingRate,
      unit: FieldUnit.percent,
      decimals: 1,
    ),
    AssumptionKey.customsRate: ScenarioField(
      key: AssumptionKey.customsRate,
      unit: FieldUnit.percent,
      decimals: 1,
    ),
    AssumptionKey.fitOutFurniture: ScenarioField(
      key: AssumptionKey.fitOutFurniture,
      unit: FieldUnit.money,
    ),
    AssumptionKey.fitOutPainting: ScenarioField(
      key: AssumptionKey.fitOutPainting,
      unit: FieldUnit.money,
    ),
    AssumptionKey.fitOutSignage: ScenarioField(
      key: AssumptionKey.fitOutSignage,
      unit: FieldUnit.money,
    ),
    AssumptionKey.fitOutHvac: ScenarioField(
      key: AssumptionKey.fitOutHvac,
      unit: FieldUnit.money,
    ),
    AssumptionKey.fitOutInstallationLabour: ScenarioField(
      key: AssumptionKey.fitOutInstallationLabour,
      unit: FieldUnit.money,
    ),
    AssumptionKey.licensing: ScenarioField(
      key: AssumptionKey.licensing,
      unit: FieldUnit.money,
    ),
    AssumptionKey.openingMarketing: ScenarioField(
      key: AssumptionKey.openingMarketing,
      unit: FieldUnit.money,
    ),
    AssumptionKey.contingencyRate: ScenarioField(
      key: AssumptionKey.contingencyRate,
      unit: FieldUnit.percent,
      decimals: 1,
    ),
    AssumptionKey.maximumSetupDays: ScenarioField(
      key: AssumptionKey.maximumSetupDays,
      unit: FieldUnit.days,
      decimals: 0,
    ),
    AssumptionKey.projectionMonths: ScenarioField(
      key: AssumptionKey.projectionMonths,
      unit: FieldUnit.months,
      decimals: 0,
    ),
    AssumptionKey.conservativeOccupancy: ScenarioField(
      key: AssumptionKey.conservativeOccupancy,
      unit: FieldUnit.percent,
      decimals: 1,
    ),
    AssumptionKey.optimisticOccupancy: ScenarioField(
      key: AssumptionKey.optimisticOccupancy,
      unit: FieldUnit.percent,
      decimals: 1,
    ),
    AssumptionKey.annualDiscountRate: ScenarioField(
      key: AssumptionKey.annualDiscountRate,
      unit: FieldUnit.percent,
      decimals: 1,
    ),
    AssumptionKey.workingCapitalFixed: ScenarioField(
      key: AssumptionKey.workingCapitalFixed,
      unit: FieldUnit.money,
    ),
    AssumptionKey.openingDelayBuffer: ScenarioField(
      key: AssumptionKey.openingDelayBuffer,
      unit: FieldUnit.money,
    ),
    AssumptionKey.criticalFailureStartMonth: ScenarioField(
      key: AssumptionKey.criticalFailureStartMonth,
      unit: FieldUnit.months,
      decimals: 0,
    ),
    AssumptionKey.criticalFailureDowntimeDays: ScenarioField(
      key: AssumptionKey.criticalFailureDowntimeDays,
      unit: FieldUnit.days,
      decimals: 0,
    ),
  };

  static ScenarioField? descriptorFor(AssumptionKey key) => descriptors[key];

  /// The current value of a named input, or `null` when the scenario has no
  /// such input (for example a ramp-up month that is not configured, or the
  /// equipment selection, which is a choice rather than a number).
  static num? read(FinancialScenario scenario, AssumptionKey key) {
    final revenue = scenario.revenue;
    final staffing = scenario.staffing;
    final expenses = scenario.operatingExpenses;
    final startup = scenario.startupCosts;

    return switch (key) {
      AssumptionKey.roundDuration => revenue.capacity.roundDuration.value,
      AssumptionKey.turnaroundTime => revenue.capacity.turnaroundTime.value,
      AssumptionKey.ticketPrice => revenue.pricing.ticketPricePerPlayer.amount,
      AssumptionKey.averagePlayersPerRound =>
        revenue.pricing.averagePlayersPerRound,
      AssumptionKey.maximumPlayersPerRound =>
        revenue.capacity.maximumPlayersPerRound,
      AssumptionKey.operatingHoursPerDay => revenue.schedule.hoursPerDay,
      AssumptionKey.operatingDaysPerWeek => revenue.schedule.daysPerWeek,
      AssumptionKey.operatingDaysPerMonth => revenue.schedule.daysPerMonth,
      AssumptionKey.occupancyMonth1 => _rampUpPercent(revenue.occupancy, 1),
      AssumptionKey.occupancyMonth2 => _rampUpPercent(revenue.occupancy, 2),
      AssumptionKey.occupancyMonth3 => _rampUpPercent(revenue.occupancy, 3),
      AssumptionKey.stableOccupancy => revenue.occupancy.stable.percent,
      AssumptionKey.initialEmployeeCount => staffing.initialEmployeeCount,
      AssumptionKey.expandedEmployeeCount => staffing.expandedEmployeeCount,
      AssumptionKey.expansionMonth => staffing.expansionMonth,
      AssumptionKey.monthlySalaryPerEmployee =>
        staffing.monthlySalaryPerEmployee.amount,
      AssumptionKey.monthlyIncentivePerEmployee =>
        staffing.monthlyIncentivePerEmployee.amount,
      AssumptionKey.rent => expenses.rent.amount,
      AssumptionKey.mallSharedServices => expenses.mallSharedServices.amount,
      AssumptionKey.electricity => expenses.electricity.amount,
      AssumptionKey.maintenance => expenses.maintenanceAndConsumables.amount,
      AssumptionKey.continuousMarketing => expenses.continuousMarketing.amount,
      AssumptionKey.mallDeposit => startup.property.mallDeposit.amount,
      AssumptionKey.contractDurationMonths =>
        startup.property.contractDurationMonths,
      AssumptionKey.shippingRate => startup.equipment.shippingRate.percent,
      AssumptionKey.customsRate => startup.equipment.customsRate.percent,
      AssumptionKey.fitOutFurniture => startup.fitOut.receptionFurniture.amount,
      AssumptionKey.fitOutPainting => startup.fitOut.paintingAndGraphics.amount,
      AssumptionKey.fitOutSignage => startup.fitOut.signage.amount,
      AssumptionKey.fitOutHvac => startup.fitOut.hvac.amount,
      AssumptionKey.fitOutInstallationLabour =>
        startup.fitOut.installationLabour.amount,
      AssumptionKey.licensing =>
        startup.preOpening.registrationAndLicensing.amount,
      AssumptionKey.openingMarketing =>
        startup.preOpening.openingMarketingCampaign.amount,
      AssumptionKey.contingencyRate =>
        startup.preOpening.contingencyRate.percent,
      AssumptionKey.maximumSetupDays => startup.preOpening.maximumSetupDays,
      AssumptionKey.projectionMonths => scenario.projection.projectionMonths,
      AssumptionKey.conservativeOccupancy => _sensitivityPercent(
        scenario,
        SensitivityScenarioKind.conservative,
      ),
      AssumptionKey.optimisticOccupancy => _sensitivityPercent(
        scenario,
        SensitivityScenarioKind.optimistic,
      ),
      AssumptionKey.annualDiscountRate =>
        scenario.investmentAssumptions.annualDiscountRate.percent,
      AssumptionKey.workingCapitalFixed =>
        scenario.workingCapital.fixedAmount.amount,
      AssumptionKey.openingDelayBuffer =>
        scenario.fundingAssumptions.openingDelayBuffer.amount,
      AssumptionKey.criticalFailureStartMonth =>
        scenario.stressAssumptions.failureStartMonth,
      AssumptionKey.criticalFailureDowntimeDays =>
        scenario.stressAssumptions.downtimeDays,
      // Not a number: the equipment choice is made by selecting a package.
      AssumptionKey.selectedEquipmentPackage => null,
    };
  }

  /// Returns a copy of [scenario] with one named input changed.
  ///
  /// The value is taken at face value; whether it is *allowed* is the
  /// validator's decision, so that the UI can show a scenario with an invalid
  /// field rather than silently refusing the keystroke.
  static FinancialScenario write(
    FinancialScenario scenario,
    AssumptionKey key,
    num value,
  ) {
    final revenue = scenario.revenue;
    final staffing = scenario.staffing;
    final expenses = scenario.operatingExpenses;
    final startup = scenario.startupCosts;

    switch (key) {
      case AssumptionKey.roundDuration:
        return scenario.copyWith(
          revenue: revenue.copyWith(
            capacity: revenue.capacity.copyWith(
              roundDuration: Minutes(value.toDouble()),
            ),
          ),
        );
      case AssumptionKey.turnaroundTime:
        return scenario.copyWith(
          revenue: revenue.copyWith(
            capacity: revenue.capacity.copyWith(
              turnaroundTime: Minutes(value.toDouble()),
            ),
          ),
        );
      case AssumptionKey.ticketPrice:
        return scenario.copyWith(
          revenue: revenue.copyWith(
            pricing: revenue.pricing.copyWith(
              ticketPricePerPlayer: Money.of(value),
            ),
          ),
        );
      case AssumptionKey.averagePlayersPerRound:
        return scenario.copyWith(
          revenue: revenue.copyWith(
            pricing: revenue.pricing.copyWith(
              averagePlayersPerRound: value.toDouble(),
            ),
          ),
        );
      case AssumptionKey.maximumPlayersPerRound:
        return scenario.copyWith(
          revenue: revenue.copyWith(
            capacity: revenue.capacity.copyWith(
              maximumPlayersPerRound: value.round(),
            ),
          ),
        );
      case AssumptionKey.operatingHoursPerDay:
        return scenario.copyWith(
          revenue: revenue.copyWith(
            schedule: revenue.schedule.copyWith(hoursPerDay: value.toDouble()),
          ),
        );
      case AssumptionKey.operatingDaysPerWeek:
        return scenario.copyWith(
          revenue: revenue.copyWith(
            schedule: revenue.schedule.copyWith(daysPerWeek: value.round()),
          ),
        );
      case AssumptionKey.operatingDaysPerMonth:
        return scenario.copyWith(
          revenue: revenue.copyWith(
            schedule: revenue.schedule.copyWith(daysPerMonth: value.toDouble()),
          ),
        );
      case AssumptionKey.occupancyMonth1:
        return _writeRampUp(scenario, 1, value);
      case AssumptionKey.occupancyMonth2:
        return _writeRampUp(scenario, 2, value);
      case AssumptionKey.occupancyMonth3:
        return _writeRampUp(scenario, 3, value);
      case AssumptionKey.stableOccupancy:
        return scenario.copyWith(
          revenue: revenue.copyWith(
            occupancy: revenue.occupancy.copyWith(
              stable: Percentage.fromPercent(value),
            ),
          ),
        );
      case AssumptionKey.initialEmployeeCount:
        return scenario.copyWith(
          staffing: staffing.copyWith(initialEmployeeCount: value.round()),
        );
      case AssumptionKey.expandedEmployeeCount:
        return scenario.copyWith(
          staffing: staffing.copyWith(expandedEmployeeCount: value.round()),
        );
      case AssumptionKey.expansionMonth:
        return scenario.copyWith(
          staffing: staffing.copyWith(expansionMonth: value.round()),
        );
      case AssumptionKey.monthlySalaryPerEmployee:
        return scenario.copyWith(
          staffing: staffing.copyWith(
            monthlySalaryPerEmployee: Money.of(value),
          ),
        );
      case AssumptionKey.monthlyIncentivePerEmployee:
        return scenario.copyWith(
          staffing: staffing.copyWith(
            monthlyIncentivePerEmployee: Money.of(value),
          ),
        );
      case AssumptionKey.rent:
        return scenario.copyWith(
          operatingExpenses: expenses.copyWith(rent: Money.of(value)),
        );
      case AssumptionKey.mallSharedServices:
        return scenario.copyWith(
          operatingExpenses: expenses.copyWith(
            mallSharedServices: Money.of(value),
          ),
        );
      case AssumptionKey.electricity:
        return scenario.copyWith(
          operatingExpenses: expenses.copyWith(electricity: Money.of(value)),
        );
      case AssumptionKey.maintenance:
        return scenario.copyWith(
          operatingExpenses: expenses.copyWith(
            maintenanceAndConsumables: Money.of(value),
          ),
        );
      case AssumptionKey.continuousMarketing:
        return scenario.copyWith(
          operatingExpenses: expenses.copyWith(
            continuousMarketing: Money.of(value),
          ),
        );
      case AssumptionKey.mallDeposit:
        return scenario.copyWith(
          startupCosts: startup.copyWith(
            property: startup.property.copyWith(mallDeposit: Money.of(value)),
          ),
        );
      case AssumptionKey.contractDurationMonths:
        return scenario.copyWith(
          startupCosts: startup.copyWith(
            property: startup.property.copyWith(
              contractDurationMonths: value.round(),
            ),
          ),
        );
      case AssumptionKey.shippingRate:
        return scenario.copyWith(
          startupCosts: startup.copyWith(
            equipment: startup.equipment.copyWith(
              shippingRate: Percentage.fromPercent(value),
            ),
          ),
        );
      case AssumptionKey.customsRate:
        return scenario.copyWith(
          startupCosts: startup.copyWith(
            equipment: startup.equipment.copyWith(
              customsRate: Percentage.fromPercent(value),
            ),
          ),
        );
      case AssumptionKey.fitOutFurniture:
        return _writeFitOut(
          scenario,
          startup.fitOut.copyWith(receptionFurniture: Money.of(value)),
        );
      case AssumptionKey.fitOutPainting:
        return _writeFitOut(
          scenario,
          startup.fitOut.copyWith(paintingAndGraphics: Money.of(value)),
        );
      case AssumptionKey.fitOutSignage:
        return _writeFitOut(
          scenario,
          startup.fitOut.copyWith(signage: Money.of(value)),
        );
      case AssumptionKey.fitOutHvac:
        return _writeFitOut(
          scenario,
          startup.fitOut.copyWith(hvac: Money.of(value)),
        );
      case AssumptionKey.fitOutInstallationLabour:
        return _writeFitOut(
          scenario,
          startup.fitOut.copyWith(installationLabour: Money.of(value)),
        );
      case AssumptionKey.licensing:
        return _writePreOpening(
          scenario,
          startup.preOpening.copyWith(
            registrationAndLicensing: Money.of(value),
          ),
        );
      case AssumptionKey.openingMarketing:
        return _writePreOpening(
          scenario,
          startup.preOpening.copyWith(
            openingMarketingCampaign: Money.of(value),
          ),
        );
      case AssumptionKey.contingencyRate:
        return _writePreOpening(
          scenario,
          startup.preOpening.copyWith(
            contingencyRate: Percentage.fromPercent(value),
          ),
        );
      case AssumptionKey.maximumSetupDays:
        return _writePreOpening(
          scenario,
          startup.preOpening.copyWith(maximumSetupDays: value.round()),
        );
      case AssumptionKey.projectionMonths:
        return scenario.copyWith(
          projection: ProjectionSettings(projectionMonths: value.round()),
        );
      case AssumptionKey.conservativeOccupancy:
        return _writeSensitivity(
          scenario,
          SensitivityScenarioKind.conservative,
          value,
        );
      case AssumptionKey.optimisticOccupancy:
        return _writeSensitivity(
          scenario,
          SensitivityScenarioKind.optimistic,
          value,
        );
      case AssumptionKey.annualDiscountRate:
        return scenario.copyWith(
          investmentAssumptions: scenario.investmentAssumptions.copyWith(
            annualDiscountRate: Percentage.fromPercent(value),
          ),
        );
      case AssumptionKey.workingCapitalFixed:
        return scenario.copyWith(
          workingCapital: scenario.workingCapital.copyWith(
            method: WorkingCapitalMethod.fixedAmount,
            fixedAmount: Money.of(value),
          ),
        );
      case AssumptionKey.openingDelayBuffer:
        return scenario.copyWith(
          fundingAssumptions: scenario.fundingAssumptions.copyWith(
            openingDelayBuffer: Money.of(value),
          ),
        );
      case AssumptionKey.criticalFailureStartMonth:
        return scenario.copyWith(
          stressAssumptions: scenario.stressAssumptions.copyWith(
            failureStartMonth: value.round().clamp(1, 120),
          ),
        );
      case AssumptionKey.criticalFailureDowntimeDays:
        return scenario.copyWith(
          stressAssumptions: scenario.stressAssumptions.copyWith(
            downtimeDays: value.round().clamp(0, 31),
          ),
        );
      case AssumptionKey.selectedEquipmentPackage:
        // Chosen from a list, not typed. Use [selectEquipmentPackage].
        return scenario;
    }
  }

  /// Switches the equipment option the scenario is costed against.
  static FinancialScenario selectEquipmentPackage(
    FinancialScenario scenario,
    String packageId,
  ) {
    return scenario.copyWith(
      startupCosts: scenario.startupCosts.copyWith(
        equipment: scenario.startupCosts.equipment.copyWith(
          selectedPackageId: packageId,
        ),
      ),
    );
  }

  /// Changes the price of one equipment option.
  static FinancialScenario setEquipmentPackageCost(
    FinancialScenario scenario,
    String packageId,
    Money cost,
  ) {
    final equipment = scenario.startupCosts.equipment;
    final package = equipment.packages.firstWhere(
      (candidate) => candidate.id == packageId,
    );
    return scenario.copyWith(
      startupCosts: scenario.startupCosts.copyWith(
        equipment: equipment.withPackage(package.copyWith(cost: cost)),
      ),
    );
  }

  static num? _rampUpPercent(OccupancySchedule occupancy, int month) {
    if (month > occupancy.rampUp.length) return null;
    return occupancy.rampUp[month - 1].percent;
  }

  static num? _sensitivityPercent(
    FinancialScenario scenario,
    SensitivityScenarioKind kind,
  ) {
    for (final definition in scenario.sensitivity.scenarios) {
      if (definition.kind == kind) return definition.occupancy?.percent;
    }
    return null;
  }

  static FinancialScenario _writeRampUp(
    FinancialScenario scenario,
    int month,
    num percent,
  ) {
    return scenario.copyWith(
      revenue: scenario.revenue.copyWith(
        occupancy: scenario.revenue.occupancy.withRampUpMonth(
          month,
          Percentage.fromPercent(percent),
        ),
      ),
    );
  }

  static FinancialScenario _writeFitOut(
    FinancialScenario scenario,
    FitOutModel fitOut,
  ) {
    return scenario.copyWith(
      startupCosts: scenario.startupCosts.copyWith(fitOut: fitOut),
    );
  }

  static FinancialScenario _writePreOpening(
    FinancialScenario scenario,
    PreOpeningModel preOpening,
  ) {
    return scenario.copyWith(
      startupCosts: scenario.startupCosts.copyWith(preOpening: preOpening),
    );
  }

  static FinancialScenario _writeSensitivity(
    FinancialScenario scenario,
    SensitivityScenarioKind kind,
    num percent,
  ) {
    final scenarios = [
      for (final definition in scenario.sensitivity.scenarios)
        if (definition.kind == kind)
          definition.copyWith(occupancy: Percentage.fromPercent(percent))
        else
          definition,
    ];
    return scenario.copyWith(
      sensitivity: scenario.sensitivity.copyWith(scenarios: scenarios),
    );
  }
}
