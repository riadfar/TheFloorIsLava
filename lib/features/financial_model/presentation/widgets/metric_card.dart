import 'package:flutter/material.dart';

import '../../../../app/theme/app_theme.dart';
import '../../../../l10n/generated/app_localizations.dart';

/// How a figure should be coloured.
enum MetricTone {
  /// Just a number - no judgement attached.
  neutral,

  /// Good news: profit, recovery, headroom.
  positive,

  /// Bad news: a loss, a shortfall.
  negative,

  /// Worth a second look.
  warning,
}

/// One headline figure.
///
/// The value is the loudest thing in the card; everything else supports it.
/// Where a figure is derived, the card offers the derivation rather than asking
/// the reader to take it on trust.
class MetricCard extends StatelessWidget {
  const MetricCard({
    required this.label,
    required this.value,
    this.caption,
    this.tone = MetricTone.neutral,
    this.onExplain,
    super.key,
  });

  final String label;
  final String value;

  /// A short line under the value: a qualifier, not a second metric.
  final String? caption;

  final MetricTone tone;

  /// When given, the card offers a "how is this calculated?" affordance.
  final VoidCallback? onExplain;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.financialColors;
    final l10n = AppLocalizations.of(context);

    final valueColour = switch (tone) {
      MetricTone.neutral => theme.colorScheme.onSurface,
      MetricTone.positive => colors.positive,
      MetricTone.negative => colors.negative,
      MetricTone.warning => colors.warning,
    };

    return Card(
      child: InkWell(
        onTap: onExplain,
        borderRadius: AppSpacing.cardRadius,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      label,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: colors.mutedText,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (onExplain != null)
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: colors.mutedText,
                      semanticLabel: l10n.howIsThisCalculated,
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  value,
                  style: AppTheme.tabular(
                    theme.textTheme.headlineSmall!,
                  ).copyWith(color: valueColour, fontWeight: FontWeight.w600),
                ),
              ),
              if (caption != null) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  caption!,
                  style: theme.textTheme.bodySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// A label and a value on one line, for lists of supporting figures.
class MetricRow extends StatelessWidget {
  const MetricRow({
    required this.label,
    required this.value,
    this.tone = MetricTone.neutral,
    this.emphasised = false,
    this.indented = false,
    this.caption,
    super.key,
  });

  final String label;
  final String value;
  final MetricTone tone;

  /// Used for totals, which carry more weight than their components.
  final bool emphasised;
  final bool indented;
  final String? caption;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.financialColors;

    final valueColour = switch (tone) {
      MetricTone.neutral => theme.colorScheme.onSurface,
      MetricTone.positive => colors.positive,
      MetricTone.negative => colors.negative,
      MetricTone.warning => colors.warning,
    };

    final labelStyle = emphasised
        ? theme.textTheme.titleSmall
        : theme.textTheme.bodyMedium;
    final valueStyle = AppTheme.tabular(
      emphasised ? theme.textTheme.titleSmall! : theme.textTheme.bodyMedium!,
    ).copyWith(color: valueColour, fontWeight: FontWeight.w600);

    return Semantics(
      label: label,
      value: value,
      child: Padding(
        padding: EdgeInsets.only(
          left: indented ? AppSpacing.lg : 0,
          top: AppSpacing.sm,
          bottom: AppSpacing.sm,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: labelStyle),
                  if (caption != null)
                    Text(caption!, style: theme.textTheme.bodySmall),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            // Flexible, because some values are sentences - "Not recoverable
            // under this case" must wrap rather than overflow the row.
            Flexible(
              child: Text(value, style: valueStyle, textAlign: TextAlign.end),
            ),
          ],
        ),
      ),
    );
  }
}
