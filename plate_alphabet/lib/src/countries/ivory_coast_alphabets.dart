import 'package:plate_core/plate_core.dart';

/// The alphabets behind Ivory Coast slots.
///
/// The article excludes no letter, so [letters] is the full Latin capital set.
/// The plates use Latin digits.
abstract final class IvoryCoastAlphabets {
  static const PlateAlphabet letters = PlateAlphabet.latinUppercase;
  static const PlateAlphabet digits = PlateAlphabet.latinDigits;
}
