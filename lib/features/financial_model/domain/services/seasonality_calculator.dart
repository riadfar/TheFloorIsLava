import 'dart:math' as math;

import '../entities/scenario/seasonality_model.dart';
import '../value_objects/percentage.dart';

class SeasonalityCalculator {
  const SeasonalityCalculator();

  /// Applies planning multipliers and clamps demand to physical capacity.
  ///
  /// Day-of-week factors are equally weighted across all seven days because V1
  /// has no weekly operating profile. Projection month 1 maps to calendar
  /// month 1 and the sequence repeats after month 12.
  Percentage effectiveOccupancy({
    required Percentage baseOccupancy,
    required int projectionMonth,
    required SeasonalityModel model,
  }) {
    if (!model.enabled) return baseOccupancy;

    final calendarMonth = ((projectionMonth - 1) % 12) + 1;
    final dayAverage =
        List.generate(
          DateTime.daysPerWeek,
          (index) => model.dayOfWeekFactors[index + 1] ?? 1,
        ).reduce((left, right) => left + right) /
        DateTime.daysPerWeek;

    var factor =
        (model.monthFactors[calendarMonth] ?? 1) *
        dayAverage *
        model.weatherFactor *
        model.marketingDemandFactor;
    for (final event in model.events) {
      if (event.active && _containsMonth(event, calendarMonth)) {
        factor *= event.factor;
      }
    }

    return Percentage.fromFraction(
      math.max(0, math.min(1, baseOccupancy.fraction * factor)),
    );
  }

  bool _containsMonth(CalendarEventFactor event, int month) {
    if (event.startMonth <= event.endMonth) {
      return month >= event.startMonth && month <= event.endMonth;
    }
    return month >= event.startMonth || month <= event.endMonth;
  }
}
