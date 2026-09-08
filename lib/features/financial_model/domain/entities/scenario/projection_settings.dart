import 'package:equatable/equatable.dart';

/// How far forward the model projects.
class ProjectionSettings extends Equatable {
  const ProjectionSettings({required this.projectionMonths});

  /// Number of trading months to project, excluding month 0. The study runs 24.
  final int projectionMonths;

  /// Months grouped into one reported year.
  static const int monthsPerYear = 12;

  ProjectionSettings copyWith({int? projectionMonths}) => ProjectionSettings(
    projectionMonths: projectionMonths ?? this.projectionMonths,
  );

  @override
  List<Object?> get props => [projectionMonths];
}
