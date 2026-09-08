import 'package:flutter/material.dart';

import '../../../../app/theme/app_theme.dart';
import '../../../../core/responsive/responsive_layout.dart';

/// The frame every screen sits in: a title bar, then content constrained to a
/// comfortable reading width and centred on wide displays.
///
/// Screens supply their own scrollable so each one can choose the right kind -
/// a list on a phone, a table on a tablet - without a second scroll view
/// wrapping it.
class ScreenScaffold extends StatelessWidget {
  const ScreenScaffold({
    required this.title,
    required this.body,
    this.subtitle,
    this.actions,
    super.key,
  });

  final String title;
  final String? subtitle;
  final List<Widget>? actions;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.financialColors;
    final layout = context.layout;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            border: Border(bottom: BorderSide(color: colors.border)),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: layout.gutter,
              vertical: AppSpacing.md,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: theme.textTheme.titleLarge),
                      if (subtitle != null)
                        Text(subtitle!, style: theme.textTheme.bodySmall),
                    ],
                  ),
                ),
                ...?actions,
              ],
            ),
          ),
        ),
        Expanded(
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: layout.contentMaxWidth),
              child: body,
            ),
          ),
        ),
      ],
    );
  }
}

/// Vertical rhythm between the blocks of a screen.
class ScreenSection extends StatelessWidget {
  const ScreenSection({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: AppSpacing.lg),
    child: child,
  );
}
