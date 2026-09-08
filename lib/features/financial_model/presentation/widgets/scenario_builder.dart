import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../application/state/scenario_cubit.dart';
import '../../application/state/scenario_state.dart';
import '../../domain/entities/results/financial_projection.dart';
import '../../domain/entities/scenario/financial_scenario.dart';

/// Builds a screen once the scenario and its projection are both available.
///
/// Screens never see a half-loaded state, and never have to null-check the
/// projection, so their code stays about the numbers rather than about
/// lifecycle.
class ScenarioBuilder extends StatelessWidget {
  const ScenarioBuilder({required this.builder, super.key});

  final Widget Function(
    BuildContext context,
    FinancialScenario scenario,
    FinancialProjection projection,
    ScenarioState state,
  )
  builder;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ScenarioCubit, ScenarioState>(
      builder: (context, state) {
        if (!state.isReady) {
          return const Center(child: CircularProgressIndicator());
        }
        return builder(context, state.scenario!, state.projection!, state);
      },
    );
  }
}
