import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../app/theme/app_theme.dart';

/// One month's value on a chart.
class ChartPoint {
  const ChartPoint({required this.month, required this.value});

  final int month;
  final double value;
}

/// Shared geometry for the two chart types: axis range, ticks and the plotting
/// rectangle. Keeping it in one place is what makes the charts look like a set.
class _ChartGeometry {
  _ChartGeometry(this.points, this.size, this.labelWidth) {
    final values = points.map((point) => point.value).toList();
    // Zero is always on the axis: a cash-flow chart that hides the break-even
    // line tells the wrong story.
    final rawMin = math.min(0.0, values.reduce(math.min));
    final rawMax = math.max(0.0, values.reduce(math.max));
    final step = _niceStep((rawMax - rawMin) / 4);

    min = (rawMin / step).floorToDouble() * step;
    max = (rawMax / step).ceilToDouble() * step;
    if (min == max) max = min + step;
    this.step = step;

    plot = Rect.fromLTRB(
      labelWidth,
      6,
      size.width,
      math.max(6.0, size.height - _axisHeight),
    );
  }

  static const double _axisHeight = 20;

  final List<ChartPoint> points;
  final Size size;
  final double labelWidth;

  late final double min;
  late final double max;
  late final double step;
  late final Rect plot;

  double yFor(double value) =>
      plot.bottom - (value - min) / (max - min) * plot.height;

  double get zeroY => yFor(0);

  /// A round number close to [raw], so axis labels read as 5,000 rather than
  /// 4,873.
  static double _niceStep(double raw) {
    if (raw <= 0) return 1;
    final magnitude = math
        .pow(10, (math.log(raw) / math.ln10).floor())
        .toDouble();
    final normalised = raw / magnitude;
    final niceNormalised = normalised <= 1
        ? 1.0
        : normalised <= 2
        ? 2.0
        : normalised <= 5
        ? 5.0
        : 10.0;
    return niceNormalised * magnitude;
  }

  Iterable<double> get ticks sync* {
    for (var value = min; value <= max + step / 2; value += step) {
      yield value;
    }
  }
}

