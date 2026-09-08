import 'package:flutter/widgets.dart';

/// Width bands, following the Material window size classes.
enum WindowSizeClass {
  /// Phones in portrait.
  compact,

  /// Small tablets, phones in landscape, split-screen windows.
  medium,

  /// Tablets in landscape, small desktop windows.
  expanded,

  /// Large tablets and desktops.
  large,
}

/// How the app's destinations are presented.
enum NavigationStyle {
  /// A bar along the bottom: reachable by thumb on a phone.
  bottomBar,

  /// A narrow icon rail down the side.
  rail,

  /// A wide rail with labels, for screens with width to spare.
  extendedRail,
}

/// The single place that decides how the app adapts to a screen.
///
/// Widgets ask this object questions ("how many columns?", "is there room for a
/// table?") instead of testing `MediaQuery.size.width > 600` themselves. That
/// keeps breakpoints out of the widget tree and makes the rules testable.
class ResponsiveLayout {
  const ResponsiveLayout({required this.size});

  factory ResponsiveLayout.of(BuildContext context) =>
      ResponsiveLayout(size: MediaQuery.sizeOf(context));

  final Size size;

  static const double _mediumWidth = 600;
  static const double _expandedWidth = 840;
  static const double _largeWidth = 1200;

  /// Below this height a screen is a phone on its side: short, and easily
  /// overwhelmed by chrome.
  static const double _shortHeight = 640;

  /// Wide layouts need real height as well as width before they earn a table.
  static const double _tableMinHeight = 500;

  /// Width at which a second column of content, or a real data grid, starts to
  /// pay for itself. Set below the Material "expanded" breakpoint on purpose:
  /// common tablets are 744-834dp wide in portrait, and they should get the
  /// tablet treatment rather than a stretched phone layout.
  static const double _twoColumnWidth = 700;

  double get width => size.width;
  double get height => size.height;

  WindowSizeClass get sizeClass {
    if (width < _mediumWidth) return WindowSizeClass.compact;
    if (width < _expandedWidth) return WindowSizeClass.medium;
    if (width < _largeWidth) return WindowSizeClass.expanded;
    return WindowSizeClass.large;
  }

  bool get isCompact => sizeClass == WindowSizeClass.compact;
  bool get isLandscape => width > height;

  /// True where two columns of content are genuinely comfortable.
  bool get supportsTwoColumns => width >= _twoColumnWidth;

  NavigationStyle get navigationStyle {
    if (width < _mediumWidth) return NavigationStyle.bottomBar;
    // A phone on its side is wide but short: labels alongside the icons would
    // cost width the content needs more.
    if (width < 1000 || height < _shortHeight) return NavigationStyle.rail;
    return NavigationStyle.extendedRail;
  }

  /// Beyond this the content stops growing and centres instead, so lines of
  /// text and table rows never become uncomfortably wide.
  double get contentMaxWidth => switch (sizeClass) {
    WindowSizeClass.compact => double.infinity,
    WindowSizeClass.medium => 900,
    WindowSizeClass.expanded => 1100,
    WindowSizeClass.large => 1280,
  };

  double get gutter => switch (sizeClass) {
    WindowSizeClass.compact => 16,
    WindowSizeClass.medium => 20,
    WindowSizeClass.expanded || WindowSizeClass.large => 24,
  };

  EdgeInsets get pagePadding =>
      EdgeInsets.symmetric(horizontal: gutter, vertical: isCompact ? 12 : 20);

  /// Minimum comfortable width for a key-figure tile. Grids derive their column
  /// count from this rather than from a breakpoint table.
  double get metricTileMinWidth => switch (sizeClass) {
    WindowSizeClass.compact => 158,
    WindowSizeClass.medium => 200,
    WindowSizeClass.expanded || WindowSizeClass.large => 220,
  };

  /// A dense table needs width for its columns and height for its rows.
  bool get useDataTable =>
      width >= _twoColumnWidth && height >= _tableMinHeight;

  /// Charts get taller as the window does, within sensible limits.
  double get chartHeight {
    if (isCompact) return 200;
    if (height < _shortHeight) return 190;
    return sizeClass == WindowSizeClass.large ? 280 : 240;
  }
}

extension ResponsiveContext on BuildContext {
  /// The layout rules for this screen.
  ResponsiveLayout get layout => ResponsiveLayout.of(this);
}
