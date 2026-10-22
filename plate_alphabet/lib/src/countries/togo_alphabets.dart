import 'package:plate_core/plate_core.dart';

/// The alphabets behind Togolese slots.
///
/// The article excludes no letter, so [letters] is the full Latin capital set.
/// The plates use Latin digits.
abstract final class TogoAlphabets {
  static const PlateAlphabet letters = PlateAlphabet.latinUppercase;
  static const PlateAlphabet digits = PlateAlphabet.latinDigits;
}
