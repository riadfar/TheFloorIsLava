import 'package:flutter_test/flutter_test.dart';
import 'package:the_floor_is_lava/features/financial_model/data/models/scenario_mapper.dart';
import 'package:the_floor_is_lava/features/financial_model/domain/defaults/baseline_scenario.dart';
import 'package:the_floor_is_lava/features/financial_model/domain/entities/scenario/bonus_configuration.dart';
import 'package:the_floor_is_lava/features/financial_model/domain/entities/scenario/employee_roster.dart';
import 'package:the_floor_is_lava/features/financial_model/domain/entities/scenario/payroll_configuration.dart';
import 'package:the_floor_is_lava/features/financial_model/domain/entities/scenario/staffing_model.dart';
import 'package:the_floor_is_lava/features/financial_model/domain/services/bonus_calculator.dart';
import 'package:the_floor_is_lava/features/financial_model/domain/services/financial_model_calculator.dart';
import 'package:the_floor_is_lava/features/financial_model/domain/services/overtime_calculator.dart';
import 'package:the_floor_is_lava/features/financial_model/domain/services/payroll_calculator.dart';
import 'package:the_floor_is_lava/features/financial_model/domain/services/staffing_calculator.dart';
import 'package:the_floor_is_lava/features/financial_model/domain/value_objects/money.dart';
import 'package:the_floor_is_lava/features/financial_model/domain/value_objects/percentage.dart';

