import 'package:plate_core/plate_core.dart';

/// The alphabets behind Order of Malta plates: the `SMOM` prefix is Latin
/// capitals, the number ASCII digits.
abstract final class SovereignMilitaryOrderOfMaltaAlphabets {
  static const PlateAlphabet digits = PlateAlphabet.latinDigits;

  static const PlateAlphabet letters = PlateAlphabet.latinUppercase;
}
