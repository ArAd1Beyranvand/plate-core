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
}) => plateRun(
  alphabet,
  count,
  left: left - (pitch - cellWidth) / 2,
  top: top,
  pitch: pitch,
  height: height,
);
