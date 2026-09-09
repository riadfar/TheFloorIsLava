import 'package:equatable/equatable.dart';

/// State of a metric that cannot always produce a meaningful value.
enum CalculationStatus {
  valid,
  invalid,
  notMeaningful,
  notApplicable,
  insufficientData,
  noSolution,
}

/// A typed value together with its calculation state.
///
/// Non-valid results never carry a [value]. [reasonCode] is a stable,
/// presentation-independent key that callers can map to localized copy.
class MetricResult<T> extends Equatable {
  const MetricResult._({required this.status, this.value, this.reasonCode});

  const MetricResult.valid(T value)
    : this._(status: CalculationStatus.valid, value: value);

  const MetricResult.invalid(String reasonCode)
    : this._(status: CalculationStatus.invalid, reasonCode: reasonCode);

  const MetricResult.notMeaningful(String reasonCode)
    : this._(status: CalculationStatus.notMeaningful, reasonCode: reasonCode);

  const MetricResult.notApplicable(String reasonCode)
    : this._(status: CalculationStatus.notApplicable, reasonCode: reasonCode);

  const MetricResult.insufficientData(String reasonCode)
    : this._(
        status: CalculationStatus.insufficientData,
        reasonCode: reasonCode,
      );

  const MetricResult.noSolution(String reasonCode)
    : this._(status: CalculationStatus.noSolution, reasonCode: reasonCode);

  final CalculationStatus status;
  final T? value;
  final String? reasonCode;

  bool get isValid => status == CalculationStatus.valid;

  MetricResult<R> map<R>(R Function(T value) transform) {
    if (isValid) return MetricResult<R>.valid(transform(value as T));
    switch (status) {
      case CalculationStatus.valid:
        throw StateError('A valid metric must carry a value');
      case CalculationStatus.invalid:
        return MetricResult<R>.invalid(reasonCode ?? 'invalid');
      case CalculationStatus.notMeaningful:
        return MetricResult<R>.notMeaningful(reasonCode ?? 'not_meaningful');
      case CalculationStatus.notApplicable:
        return MetricResult<R>.notApplicable(reasonCode ?? 'not_applicable');
      case CalculationStatus.insufficientData:
        return MetricResult<R>.insufficientData(
          reasonCode ?? 'insufficient_data',
        );
      case CalculationStatus.noSolution:
        return MetricResult<R>.noSolution(reasonCode ?? 'no_solution');
    }
  }

  @override
  List<Object?> get props => [status, value, reasonCode];
}
