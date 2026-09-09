import '../entities/results/break_even_result.dart';
import '../entities/results/calculation_outcome.dart';
import '../value_objects/money.dart';
import '../value_objects/percentage.dart';

/// Calculates operational break-even from steady-state monthly costs.
class BreakEvenCalculator {
  const BreakEvenCalculator();

  BreakEvenResult calculate({
    required Money steadyStateMonthlyOpex,
    required int maximumRoundsPerDay,
    required double averagePlayersPerRound,
    required Money ticketPrice,
    required double daysPerMonth,
  }) {
    final revenue = MetricResult<Money>.valid(steadyStateMonthlyOpex);
    const invalidDivisor = 'break_even_invalid_divisor';

    final canCalculatePlayedRounds =
        daysPerMonth > 0 &&
        averagePlayersPerRound > 0 &&
        ticketPrice.isPositive;
    final playedRounds = canCalculatePlayedRounds
        ? steadyStateMonthlyOpex.amount /
              daysPerMonth /
              (averagePlayersPerRound * ticketPrice.amount)
        : null;

    final playedRoundsResult = playedRounds == null
        ? const MetricResult<double>.invalid(invalidDivisor)
        : MetricResult<double>.valid(playedRounds);
    final playersResult = playedRounds == null
        ? const MetricResult<double>.invalid(invalidDivisor)
        : MetricResult<double>.valid(playedRounds * averagePlayersPerRound);
    final occupancyResult = playedRounds == null || maximumRoundsPerDay <= 0
        ? const MetricResult<Percentage>.invalid(invalidDivisor)
        : MetricResult<Percentage>.valid(
            Percentage.fromFraction(playedRounds / maximumRoundsPerDay),
          );

    final canCalculateTicketPrice =
        daysPerMonth > 0 &&
        averagePlayersPerRound > 0 &&
        maximumRoundsPerDay > 0;
    final ticketPriceResult = canCalculateTicketPrice
        ? MetricResult<Money>.valid(
            steadyStateMonthlyOpex /
                (daysPerMonth * averagePlayersPerRound * maximumRoundsPerDay),
          )
        : const MetricResult<Money>.invalid(invalidDivisor);

    return BreakEvenResult(
      breakEvenRevenue: revenue,
      breakEvenOccupancy: occupancyResult,
      breakEvenPlayedRoundsPerDay: playedRoundsResult,
      breakEvenPlayersPerDay: playersResult,
      breakEvenTicketPrice: ticketPriceResult,
    );
  }
}
