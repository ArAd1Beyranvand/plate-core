import 'package:plate_core/plate_core.dart';

/// The alphabets behind Antigua and Barbuda slots: the class letter (`A`
/// private, `G` government, `H` taxi) and the Western digits of the number.
/// All 26 Latin capitals; the article names no excluded letter.
abstract final class AntiguaAndBarbudaAlphabets {
  static const PlateAlphabet digits = PlateAlphabet.latinDigits;

  static const PlateAlphabet letters = PlateAlphabet(
    id: 'ag.letters',
    characters: <String>[
      'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', //
      'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z',
    ],
    input: AlphabetInput.typed,
    isNumeric: false,
  );
}
