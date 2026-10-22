import 'package:plate_core/plate_core.dart';

import '../plate_alphabet.dart';

/// Belgian plates use Western digits and the plain Latin capitals; the
/// motorcycle plate's first character is the photographed `M` or a digit, so
/// it takes both.
abstract final class BelgiumAlphabets {
  static const PlateAlphabet digits = PlateAlphabetDigits.english;

  static const PlateAlphabet letters = PlateAlphabet.pattern(
    id: 'be.letters',
    include: 'A-Z',
    input: AlphabetInput.typed,
    isNumeric: false,
  );

  static const PlateAlphabet alphanumeric = PlateAlphabet.pattern(
    id: 'be.alphanumeric',
    include: 'A-Z 0-9',
    input: AlphabetInput.typed,
    isNumeric: false,
  );
}
