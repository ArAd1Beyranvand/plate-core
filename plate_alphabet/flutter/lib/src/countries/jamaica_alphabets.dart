import 'package:plate_core/plate_core.dart';

import '../plate_alphabet.dart';

/// The alphabets behind Jamaican slots: Western digits and the serial's
/// letters. All of A–Z is accepted; which letters are issued is the
/// validator's business.
abstract final class JamaicaAlphabets {
  static const PlateAlphabet digits = PlateAlphabetDigits.english;

  static const PlateAlphabet letters = PlateAlphabet.pattern(
    id: 'jm.letters',
    include: 'A-Z',
  );
}
