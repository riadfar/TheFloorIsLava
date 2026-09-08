import '../entities/scenario/revenue_model.dart';
import '../value_objects/money.dart';

/// Turns rounds into money.
class RevenueCalculator {
  const RevenueCalculator();

  /// Rounds sold in a day x players in a round x price per player.
  Money dailyRevenue({
    required double actualRoundsPerDay,
    required PricingModel pricing,
  }) {
    return pricing.ticketPricePerPlayer *
        actualRoundsPerDay *
        pricing.averagePlayersPerRound;
  }

  /// A day's takings repeated across the trading days of an average month.
  Money monthlyRevenue({
    required Money dailyRevenue,
    required double operatingDaysPerMonth,
  }) {
    return dailyRevenue * operatingDaysPerMonth;
  }
}
