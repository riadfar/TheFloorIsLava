import 'package:equatable/equatable.dart';

/// Identity and provenance of a scenario.
///
/// Kept separate from the numbers so that scenario management (naming,
/// duplicating, comparing) can grow later without touching the financial model.
class ScenarioMetadata extends Equatable {
  const ScenarioMetadata({
    required this.id,
    required this.name,
    required this.description,
    required this.currencyCode,
    required this.createdAt,
    required this.updatedAt,
    required this.calculationModelVersion,
  });

  final String id;
  final String name;
  final String description;

  /// ISO 4217 code, e.g. `USD`. The amounts themselves are currency-agnostic;
  /// this is what gives them meaning and drives formatting.
  final String currencyCode;

  final DateTime createdAt;
  final DateTime updatedAt;

  /// Version of the calculation rules this scenario was authored against, so a
  /// future change to the formulas cannot silently reinterpret old data.
  final String calculationModelVersion;

  ScenarioMetadata copyWith({
    String? id,
    String? name,
    String? description,
    String? currencyCode,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? calculationModelVersion,
  }) {
    return ScenarioMetadata(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      currencyCode: currencyCode ?? this.currencyCode,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      calculationModelVersion:
          calculationModelVersion ?? this.calculationModelVersion,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    currencyCode,
    createdAt,
    updatedAt,
    calculationModelVersion,
  ];
}
