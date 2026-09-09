import 'package:equatable/equatable.dart';

import '../../value_objects/money.dart';
import '../../value_objects/percentage.dart';

enum DebtAmortizationKind { interestOnly, annuity }

/// Financing assumptions. Disabled debt is deliberately the baseline default.
class DebtAssumptions extends Equatable {
  const DebtAssumptions({
    this.enabled = false,
    this.principal = Money.zero,
    this.annualInterestRate = Percentage.zero,
    this.termMonths = 0,
    this.disbursementMonth = 0,
    this.firstPaymentMonth = 1,
    this.kind = DebtAmortizationKind.annuity,
  });

  final bool enabled;
  final Money principal;
  final Percentage annualInterestRate;
  final int termMonths;
  final int disbursementMonth;
  final int firstPaymentMonth;
  final DebtAmortizationKind kind;

  DebtAssumptions copyWith({
    bool? enabled,
    Money? principal,
    Percentage? annualInterestRate,
    int? termMonths,
    int? disbursementMonth,
    int? firstPaymentMonth,
    DebtAmortizationKind? kind,
  }) {
    return DebtAssumptions(
      enabled: enabled ?? this.enabled,
      principal: principal ?? this.principal,
      annualInterestRate: annualInterestRate ?? this.annualInterestRate,
      termMonths: termMonths ?? this.termMonths,
      disbursementMonth: disbursementMonth ?? this.disbursementMonth,
      firstPaymentMonth: firstPaymentMonth ?? this.firstPaymentMonth,
      kind: kind ?? this.kind,
    );
  }

  @override
  List<Object?> get props => [
    enabled,
    principal,
    annualInterestRate,
    termMonths,
    disbursementMonth,
    firstPaymentMonth,
    kind,
  ];
}
