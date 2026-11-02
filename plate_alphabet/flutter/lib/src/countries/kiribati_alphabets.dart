import 'package:plate_core/plate_core.dart';

/// The alphabets behind Kiribati slots.
///
/// The article gives `ABC 123` and names no excluded letter, so [letters] is
/// the full Latin capital set.
abstract final class KiribatiAlphabets {
  static const PlateAlphabet letters = PlateAlphabet.latinUppercase;
  static const PlateAlphabet digits = PlateAlphabet.latinDigits;
}
