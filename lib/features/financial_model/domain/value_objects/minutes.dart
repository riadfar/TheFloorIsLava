/// An immutable duration expressed in minutes.
///
/// The capacity model reasons in minutes throughout (round length, turnaround,
/// minutes of trading per day), so a dedicated type removes any doubt about the
/// unit a number is carrying.
class Minutes implements Comparable<Minutes> {
  const Minutes(this.value);

  /// The duration in minutes. Fractional values are allowed so the model can
  /// express, for example, a 12.5 minute round.
  final double value;

  static const Minutes zero = Minutes(0);

  factory Minutes.fromHours(num hours) => Minutes(hours * 60);

  double get inHours => value / 60;

  bool get isZero => value == 0;
  bool get isPositive => value > 0;

  Minutes operator +(Minutes other) => Minutes(value + other.value);
  Minutes operator -(Minutes other) => Minutes(value - other.value);

  bool operator <(Minutes other) => value < other.value;
  bool operator <=(Minutes other) => value <= other.value;
  bool operator >(Minutes other) => value > other.value;
  bool operator >=(Minutes other) => value >= other.value;

  @override
  int compareTo(Minutes other) => value.compareTo(other.value);

  @override
  bool operator ==(Object other) => other is Minutes && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'Minutes($value)';
}
