import 'package:flutter/widgets.dart';

/// The colours of the current Virgin Islands plates, sampled as the modal
/// pixel of each flattened photo (colour-balanced offline), not from the
/// article's prose ("white on red", "black on white").
abstract final class BritishVirginIslandsColors {
  /// Private vehicles, field. Photo: `F1E402`.
  static const Color yellow = Color(0xFFF1E402);

  /// Private vehicles, ink. Photo: `2B2A2B`.
  static const Color yellowInk = Color(0xFF2B2A2B);

  /// Government, field. Photo: `DB2B1E`.
  static const Color red = Color(0xFFDB2B1E);

  /// Government, ink. Photo: `FFFBFB`.
  static const Color redInk = Color(0xFFFFFBFB);

  /// Commercial, field: a pale blue, not white. Photo: `E4F6FC`.
  static const Color paleBlue = Color(0xFFE4F6FC);

  /// Commercial, ink. Photo: `19191D`.
  static const Color paleBlueInk = Color(0xFF19191D);

  /// Taxi, field: a grey-white. Photo: `E6E6E4`.
  static const Color grey = Color(0xFFE6E6E4);

  /// Taxi, ink. Photo: `0F0C0A`.
  static const Color greyInk = Color(0xFF0F0C0A);

  static const Color inactive = Color(0xFFB0B0B0);
}
