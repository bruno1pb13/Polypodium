import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Content width from which detail screens split into two panes.
const double kTwoPaneBreakpoint = 1000.0;

/// Horizontal padding that keeps content at most [maxWidth] wide, centered,
/// with at least [gutter] on each side.
double centeredGutter(double availableWidth, double maxWidth,
        {double gutter = 16}) =>
    math.max(0.0, (availableWidth - maxWidth) / 2) + gutter;

/// A list that becomes a grid of columns when there is room for more than
/// one item side by side.
///
/// Items keep their own padding, so the same item widget works in both
/// layouts. Items in a row share the height of the tallest one.
class AdaptiveListView extends StatelessWidget {
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final EdgeInsetsGeometry? padding;
  final ScrollPhysics? physics;

  /// Narrowest an item may get before the grid drops a column.
  final double minItemWidth;
  final int maxColumns;

  const AdaptiveListView.builder({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.padding,
    this.physics,
    this.minItemWidth = 360,
    this.maxColumns = 4,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final columns =
          (constraints.maxWidth / minItemWidth).floor().clamp(1, maxColumns);
      if (columns == 1) {
        return ListView.builder(
          physics: physics,
          padding: padding,
          itemCount: itemCount,
          itemBuilder: itemBuilder,
        );
      }
      return ListView.builder(
        physics: physics,
        padding: padding,
        itemCount: (itemCount / columns).ceil(),
        itemBuilder: (context, row) => IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var c = 0; c < columns; c++)
                Expanded(
                  child: row * columns + c < itemCount
                      ? itemBuilder(context, row * columns + c)
                      : const SizedBox.shrink(),
                ),
            ],
          ),
        ),
      );
    });
  }
}

/// A [ListView] whose content stays at a readable width, centered, while the
/// whole area still scrolls.
class ReadableListView extends StatelessWidget {
  final List<Widget> children;
  final EdgeInsets padding;
  final double maxWidth;

  const ReadableListView({
    super.key,
    required this.children,
    this.padding = EdgeInsets.zero,
    this.maxWidth = 760,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final gutter =
            centeredGutter(constraints.maxWidth, maxWidth, gutter: 0);
        return ListView(
          padding: padding + EdgeInsets.symmetric(horizontal: gutter),
          children: children,
        );
      },
    );
  }
}
