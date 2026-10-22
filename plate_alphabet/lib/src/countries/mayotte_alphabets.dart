import 'package:plate_core/plate_core.dart';

import 'france_alphabets.dart';

/// The alphabets behind Mayotte's slots, which uses French stamping dies and
/// the SIV format: the serial letters are France's (Latin without I, O, U) and
/// the département code is the digits `976`.
abstract final class MayotteAlphabets {
  static const PlateAlphabet digits = PlateAlphabet.latinDigits;
  static const PlateAlphabet letters = FranceAlphabets.letters;
}
