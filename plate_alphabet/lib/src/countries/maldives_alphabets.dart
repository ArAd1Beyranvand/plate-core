import 'package:plate_core/plate_core.dart';

import '../plate_alphabet.dart';

/// The alphabets behind Maldivian slots.
///
/// [letters] is all of A–Z: the article restricts nothing but the category
/// code, and that rule lives in `MaldivesPlateValidator`, which reports rather
/// than bars.
abstract final class MaldivesAlphabets {
  static const PlateAlphabet digits = PlateAlphabetDigits.english;

  /// The category's type letter before the serial.
  static const PlateAlphabet type = PlateAlphabet(
    id: 'mv.type',
    characters: <String>['P', 'C', 'G', 'S', 'T', 'D'],
    input: AlphabetInput.chosen,
    isNumeric: false,
  );

  static const PlateAlphabet letters = PlateAlphabet.pattern(
    id: 'mv.letters',
    include: 'A-Z',
    input: AlphabetInput.typed,
    isNumeric: false,
  );
}
