import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:the_floor_is_lava/core/responsive/responsive_layout.dart';

/// Representative devices, so the rules are checked against real shapes rather
/// than arbitrary numbers.
const Size smallPhonePortrait = Size(360, 740);
const Size largePhonePortrait = Size(430, 932);
const Size largePhoneLandscape = Size(932, 430);
const Size smallTabletPortrait = Size(744, 1133);
const Size tabletPortrait = Size(834, 1194);
const Size tabletLandscape = Size(1194, 834);
const Size largeTabletLandscape = Size(1366, 1024);

void main() {
  ResponsiveLayout layoutFor(Size size) => ResponsiveLayout(size: size);

  group('window size classes', () {
    test('phones in portrait are compact', () {
      expect(layoutFor(smallPhonePortrait).sizeClass, WindowSizeClass.compact);
      expect(layoutFor(largePhonePortrait).sizeClass, WindowSizeClass.compact);
    });

    test('a phone on its side and a small tablet are medium or wider', () {
      expect(
        layoutFor(largePhoneLandscape).sizeClass,
        WindowSizeClass.expanded,
      );
      expect(layoutFor(smallTabletPortrait).sizeClass, WindowSizeClass.medium);
    });

    test('large tablets are the largest class', () {
      expect(layoutFor(tabletLandscape).sizeClass, WindowSizeClass.expanded);
      expect(layoutFor(largeTabletLandscape).sizeClass, WindowSizeClass.large);
    });
  });

  group('navigation', () {
    test('a phone in portrait gets a bottom bar', () {
      expect(
        layoutFor(smallPhonePortrait).navigationStyle,
        NavigationStyle.bottomBar,
      );
    });

    test('a phone on its side gets an icon rail, not a labelled one', () {
      // Wide but short: labels would cost width the content needs more.
      expect(
        layoutFor(largePhoneLandscape).navigationStyle,
        NavigationStyle.rail,
      );
    });

    test('a tablet in portrait gets an icon rail', () {
      expect(layoutFor(tabletPortrait).navigationStyle, NavigationStyle.rail);
    });

    test('a tablet in landscape gets a labelled rail', () {
      expect(
        layoutFor(tabletLandscape).navigationStyle,
        NavigationStyle.extendedRail,
      );
      expect(
        layoutFor(largeTabletLandscape).navigationStyle,
        NavigationStyle.extendedRail,
      );
    });
  });

  group('content decisions', () {
    test('only wide and tall windows get a data table', () {
      expect(layoutFor(smallPhonePortrait).useDataTable, isFalse);
      expect(layoutFor(largePhoneLandscape).useDataTable, isFalse);
      expect(layoutFor(tabletPortrait).useDataTable, isTrue);
      expect(layoutFor(tabletLandscape).useDataTable, isTrue);
    });

    test('content stops widening beyond a comfortable measure', () {
      expect(layoutFor(smallPhonePortrait).contentMaxWidth, double.infinity);
      expect(
        layoutFor(largeTabletLandscape).contentMaxWidth,
        lessThan(largeTabletLandscape.width),
      );
      expect(
        layoutFor(tabletLandscape).contentMaxWidth,
        lessThan(tabletLandscape.width),
      );
    });

    test('two-column content needs real width', () {
      expect(layoutFor(largePhonePortrait).supportsTwoColumns, isFalse);
      expect(layoutFor(smallTabletPortrait).supportsTwoColumns, isTrue);
      expect(layoutFor(tabletPortrait).supportsTwoColumns, isTrue);
    });

    test('gutters and tiles grow with the window', () {
      expect(
        layoutFor(tabletLandscape).gutter,
        greaterThan(layoutFor(smallPhonePortrait).gutter),
      );
      expect(
        layoutFor(tabletLandscape).metricTileMinWidth,
        greaterThan(layoutFor(smallPhonePortrait).metricTileMinWidth),
      );
    });

    test('a short window gets a shorter chart', () {
      expect(
        layoutFor(largePhoneLandscape).chartHeight,
        lessThan(layoutFor(largeTabletLandscape).chartHeight),
      );
    });
  });
}
