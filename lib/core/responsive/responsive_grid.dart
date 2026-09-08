import 'package:flutter/widgets.dart';

/// A grid that chooses its own column count from the width it is given.
///
/// Using a minimum tile width rather than fixed breakpoints means the grid also
/// behaves correctly inside a column of a wider layout, where the available
/// width is not the screen width.
class ResponsiveGrid extends StatelessWidget {
  const ResponsiveGrid({
    required this.children,
    required this.minTileWidth,
    this.spacing = 12,
    this.runSpacing = 12,
    this.maxColumns,
    super.key,
  });

  final List<Widget> children;
  final double minTileWidth;
  final double spacing;
  final double runSpacing;

  /// Optional ceiling, so a very wide window does not produce a row of slivers.
  final int? maxColumns;

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = _columnsFor(constraints.maxWidth);
        final tileWidth =
            (constraints.maxWidth - spacing * (columns - 1)) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: runSpacing,
          children: [
            for (final child in children)
              SizedBox(width: tileWidth, child: child),
          ],
        );
      },
    );
  }

  int _columnsFor(double availableWidth) {
    if (!availableWidth.isFinite || availableWidth <= 0) return 1;
    var columns = ((availableWidth + spacing) / (minTileWidth + spacing))
        .floor();
    columns = columns.clamp(1, children.length);
    if (maxColumns != null) columns = columns.clamp(1, maxColumns!);
    return columns;
  }
}
