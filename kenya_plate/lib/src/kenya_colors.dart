import 'package:flutter/widgets.dart';

/// Sampled from a perspective-flattened photograph and white-balanced against
/// a cloth in frame, so within photographic error of the paint. [green] is
/// unbalanced; [red] is not sampled (the article only says "red").
abstract final class KenyaColors {
  /// Rear plate field, median of the flattened square plate: raw `946317`,
  /// balanced `FFA826` (red clipped).
  static const Color yellow = Color(0xFFFFA826);

  /// Front plate field. The photographed white reads grey from shade; this is
  /// the balanced value.
  static const Color white = Color(0xFFFFFFFF);

  /// Private ink, median of the stroke pixels: `242830` / `1C1C20`.
  static const Color black = Color(0xFF1E2024);

  /// County-government ink, balanced: raw `394C73`.
  static const Color blue = Color(0xFF6681BF);

  /// Electric vehicles, `ev.png`: `039F6F`.
  static const Color green = Color(0xFF039F6F);

  /// Unsampled: the article's red diplomatic plate.
  static const Color red = Color(0xFFBB0000);

  /// Flag stripes, from the official flag: black, red, green.
  static const Color flagBlack = Color(0xFF000000);
  static const Color flagRed = Color(0xFFBB0000);
  static const Color flagGreen = Color(0xFF006600);
  static const Color flagWhite = Color(0xFFFFFFFF);

  static const Color inactive = Color(0xFFB0B0B0);
}
