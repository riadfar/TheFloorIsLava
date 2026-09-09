import 'package:equatable/equatable.dart';

import '../../value_objects/percentage.dart';

/// Configurable VAT cash-outflow stub; no jurisdictional rate is assumed.
class TaxAssumptions extends Equatable {
  const TaxAssumptions({
    this.vatRate = Percentage.zero,
    this.pricesIncludeVat = false,
  });

  final Percentage vatRate;
  final bool pricesIncludeVat;

  @override
  List<Object?> get props => [vatRate, pricesIncludeVat];
}
