import 'package:equatable/equatable.dart';

import '../../value_objects/minutes.dart';
import '../../value_objects/money.dart';
import '../../value_objects/percentage.dart';

/// What a seat costs and how many seats a round is expected to sell.
class PricingModel extends Equatable {
  const PricingModel({
    required this.ticketPricePerPlayer,
    required this.averagePlayersPerRound,
  });

  /// Price charged per player, per round.
  final Money ticketPricePerPlayer;

  /// Expected players in a round. Deliberately fractional - the study's 3.63 is
  /// an average, not a headcount.
  final double averagePlayersPerRound;

  PricingModel copyWith({
    Money? ticketPricePerPlayer,
    double? averagePlayersPerRound,
  }) {
    return PricingModel(
      ticketPricePerPlayer: ticketPricePerPlayer ?? this.ticketPricePerPlayer,
      averagePlayersPerRound:
          averagePlayersPerRound ?? this.averagePlayersPerRound,
    );
  }

  @override
  List<Object?> get props => [ticketPricePerPlayer, averagePlayersPerRound];
}

/// How long a sellable slot takes and how many players it can physically hold.
class CapacityModel extends Equatable {
  const CapacityModel({
    required this.roundDuration,
    required this.turnaroundTime,
    required this.maximumPlayersPerRound,
  });

  /// Playing time of a single round.
  final Minutes roundDuration;

  /// Reset time between rounds. Sold time plus turnaround is what actually
  /// consumes the trading day.
  final Minutes turnaroundTime;

  /// Physical seat count of the attraction. It does not enter the revenue
  /// formula; it is the ceiling that [PricingModel.averagePlayersPerRound] must
  /// respect.
  final int maximumPlayersPerRound;

  CapacityModel copyWith({
    Minutes? roundDuration,
    Minutes? turnaroundTime,
    int? maximumPlayersPerRound,
  }) {
    return CapacityModel(
      roundDuration: roundDuration ?? this.roundDuration,
      turnaroundTime: turnaroundTime ?? this.turnaroundTime,
      maximumPlayersPerRound:
          maximumPlayersPerRound ?? this.maximumPlayersPerRound,
    );
  }

  @override
  List<Object?> get props => [
    roundDuration,
    turnaroundTime,
    maximumPlayersPerRound,
  ];
}

/// When the venue is open.
class DayOperatingHours extends Equatable {
  const DayOperatingHours({required this.weekday, required this.hours})
    : assert(weekday >= DateTime.monday && weekday <= DateTime.sunday),
      assert(hours >= 0 && hours <= 24);

  /// Uses [DateTime.weekday]: Monday is 1 and Sunday is 7.
  final int weekday;
  final double hours;

  DayOperatingHours copyWith({int? weekday, double? hours}) {
    return DayOperatingHours(
      weekday: weekday ?? this.weekday,
      hours: hours ?? this.hours,
    );
  }

  @override
  List<Object?> get props => [weekday, hours];
}

/// Optional day-by-day hours used as a weighted flat-day approximation.
///
/// The monthly model still uses one representative operating day. When this
/// profile is enabled, that day uses the average hours of configured open days.
class WeeklyOperatingProfile extends Equatable {
  const WeeklyOperatingProfile({this.days = const []});

  /// An empty list disables the profile.
  final List<DayOperatingHours> days;

  bool get isEnabled => days.isNotEmpty;

  double? hoursForWeekday(int weekday) {
    for (final day in days) {
      if (day.weekday == weekday) return day.hours;
    }
    return null;
  }

  double averageHoursPerOperatingDay() {
    final operatingDays = days.where((day) => day.hours > 0);
    if (operatingDays.isEmpty) return 0;
    return operatingDays.fold<double>(0, (sum, day) => sum + day.hours) /
        operatingDays.length;
  }

  WeeklyOperatingProfile copyWith({List<DayOperatingHours>? days}) {
    return WeeklyOperatingProfile(days: days ?? this.days);
  }

  @override
  List<Object?> get props => [days];
}

