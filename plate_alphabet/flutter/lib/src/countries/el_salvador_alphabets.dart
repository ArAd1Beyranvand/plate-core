import 'package:plate_core/plate_core.dart';

/// The alphabets behind Salvadoran slots.
///
/// The 1976 plates print one letter (the class: `P`, `M`) and digits. The
/// article names no excluded letter, so [letters] is the full Latin capital set.
abstract final class ElSalvadorAlphabets {
  static const PlateAlphabet letters = PlateAlphabet.latinUppercase;
  static const PlateAlphabet digits = PlateAlphabet.latinDigits;
}
