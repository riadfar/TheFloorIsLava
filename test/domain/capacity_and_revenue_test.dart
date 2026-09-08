import 'package:flutter_test/flutter_test.dart';
import 'package:the_floor_is_lava/features/financial_model/domain/entities/scenario/revenue_model.dart';
import 'package:the_floor_is_lava/features/financial_model/domain/services/capacity_calculator.dart';
import 'package:the_floor_is_lava/features/financial_model/domain/services/revenue_calculator.dart';
import 'package:the_floor_is_lava/features/financial_model/domain/value_objects/minutes.dart';
import 'package:the_floor_is_lava/features/financial_model/domain/value_objects/money.dart';
import 'package:the_floor_is_lava/features/financial_model/domain/value_objects/percentage.dart';

import '../fixtures/money_matchers.dart';
import '../fixtures/scenario_fixtures.dart';

RevenueModel revenueWith({
  double roundDuration = 15,
  double turnaround = 5,
  double hoursPerDay = 13,
  double daysPerMonth = 30.4,
  double players = 3.63,
  num ticketPrice = 4,
}) {
  final base = baseline().revenue;
  return base.copyWith(
    capacity: base.capacity.copyWith(
      roundDuration: Minutes(roundDuration),
      turnaroundTime: Minutes(turnaround),
    ),
    schedule: base.schedule.copyWith(
      hoursPerDay: hoursPerDay,
      daysPerMonth: daysPerMonth,
    ),
    pricing: base.pricing.copyWith(
      averagePlayersPerRound: players,
      ticketPricePerPlayer: Money.of(ticketPrice),
    ),
  );
}

void main() {
  const capacity = CapacityCalculator();
  const revenue = RevenueCalculator();

  group('CapacityCalculator', () {
    test('adds turnaround to the round to get the slot length', () {
      expect(
        capacity.totalRoundTime(revenueWith().capacity),
        const Minutes(20),
      );
    });

    test('floors a fractional day - a part round cannot be sold', () {
      // 13 hours is 780 minutes; a 25 minute slot fits 31.2 times.
      expect(capacity.maximumRoundsPerDay(revenueWith(turnaround: 10)), 31);
    });

    test('a whole quotient is not lost to floating-point error', () {
      // 7 x 60 / 7 is exactly 60 rounds.
      expect(
        capacity.maximumRoundsPerDay(
          revenueWith(hoursPerDay: 7, roundDuration: 7, turnaround: 0),
        ),
        60,
      );
    });

    test('supports round-the-clock operation', () {
      expect(capacity.maximumRoundsPerDay(revenueWith(hoursPerDay: 24)), 72);
    });

    test('a round that consumes no time yields no capacity, not infinity', () {
      expect(
        capacity.maximumRoundsPerDay(
          revenueWith(roundDuration: 0, turnaround: 0),
        ),
        0,
      );
    });

    test('no trading hours means no rounds', () {
      expect(capacity.maximumRoundsPerDay(revenueWith(hoursPerDay: 0)), 0);
    });

    test('a turnaround longer than the trading day leaves no rounds', () {
      expect(capacity.maximumRoundsPerDay(revenueWith(turnaround: 24 * 60)), 0);
    });

    test('occupancy scales capacity into expected utilisation', () {
      expect(
        capacity.actualRoundsPerDay(39, const Percentage.fromPercent(69)),
        closeTo(26.91, 1e-9),
      );
      expect(capacity.actualRoundsPerDay(39, Percentage.zero), 0);
      expect(capacity.actualRoundsPerDay(39, Percentage.one), 39);
    });
  });

  group('RevenueCalculator', () {
    test('a day takes rounds x players x price', () {
      expect(
        revenue.dailyRevenue(
          actualRoundsPerDay: 26.91,
          pricing: revenueWith().pricing,
        ),
        isMoney(390.7332),
      );
    });

    test('nothing is sold at zero occupancy', () {
      expect(
        revenue.dailyRevenue(
          actualRoundsPerDay: 0,
          pricing: revenueWith().pricing,
        ),
        isMoney(0),
      );
    });

    test('full occupancy sells every round', () {
      expect(
        revenue.dailyRevenue(
          actualRoundsPerDay: 39,
          pricing: revenueWith().pricing,
        ),
        isMoney(566.28),
      );
    });

    test('a free ticket produces no revenue', () {
      expect(
        revenue.dailyRevenue(
          actualRoundsPerDay: 26.91,
          pricing: revenueWith(ticketPrice: 0).pricing,
        ),
        isMoney(0),
      );
    });

    test('a fractional average player count is preserved', () {
      expect(
        revenue.dailyRevenue(
          actualRoundsPerDay: 10,
          pricing: revenueWith(players: 3.63).pricing,
        ),
        isMoney(145.20),
      );
    });

    test('a month is a day repeated across the trading days', () {
      expect(
        revenue.monthlyRevenue(
          dailyRevenue: Money.of(390.7332),
          operatingDaysPerMonth: 30.4,
        ),
        isMoney(11878.28928),
      );
    });

    test('changing the day count changes the month proportionally', () {
      expect(
        revenue.monthlyRevenue(
          dailyRevenue: Money.of(100),
          operatingDaysPerMonth: 20,
        ),
        isMoney(2000),
      );
      expect(
        revenue.monthlyRevenue(
          dailyRevenue: Money.of(100),
          operatingDaysPerMonth: 0,
        ),
        isMoney(0),
      );
    });
  });
}
