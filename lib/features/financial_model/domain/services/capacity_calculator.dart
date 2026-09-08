import '../entities/results/financial_projection.dart';
import '../entities/scenario/revenue_model.dart';
import '../value_objects/minutes.dart';
import '../value_objects/percentage.dart';

/// How many rounds the venue can run, and how many it expects to sell.
///
/// Nothing here knows about money. Capacity is a physical property of the room
/// and the timetable; demand is applied on top of it as an occupancy rate.
class CapacityCalculator {
  const CapacityCalculator();

  /// Slack allowed when flooring, so that a quotient which is mathematically a
  /// whole number is not pushed down a round by binary floating-point error
  /// (for example 38.999999999999996 for what is exactly 39).
  static const double _floorTolerance = 1e-9;

  /// Playing time plus turnaround - the time one round really consumes.
  Minutes totalRoundTime(CapacityModel capacity) =>
      capacity.roundDuration + capacity.turnaroundTime;

  Minutes operatingMinutesPerDay(OperatingSchedule schedule) =>
      Minutes.fromHours(schedule.hoursPerDay);

  /// Whole rounds that fit into a trading day.
  ///
  /// Returns 0 for a timetable that cannot run at all (no trading hours, or a
  /// round that consumes no time). Those inputs are rejected by validation
  /// before they reach the engine; the guard exists so the engine stays total
  /// and never divides by zero.
  int maximumRoundsPerDay(RevenueModel revenue) {
    final roundTime = totalRoundTime(revenue.capacity);
    final dayMinutes = operatingMinutesPerDay(revenue.schedule);
    if (roundTime.value <= 0 || dayMinutes.value <= 0) return 0;

    final quotient = dayMinutes.value / roundTime.value;
    return (quotient + _floorTolerance).floor();
  }

  /// Rounds actually expected to run, once demand is taken into account.
  double actualRoundsPerDay(int maximumRoundsPerDay, Percentage occupancy) =>
      maximumRoundsPerDay * occupancy.fraction;

  CapacitySummary summarise(RevenueModel revenue) {
    return CapacitySummary(
      totalRoundTime: totalRoundTime(revenue.capacity),
      operatingMinutesPerDay: operatingMinutesPerDay(revenue.schedule),
      maximumRoundsPerDay: maximumRoundsPerDay(revenue),
    );
  }
}
