import 'package:flutter/material.dart';

import '../../../../app/theme/app_theme.dart';

enum NoticeTone { warning, error, info }

/// A short, non-blocking message about the state of the model.
///
/// Always carries an icon *and* text: the tone is a reinforcement, never the
/// only carrier of meaning.
class NoticeBanner extends StatelessWidget {
  const NoticeBanner({
    required this.message,
    this.tone = NoticeTone.warning,
    this.onDismiss,
    super.key,
  });

  final String message;
  final NoticeTone tone;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.financialColors;

    final (foreground, background, icon) = switch (tone) {
      NoticeTone.warning => (
        colors.warning,
        colors.warningSurface,
        Icons.warning_amber_rounded,
      ),
      NoticeTone.error => (
        colors.negative,
        colors.negativeSurface,
        Icons.error_outline,
      ),
      NoticeTone.info => (colors.info, colors.infoSurface, Icons.info_outline),
    };

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
        border: Border.all(color: foreground.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: foreground),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface,
                height: 1.35,
              ),
            ),
          ),
          if (onDismiss != null)
            IconButton(
              onPressed: onDismiss,
              icon: const Icon(Icons.close, size: 16),
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            ),
        ],
      ),
    );
  }
}