void main() {
  const payrollCalculator = PayrollCalculator();
  const bonusCalculator = BonusCalculator();

  Employee employee(
    String id,
    List<double> shiftHours, {
    bool founder = false,
  }) {
    return Employee(
      id: id,
      name: id,
      isFounder: founder,
      weeklyShifts: [
        for (var index = 0; index < shiftHours.length; index++)
          ShiftAssignment(
            weekday: (index % 7) + 1,
            startHour: 0,
            endHour: shiftHours[index],
          ),
      ],
    );
  }

  test('proportional payroll splits budget by worked hours', () {
    final staffing = BaselineScenario.build().staffing.copyWith(
      payroll: const PayrollConfiguration(
        mode: PayrollAllocationMode.proportionalHours,
        sharedMonthlyPayrollBudget: Money.units(1600),
      ),
      roster: EmployeeRoster(
        employees: [
          employee('A', [20, 20, 20, 20, 20]),
          employee('B', [20, 20, 20]),
        ],
      ),
    );
    final result = payrollCalculator.calculate(
      staffing: staffing,
      employeeCount: 2,
      daysPerMonth: 7,
      daysPerWeek: 7,
    );

    expect(result.employeePay['A'], Money.units(1000));
    expect(result.employeePay['B'], Money.units(600));
  });

  test('equal hours receive equal proportional pay', () {
    final staffing = BaselineScenario.build().staffing.copyWith(
      payroll: const PayrollConfiguration(
        mode: PayrollAllocationMode.proportionalHours,
        sharedMonthlyPayrollBudget: Money.units(1000),
      ),
      roster: EmployeeRoster(
        employees: [
          employee('A', [10]),
          employee('B', [10]),
        ],
      ),
    );
    final result = payrollCalculator.calculate(
      staffing: staffing,
      employeeCount: 2,
      daysPerMonth: 7,
      daysPerWeek: 7,
    );

    expect(result.employeePay['A'], Money.units(500));
    expect(result.employeePay['B'], Money.units(500));
  });

  test('overtime is costed separately from regular hours', () {
    final result = const OvertimeCalculator().calculate(
      hours: 180,
      baseHourly: Money.units(10),
      regularHoursCap: 160,
      overtimeMultiplier: 1.5,
    );

    expect(result.regularCost, Money.units(1600));
    expect(result.overtimeCost, Money.units(300));
  });

  test('percentage bonus is zero below and at target, then uses excess', () {
    const configuration = BonusConfiguration(
      mode: BonusMode.percentageOfExcessRevenue,
      revenueTarget: Money.units(1000),
      percentageOfExcess: Percentage.fromPercent(10),
    );

    expect(
      bonusCalculator.calculate(
        configuration: configuration,
        revenue: Money.units(999),
      ),
      Money.zero,
    );
    expect(
      bonusCalculator.calculate(
        configuration: configuration,
        revenue: Money.units(1000),
      ),
      Money.zero,
    );
    expect(
      bonusCalculator.calculate(
        configuration: configuration,
        revenue: Money.units(1200),
      ),
      Money.units(20),
    );
  });

  test('fixed bonus responds to threshold, amount, and mode', () {
    const configuration = BonusConfiguration(
      mode: BonusMode.fixedAmountAtThreshold,
      thresholdMultiplier: Percentage.fromFraction(1.2),
      fixedBonusAmount: Money.units(75),
    );

    Money calculate(Money revenue, BonusConfiguration config) =>
        bonusCalculator.calculate(
          configuration: config,
          revenue: revenue,
          expectedRevenue: Money.units(1000),
        );

    expect(calculate(Money.units(1199), configuration), Money.zero);
    expect(calculate(Money.units(1200), configuration), Money.units(75));
    expect(calculate(Money.units(1300), configuration), Money.units(75));
    expect(
      calculate(
        Money.units(1200),
        const BonusConfiguration(
          mode: BonusMode.fixedAmountAtThreshold,
          thresholdMultiplier: Percentage.fromFraction(1.1),
          fixedBonusAmount: Money.units(100),
        ),
      ),
      Money.units(100),
    );
    expect(
      calculate(
        Money.units(2000),
        const BonusConfiguration(mode: BonusMode.disabled),
      ),
      Money.zero,
    );
  });

  test('financial model includes triggered bonus in monthly payroll', () {
    final scenario = BaselineScenario.build();
    final configured = scenario.copyWith(
      staffing: scenario.staffing.copyWith(
        payroll: scenario.staffing.payroll.copyWith(
          bonus: const BonusConfiguration(
            mode: BonusMode.fixedAmountAtThreshold,
            thresholdMultiplier: Percentage.one,
            fixedBonusAmount: Money.units(100),
          ),
        ),
      ),
    );

    final baselineProjection = const FinancialModelCalculator().calculate(
      scenario,
    );
    final bonusProjection = const FinancialModelCalculator().calculate(
      configured,
    );

    expect(bonusProjection.monthlyResults[3].payroll, Money.units(570));
    expect(bonusProjection.monthlyResults[4].payroll, Money.units(670));
    expect(
      bonusProjection.monthlyResults[4].totalOperatingExpenses,
      baselineProjection.monthlyResults[4].totalOperatingExpenses +
          Money.units(100),
    );
  });

  test('empty fixed roster exactly matches baseline staffing calculator', () {
    final staffing = BaselineScenario.build().staffing;
    const existing = StaffingCalculator();
    final result = payrollCalculator.calculateForMonth(
      staffing: staffing,
      month: 3,
      daysPerMonth: 30.4,
      daysPerWeek: 7,
    );

    expect(result.total, existing.payrollForMonth(staffing, 3));
  });

  test('founders receive no cash payroll', () {
    final staffing = BaselineScenario.build().staffing.copyWith(
      roster: EmployeeRoster(
        employees: [
          employee('founder', [10], founder: true),
        ],
      ),
    );
    final result = payrollCalculator.calculate(
      staffing: staffing,
      employeeCount: 1,
      daysPerMonth: 7,
      daysPerWeek: 7,
    );

    expect(result.employeePay['founder'], Money.zero);
    expect(result.total, Money.zero);
  });

  test('payroll configuration and roster survive persistence', () {
    final scenario = BaselineScenario.build();
    final configured = scenario.copyWith(
      staffing: scenario.staffing.copyWith(
        payroll: const PayrollConfiguration(
          mode: PayrollAllocationMode.proportionalHours,
          sharedMonthlyPayrollBudget: Money.units(2000),
          overtimeMultiplier: 2,
          bonus: BonusConfiguration(
            mode: BonusMode.fixedAmountAtThreshold,
            thresholdMultiplier: Percentage.fromFraction(1.25),
            fixedBonusAmount: Money.units(100),
          ),
          staffingExpansionOccupancyThreshold: Percentage.fromPercent(55),
        ),
        roster: EmployeeRoster(
          employees: [
            employee('A', [8]),
            employee('founder', [6], founder: true),
          ],
        ),
        regularHoursPerMonthCap: 160,
        headcountRule: StaffingHeadcountRule.byOccupancyThreshold,
      ),
    );

    final restored = ScenarioMapper.fromJson(ScenarioMapper.toJson(configured));
    expect(restored.staffing.payroll, configured.staffing.payroll);
    expect(restored.staffing.roster, configured.staffing.roster);
    expect(
      restored.staffing.regularHoursPerMonthCap,
      configured.staffing.regularHoursPerMonthCap,
    );
    expect(restored.staffing.headcountRule, configured.staffing.headcountRule);
  });

  test('missing version-two staffing fields use baseline defaults', () {
    final json = ScenarioMapper.toJson(BaselineScenario.build());
    json['schemaVersion'] = 1;
    final staffing = json['staffing'] as Map<String, dynamic>;
    staffing
      ..remove('payroll')
      ..remove('roster')
      ..remove('regularHoursPerMonthCap')
      ..remove('headcountRule');

    final restored = ScenarioMapper.fromJson(json).staffing;
    expect(restored.payroll, const PayrollConfiguration());
    expect(restored.roster, const EmployeeRoster());
    expect(restored.regularHoursPerMonthCap, isNull);
    expect(restored.headcountRule, StaffingHeadcountRule.byMonth);
  });
}
