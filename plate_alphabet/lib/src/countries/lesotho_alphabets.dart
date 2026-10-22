import 'package:plate_core/plate_core.dart';

/// The alphabets behind Lesotho slots: the one or two letters of a plate (`A`, `LX`). All 26 Latin capitals; the
/// article names no excluded letter.
abstract final class LesothoAlphabets {
  static const PlateAlphabet digits = PlateAlphabet.latinDigits;

  static const PlateAlphabet letters = PlateAlphabet.pattern(
    id: 'ls.letters',
    include: 'A-Z',
    input: AlphabetInput.typed,
    isNumeric: false,
  );
}
