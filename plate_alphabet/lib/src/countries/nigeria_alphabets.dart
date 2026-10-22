import 'package:plate_core/plate_core.dart';

/// The alphabets behind Nigerian slots.
///
/// The article names no excluded letter, so [letters] is the full Latin
/// capital set.
abstract final class NigeriaAlphabets {
  static const PlateAlphabet letters = PlateAlphabet.latinUppercase;
  static const PlateAlphabet digits = PlateAlphabet.latinDigits;
}
