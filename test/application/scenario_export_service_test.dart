import 'package:flutter_test/flutter_test.dart';
import 'package:the_floor_is_lava/core/error/failures.dart';
import 'package:the_floor_is_lava/features/financial_model/application/export/scenario_export_service.dart';
import 'package:the_floor_is_lava/features/financial_model/application/state/scenario_cubit.dart';
import 'package:the_floor_is_lava/features/financial_model/application/use_cases/load_scenario.dart';
import 'package:the_floor_is_lava/features/financial_model/application/use_cases/reset_scenario.dart';
import 'package:the_floor_is_lava/features/financial_model/application/use_cases/save_scenario.dart';
import 'package:the_floor_is_lava/features/financial_model/domain/services/financial_model_calculator.dart';

import '../fixtures/fake_repositories.dart';
import '../fixtures/scenario_fixtures.dart';

void main() {
  const service = ScenarioExportService();
  const calculator = FinancialModelCalculator();

  test('JSON round trip preserves calculated baseline figures', () {
    final original = calculator.calculate(baseline());
    final json = service.exportScenarioJson(baseline());
    final restored = calculator.calculate(service.importScenarioJson(json));

    expect(restored.startupCosts.total, original.startupCosts.total);
    expect(
      restored.yearOne!.operatingProfit,
      original.yearOne!.operatingProfit,
    );
    expect(restored.monthlyResults, original.monthlyResults);
  });

  test('projection CSV has the Excel-compatible header and month zero', () {
    final projection = calculator.calculate(baseline());
    final csv = service.exportProjectionCsv(projection);
    final rows = csv.split('\r\n');

    expect(
      rows.first,
      'Month,Occupancy%,MaxRounds,ActualRounds,DailyRevenue,MonthlyRevenue,'
      'Employees,Payroll,OtherExpenses,TotalExpenses,OperatingProfit,'
      'ProfitMargin%,NetCashFlow,CumulativeCashFlow',
    );
    expect(rows, hasLength(projection.monthlyResults.length + 1));
    expect(rows[1].split(',').first, '0');
  });

  test(
    'invalid JSON import emits a typed failure and keeps active data',
    () async {
      final repository = FakeScenarioRepository();
      final cubit = ScenarioCubit(
        loadScenario: LoadScenario(repository),
        saveScenario: SaveScenario(repository),
        resetScenario: ResetScenario(repository),
      );
      await cubit.initialise();
      final original = cubit.state.scenario;

      await cubit.importScenarioFromJson('{not valid json');

      expect(cubit.state.failure, isA<ImportFailure>());
      expect(cubit.state.scenario, original);
      expect(repository.scenarios, hasLength(1));
      await cubit.close();
    },
  );
}
