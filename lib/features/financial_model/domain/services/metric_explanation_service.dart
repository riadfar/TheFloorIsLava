import '../entities/results/financial_projection.dart';
import '../entities/results/monthly_financial_result.dart';
import '../value_objects/minutes.dart';
import '../value_objects/money.dart';
import '../value_objects/percentage.dart';

/// A figure the user can ask "how is this calculated?" about.
enum MetricId {
  maximumRoundsPerDay,
  actualRoundsPerDay,
  dailyRevenue,
  monthlyRevenue,
  payroll,
  totalOperatingExpenses,
  operatingProfit,
  profitMargin,
  deliveredEquipment,
  contingency,
  initialInvestment,
  cumulativeCashFlow,
  yearOneProfit,
  yearOneRoi,
  payback,
}

/// A named quantity that feeds a metric.
enum OperandId {
  roundDuration,
  turnaroundTime,
  totalRoundTime,
  operatingHoursPerDay,
  operatingMinutesPerDay,
  maximumRoundsPerDay,
  occupancy,
  actualRoundsPerDay,
  averagePlayersPerRound,
  ticketPrice,
  dailyRevenue,
  operatingDaysPerMonth,
  monthlyRevenue,
  employeeCount,
  salaryPerEmployee,
  incentivePerEmployee,
  costPerEmployee,
  payroll,
  otherOperatingExpenses,
  totalOperatingExpenses,
  operatingProfit,
  equipmentCost,
  shippingRate,
  shipping,
  customsRate,
  customs,
  deliveredEquipment,
  fitOutTotal,
  propertyTotal,
  preOpeningTotal,
  startupSubtotal,
  contingencyRate,
  contingency,
  initialInvestment,
  previousCumulativeCashFlow,
  netCashFlow,
  cumulativeCashFlow,
  yearOneProfit,
  lastNegativeMonth,
  shortfallAtLastNegativeMonth,
}

/// A quantity carried out of the domain with its unit intact, so the
/// presentation layer can format it without guessing what it is.
sealed class ExplanationValue {
  const ExplanationValue();
}

class MoneyValue extends ExplanationValue {
  const MoneyValue(this.value);
  final Money value;
}

class PercentageValue extends ExplanationValue {
  const PercentageValue(this.value);
  final Percentage value;
}

class MinutesValue extends ExplanationValue {
  const MinutesValue(this.value);
  final Minutes value;
}

class CountValue extends ExplanationValue {
  const CountValue(this.value);
  final int value;
}

/// A plain number, e.g. 26.91 rounds or 3.63 players.
class NumberValue extends ExplanationValue {
  const NumberValue(this.value, {this.decimals = 2});
  final double value;
  final int decimals;
}

class MonthValue extends ExplanationValue {
  const MonthValue(this.monthNumber);
  final int monthNumber;
}

class Operand {
  const Operand(this.id, this.value);
  final OperandId id;
  final ExplanationValue value;
}

/// The derivation of one figure: which inputs went in, and what came out.
///
/// The domain supplies the identifiers and the values; the presentation layer
/// supplies the wording. No number here is recomputed - every one is read back
/// out of the projection that produced it.
class MetricExplanation {
  const MetricExplanation({
    required this.metric,
    required this.operands,
    required this.result,
    this.monthNumber,
  });

  final MetricId metric;
  final List<Operand> operands;
  final ExplanationValue result;

  /// The month the explanation refers to, for month-scoped metrics.
  final int? monthNumber;
}

/// Builds the "how is this calculated?" derivations.
class MetricExplanationService {
  const MetricExplanationService();

