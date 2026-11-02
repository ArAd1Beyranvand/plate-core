import 'package:plate_core/plate_core.dart';

/// The alphabets behind Cypriot slots.
///
/// Plates print Latin capitals and ASCII digits. The article names no excluded
/// letter, so [letters] is the whole alphabet; a diplomatic plate's class
/// (`CD`, `CC`, `AT`) is a two-letter field the validator checks.
abstract final class CyprusAlphabets {
  static const PlateAlphabet digits = PlateAlphabet.latinDigits;
  static const PlateAlphabet letters = PlateAlphabet.latinUppercase;
}
