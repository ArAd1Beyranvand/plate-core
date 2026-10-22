import 'package:flutter/widgets.dart';

/// Colours of the 2005 graphic plate, from the flattened photo (white-balanced
/// by the offline stage) and the original where noted. The article's "black on
/// white" is the plain-plate description; the photo is a beach picture.
abstract final class SintMaartenColors {
  /// Field, the brief's modal colour of the flattened photo: `A1C3BC`.
  static const Color field = Color(0xFFA1C3BC);

  /// Digits and prefix, brief ink: `281C1B`.
  static const Color black = Color(0xFF281C1B);

  /// Caption and web address, modal yellow of the caption row of the original
  /// photo: `D1BF69`.
  static const Color caption = Color(0xFFD1BF69);

  static const Color inactive = Color(0xFFB0B0B0);
}
