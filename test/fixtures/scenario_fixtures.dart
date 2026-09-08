import 'package:the_floor_is_lava/features/financial_model/domain/defaults/baseline_scenario.dart';
import 'package:the_floor_is_lava/features/financial_model/domain/entities/scenario/financial_scenario.dart';

/// A fixed baseline, so tests never depend on the wall clock.
final DateTime fixedNow = DateTime.utc(2026, 9, 8, 12, 17);

FinancialScenario baseline() => BaselineScenario.build(now: fixedNow);
