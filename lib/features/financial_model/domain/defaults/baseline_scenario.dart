import '../entities/scenario/assumption_status.dart';
import '../entities/scenario/financial_scenario.dart';
import '../entities/scenario/operating_expense_model.dart';
import '../entities/scenario/projection_settings.dart';
import '../entities/scenario/revenue_model.dart';
import '../entities/scenario/scenario_metadata.dart';
import '../entities/scenario/sensitivity_settings.dart';
import '../entities/scenario/staffing_model.dart';
import '../entities/scenario/startup_cost_model.dart';
import '../value_objects/minutes.dart';
import '../value_objects/money.dart';
import '../value_objects/percentage.dart';

/// The Floor is Lava feasibility study, expressed as a scenario.
///
/// These are seed values, not constants. Every one of them is editable in the
/// application, and every derived figure recalculates from whatever the user
/// leaves here. The workbook is the reference the regression tests measure
/// against; it is not a runtime dependency of the app.
abstract final class BaselineScenario {
  static const String scenarioId = 'floor-is-lava-base';
  static const String equipmentPackage1Id = 'grid-room-complete';
  static const String equipmentPackage2Id = 'individual-components';

  static const String conservativeScenarioId = 'conservative';
  static const String baseScenarioId = 'base';
  static const String optimisticScenarioId = 'optimistic';

  /// Builds the baseline. [now] is injected so the result is reproducible in
  /// tests.
  static FinancialScenario build({DateTime? now}) {
    final timestamp = now ?? DateTime.now();
    return FinancialScenario(
      metadata: ScenarioMetadata(
        id: scenarioId,
        name: 'Floor is Lava - Base',
        description:
            'Baseline feasibility study for a Floor is Lava grid room in a '
            'shopping mall.',
        currencyCode: 'USD',
        createdAt: timestamp,
        updatedAt: timestamp,
        calculationModelVersion:
            FinancialScenario.currentCalculationModelVersion,
      ),
      revenue: const RevenueModel(
        pricing: PricingModel(
          ticketPricePerPlayer: Money.units(4),
          // An average, not a headcount - the fractional value is deliberate.
          averagePlayersPerRound: 3.63,
        ),
        capacity: CapacityModel(
          roundDuration: Minutes(15),
          turnaroundTime: Minutes(5),
          maximumPlayersPerRound: 6,
        ),
        // Roughly 1 PM to 2 AM, seven days a week.
        schedule: OperatingSchedule(
          hoursPerDay: 13,
          daysPerWeek: 7,
          daysPerMonth: 30.4,
        ),
        occupancy: OccupancySchedule(
          rampUp: [
            Percentage.fromPercent(8),
            Percentage.fromPercent(23),
            Percentage.fromPercent(46),
          ],
          stable: Percentage.fromPercent(69),
        ),
      ),
      staffing: const StaffingModel(
        initialEmployeeCount: 2,
        expandedEmployeeCount: 3,
        expansionMonth: 3,
        monthlySalaryPerEmployee: Money.units(160),
        monthlyIncentivePerEmployee: Money.units(30),
      ),
      operatingExpenses: const OperatingExpenseModel(
        rent: Money.units(3000),
        mallSharedServices: Money.units(50),
        electricity: Money.units(250),
        maintenanceAndConsumables: Money.units(100),
        continuousMarketing: Money.units(150),
      ),
      startupCosts: const StartupCostModel(
        equipment: EquipmentModel(
          packages: [
            EquipmentPackage(
              id: equipmentPackage1Id,
              name: 'Package 1 - complete Grid Room',
              description: 'Turnkey grid room supplied as a single package.',
              cost: Money.units(10285),
            ),
            EquipmentPackage(
              id: equipmentPackage2Id,
              name: 'Package 2 - individual components',
              description:
                  'Components sourced separately and assembled on site.',
              cost: Money.units(5270),
            ),
          ],
          selectedPackageId: equipmentPackage2Id,
          shippingRate: Percentage.fromPercent(12),
          customsRate: Percentage.fromPercent(25),
        ),
        fitOut: FitOutModel(
          receptionFurniture: Money.units(300),
          paintingAndGraphics: Money.units(200),
          signage: Money.units(100),
          hvac: Money.units(800),
          installationLabour: Money.units(1000),
        ),
        property: PropertyModel(
          mallDeposit: Money.zero,
          contractDurationMonths: 12,
        ),
        preOpening: PreOpeningModel(
          registrationAndLicensing: Money.units(300),
          openingMarketingCampaign: Money.units(2000),
          contingencyRate: Percentage.fromPercent(10),
          maximumSetupDays: 24,
        ),
      ),
      projection: const ProjectionSettings(projectionMonths: 24),
      sensitivity: const SensitivitySettings(
        scenarios: [
          SensitivityScenarioDefinition(
            id: conservativeScenarioId,
            kind: SensitivityScenarioKind.conservative,
            occupancy: Percentage.fromPercent(20),
          ),
          // No occupancy of its own: the base case tracks whatever stable
          // occupancy the scenario is set to.
          SensitivityScenarioDefinition(
            id: baseScenarioId,
            kind: SensitivityScenarioKind.base,
          ),
          SensitivityScenarioDefinition(
            id: optimisticScenarioId,
            kind: SensitivityScenarioKind.optimistic,
            occupancy: Percentage.fromPercent(60),
          ),
        ],
      ),
      annotations: annotations,
    );
  }

  /// How much confidence the study attaches to each input.
  ///
  /// The workbook is explicit that rent, key money, freight, customs and
  /// occupancy are guesses; equipment quotes and the operator's own pricing are
  /// firmer. Anything not listed falls back to "estimated".
  static const AssumptionAnnotations annotations = AssumptionAnnotations(
    statuses: {
      AssumptionKey.roundDuration: AssumptionStatus.confirmed,
      AssumptionKey.turnaroundTime: AssumptionStatus.confirmed,
      AssumptionKey.ticketPrice: AssumptionStatus.confirmed,
      AssumptionKey.maximumPlayersPerRound: AssumptionStatus.confirmed,
      AssumptionKey.operatingHoursPerDay: AssumptionStatus.confirmed,
      AssumptionKey.operatingDaysPerWeek: AssumptionStatus.confirmed,
      AssumptionKey.operatingDaysPerMonth: AssumptionStatus.confirmed,
      AssumptionKey.selectedEquipmentPackage: AssumptionStatus.verified,
      AssumptionKey.monthlySalaryPerEmployee: AssumptionStatus.verified,
      AssumptionKey.monthlyIncentivePerEmployee: AssumptionStatus.verified,
      AssumptionKey.licensing: AssumptionStatus.verified,
      AssumptionKey.openingMarketing: AssumptionStatus.verified,
      AssumptionKey.fitOutFurniture: AssumptionStatus.verified,
      AssumptionKey.fitOutPainting: AssumptionStatus.verified,
      AssumptionKey.fitOutSignage: AssumptionStatus.verified,
      AssumptionKey.fitOutHvac: AssumptionStatus.verified,
      AssumptionKey.fitOutInstallationLabour: AssumptionStatus.verified,
    },
    defaultStatus: AssumptionStatus.estimated,
  );
}
