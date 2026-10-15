import 'package:flutter/widgets.dart';

/// A rectangle in plate coordinates: origin at the plate's top-left, units
/// shared with [PlateSpec.canvasWidth] and [PlateSpec.canvasHeight].
@immutable
class PlateBox {
  const PlateBox(this.left, this.top, this.width, this.height);
  final double left, top, width, height;
  double get right => left + width;
  double get bottom => top + height;
  Rect get rect => Rect.fromLTWH(left, top, width, height);
}