/// When the venue is open.
class OperatingSchedule extends Equatable {
  const OperatingSchedule({
    required this.hoursPerDay,
    required this.daysPerWeek,
    required this.daysPerMonth,
    this.weeklyProfile = const WeeklyOperatingProfile(),
  });

  /// Trading hours in a day. Used when [weeklyProfile] is disabled.
  final double hoursPerDay;

  /// Trading days in a week. Descriptive in this model: the study drives the
  /// monthly total from [daysPerMonth] directly rather than deriving it from
  /// the weekly pattern, and that behaviour is preserved.
  final int daysPerWeek;

  /// Trading days in an average month (30.4 in the study).
  final double daysPerMonth;

  /// Optional day-by-day hours for the representative monthly operating day.
  final WeeklyOperatingProfile weeklyProfile;

  OperatingSchedule copyWith({
    double? hoursPerDay,
    int? daysPerWeek,
    double? daysPerMonth,
    WeeklyOperatingProfile? weeklyProfile,
  }) {
    return OperatingSchedule(
      hoursPerDay: hoursPerDay ?? this.hoursPerDay,
      daysPerWeek: daysPerWeek ?? this.daysPerWeek,
      daysPerMonth: daysPerMonth ?? this.daysPerMonth,
      weeklyProfile: weeklyProfile ?? this.weeklyProfile,
    );
  }

  @override
  List<Object?> get props => [
    hoursPerDay,
    daysPerWeek,
    daysPerMonth,
    weeklyProfile,
  ];
}

/// The share of theoretical capacity the business expects to actually sell,
/// month by month.
///
/// The study models a ramp-up (8% / 23% / 46%) followed by a stable level
/// (69%). Expressing the ramp as a list rather than three named fields keeps the
/// study's rule exact while allowing a longer or shorter ramp later without
/// changing the calculation engine.
class OccupancySchedule extends Equatable {
  const OccupancySchedule({required this.rampUp, required this.stable});

  /// Occupancy for month 1, month 2, ... in order. May be empty.
  final List<Percentage> rampUp;

  /// Occupancy applied from the first month after the ramp-up onwards.
  final Percentage stable;

  /// Occupancy for a projection month. Month 0 is the investment month and has
  /// no trading, so callers must not ask for it.
  Percentage occupancyForMonth(int month) {
    if (month >= 1 && month <= rampUp.length) {
      return rampUp[month - 1];
    }
    return stable;
  }

  /// First month that trades at the stable level.
  int get firstStableMonth => rampUp.length + 1;

  OccupancySchedule copyWith({List<Percentage>? rampUp, Percentage? stable}) {
    return OccupancySchedule(
      rampUp: rampUp ?? this.rampUp,
      stable: stable ?? this.stable,
    );
  }

  /// Replaces one ramp-up month, extending the ramp with the stable value if
  /// the index sits beyond the current list.
  OccupancySchedule withRampUpMonth(int month, Percentage occupancy) {
    final updated = List<Percentage>.from(rampUp);
    while (updated.length < month) {
      updated.add(stable);
    }
    updated[month - 1] = occupancy;
    return copyWith(rampUp: updated);
  }

  @override
  List<Object?> get props => [rampUp, stable];
}

/// Everything that determines how much money comes in.
class RevenueModel extends Equatable {
  const RevenueModel({
    required this.pricing,
    required this.capacity,
    required this.schedule,
    required this.occupancy,
  });

  final PricingModel pricing;
  final CapacityModel capacity;
  final OperatingSchedule schedule;
  final OccupancySchedule occupancy;

  RevenueModel copyWith({
    PricingModel? pricing,
    CapacityModel? capacity,
    OperatingSchedule? schedule,
    OccupancySchedule? occupancy,
  }) {
    return RevenueModel(
      pricing: pricing ?? this.pricing,
      capacity: capacity ?? this.capacity,
      schedule: schedule ?? this.schedule,
      occupancy: occupancy ?? this.occupancy,
    );
  }

  @override
  List<Object?> get props => [pricing, capacity, schedule, occupancy];
}
