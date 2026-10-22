import 'package:plate_core/plate_core.dart';

/// The alphabets behind Honduran slots.
///
/// The 2018 plates print three letters (a class code, then a two-letter
/// series) and four digits. The article names no excluded letter, so
/// [letters] is the full Latin capital set.
abstract final class HondurasAlphabets {
  static const PlateAlphabet letters = PlateAlphabet.latinUppercase;
  static const PlateAlphabet digits = PlateAlphabet.latinDigits;
}
