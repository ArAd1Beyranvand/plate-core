import 'package:plate_core/plate_core.dart';

import '../plate_alphabet.dart';

/// The alphabets behind Timor-Leste slots. Plates print Latin capitals and
/// Western digits; which letters a series uses is `TimorLesteValidator`'s
/// business, not the keypad's.
abstract final class TimorLesteAlphabets {
  static const PlateAlphabet digits = PlateAlphabetDigits.english;

  static const PlateAlphabet letters = PlateAlphabet.pattern(
    id: 'tl.letters',
    include: 'A-Z',
  );
}
