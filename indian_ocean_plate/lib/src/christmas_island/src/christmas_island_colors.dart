import 'package:flutter/widgets.dart';

/// Colours sampled from the flattened references (modal colour of a region).
///
/// The graphic (`Australia_Christmas_Island_license_plate_graphic.png`) is
/// clean artwork; the yellow plate is a photograph, so its values are
/// colour-balanced pixels and marked `// CALIBRATE`.
abstract final class ChristmasIslandColors {
  /// Graphic plate field. Artwork.
  static const Color white = Color(0xFFFAFAFA);

  /// Graphic plate digits and rim. Artwork.
  static const Color black = Color(0xFF000000);

  /// Issued plate field. `XI.plate.jpg`.
  static const Color yellow = Color(0xFFDDCB1B); // CALIBRATE

  /// Issued plate digits, captions and rim. Same photo, near-black navy.
  static const Color navy = Color(0xFF201F2F); // CALIBRATE

  /// Panel colour for the (unprinted) country block.
  static const Color panel = Color(0xFF1B5E20);

  static const Color inactiveOnLight = Color(0xFFB0B0B0);
  static const Color inactiveOnYellow = Color(0xFF8C8433);
}
