import 'package:plate_core/plate_core.dart';

/// The alphabets behind Cook Islands slots.
///
/// The article gives the car format as four digits (`1234`) and names no
/// excluded letter, so [letters] is the full Latin capital set. The zero is
/// stamped with a slash (`Ø`); that is the die, not a separate character.
abstract final class CookIslandsAlphabets {
  static const PlateAlphabet letters = PlateAlphabet.latinUppercase;
  static const PlateAlphabet digits = PlateAlphabet.latinDigits;
}
