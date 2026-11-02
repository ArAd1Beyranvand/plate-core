import 'package:plate_core/plate_core.dart';

/// The alphabets behind Central African slots.
///
/// The article names no excluded letter, so [letters] is the full Latin
/// capital set. The plates use Latin digits.
abstract final class CentralAfricanRepublicAlphabets {
  static const PlateAlphabet letters = PlateAlphabet.latinUppercase;
  static const PlateAlphabet digits = PlateAlphabet.latinDigits;
}
