import 'package:flutter/widgets.dart';

/// Colours sampled from the reference photos (PTA, diplomatic) and artwork
/// (Mercosur). Entries without a picture are marked as placeholders.
abstract final class BoliviaColors {
  /// PTA field and ink.
  static const Color white = Color(0xFFF4F4F0);
  static const Color blue = Color(0xFF2F4DC5);

  /// Diplomatic (`CD`) field and ink. The photo's red is sun-faded; this is
  /// what its pixels say, not the paint when new.
  static const Color diplomaticWhite = Color(0xFFFCF8F6);
  static const Color diplomaticRed = Color(0xFFF26771);

  static const Color mercosurBlue = Color(0xFF004088);
  static const Color mercosurBlack = Color(0xFF111111);
  static const Color mercosurWhite = Color(0xFFFCFCFC);

  /// The flag's stripes; the photos show the same hues over-exposed.
  static const Color flagRed = Color(0xFFD52B1E);
  static const Color flagYellow = Color(0xFFF9E300);
  static const Color flagGreen = Color(0xFF007934);

  /// Not photographed; the article gives only the ink/field names. The yellow
  /// and green are kept clear of the flag's so its stripes stay visible.
  static const Color consularBlue = blue;
  static const Color missionYellow = Color(0xFFFFC72C);
  static const Color organizationGreen = Color(0xFF0B9A55);
  static const Color black = Color(0xFF1B1B1D);

  static const Color inactiveOnDark = Color(0xFF8A8A8A);
  static const Color inactiveOnLight = Color(0xFFB0B0B0);
}
