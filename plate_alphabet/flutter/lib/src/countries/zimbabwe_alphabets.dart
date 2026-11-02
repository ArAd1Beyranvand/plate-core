import 'package:plate_core/plate_core.dart';

/// The alphabets behind Zimbabwean slots.
///
/// The article gives the 2006 format as three letters and four digits and
/// names no excluded letter, so [letters] is the full Latin capital set.
abstract final class ZimbabweAlphabets {
  static const PlateAlphabet letters = PlateAlphabet.latinUppercase;
  static const PlateAlphabet digits = PlateAlphabet.latinDigits;
}
