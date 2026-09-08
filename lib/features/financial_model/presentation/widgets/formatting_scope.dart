import 'package:flutter/widgets.dart';

import '../../../../core/formatting/value_formatter.dart';

/// Makes one configured [ValueFormatter] available to the whole screen tree.
///
/// The formatter depends on both the scenario (its currency) and the user's
/// preferences (decimal places, locale). Building it once here keeps those two
/// sources in one place and stops every widget from constructing its own.
class FormattingScope extends InheritedWidget {
  const FormattingScope({
    required this.formatter,
    required super.child,
    super.key,
  });

  final ValueFormatter formatter;

  static ValueFormatter of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<FormattingScope>();
    assert(scope != null, 'No FormattingScope found in the widget tree');
    return scope!.formatter;
  }

  @override
  bool updateShouldNotify(FormattingScope oldWidget) {
    final previous = oldWidget.formatter;
    return previous.localeName != formatter.localeName ||
        previous.currencyCode != formatter.currencyCode ||
        previous.decimalPrecision != formatter.decimalPrecision;
  }
}

extension FormattingContext on BuildContext {
  ValueFormatter get formatter => FormattingScope.of(this);
}
