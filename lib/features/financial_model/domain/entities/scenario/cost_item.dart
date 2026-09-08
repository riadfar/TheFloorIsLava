import 'package:equatable/equatable.dart';

import '../../value_objects/money.dart';
import 'assumption_status.dart';

/// A user-created line of money, used for expense and start-up categories that
/// the study does not name explicitly.
///
/// The five named monthly expenses and the five named fit-out items stay as
/// dedicated fields so the model still reads like the original study. This type
/// exists so the model can grow without those fields becoming a dumping ground.
class CostItem extends Equatable {
  const CostItem({
    required this.id,
    required this.label,
    required this.amount,
    this.status = AssumptionStatus.userDefined,
  });

  final String id;
  final String label;
  final Money amount;
  final AssumptionStatus status;

  CostItem copyWith({String? label, Money? amount, AssumptionStatus? status}) {
    return CostItem(
      id: id,
      label: label ?? this.label,
      amount: amount ?? this.amount,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [id, label, amount, status];
}
