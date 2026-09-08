import '../entities/results/startup_cost_breakdown.dart';
import '../entities/scenario/financial_scenario.dart';
import '../entities/scenario/startup_cost_model.dart';
import '../value_objects/money.dart';
import '../value_objects/percentage.dart';

/// Builds the initial investment from its components.
///
/// The result carries the individual lines as well as the totals, so the
/// start-up screen can expand any subtotal without re-deriving what belongs in
/// it.
class StartupCostCalculator {
  const StartupCostCalculator();

  Money equipmentCost(EquipmentModel equipment) =>
      equipment.selectedPackage.cost;

  Money shipping(EquipmentModel equipment) =>
      equipmentCost(equipment) * equipment.shippingRate.fraction;

  Money customs(EquipmentModel equipment) =>
      equipmentCost(equipment) * equipment.customsRate.fraction;

  /// Equipment landed and cleared.
  Money deliveredEquipment(EquipmentModel equipment) =>
      equipmentCost(equipment) + shipping(equipment) + customs(equipment);

  Money fitOutTotal(FitOutModel fitOut) => Money.sum([
    fitOut.receptionFurniture,
    fitOut.paintingAndGraphics,
    fitOut.signage,
    fitOut.hvac,
    fitOut.installationLabour,
    ...fitOut.additionalItems.map((item) => item.amount),
  ]);

  /// Deposit plus the first month's rent, taken from the recurring rent input
  /// so the two can never disagree.
  Money propertyTotal({
    required Money mallDeposit,
    required Money monthlyRent,
  }) => mallDeposit + monthlyRent;

  Money preOpeningTotal(PreOpeningModel preOpening) => Money.sum([
    preOpening.registrationAndLicensing,
    preOpening.openingMarketingCampaign,
    ...preOpening.additionalItems.map((item) => item.amount),
  ]);

  Money contingency({
    required Money subtotal,
    required Percentage contingencyRate,
  }) {
    return subtotal * contingencyRate.fraction;
  }

  StartupCostBreakdown calculate(FinancialScenario scenario) {
    final startup = scenario.startupCosts;
    final equipment = startup.equipment;

    final equipmentAmount = equipmentCost(equipment);
    final shippingAmount = shipping(equipment);
    final customsAmount = customs(equipment);

    final deliveredEquipmentGroup = StartupCostGroup(
      id: StartupCostGroupId.deliveredEquipment,
      lines: [
        StartupCostLine(
          id: StartupCostLineId.equipment,
          amount: equipmentAmount,
        ),
        StartupCostLine(id: StartupCostLineId.shipping, amount: shippingAmount),
        StartupCostLine(id: StartupCostLineId.customs, amount: customsAmount),
      ],
      total: equipmentAmount + shippingAmount + customsAmount,
    );

    final fitOut = startup.fitOut;
    final fitOutGroup = StartupCostGroup(
      id: StartupCostGroupId.fitOut,
      lines: [
        StartupCostLine(
          id: StartupCostLineId.fitOutFurniture,
          amount: fitOut.receptionFurniture,
        ),
        StartupCostLine(
          id: StartupCostLineId.fitOutPainting,
          amount: fitOut.paintingAndGraphics,
        ),
        StartupCostLine(
          id: StartupCostLineId.fitOutSignage,
          amount: fitOut.signage,
        ),
        StartupCostLine(id: StartupCostLineId.fitOutHvac, amount: fitOut.hvac),
        StartupCostLine(
          id: StartupCostLineId.fitOutInstallationLabour,
          amount: fitOut.installationLabour,
        ),
        for (final item in fitOut.additionalItems)
          StartupCostLine(
            id: StartupCostLineId.custom,
            amount: item.amount,
            customLabel: item.label,
          ),
      ],
      total: fitOutTotal(fitOut),
    );

    final monthlyRent = scenario.operatingExpenses.rent;
    final propertyGroup = StartupCostGroup(
      id: StartupCostGroupId.property,
      lines: [
        StartupCostLine(
          id: StartupCostLineId.mallDeposit,
          amount: startup.property.mallDeposit,
        ),
        StartupCostLine(
          id: StartupCostLineId.firstMonthRent,
          amount: monthlyRent,
        ),
      ],
      total: propertyTotal(
        mallDeposit: startup.property.mallDeposit,
        monthlyRent: monthlyRent,
      ),
    );

    final preOpening = startup.preOpening;
    final preOpeningGroup = StartupCostGroup(
      id: StartupCostGroupId.preOpening,
      lines: [
        StartupCostLine(
          id: StartupCostLineId.licensing,
          amount: preOpening.registrationAndLicensing,
        ),
        StartupCostLine(
          id: StartupCostLineId.openingMarketing,
          amount: preOpening.openingMarketingCampaign,
        ),
        for (final item in preOpening.additionalItems)
          StartupCostLine(
            id: StartupCostLineId.custom,
            amount: item.amount,
            customLabel: item.label,
          ),
      ],
      total: preOpeningTotal(preOpening),
    );

    final subtotal = Money.sum([
      deliveredEquipmentGroup.total,
      fitOutGroup.total,
      propertyGroup.total,
      preOpeningGroup.total,
    ]);
    final contingencyAmount = contingency(
      subtotal: subtotal,
      contingencyRate: preOpening.contingencyRate,
    );

    return StartupCostBreakdown(
      equipmentCost: equipmentAmount,
      shipping: shippingAmount,
      customs: customsAmount,
      deliveredEquipment: deliveredEquipmentGroup,
      fitOut: fitOutGroup,
      property: propertyGroup,
      preOpening: preOpeningGroup,
      subtotal: subtotal,
      contingencyRate: preOpening.contingencyRate,
      contingency: contingencyAmount,
      total: subtotal + contingencyAmount,
    );
  }
}
