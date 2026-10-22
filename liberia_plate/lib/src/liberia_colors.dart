import 'package:flutter/widgets.dart';

/// The colours of the diplomatic plate, sampled by the offline stage from the
/// flattened February 2017 photograph (field `E4E8E9`, ink `191719`).
///
/// The flag's red and blue are NOT sampled: they are the official values of
/// the national flag, since a 70-unit photo of stripes is too small to trust.
abstract final class LiberiaColors {
  static const Color field = Color(0xFFE4E8E9);
  static const Color ink = Color(0xFF191719);

  /// Flag red (official).
  static const Color flagRed = Color(0xFFBF0A30); // CALIBRATE

  /// Flag blue (official).
  static const Color flagBlue = Color(0xFF002868); // CALIBRATE

  static const Color flagWhite = Color(0xFFFFFFFF);
  static const Color inactive = Color(0xFFB0B0B0);
}
