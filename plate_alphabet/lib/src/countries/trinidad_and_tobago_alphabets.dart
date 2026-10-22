import 'package:plate_core/plate_core.dart';

import '../plate_alphabet.dart';

/// The alphabets behind Trinidad and Tobago slots: Western digits and the
/// series letters. All of A–Z is accepted; the letters the Licensing Authority
/// withholds (I, O, Q, V at the end of a series) are the validator's business.
abstract final class TrinidadAndTobagoAlphabets {
  static const PlateAlphabet digits = PlateAlphabetDigits.english;

  static const PlateAlphabet letters = PlateAlphabet.pattern(
    id: 'tt.letters',
    include: 'A-Z',
    input: AlphabetInput.typed,
    isNumeric: false,
  );
}
