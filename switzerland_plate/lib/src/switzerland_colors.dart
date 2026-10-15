import 'package:flutter/widgets.dart';

/// The colours a Swiss plate is printed in, sampled as the modal colour of a
/// region of the colour-balanced flat photographs (`.plateref/ch`). They come
/// from photographs, not artwork, so they are the plates as photographed. The
/// Federal Roads Office publishes no colour values.
abstract final class SwitzerlandColors {
  /// The standard field.
  static const Color white = Color(0xFFEDEBE8);

  /// Ink and rim of every plate but the military and the diplomatic ones.
  static const Color black = Color(0xFF24211F);

  /// Utility vehicles (`Swiss_utilitary_reg_4229`): a sky blue.
  static const Color utility = Color(0xFF5EB2E2);

  /// Exceptional transport.
  static const Color exceptional = Color(0xFFCA922E);

  /// The agricultural front plate: a green, sampled off the 1999 front plate.
  static const Color agricultural = Color(0xFF22F6D2);

  /// Scooters.
  static const Color scooter = Color(0xFFF6D602);

  /// Red bicycle-carrier plates (`Rotes_Kontrollschild`). Estimated from the
  /// unrectified original.
  static const Color red = Color(0xFFD83030);

  /// Military field. Estimated from the unrectified original; the ink is white.
  static const Color military = Color(0xFF5A5A58);

  /// Diplomatic (`CD`) band, and `CC` consular band.
  static const Color diplomaticBlue = Color(0xFF2B67AE);
  static const Color consularGreen = Color(0xFF4B8760);

  /// Temporary plates' and customs plates' sticker.
  static const Color stickerRed = Color(0xFFF61E2A);
  static const Color customsRed = Color(0xFFD21626);

  static const Color inactive = Color(0x66666666);
}
