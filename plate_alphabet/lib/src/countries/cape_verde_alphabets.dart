import 'package:plate_core/plate_core.dart';

/// The alphabets behind Cape Verdean slots.
///
/// The article excludes no letter, so [letters] is the full Latin capital set;
/// which letter pairs are issued as island codes is the validator's concern.
/// The plates use Latin digits.
abstract final class CapeVerdeAlphabets {
  static const PlateAlphabet letters = PlateAlphabet.latinUppercase;
  static const PlateAlphabet digits = PlateAlphabet.latinDigits;
}
