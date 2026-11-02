import 'package:plate_core/plate_core.dart';

/// The alphabets behind Gambian slots.
///
/// The article names no excluded letter, so [letters] is the full Latin
/// capital set. The plates use Latin digits.
abstract final class GambiaAlphabets {
  static const PlateAlphabet letters = PlateAlphabet.latinUppercase;
  static const PlateAlphabet digits = PlateAlphabet.latinDigits;
}
