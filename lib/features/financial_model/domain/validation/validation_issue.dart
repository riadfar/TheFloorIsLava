import 'package:equatable/equatable.dart';

import '../entities/scenario/assumption_status.dart';

/// Whether an issue blocks the scenario or merely deserves attention.
enum ValidationSeverity {
  /// The scenario is not a valid business and must not be saved as-is.
  error,

  /// The scenario computes, but something about it looks wrong.
  warning,
}

/// What is wrong, as a typed code rather than a message.
///
/// The domain never produces user-facing text; the presentation layer turns
/// these codes into localised messages.
enum ValidationCode {
  mustBeGreaterThan,
  mustBeAtLeast,
  mustNotExceed,
  averagePlayersExceedCapacity,
  roundTimeNotPositive,
  contingencyAboveOneHundredPercent,
  optimisticOccupancyBelowBase,
  conservativeOccupancyAboveBase,
  expandedHeadcountBelowInitial,
}

class ValidationIssue extends Equatable {
  const ValidationIssue({
    required this.key,
    required this.code,
    this.limit,
    this.severity = ValidationSeverity.error,
  });

  const ValidationIssue.warning({
    required this.key,
    required this.code,
    this.limit,
  }) : severity = ValidationSeverity.warning;

  /// The input the issue is attached to, so the UI can show it in place.
  final AssumptionKey key;
  final ValidationCode code;

  /// The boundary that was breached, where the code implies one.
  final num? limit;

  final ValidationSeverity severity;

  bool get isError => severity == ValidationSeverity.error;

  @override
  List<Object?> get props => [key, code, limit, severity];
}

/// The outcome of validating a whole scenario.
class ValidationReport extends Equatable {
  const ValidationReport(this.issues);

  const ValidationReport.valid() : issues = const [];

  final List<ValidationIssue> issues;

  /// A scenario is usable when nothing in it is an outright error. Warnings do
  /// not block calculation.
  bool get isValid => !issues.any((issue) => issue.isError);

  List<ValidationIssue> get errors =>
      issues.where((issue) => issue.isError).toList();

  List<ValidationIssue> get warnings =>
      issues.where((issue) => !issue.isError).toList();

  List<ValidationIssue> forKey(AssumptionKey key) =>
      issues.where((issue) => issue.key == key).toList();

  ValidationIssue? firstErrorFor(AssumptionKey key) {
    for (final issue in issues) {
      if (issue.key == key && issue.isError) return issue;
    }
    return null;
  }

  @override
  List<Object?> get props => [issues];
}
