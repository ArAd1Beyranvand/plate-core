import 'package:flutter/widgets.dart';

/// The colours of the Montserrat plate.
///
/// Both are sampled from `Montserrat___Car_licence_plate_2000s_M_1667`,
/// flattened and colour-balanced: the field is the modal colour of the
/// background, the ink the modal colour of the glyph interiors. The article
/// says only that the letters are white and the background "can vary"; no
/// other background was photographed, so there is one theme.
abstract final class MontserratColors {
  static const Color black = Color(0xFF282624);
  static const Color white = Color(0xFFF0F3F1);
  static const Color inactive = Color(0xFF8A8A88);
}
