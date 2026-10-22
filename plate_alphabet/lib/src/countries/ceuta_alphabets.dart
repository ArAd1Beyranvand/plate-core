import 'package:plate_core/plate_core.dart';

/// The alphabets behind Ceuta's slots; the plates are Spain's national series.
///
/// The article lists the consonants B C D F G H J K L M N P R S T V W X Y Z
/// for the three-letter counter, and the diplomatic prefixes CD, CC, TA and
/// OI, so [diplomaticLetters] is only the letters those four use.
abstract final class CeutaAlphabets {
  /// The prefixes on diplomatic plates: red `CD`, green `CC`, yellow `TA`,
  /// blue `OI`.
  static const List<String> diplomaticCodes = <String>['CD', 'CC', 'TA', 'OI'];

  static const PlateAlphabet digits = PlateAlphabet.latinDigits;

  static const PlateAlphabet letters = PlateAlphabet.pattern(
    id: 'ce.letters',
    include: 'B-Z',
    exclude: 'E I O Q U',
    input: AlphabetInput.typed,
    isNumeric: false,
  );

  static const PlateAlphabet diplomaticLetters = PlateAlphabet.pattern(
    id: 'ce.diplomatic.letters',
    include: 'A C D I O T',
    input: AlphabetInput.typed,
    isNumeric: false,
  );

  /// The one-to-three letter code of a state or police plate (`CME`, `ET`).
  static const PlateAlphabet stateLetters = PlateAlphabet.latinUppercase;
}
