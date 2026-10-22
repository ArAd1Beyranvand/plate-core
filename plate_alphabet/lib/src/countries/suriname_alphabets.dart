import 'package:plate_core/plate_core.dart';

/// The alphabets behind Surinamese slots.
///
/// The article gives two letters and four digits, the first letter always `P`,
/// and names no excluded letter, so [letters] is the full Latin capital set.
/// The leading `P` is the validator's rule, not the alphabet's.
abstract final class SurinameAlphabets {
  static const PlateAlphabet letters = PlateAlphabet.latinUppercase;
  static const PlateAlphabet digits = PlateAlphabet.latinDigits;
}
