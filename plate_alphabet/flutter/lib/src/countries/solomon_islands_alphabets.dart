import 'package:plate_core/plate_core.dart';

/// The alphabets behind Solomon Islands slots.
///
/// The series runs `MA-0000` to `MA-9999`, then `MB-0000`; no letter is
/// excluded, so [letters] is the full Latin capital set.
abstract final class SolomonIslandsAlphabets {
  static const PlateAlphabet letters = PlateAlphabet.latinUppercase;
  static const PlateAlphabet digits = PlateAlphabet.latinDigits;
}
