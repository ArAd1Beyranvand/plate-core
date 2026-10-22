import 'package:plate_core/plate_core.dart';

/// The alphabets behind Sahrawi slots: Latin capitals (the `SH` and `GSH`
/// prefixes) and ASCII digits.
abstract final class SahrawiArabDemocraticRepublicAlphabets {
  static const PlateAlphabet digits = PlateAlphabet.latinDigits;

  static const PlateAlphabet letters = PlateAlphabet.latinUppercase;
}
