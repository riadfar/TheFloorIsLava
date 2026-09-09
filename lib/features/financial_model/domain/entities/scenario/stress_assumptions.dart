import 'package:equatable/equatable.dart';

class StressAssumptions extends Equatable {
  const StressAssumptions({
    this.criticalFailureEnabled = false,
    this.failureStartMonth = 6,
    this.downtimeDays = 14,
  });

  final bool criticalFailureEnabled;
  final int failureStartMonth;
  final int downtimeDays;

  StressAssumptions copyWith({
    bool? criticalFailureEnabled,
    int? failureStartMonth,
    int? downtimeDays,
  }) {
    return StressAssumptions(
      criticalFailureEnabled:
          criticalFailureEnabled ?? this.criticalFailureEnabled,
      failureStartMonth: failureStartMonth ?? this.failureStartMonth,
      downtimeDays: downtimeDays ?? this.downtimeDays,
    );
  }

  @override
  List<Object?> get props => [
    criticalFailureEnabled,
    failureStartMonth,
    downtimeDays,
  ];
}
