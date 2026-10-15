import 'dart:math';

import 'package:plate_core/plate_core.dart';

/// One field of [count] characters printed at [pitch], cells [cellWidth] wide
/// starting at [left]; the box spans the whole run and `spacing` brings the
/// font's advance up to the pitch.
PlateSlot psRun({
  required PlateAlphabet alphabet,
  required int count,
  required double left,
  required double top,
  required double cellWidth,
  required double height,
  required double pitch,
}) => PlateSlot(
  alphabet: alphabet,
  box: PlateBox(left - (pitch - cellWidth) / 2, top, count * pitch, height),
  length: count,
  spacing: max(0, pitch - 0.6 * 0.72 * height),
);
