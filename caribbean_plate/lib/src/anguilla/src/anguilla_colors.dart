import 'package:flutter/widgets.dart';

/// The colours of the 2007 Anguillan plate, sampled from the pixels of
/// `License_Plate_2007_Anguilla.svg` (modal colour of a region).
abstract final class AnguillaColors {
  /// The gradient's blue, flat across the top and bottom ~11% of the height.
  static const Color sky = Color(0xFF69BAEE);

  /// The gradient's white middle, from 39% to 62% of the height.
  static const Color white = Color(0xFFFFFFFF);

  /// Type letter and digits.
  static const Color black = Color(0xFF000000);

  /// "Anguilla" and "Rainbow City".
  static const Color caption = Color(0xFF000088);

  static const Color inactive = Color(0xFFB0B0B0);
}
