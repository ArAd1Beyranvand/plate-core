import 'package:plate_core/plate_core.dart';

/// The alphabets behind Spanish slots.
///
/// The article lists the consonants B C D F G H J K L M N P R S T V W X Y Z
/// for the three-letter counter, and the diplomatic prefixes CD, CC, TA and
/// OI, so [diplomaticLetters] is only the letters those four use.
abstract final class SpainAlphabets {
  static const PlateAlphabet digits = PlateAlphabet.latinDigits;

  static const PlateAlphabet letters = PlateAlphabet(
    id: 'es.letters',
    characters: <String>[
      'B', 'C', 'D', 'F', 'G', 'H', 'J', 'K', 'L', 'M', //
      'N', 'P', 'R', 'S', 'T', 'V', 'W', 'X', 'Y', 'Z',
    ],
    input: AlphabetInput.typed,
    isNumeric: false,
  );

  static const PlateAlphabet diplomaticLetters = PlateAlphabet(
    id: 'es.diplomatic.letters',
    characters: <String>['A', 'C', 'D', 'I', 'O', 'T'],
    input: AlphabetInput.typed,
    isNumeric: false,
  );

  /// The prefixes on diplomatic plates: red `CD`, green `CC`, yellow `TA`,
  /// blue `OI`.
  static const List<String> diplomaticCodes = <String>['CD', 'CC', 'TA', 'OI'];
}
