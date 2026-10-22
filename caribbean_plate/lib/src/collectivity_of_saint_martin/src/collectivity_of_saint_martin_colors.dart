import 'package:flutter/widgets.dart';

/// White, black and the band blue are the French plate's, from the vector
/// artwork (`License_plate_of_France_AA-229-DB`), as `mayotte_plate` does: the
/// only Saint Martin photo is colour-cast (band reads 0A62F7, face F2F7FD).
/// The logo colours are estimated from its 38 px sticker, not sampled.
abstract final class CollectivityOfSaintMartinColors {
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color euroBlue = Color(0xFF003399);
  static const Color inactive = Color(0xFFB0B0B0);
  static const Color logoBlue = Color(0xFF2090C8);
  static const Color logoGreen = Color(0xFF4C9A3C);
  static const Color logoGrey = Color(0xFF404048);
}
