import 'package:flutter/widgets.dart';

/// The colours of the Senegalese plates, sampled from the flattened reference
/// plates.
abstract final class SenegalColors {
  /// The 1989–2019 field and the country strip of the current plates: `003399`.
  static const Color blue = Color(0xFF003399);

  /// Ink of the 1989–2019 plates: `FEFEFE`.
  static const Color white = Color(0xFFFEFEFE);

  /// Field of the current plates: `FFFFFF`.
  static const Color plateWhite = Color(0xFFFFFFFF);

  /// Ink and frame of the current plates: `000000`.
  static const Color black = Color(0xFF000000);

  static const Color inactive = Color(0xFFB0B0B0);
}
