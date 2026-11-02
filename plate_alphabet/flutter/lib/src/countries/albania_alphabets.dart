import 'package:plate_core/plate_core.dart';

/// The alphabets behind Albanian slots.
///
/// Plates are Latin capitals and ASCII digits. The article gives no excluded
/// letters, so every capital is accepted; the class and branch codes
/// (`MB`, `PU`, `CD`...) are fixed words the validators check.
abstract final class AlbaniaAlphabets {
  static const PlateAlphabet digits = PlateAlphabet.latinDigits;

  static const PlateAlphabet letters = PlateAlphabet.latinUppercase;
}
