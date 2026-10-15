import 'package:plate_core/plate_core.dart';

/// The alphabets behind Italian slots.
///
/// The article gives the serial letters as the Latin alphabet except I, O, Q
/// and U (a base-22 digit), so [letters] has 22 characters.
abstract final class ItalyAlphabets {
  static const PlateAlphabet digits = PlateAlphabet.latinDigits;

  static const PlateAlphabet letters = PlateAlphabet(
    id: 'it.letters',
    characters: <String>[
      'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'J', 'K', 'L', //
      'M', 'N', 'P', 'R', 'S', 'T', 'V', 'W', 'X', 'Y', 'Z',
    ],
    input: AlphabetInput.typed,
    isNumeric: false,
  );
}
