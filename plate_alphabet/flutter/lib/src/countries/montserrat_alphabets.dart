import 'package:plate_core/plate_core.dart';

/// The alphabets behind Montserratian slots.
///
/// The article gives a type letter ('M' private, 'R' rental, ...) and up to
/// four digits, and names no excluded letter, so [letters] is the full Latin
/// capital set.
abstract final class MontserratAlphabets {
  static const PlateAlphabet letters = PlateAlphabet.latinUppercase;
  static const PlateAlphabet digits = PlateAlphabet.latinDigits;
}
