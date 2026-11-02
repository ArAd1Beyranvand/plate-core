import 'package:plate_core/plate_core.dart';

/// The alphabets behind South African slots.
///
/// The article excludes no letter, so [letters] is the full Latin capital set;
/// which province suffixes are issued is the validator's concern. The plates
/// use Latin digits.
abstract final class SouthAfricaAlphabets {
  static const PlateAlphabet letters = PlateAlphabet.latinUppercase;
  static const PlateAlphabet digits = PlateAlphabet.latinDigits;
}
