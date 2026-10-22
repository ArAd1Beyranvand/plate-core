import 'package:plate_core/plate_core.dart';

import '../plate_alphabet.dart';

/// Luxembourg plates use Western digits and the plain Latin capitals.
abstract final class LuxembourgAlphabets {
  static const PlateAlphabet digits = PlateAlphabetDigits.english;

  static const PlateAlphabet letters = PlateAlphabet.pattern(
    id: 'lu.letters',
    include: 'A-Z',
    input: AlphabetInput.typed,
    isNumeric: false,
  );
}
