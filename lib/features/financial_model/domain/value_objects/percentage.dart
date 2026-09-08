/// An immutable proportion, stored internally as a fraction.
///
/// The specification requires one consistent representation: `0.69` internally
/// and `69%` in the UI. Wrapping it prevents the most common bug in this kind
/// of model - multiplying by `69` instead of `0.69`.
class Percentage implements Comparable<Percentage> {
  const Percentage.fromFraction(this.fraction);

  /// Creates a percentage from a human-facing value, e.g. `69` for 69%.
  const Percentage.fromPercent(num percent) : fraction = percent / 100;

  /// The proportion as a fraction of one, e.g. `0.69`.
  final double fraction;

  static const Percentage zero = Percentage.fromFraction(0);
  static const Percentage one = Percentage.fromFraction(1);

  /// The proportion in percentage points, e.g. `69`.
  double get percent => fraction * 100;

  bool get isZero => fraction == 0;

  Percentage operator +(Percentage other) =>
      Percentage.fromFraction(fraction + other.fraction);
  Percentage operator -(Percentage other) =>
      Percentage.fromFraction(fraction - other.fraction);

  bool operator <(Percentage other) => fraction < other.fraction;
  bool operator <=(Percentage other) => fraction <= other.fraction;
  bool operator >(Percentage other) => fraction > other.fraction;
  bool operator >=(Percentage other) => fraction >= other.fraction;

  @override
  int compareTo(Percentage other) => fraction.compareTo(other.fraction);

  @override
  bool operator ==(Object other) =>
      other is Percentage && other.fraction == fraction;

  @override
  int get hashCode => fraction.hashCode;

  @override
  String toString() => 'Percentage(${percent.toStringAsFixed(2)}%)';
}
