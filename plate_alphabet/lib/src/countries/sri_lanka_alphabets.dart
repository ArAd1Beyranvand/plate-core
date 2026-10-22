import 'package:plate_core/plate_core.dart';

/// The alphabets behind Sri Lankan slots: Latin letters and digits.
abstract final class SriLankaAlphabets {
  static const PlateAlphabet digits = PlateAlphabet.latinDigits;

  static const PlateAlphabet letters = PlateAlphabet.pattern(
    id: 'lk.letters',
    include: 'A-Z',
    input: AlphabetInput.typed,
    isNumeric: false,
  );
}
