import 'package:flutter/material.dart';

import '../../../../app/theme/app_theme.dart';
import '../../../../core/formatting/value_formatter.dart';
import '../../../../core/responsive/responsive_layout.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/services/metric_explanation_service.dart';
import '../l10n/model_labels.dart';
import 'formatting_scope.dart';

/// Renders a domain [ExplanationValue] with its unit intact.
String formatExplanationValue(
  ExplanationValue value,
  ValueFormatter formatter,
  AppLocalizations l10n,
) {
  return switch (value) {
    MoneyValue(:final value) => formatter.money(value),
    PercentageValue(:final value) => formatter.percentage(value),
    MinutesValue(:final value) =>
      '${formatter.minutes(value)} ${l10n.unitMinutes}',
    CountValue(:final value) => formatter.count(value),
    NumberValue(:final value, :final decimals) => formatter.number(
      value,
      decimals: decimals,
    ),
    MonthValue(:final monthNumber) => l10n.monthLabel(monthNumber),
  };
}

/// The "how is this calculated?" panel.
///
/// It shows the formula in words, the values that went into it, and the answer.
/// Every value comes from the projection that produced the figure, so the panel
/// can never disagree with the number it explains.
class CalculationExplanationView extends StatelessWidget {
  const CalculationExplanationView({required this.explanation, super.key});

  final MetricExplanation explanation;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.financialColors;
    final l10n = AppLocalizations.of(context);
    final formatter = context.formatter;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          l10n.metricTitle(explanation.metric),
          style: theme.textTheme.titleMedium,
        ),
        if (explanation.monthNumber != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            l10n.monthLabel(explanation.monthNumber!),
            style: theme.textTheme.bodySmall,
          ),
        ],
        const SizedBox(height: AppSpacing.lg),
        _Label(text: l10n.formulaLabel),
        const SizedBox(height: AppSpacing.xs),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: colors.infoSurface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
          ),
          child: Text(
            l10n.metricFormula(explanation.metric),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.editableAccent,
              height: 1.4,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        _Label(text: l10n.inputsLabel),
        const SizedBox(height: AppSpacing.xs),
        for (final operand in explanation.operands)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.operandLabel(operand.id),
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Text(
                  formatExplanationValue(operand.value, formatter, l10n),
                  style: AppTheme.tabular(theme.textTheme.bodyMedium!),
                ),
              ],
            ),
          ),
        const SizedBox(height: AppSpacing.md),
        const Divider(),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: Text(l10n.resultLabel, style: theme.textTheme.titleSmall),
            ),
            Text(
              formatExplanationValue(explanation.result, formatter, l10n),
              style: AppTheme.tabular(theme.textTheme.titleMedium!),
            ),
          ],
        ),
      ],
    );
  }
}

class _Label extends StatelessWidget {
  const _Label({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: Theme.of(context).textTheme.labelSmall
          ?.copyWith(fontWeight: FontWeight.w600),
    );
  }
}

/// Presents an explanation in whichever container suits the screen: a sheet
/// from the bottom on a phone, a dialog where there is room around it.
Future<void> showCalculationExplanation(
  BuildContext context,
  MetricExplanation? explanation,
) {
  if (explanation == null) return Future<void>.value();

  final layout = context.layout;
  final formatter = context.formatter;
  final content = FormattingScope(
    formatter: formatter,
    child: CalculationExplanationView(explanation: explanation),
  );

  if (layout.isCompact) {
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            0,
            AppSpacing.xl,
            AppSpacing.xl,
          ),
          child: content,
        ),
      ),
    );
  }

  final l10n = AppLocalizations.of(context);
  return showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: SingleChildScrollView(child: content),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.close),
        ),
      ],
    ),
  );
}
