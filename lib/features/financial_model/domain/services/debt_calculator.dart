import 'dart:math' as math;

import 'package:equatable/equatable.dart';

import '../entities/scenario/debt_assumptions.dart';
import '../value_objects/money.dart';

class DebtPayment extends Equatable {
  const DebtPayment({
    required this.monthNumber,
    required this.interest,
    required this.principalPortion,
    required this.totalPayment,
    required this.remainingBalance,
  });

  final int monthNumber;
  final Money interest;
  final Money principalPortion;
  final Money totalPayment;
  final Money remainingBalance;

  @override
  List<Object?> get props => [
    monthNumber,
    interest,
    principalPortion,
    totalPayment,
    remainingBalance,
  ];
}

class DebtCalculator {
  const DebtCalculator();

  List<DebtPayment> calculate(DebtAssumptions assumptions) {
    if (!assumptions.enabled ||
        assumptions.principal.isZero ||
        assumptions.termMonths <= 0) {
      return const [];
    }

    final monthlyRate = assumptions.annualInterestRate.fraction / 12;
    final payment = _annuityPayment(
      assumptions.principal,
      monthlyRate,
      assumptions.termMonths,
    );
    var balance = assumptions.principal;
    final schedule = <DebtPayment>[];

    for (var index = 0; index < assumptions.termMonths; index++) {
      final isLast = index == assumptions.termMonths - 1;
      final interest = balance * monthlyRate;
      late final Money principalPortion;
      late final Money totalPayment;

      if (assumptions.kind == DebtAmortizationKind.interestOnly) {
        // Interest is serviced monthly; the full principal is a balloon in the
        // final payment month.
        principalPortion = isLast ? balance : Money.zero;
        totalPayment = interest + principalPortion;
      } else {
        principalPortion = isLast
            ? balance
            : _minimum(payment - interest, balance);
        totalPayment = interest + principalPortion;
      }

      balance -= principalPortion;
      schedule.add(
        DebtPayment(
          monthNumber: assumptions.firstPaymentMonth + index,
          interest: interest,
          principalPortion: principalPortion,
          totalPayment: totalPayment,
          remainingBalance: balance,
        ),
      );
    }

    return List.unmodifiable(schedule);
  }

  Money _annuityPayment(Money principal, double rate, int termMonths) {
    if (rate == 0) return principal / termMonths;
    final growth = math.pow(1 + rate, termMonths).toDouble();
    return principal * (rate * growth / (growth - 1));
  }

  Money _minimum(Money left, Money right) => left <= right ? left : right;
}
