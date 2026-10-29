import 'package:flutter/widgets.dart';

/// A rectangle in plate coordinates: origin at the plate's top-left, units
/// shared with [PlateSpec.canvasWidth] and [PlateSpec.canvasHeight].
@immutable
class PlateBox {
  const PlateBox(this.left, this.top, this.width, this.height);
  final double left, top, width, height;
  double get right => left + width;
  double get bottom => top + height;
  // TODO(ts): [H10] model Rect is a plain {left, top, right, bottom} type defined once.
  // TODO(kt): [H10] own Rect in commonMain; convert to Compose Rect in ui only.
  // TODO(py): [H10] own NamedTuple Rect; QRectF only in the ui layer.
  Rect get rect => Rect.fromLTWH(left, top, width, height);
}
