import 'package:plate_core/plate_core.dart';

/// The alphabets behind Chilean slots.
///
/// The article gives the 2007 format's 18 letters: B C D F G H J K L P R S T V
/// W X Y Z (no vowels, M, N, Ñ or Q). The trailer, police and provisional
/// plates draw on the whole Latin alphabet, and the diplomatic prefixes CD, CC,
/// AT, CH, OI and PAT use only [diplomaticLetters].
abstract final class ChileAlphabets {
  static const PlateAlphabet digits = PlateAlphabet.latinDigits;

  static const PlateAlphabet letters = PlateAlphabet(
    id: 'cl.letters',
    characters: <String>[
      'B', 'C', 'D', 'F', 'G', 'H', 'J', 'K', 'L', //
      'P', 'R', 'S', 'T', 'V', 'W', 'X', 'Y', 'Z',
    ],
    input: AlphabetInput.typed,
    isNumeric: false,
  );

  static const PlateAlphabet anyLetters = PlateAlphabet.latinUppercase;

  static const PlateAlphabet diplomaticLetters = PlateAlphabet(
    id: 'cl.diplomatic.letters',
    characters: <String>['A', 'C', 'D', 'H', 'I', 'O', 'P', 'T'],
    input: AlphabetInput.typed,
    isNumeric: false,
  );
}