/// Draws axis labels and grid lines. Used by both chart painters so they share
/// exactly the same frame.
void _paintAxes(
  Canvas canvas,
  _ChartGeometry geometry,
  String Function(double) labelForValue,
  Color gridColour,
  Color labelColour,
  TextStyle labelStyle,
) {
  final gridPaint = Paint()
    ..color = gridColour
    ..strokeWidth = 1;

  for (final tick in geometry.ticks) {
    final y = geometry.yFor(tick);
    canvas.drawLine(
      Offset(geometry.plot.left, y),
      Offset(geometry.plot.right, y),
      gridPaint,
    );

    final painter = TextPainter(
      text: TextSpan(
        text: labelForValue(tick),
        style: labelStyle.copyWith(color: labelColour),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(
      canvas,
      Offset(
        math.max(0, geometry.plot.left - painter.width - 6),
        y - painter.height / 2,
      ),
    );
  }
}

void _paintMonthLabels(
  Canvas canvas,
  _ChartGeometry geometry,
  double Function(int index) xForIndex,
  Color labelColour,
  TextStyle labelStyle,
  String Function(int month) labelForMonth,
) {
  final points = geometry.points;
  if (points.isEmpty) return;

  // Roughly one label every 60 logical pixels, so a narrow chart thins them out
  // instead of overlapping.
  final maximumLabels = math.max(2, geometry.plot.width ~/ 60);
  final stride = math.max(1, (points.length / maximumLabels).ceil());

  for (var index = 0; index < points.length; index += stride) {
    final painter = TextPainter(
      text: TextSpan(
        text: labelForMonth(points[index].month),
        style: labelStyle.copyWith(color: labelColour),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final x = (xForIndex(index) - painter.width / 2).clamp(
      0.0,
      geometry.size.width - painter.width,
    );
    painter.paint(canvas, Offset(x, geometry.plot.bottom + 4));
  }
}

/// A line chart with the area under the curve filled, split at zero so a
/// deficit reads differently from a surplus.
class CumulativeLineChart extends StatelessWidget {
  const CumulativeLineChart({
    required this.points,
    required this.labelForValue,
    required this.labelForMonth,
    required this.semanticsLabel,
    this.height = 220,
    super.key,
  });

  final List<ChartPoint> points;
  final String Function(double) labelForValue;
  final String Function(int) labelForMonth;

  /// A spoken summary - a painted chart is invisible to a screen reader.
  final String semanticsLabel;

  final double height;

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) return SizedBox(height: height);
    final theme = Theme.of(context);
    final colors = context.financialColors;

    return Semantics(
      label: semanticsLabel,
      child: SizedBox(
        height: height,
        child: CustomPaint(
          size: Size.infinite,
          painter: _LinePainter(
            points: points,
            labelForValue: labelForValue,
            labelForMonth: labelForMonth,
            positive: colors.positive,
            negative: colors.negative,
            grid: colors.chartGrid,
            labelColour: colors.mutedText,
            labelStyle: theme.textTheme.labelSmall ?? const TextStyle(),
            baseline: theme.colorScheme.onSurface.withValues(alpha: 0.35),
          ),
        ),
      ),
    );
  }
}

class _LinePainter extends CustomPainter {
  _LinePainter({
    required this.points,
    required this.labelForValue,
    required this.labelForMonth,
    required this.positive,
    required this.negative,
    required this.grid,
    required this.labelColour,
    required this.labelStyle,
    required this.baseline,
  });

  final List<ChartPoint> points;
  final String Function(double) labelForValue;
  final String Function(int) labelForMonth;
  final Color positive;
  final Color negative;
  final Color grid;
  final Color labelColour;
  final TextStyle labelStyle;
  final Color baseline;

  @override
  void paint(Canvas canvas, Size size) {
    final geometry = _ChartGeometry(points, size, 52);
    if (geometry.plot.width <= 0 || geometry.plot.height <= 0) return;

    _paintAxes(canvas, geometry, labelForValue, grid, labelColour, labelStyle);

    double xFor(int index) => points.length == 1
        ? geometry.plot.center.dx
        : geometry.plot.left +
              geometry.plot.width * (index / (points.length - 1));

    _paintMonthLabels(
      canvas,
      geometry,
      xFor,
      labelColour,
      labelStyle,
      labelForMonth,
    );

    // The break-even line, drawn stronger than the grid.
    canvas.drawLine(
      Offset(geometry.plot.left, geometry.zeroY),
      Offset(geometry.plot.right, geometry.zeroY),
      Paint()
        ..color = baseline
        ..strokeWidth = 1.2,
    );

    final linePath = Path();
    for (var index = 0; index < points.length; index++) {
      final offset = Offset(xFor(index), geometry.yFor(points[index].value));
      if (index == 0) {
        linePath.moveTo(offset.dx, offset.dy);
      } else {
        linePath.lineTo(offset.dx, offset.dy);
      }
    }

    // Fill under the curve, clipped above and below zero so the two halves can
    // be coloured differently.
    final fillPath = Path.from(linePath)
      ..lineTo(xFor(points.length - 1), geometry.zeroY)
      ..lineTo(xFor(0), geometry.zeroY)
      ..close();

    canvas.save();
    canvas.clipRect(
      Rect.fromLTRB(
        geometry.plot.left,
        geometry.plot.top,
        geometry.plot.right,
        geometry.zeroY,
      ),
    );
    canvas.drawPath(
      fillPath,
      Paint()..color = positive.withValues(alpha: 0.14),
    );
    canvas.restore();

    canvas.save();
    canvas.clipRect(
      Rect.fromLTRB(
        geometry.plot.left,
        geometry.zeroY,
        geometry.plot.right,
        geometry.plot.bottom,
      ),
    );
    canvas.drawPath(
      fillPath,
      Paint()..color = negative.withValues(alpha: 0.14),
    );
    canvas.restore();

    canvas.drawPath(
      linePath,
      Paint()
        ..color = positive
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(_LinePainter oldDelegate) =>
      oldDelegate.points != points ||
      oldDelegate.positive != positive ||
      oldDelegate.grid != grid;
}

/// A column chart, one column per month.
class MonthlyBarChart extends StatelessWidget {
  const MonthlyBarChart({
    required this.points,
    required this.labelForValue,
    required this.labelForMonth,
    required this.semanticsLabel,
    this.height = 220,
    super.key,
  });

  final List<ChartPoint> points;
  final String Function(double) labelForValue;
  final String Function(int) labelForMonth;
  final String semanticsLabel;
  final double height;

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) return SizedBox(height: height);
    final theme = Theme.of(context);
    final colors = context.financialColors;

    return Semantics(
      label: semanticsLabel,
      child: SizedBox(
        height: height,
        child: CustomPaint(
          size: Size.infinite,
          painter: _BarPainter(
            points: points,
            labelForValue: labelForValue,
            labelForMonth: labelForMonth,
            barColour: theme.colorScheme.primary,
            negativeColour: colors.negative,
            grid: colors.chartGrid,
            labelColour: colors.mutedText,
            labelStyle: theme.textTheme.labelSmall ?? const TextStyle(),
          ),
        ),
      ),
    );
  }
}

class _BarPainter extends CustomPainter {
  _BarPainter({
    required this.points,
    required this.labelForValue,
    required this.labelForMonth,
    required this.barColour,
    required this.negativeColour,
    required this.grid,
    required this.labelColour,
    required this.labelStyle,
  });

  final List<ChartPoint> points;
  final String Function(double) labelForValue;
  final String Function(int) labelForMonth;
  final Color barColour;
  final Color negativeColour;
  final Color grid;
  final Color labelColour;
  final TextStyle labelStyle;

  @override
  void paint(Canvas canvas, Size size) {
    final geometry = _ChartGeometry(points, size, 52);
    if (geometry.plot.width <= 0 || geometry.plot.height <= 0) return;

    _paintAxes(canvas, geometry, labelForValue, grid, labelColour, labelStyle);

    final slot = geometry.plot.width / points.length;
    final barWidth = math.max(2.0, math.min(24.0, slot * 0.62));
    double centreOf(int index) => geometry.plot.left + slot * (index + 0.5);

    _paintMonthLabels(
      canvas,
      geometry,
      centreOf,
      labelColour,
      labelStyle,
      labelForMonth,
    );

    for (var index = 0; index < points.length; index++) {
      final value = points[index].value;
      final top = math.min(geometry.yFor(value), geometry.zeroY);
      final bottom = math.max(geometry.yFor(value), geometry.zeroY);
      final centre = centreOf(index);

      canvas.drawRRect(
        RRect.fromRectAndCorners(
          Rect.fromLTRB(
            centre - barWidth / 2,
            top,
            centre + barWidth / 2,
            math.max(bottom, top + 1),
          ),
          topLeft: const Radius.circular(3),
          topRight: const Radius.circular(3),
        ),
        Paint()..color = value < 0 ? negativeColour : barColour,
      );
    }
  }

  @override
  bool shouldRepaint(_BarPainter oldDelegate) =>
      oldDelegate.points != points ||
      oldDelegate.barColour != barColour ||
      oldDelegate.grid != grid;
}
