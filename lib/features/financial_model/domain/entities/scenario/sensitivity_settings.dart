import 'package:equatable/equatable.dart';

import '../../value_objects/percentage.dart';

/// The role a sensitivity scenario plays, so the UI can name the well-known
/// ones without the domain holding display strings.
enum SensitivityScenarioKind { conservative, base, optimistic, custom }

/// One what-if case: the same business at a different occupancy.
class SensitivityScenarioDefinition extends Equatable {
  const SensitivityScenarioDefinition({
    required this.id,
    required this.kind,
    this.occupancy,
    this.customName,
  });

  final String id;
  final SensitivityScenarioKind kind;

  /// Occupancy to test. `null` means "use the scenario's own stable occupancy",
  /// which is how the study defines its Base case.
  final Percentage? occupancy;

  /// Name for [SensitivityScenarioKind.custom] cases.
  final String? customName;

  bool get usesBaseOccupancy => occupancy == null;

  SensitivityScenarioDefinition copyWith({
    Percentage? occupancy,
    String? customName,
  }) {
    return SensitivityScenarioDefinition(
      id: id,
      kind: kind,
      occupancy: occupancy ?? this.occupancy,
      customName: customName ?? this.customName,
    );
  }

  @override
  List<Object?> get props => [id, kind, occupancy, customName];
}

/// The set of what-if cases shown on the sensitivity screen.
class SensitivitySettings extends Equatable {
  const SensitivitySettings({required this.scenarios});

  final List<SensitivityScenarioDefinition> scenarios;

  SensitivitySettings copyWith({
    List<SensitivityScenarioDefinition>? scenarios,
  }) => SensitivitySettings(scenarios: scenarios ?? this.scenarios);

  SensitivitySettings withScenario(SensitivityScenarioDefinition scenario) {
    return copyWith(
      scenarios: [
        for (final existing in scenarios)
          if (existing.id == scenario.id) scenario else existing,
      ],
    );
  }

  @override
  List<Object?> get props => [scenarios];
}
