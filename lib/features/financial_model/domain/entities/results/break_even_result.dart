import 'package:equatable/equatable.dart';

import '../../value_objects/money.dart';
import '../../value_objects/percentage.dart';
import 'calculation_outcome.dart';

/// Operational break-even for one steady-state trading month.
///
/// This describes the sales level at which monthly operating revenue equals
/// monthly operating expense. It is separate from investment payback, which
/// asks when cumulative cash flow recovers the initial investment.
class BreakEvenResult extends Equatable {
  const BreakEvenResult({
    required this.breakEvenRevenue,
    required this.breakEvenOccupancy,
    required this.breakEvenPlayedRoundsPerDay,
    required this.breakEvenPlayersPerDay,
    required this.breakEvenTicketPrice,
  });

  final MetricResult<Money> breakEvenRevenue;

  /// Raw required occupancy. Values above 100% are deliberately retained so
  /// callers can identify an operationally infeasible result.
  final MetricResult<Percentage> breakEvenOccupancy;
  final MetricResult<double> breakEvenPlayedRoundsPerDay;
  final MetricResult<double> breakEvenPlayersPerDay;

  /// Ticket price required at 100% physical round capacity.
  final MetricResult<Money> breakEvenTicketPrice;

  @override
  List<Object?> get props => [
    breakEvenRevenue,
    breakEvenOccupancy,
    breakEvenPlayedRoundsPerDay,
    breakEvenPlayersPerDay,
    breakEvenTicketPrice,
  ];
}
