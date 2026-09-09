import 'package:equatable/equatable.dart';

class CalendarEventFactor extends Equatable {
  const CalendarEventFactor({
    required this.id,
    required this.name,
    required this.startMonth,
    required this.endMonth,
    required this.factor,
    this.active = true,
  });

  final String id;
  final String name;
  final int startMonth;
  final int endMonth;
  final double factor;
  final bool active;

  CalendarEventFactor copyWith({
    String? id,
    String? name,
    int? startMonth,
    int? endMonth,
    double? factor,
    bool? active,
  }) {
    return CalendarEventFactor(
      id: id ?? this.id,
      name: name ?? this.name,
      startMonth: startMonth ?? this.startMonth,
      endMonth: endMonth ?? this.endMonth,
      factor: factor ?? this.factor,
      active: active ?? this.active,
    );
  }

  @override
  List<Object?> get props => [id, name, startMonth, endMonth, factor, active];
}

/// Optional demand multipliers. Disabled models preserve raw occupancy.
class SeasonalityModel extends Equatable {
  const SeasonalityModel({
    this.enabled = false,
    this.dayOfWeekFactors = const {},
    this.monthFactors = const {},
    this.events = const [],
    this.weatherFactor = 1,
    this.marketingDemandFactor = 1,
  });

  final bool enabled;
  final Map<int, double> dayOfWeekFactors;
  final Map<int, double> monthFactors;
  final List<CalendarEventFactor> events;
  final double weatherFactor;
  final double marketingDemandFactor;

  SeasonalityModel copyWith({
    bool? enabled,
    Map<int, double>? dayOfWeekFactors,
    Map<int, double>? monthFactors,
    List<CalendarEventFactor>? events,
    double? weatherFactor,
    double? marketingDemandFactor,
  }) {
    return SeasonalityModel(
      enabled: enabled ?? this.enabled,
      dayOfWeekFactors: dayOfWeekFactors ?? this.dayOfWeekFactors,
      monthFactors: monthFactors ?? this.monthFactors,
      events: events ?? this.events,
      weatherFactor: weatherFactor ?? this.weatherFactor,
      marketingDemandFactor:
          marketingDemandFactor ?? this.marketingDemandFactor,
    );
  }

  @override
  List<Object?> get props => [
    enabled,
    dayOfWeekFactors,
    monthFactors,
    events,
    weatherFactor,
    marketingDemandFactor,
  ];
}
