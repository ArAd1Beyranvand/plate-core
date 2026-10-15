import 'package:plate_core/plate_core.dart';

/// The alphabets behind Mauritian slots: the two letters of the government plate (`GM`). All 26 Latin capitals; the
/// article names no excluded letter.
abstract final class MauritiusAlphabets {
  static const PlateAlphabet digits = PlateAlphabet.latinDigits;

  static const PlateAlphabet letters = PlateAlphabet(
    id: 'mu.letters',
    characters: <String>[
      'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', //
      'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z',
    ],
    input: AlphabetInput.typed,
    isNumeric: false,
  );
}
