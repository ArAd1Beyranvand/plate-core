import 'package:plate_core/plate_core.dart';

/// The alphabets behind Slovak slots.
///
/// Serial letters are the 24 the article lists: the Latin capitals without Q
/// and W, and none of the Slovak diacritics.
abstract final class SlovakiaAlphabets {
  static const PlateAlphabet digits = PlateAlphabet.latinDigits;

  static const PlateAlphabet letters = PlateAlphabet(
    id: 'sk.letters',
    characters: <String>[
      'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', //
      'M', 'N', 'O', 'P', 'R', 'S', 'T', 'U', 'V', 'X', 'Y', 'Z',
    ],
    input: AlphabetInput.typed,
    isNumeric: false,
  );

  /// A personalised plate takes any capital letter or digit.
  static const PlateAlphabet personalised = PlateAlphabet(
    id: 'sk.personalised',
    characters: <String>[
      'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', //
      'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z',
      '0', '1', '2', '3', '4', '5', '6', '7', '8', '9',
    ],
    input: AlphabetInput.typed,
    isNumeric: false,
  );
}
