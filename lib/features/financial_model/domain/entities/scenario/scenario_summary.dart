import 'package:equatable/equatable.dart';

/// Lightweight metadata used by scenario lists without loading every model.
class ScenarioSummary extends Equatable {
  const ScenarioSummary({
    required this.id,
    required this.name,
    required this.updatedAt,
    required this.isActive,
    required this.isBuiltinRecoverable,
  });

  final String id;
  final String name;
  final DateTime updatedAt;
  final bool isActive;
  final bool isBuiltinRecoverable;

  ScenarioSummary copyWith({
    String? name,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return ScenarioSummary(
      id: id,
      name: name ?? this.name,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      isBuiltinRecoverable: isBuiltinRecoverable,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    updatedAt,
    isActive,
    isBuiltinRecoverable,
  ];
}
