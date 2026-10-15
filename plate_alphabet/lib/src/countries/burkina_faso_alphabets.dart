import 'package:plate_core/plate_core.dart';

/// The alphabets behind Burkinabè slots.
///
/// The article names no excluded letter, so [letters] is the full Latin
/// capital set. The plates use Latin digits.
abstract final class BurkinaFasoAlphabets {
  static const PlateAlphabet letters = PlateAlphabet.latinUppercase;
  static const PlateAlphabet digits = PlateAlphabet.latinDigits;
}
