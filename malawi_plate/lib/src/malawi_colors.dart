import 'package:flutter/widgets.dart';

/// The colours of the Malawian plate, sampled from `License_plate_of_Malawi`
/// (one flattened, colour-balanced photo): the field and the embossed ink.
abstract final class MalawiColors {
  /// Field, `211A20`.
  static const Color black = Color(0xFF211A20);

  /// Embossed silver ink, `C3BEB0`.
  static const Color silver = Color(0xFFC3BEB0);

  static const Color inactive = Color(0xFF6B6468);
}
