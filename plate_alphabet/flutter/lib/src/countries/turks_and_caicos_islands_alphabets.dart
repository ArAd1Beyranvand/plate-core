import 'package:plate_core/plate_core.dart';

/// The alphabets behind Turks and Caicos Islands slots.
///
/// The article names no excluded letter, so [letters] is the full Latin
/// capital set (it only ever holds the `TC` prefix).
abstract final class TurksAndCaicosIslandsAlphabets {
  static const PlateAlphabet letters = PlateAlphabet.latinUppercase;
  static const PlateAlphabet digits = PlateAlphabet.latinDigits;
}
