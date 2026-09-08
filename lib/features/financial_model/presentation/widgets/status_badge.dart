import 'package:flutter/material.dart';

import '../../../../app/theme/app_theme.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/entities/scenario/assumption_status.dart';
import '../l10n/model_labels.dart';

/// Shows how much an assumption can be trusted.
///
/// The status is always spelled out in words - colour alone would leave the
/// distinction invisible to anyone who cannot see it.
class StatusBadge extends StatelessWidget {
  const StatusBadge({required this.status, this.dense = false, super.key});

  final AssumptionStatus status;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.financialColors;
    final (foreground, background) = switch (status) {
      AssumptionStatus.estimated => (colors.warning, colors.warningSurface),
      AssumptionStatus.verified => (colors.info, colors.infoSurface),
      AssumptionStatus.confirmed => (colors.positive, colors.positiveSurface),
      AssumptionStatus.userDefined => (
        colors.editableAccent,
        colors.infoSurface,
      ),
      AssumptionStatus.imported => (colors.mutedText, colors.infoSurface),
    };

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: dense ? AppSpacing.xs + 2 : AppSpacing.sm,
        vertical: dense ? 1 : 3,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
        border: Border.all(color: foreground.withValues(alpha: 0.35)),
      ),
      child: Text(
        l10n.assumptionStatusLabel(status),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: foreground,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}
