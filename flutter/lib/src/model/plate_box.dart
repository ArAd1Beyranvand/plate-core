import 'package:flutter/widgets.dart';

/// A rectangle in plate coordinates: origin at the plate's top-left, units
/// shared with [PlateSpec.canvasWidth] and [PlateSpec.canvasHeight].
@immutable
class PlateBox {
  const PlateBox(this.left, this.top, this.width, this.height);

  /// The box from its left, top, right and bottom edges.
  const PlateBox.fromLTRB(this.left, this.top, double right, double bottom)
    : width = right - left,
      height = bottom - top;

  /// The [width] × [height] box centred on ([cx], [cy]).
  const PlateBox.centered(double cx, double cy, this.width, this.height)
    : left = cx - width / 2,
      top = cy - height / 2;
  final double left, top, width, height;
  double get right => left + width;
  double get bottom => top + height;
  Rect get rect => Rect.fromLTWH(left, top, width, height);
}