  /// Explains [metric] for a given month, defaulting to the steady-state month
  /// for metrics that describe a normal month.
  MetricExplanation? explain({
    required MetricId metric,
    required FinancialProjection projection,
    MonthlyFinancialResult? month,
  }) {
    final subject = month ?? projection.steadyStateMonth;
    final scenario = projection.scenario;

    switch (metric) {
      case MetricId.maximumRoundsPerDay:
        return MetricExplanation(
          metric: metric,
          operands: [
            Operand(
              OperandId.operatingHoursPerDay,
              NumberValue(scenario.revenue.schedule.hoursPerDay),
            ),
            Operand(
              OperandId.operatingMinutesPerDay,
              MinutesValue(projection.capacity.operatingMinutesPerDay),
            ),
            Operand(
              OperandId.roundDuration,
              MinutesValue(scenario.revenue.capacity.roundDuration),
            ),
            Operand(
              OperandId.turnaroundTime,
              MinutesValue(scenario.revenue.capacity.turnaroundTime),
            ),
            Operand(
              OperandId.totalRoundTime,
              MinutesValue(projection.capacity.totalRoundTime),
            ),
          ],
          result: CountValue(projection.capacity.maximumRoundsPerDay),
        );

      case MetricId.actualRoundsPerDay:
        if (subject == null) return null;
        return MetricExplanation(
          metric: metric,
          monthNumber: subject.monthNumber,
          operands: [
            Operand(
              OperandId.maximumRoundsPerDay,
              CountValue(subject.maximumRoundsPerDay),
            ),
            Operand(OperandId.occupancy, PercentageValue(subject.occupancy)),
          ],
          result: NumberValue(subject.actualRoundsPerDay),
        );

      case MetricId.dailyRevenue:
        if (subject == null) return null;
        return MetricExplanation(
          metric: metric,
          monthNumber: subject.monthNumber,
          operands: [
            Operand(
              OperandId.actualRoundsPerDay,
              NumberValue(subject.actualRoundsPerDay),
            ),
            Operand(
              OperandId.averagePlayersPerRound,
              NumberValue(scenario.revenue.pricing.averagePlayersPerRound),
            ),
            Operand(
              OperandId.ticketPrice,
              MoneyValue(scenario.revenue.pricing.ticketPricePerPlayer),
            ),
          ],
          result: MoneyValue(subject.dailyRevenue),
        );

      case MetricId.monthlyRevenue:
        if (subject == null) return null;
        return MetricExplanation(
          metric: metric,
          monthNumber: subject.monthNumber,
          operands: [
            Operand(OperandId.dailyRevenue, MoneyValue(subject.dailyRevenue)),
            Operand(
              OperandId.operatingDaysPerMonth,
              NumberValue(scenario.revenue.schedule.daysPerMonth, decimals: 1),
            ),
          ],
          result: MoneyValue(subject.monthlyRevenue),
        );

      case MetricId.payroll:
        if (subject == null) return null;
        return MetricExplanation(
          metric: metric,
          monthNumber: subject.monthNumber,
          operands: [
            Operand(OperandId.employeeCount, CountValue(subject.employeeCount)),
            Operand(
              OperandId.salaryPerEmployee,
              MoneyValue(scenario.staffing.monthlySalaryPerEmployee),
            ),
            Operand(
              OperandId.incentivePerEmployee,
              MoneyValue(scenario.staffing.monthlyIncentivePerEmployee),
            ),
            Operand(
              OperandId.costPerEmployee,
              MoneyValue(
                scenario.staffing.monthlySalaryPerEmployee +
                    scenario.staffing.monthlyIncentivePerEmployee,
              ),
            ),
          ],
          result: MoneyValue(subject.payroll),
        );

      case MetricId.totalOperatingExpenses:
        if (subject == null) return null;
        return MetricExplanation(
          metric: metric,
          monthNumber: subject.monthNumber,
          operands: [
            Operand(OperandId.payroll, MoneyValue(subject.payroll)),
            Operand(
              OperandId.otherOperatingExpenses,
              MoneyValue(subject.otherOperatingExpenses),
            ),
          ],
          result: MoneyValue(subject.totalOperatingExpenses),
        );

      case MetricId.operatingProfit:
        if (subject == null) return null;
        return MetricExplanation(
          metric: metric,
          monthNumber: subject.monthNumber,
          operands: [
            Operand(
              OperandId.monthlyRevenue,
              MoneyValue(subject.monthlyRevenue),
            ),
            Operand(
              OperandId.totalOperatingExpenses,
              MoneyValue(subject.totalOperatingExpenses),
            ),
          ],
          result: MoneyValue(subject.operatingProfit),
        );

      case MetricId.profitMargin:
        if (subject == null) return null;
        return MetricExplanation(
          metric: metric,
          monthNumber: subject.monthNumber,
          operands: [
            Operand(
              OperandId.operatingProfit,
              MoneyValue(subject.operatingProfit),
            ),
            Operand(
              OperandId.monthlyRevenue,
              MoneyValue(subject.monthlyRevenue),
            ),
          ],
          result: PercentageValue(subject.profitMargin),
        );

      case MetricId.deliveredEquipment:
        final startup = projection.startupCosts;
        return MetricExplanation(
          metric: metric,
          operands: [
            Operand(OperandId.equipmentCost, MoneyValue(startup.equipmentCost)),
            Operand(
              OperandId.shippingRate,
              PercentageValue(scenario.startupCosts.equipment.shippingRate),
            ),
            Operand(OperandId.shipping, MoneyValue(startup.shipping)),
            Operand(
              OperandId.customsRate,
              PercentageValue(scenario.startupCosts.equipment.customsRate),
            ),
            Operand(OperandId.customs, MoneyValue(startup.customs)),
          ],
          result: MoneyValue(startup.deliveredEquipment.total),
        );

      case MetricId.contingency:
        final startup = projection.startupCosts;
        return MetricExplanation(
          metric: metric,
          operands: [
            Operand(OperandId.startupSubtotal, MoneyValue(startup.subtotal)),
            Operand(
              OperandId.contingencyRate,
              PercentageValue(startup.contingencyRate),
            ),
          ],
          result: MoneyValue(startup.contingency),
        );

      case MetricId.initialInvestment:
        final startup = projection.startupCosts;
        return MetricExplanation(
          metric: metric,
          operands: [
            Operand(
              OperandId.deliveredEquipment,
              MoneyValue(startup.deliveredEquipment.total),
            ),
            Operand(OperandId.fitOutTotal, MoneyValue(startup.fitOut.total)),
            Operand(
              OperandId.propertyTotal,
              MoneyValue(startup.property.total),
            ),
            Operand(
              OperandId.preOpeningTotal,
              MoneyValue(startup.preOpening.total),
            ),
            Operand(OperandId.startupSubtotal, MoneyValue(startup.subtotal)),
            Operand(OperandId.contingency, MoneyValue(startup.contingency)),
          ],
          result: MoneyValue(startup.total),
        );

      case MetricId.cumulativeCashFlow:
        if (subject == null) return null;
        final previousMonth = subject.monthNumber - 1;
        return MetricExplanation(
          metric: metric,
          monthNumber: subject.monthNumber,
          operands: [
            if (previousMonth >= 0)
              Operand(
                OperandId.previousCumulativeCashFlow,
                MoneyValue(
                  projection.monthlyResults[previousMonth].cumulativeCashFlow,
                ),
              ),
            Operand(OperandId.netCashFlow, MoneyValue(subject.netCashFlow)),
          ],
          result: MoneyValue(subject.cumulativeCashFlow),
        );

      case MetricId.yearOneProfit:
        final yearOne = projection.yearOne;
        if (yearOne == null) return null;
        return MetricExplanation(
          metric: metric,
          operands: [
            Operand(OperandId.monthlyRevenue, MoneyValue(yearOne.revenue)),
            Operand(
              OperandId.totalOperatingExpenses,
              MoneyValue(yearOne.operatingExpenses),
            ),
          ],
          result: MoneyValue(yearOne.operatingProfit),
        );

      case MetricId.yearOneRoi:
        final roi = projection.roi;
        if (!roi.isDefined) return null;
        return MetricExplanation(
          metric: metric,
          operands: [
            Operand(OperandId.yearOneProfit, MoneyValue(roi.yearOneProfit)),
            Operand(
              OperandId.initialInvestment,
              MoneyValue(roi.initialInvestment),
            ),
          ],
          result: PercentageValue(roi.yearOneRoi!),
        );

      case MetricId.payback:
        final payback = projection.payback;
        final crossing = payback.firstNonNegativeMonth;
        if (crossing == null) return null;
        final lastNegative = payback.lastNegativeMonth;
        return MetricExplanation(
          metric: metric,
          monthNumber: crossing,
          operands: [
            if (lastNegative != null) ...[
              Operand(OperandId.lastNegativeMonth, MonthValue(lastNegative)),
              Operand(
                OperandId.shortfallAtLastNegativeMonth,
                MoneyValue(
                  projection
                      .monthlyResults[lastNegative]
                      .cumulativeCashFlow
                      .abs,
                ),
              ),
            ],
            Operand(
              OperandId.netCashFlow,
              MoneyValue(projection.monthlyResults[crossing].netCashFlow),
            ),
          ],
          result: payback.interpolatedMonths == null
              ? MonthValue(crossing)
              : NumberValue(payback.interpolatedMonths!),
        );
    }
  }
}
