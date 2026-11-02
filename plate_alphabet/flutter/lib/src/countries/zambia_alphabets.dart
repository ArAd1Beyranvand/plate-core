import 'package:plate_core/plate_core.dart';

/// The alphabets behind Zambian slots.
///
/// The article gives no excluded letter, so [letters] is the full Latin
/// capital set.
abstract final class ZambiaAlphabets {
  static const PlateAlphabet letters = PlateAlphabet.latinUppercase;
  static const PlateAlphabet digits = PlateAlphabet.latinDigits;
}
