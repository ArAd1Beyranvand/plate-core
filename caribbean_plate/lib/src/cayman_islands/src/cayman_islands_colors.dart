import 'package:flutter/widgets.dart';

/// Colours sampled from the pixels of the Wikipedia references (modal colour
/// of a region of the flattened photo).
abstract final class CaymanIslandsColors {
  /// Private-car field. The `graphic` artwork.
  static const Color yellow = Color(0xFFE5C618);

  /// Heavy goods vehicles. `orange` photo; the offline balance gave FFB074
  /// but the pixels read this.
  static const Color orange = Color(0xFFDF8757);

  /// Taxi and hire-car field, photographed in daylight.
  static const Color white = Color(0xFFF2F2F4);

  static const Color black = Color(0xFF000000);

  /// Heavy goods digits. Photo.
  static const Color orangeInk = Color(0xFF28262A);

  /// Hire-car digits. Photo of an embossed plate, near-black.
  static const Color hireInk = Color(0xFF1E2020);

  /// Taxi digits. Photo.
  static const Color red = Color(0xFFC52217);

  /// Taxi caption. Photo.
  static const Color blue = Color(0xFF1A3CAA);

  static const Color inactiveOnDark = Color(0xFF5A5A5A);
  static const Color inactiveOnLight = Color(0xFFB0B0B0);
}
