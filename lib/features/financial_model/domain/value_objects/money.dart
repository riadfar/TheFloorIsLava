/// An immutable, currency-agnostic monetary amount.
///
/// Money is stored as a whole number of *micros* (millionths of a major unit)
/// rather than as a `double`. This keeps additions and subtractions exact and
/// prevents the classic `$4.00 -> 3.9999999997` drift described in the
/// specification, while still preserving far more precision than cents.
///
/// The extra precision matters: intermediate results of this model (for example
/// a daily revenue of `26.91 x 3.63 x $4 = $390.7332`) legitimately carry
/// fractions of a cent, and the study's monthly and annual figures are derived
/// from them. Rounding to cents happens only at display time.
///
/// Money carries no currency code on purpose. The currency is a property of the
/// scenario (see `ScenarioMetadata`), so a single scenario cannot accidentally
/// mix units, and formatting stays a presentation concern.
class Money implements Comparable<Money> {
  const Money._(this.micros);

  /// Number of micros in one major unit (for example, in one dollar).
  static const int microsPerUnit = 1000000;

  /// The amount expressed as whole micros.
  final int micros;

  static const Money zero = Money._(0);

  /// Creates money from a whole number of major units.
  ///
  /// Const-constructible, so seed data and tests can express fixed amounts as
  /// compile-time constants.
  const Money.units(int majorUnits) : micros = majorUnits * microsPerUnit;

  /// Creates money from any major-unit amount, for example `Money.of(3.5)`.
  factory Money.of(num majorUnits) =>
      Money._((majorUnits * microsPerUnit).round());

  /// Creates money directly from micros. Mainly useful for serialisation.
  factory Money.fromMicros(int micros) => Money._(micros);

  /// The amount expressed in major units. Use for ratios and display only,
  /// never as the storage format of a running total.
  double get amount => micros / microsPerUnit;

  bool get isZero => micros == 0;
  bool get isPositive => micros > 0;
  bool get isNegative => micros < 0;

  Money operator +(Money other) => Money._(micros + other.micros);
  Money operator -(Money other) => Money._(micros - other.micros);
  Money operator -() => Money._(-micros);

  /// Scales the amount by a dimensionless factor (a rate, a count, a quantity).
  Money operator *(num factor) => Money._((micros * factor).round());

  /// Divides the amount by a dimensionless divisor.
  Money operator /(num divisor) => Money._((micros / divisor).round());

  Money get abs => Money._(micros.abs());

  /// The dimensionless ratio between two amounts, or `null` when [other] is
  /// zero. Returning `null` instead of infinity forces callers to decide how an
  /// undefined ratio should be presented.
  double? ratioTo(Money other) =>
      other.micros == 0 ? null : micros / other.micros;

  bool operator <(Money other) => micros < other.micros;
  bool operator <=(Money other) => micros <= other.micros;
  bool operator >(Money other) => micros > other.micros;
  bool operator >=(Money other) => micros >= other.micros;

  static Money sum(Iterable<Money> values) {
    var total = 0;
    for (final value in values) {
      total += value.micros;
    }
    return Money._(total);
  }

  @override
  int compareTo(Money other) => micros.compareTo(other.micros);

  @override
  bool operator ==(Object other) => other is Money && other.micros == micros;

  @override
  int get hashCode => micros.hashCode;

  @override
  String toString() => 'Money(${amount.toStringAsFixed(6)})';
}
