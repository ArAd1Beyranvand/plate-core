import 'package:plate_core/plate_core.dart';

/// The alphabets behind Norwegian slots.
///
/// The article's table of registration series uses A B C D E F H J K L N P R
/// S T U V W X Y Z; G, I, M, O and Q appear in none of them, and the national
/// letters Æ, Ø, Å are not issued. Diplomatic plates carry the fixed prefix `CD`.
abstract final class NorwayAlphabets {
  static const PlateAlphabet digits = PlateAlphabet.latinDigits;

  static const PlateAlphabet letters = PlateAlphabet(
    id: 'no.letters',
    characters: <String>[
      'A', 'B', 'C', 'D', 'E', 'F', 'H', 'J', 'K', 'L', 'N', //
      'P', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z',
    ],
    input: AlphabetInput.typed,
    isNumeric: false,
  );

  static const PlateAlphabet diplomaticLetters = PlateAlphabet(
    id: 'no.diplomatic.letters',
    characters: <String>['C', 'D'],
    input: AlphabetInput.typed,
    isNumeric: false,
  );
}
