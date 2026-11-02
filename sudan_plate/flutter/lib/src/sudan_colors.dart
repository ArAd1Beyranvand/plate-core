import 'package:flutter/widgets.dart';

/// Modal pixels per region: private from artwork, transport and commercial
/// from photographs, so those carry lighting.
abstract final class SudanColors {
  static const Color privateWhite = Color(0xFFFCFCFC);
  static const Color privateBlack = Color(0xFF000000);

  static const Color transportTeal = Color(0xFF067470);
  static const Color transportWhite = Color(0xFFFCFCFC);

  static const Color commercialBlack = Color(0xFF000000);
  static const Color commercialWhite = Color(0xFFFCFCFC);

  /// Foil, so the same on every livery. Sampled off the artwork; photographs
  /// read darker under their lighting.
  static const Color hologram = Color(0xFF999999);

  static const Color inactiveOnLight = Color(0x66666666);
  static const Color inactiveOnDark = Color(0x66FFFFFF);
}
