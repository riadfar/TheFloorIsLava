import 'package:flutter_test/flutter_test.dart';
import 'package:the_floor_is_lava/features/financial_model/domain/entities/scenario/cost_item.dart';
import 'package:the_floor_is_lava/features/financial_model/domain/entities/scenario/startup_cost_model.dart';
import 'package:the_floor_is_lava/features/financial_model/domain/services/operating_expense_calculator.dart';
import 'package:the_floor_is_lava/features/financial_model/domain/services/profit_calculator.dart';
import 'package:the_floor_is_lava/features/financial_model/domain/services/staffing_calculator.dart';
import 'package:the_floor_is_lava/features/financial_model/domain/services/startup_cost_calculator.dart';
import 'package:the_floor_is_lava/features/financial_model/domain/value_objects/money.dart';
import 'package:the_floor_is_lava/features/financial_model/domain/value_objects/percentage.dart';

import '../fixtures/money_matchers.dart';
import '../fixtures/scenario_fixtures.dart';

void main() {
  const staffingCalculator = StaffingCalculator();
  const expenseCalculator = OperatingExpenseCalculator();
  const profitCalculator = ProfitCalculator();
  const startupCalculator = StartupCostCalculator();

  group('StaffingCalculator', () {
    final staffing = baseline().staffing;

    test('holds the starting headcount until the expansion month', () {
      expect(staffingCalculator.employeeCountForMonth(staffing, 1), 2);
      expect(staffingCalculator.employeeCountForMonth(staffing, 2), 2);
    });

    test('steps up from the expansion month and stays there', () {
      expect(staffingCalculator.employeeCountForMonth(staffing, 3), 3);
      expect(staffingCalculator.employeeCountForMonth(staffing, 24), 3);
    });

    test('an employee costs salary plus incentive', () {
      expect(staffingCalculator.costPerEmployee(staffing), isMoney(190));
    });

    test('payroll is headcount times that cost', () {
      expect(staffingCalculator.payroll(staffing, 3), isMoney(570));
    });

    test('no employees means no payroll', () {
      expect(staffingCalculator.payroll(staffing, 0), isMoney(0));
    });

    test('unpaid staff cost nothing', () {
      final unpaid = staffing.copyWith(
        monthlySalaryPerEmployee: Money.zero,
        monthlyIncentivePerEmployee: Money.zero,
      );
      expect(staffingCalculator.payroll(unpaid, 5), isMoney(0));
    });

    test('an expansion in month 1 applies from the start', () {
      final immediate = staffing.copyWith(expansionMonth: 1);
      expect(staffingCalculator.employeeCountForMonth(immediate, 1), 3);
    });
  });

  group('OperatingExpenseCalculator', () {
    final expenses = baseline().operatingExpenses;

    test('adds the five named monthly categories', () {
      expect(expenseCalculator.otherOperatingExpenses(expenses), isMoney(3550));
    });

    test('includes additional user-created categories', () {
      final withExtras = expenses.copyWith(
        additionalExpenses: [
          CostItem(
            id: 'insurance',
            label: 'Insurance',
            amount: Money.units(75),
          ),
          CostItem(id: 'software', label: 'Software', amount: Money.units(25)),
        ],
      );
      expect(
        expenseCalculator.otherOperatingExpenses(withExtras),
        isMoney(3650),
      );
    });

    test('total is payroll plus everything else', () {
      expect(
        expenseCalculator.totalOperatingExpenses(
          payroll: Money.units(570),
          otherOperatingExpenses: Money.units(3550),
        ),
        isMoney(4120),
      );
    });
  });

  group('ProfitCalculator', () {
    test('profit is revenue less expenses', () {
      expect(
        profitCalculator.operatingProfit(
          revenue: Money.of(11878.28928),
          totalOperatingExpenses: Money.units(4120),
        ),
        isMoney(7758.28928),
      );
    });

    test('a loss is reported as a negative profit', () {
      expect(
        profitCalculator.operatingProfit(
          revenue: Money.units(1000),
          totalOperatingExpenses: Money.units(3930),
        ),
        isMoney(-2930),
      );
    });

    test('margin is profit over revenue', () {
      final margin = profitCalculator.profitMargin(
        operatingProfit: Money.units(25),
        revenue: Money.units(100),
      );
      expect(margin!.percent, closeTo(25, 1e-9));
    });

    test('margin is undefined rather than infinite when revenue is zero', () {
      expect(
        profitCalculator.profitMargin(
          operatingProfit: Money.units(-100),
          revenue: Money.zero,
        ),
        isNull,
      );
    });
  });

  group('StartupCostCalculator', () {
    test('costs the selected package, not the other one', () {
      final scenario = baseline();
      final package1 = scenario.copyWith(
        startupCosts: scenario.startupCosts.copyWith(
          equipment: scenario.startupCosts.equipment.copyWith(
            selectedPackageId: BaselineScenarioPackages.package1,
          ),
        ),
      );

      expect(
        startupCalculator.calculate(scenario).equipmentCost,
        isMoney(5270),
      );
      expect(
        startupCalculator.calculate(package1).equipmentCost,
        isMoney(10285),
      );
    });

    test('switching package flows all the way to the investment total', () {
      final scenario = baseline();
      final package1 = scenario.copyWith(
        startupCosts: scenario.startupCosts.copyWith(
          equipment: scenario.startupCosts.equipment.copyWith(
            selectedPackageId: BaselineScenarioPackages.package1,
          ),
        ),
      );

      final result = startupCalculator.calculate(package1);
      // 10,285 landed at 37% = 14,090.45, plus 7,700 of other costs.
      expect(result.deliveredEquipment.total, isMoney(14090.45));
      expect(result.subtotal, isMoney(21790.45));
      expect(result.total, isMoney(23969.495));
    });

    test('a change in the shipping rate moves the total', () {
      final scenario = baseline();
      final higherFreight = scenario.copyWith(
        startupCosts: scenario.startupCosts.copyWith(
          equipment: scenario.startupCosts.equipment.copyWith(
            shippingRate: const Percentage.fromPercent(20),
          ),
        ),
      );
      expect(
        startupCalculator.calculate(higherFreight).shipping,
        isMoney(1054),
      );
      expect(
        startupCalculator.calculate(higherFreight).total,
        // Subtotal rises by 421.60, and 10% contingency rises with it.
        isMoney(16875.65),
      );
    });

    test('a change in the customs rate moves the total', () {
      final scenario = baseline();
      final noCustoms = scenario.copyWith(
        startupCosts: scenario.startupCosts.copyWith(
          equipment: scenario.startupCosts.equipment.copyWith(
            customsRate: Percentage.zero,
          ),
        ),
      );
      expect(startupCalculator.calculate(noCustoms).customs, isMoney(0));
      expect(startupCalculator.calculate(noCustoms).total, isMoney(14962.64));
    });

    test('a deposit is added to the first month of rent', () {
      final scenario = baseline();
      final withDeposit = scenario.copyWith(
        startupCosts: scenario.startupCosts.copyWith(
          property: scenario.startupCosts.property.copyWith(
            mallDeposit: Money.units(6000),
          ),
        ),
      );
      expect(
        startupCalculator.calculate(withDeposit).property.total,
        isMoney(9000),
      );
    });

    test('property tracks the recurring rent input', () {
      final scenario = baseline();
      final cheaperRent = scenario.copyWith(
        operatingExpenses: scenario.operatingExpenses.copyWith(
          rent: Money.units(2000),
        ),
      );
      expect(
        startupCalculator.calculate(cheaperRent).property.total,
        isMoney(2000),
      );
    });

    test('no contingency leaves the subtotal untouched', () {
      final scenario = baseline();
      final noBuffer = scenario.copyWith(
        startupCosts: scenario.startupCosts.copyWith(
          preOpening: scenario.startupCosts.preOpening.copyWith(
            contingencyRate: Percentage.zero,
          ),
        ),
      );
      final result = startupCalculator.calculate(noBuffer);
      expect(result.contingency, isMoney(0));
      expect(result.total, result.subtotal);
    });

    test('additional fit-out and pre-opening items are included', () {
      final scenario = baseline();
      final extended = scenario.copyWith(
        startupCosts: scenario.startupCosts.copyWith(
          fitOut: scenario.startupCosts.fitOut.copyWith(
            additionalItems: [
              CostItem(
                id: 'lockers',
                label: 'Lockers',
                amount: Money.units(400),
              ),
            ],
          ),
          preOpening: scenario.startupCosts.preOpening.copyWith(
            additionalItems: [
              CostItem(
                id: 'insurance',
                label: 'Insurance',
                amount: Money.units(150),
              ),
            ],
          ),
        ),
      );
      final result = startupCalculator.calculate(extended);
      expect(result.fitOut.total, isMoney(2800));
      expect(result.preOpening.total, isMoney(2450));
      expect(result.subtotal, isMoney(15469.90));
    });

    test('a fully zeroed project never produces a negative investment', () {
      final scenario = baseline();
      final zeroed = scenario.copyWith(
        operatingExpenses: scenario.operatingExpenses.copyWith(
          rent: Money.zero,
        ),
        startupCosts: StartupCostModel(
          equipment: scenario.startupCosts.equipment.copyWith(
            packages: [
              for (final package in scenario.startupCosts.equipment.packages)
                package.copyWith(cost: Money.zero),
            ],
          ),
          fitOut: const FitOutModel(
            receptionFurniture: Money.zero,
            paintingAndGraphics: Money.zero,
            signage: Money.zero,
            hvac: Money.zero,
            installationLabour: Money.zero,
          ),
          property: const PropertyModel(
            mallDeposit: Money.zero,
            contractDurationMonths: 12,
          ),
          preOpening: const PreOpeningModel(
            registrationAndLicensing: Money.zero,
            openingMarketingCampaign: Money.zero,
            contingencyRate: Percentage.zero,
            maximumSetupDays: 0,
          ),
        ),
      );
      expect(startupCalculator.calculate(zeroed).total, isMoney(0));
      expect(startupCalculator.calculate(zeroed).total.isNegative, isFalse);
    });
  });
}

/// Package identifiers, named here so the tests read as intent rather than
/// as string literals.
abstract final class BaselineScenarioPackages {
  static const String package1 = 'grid-room-complete';
  static const String package2 = 'individual-components';
}
