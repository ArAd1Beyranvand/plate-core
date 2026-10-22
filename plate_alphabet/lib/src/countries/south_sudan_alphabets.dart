import 'package:plate_core/plate_core.dart';

/// The alphabets behind South Sudanese slots.
///
/// The 2017 plates print Latin capitals and digits. The article names no
/// excluded letter, so [letters] is the full Latin capital set.
abstract final class SouthSudanAlphabets {
  static const PlateAlphabet letters = PlateAlphabet.latinUppercase;
  static const PlateAlphabet digits = PlateAlphabet.latinDigits;
}
