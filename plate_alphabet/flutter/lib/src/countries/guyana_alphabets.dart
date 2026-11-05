import 'package:plate_core/plate_core.dart';

import '../plate_alphabet.dart';

/// The alphabets behind Guyanese slots: Western digits and the series' letters.
/// All of A–Z is accepted; which letters are issued is the validator's business.
abstract final class GuyanaAlphabets {
  static const PlateAlphabet digits = PlateAlphabetDigits.english;

  static const PlateAlphabet letters = PlateAlphabet.pattern(
    id: 'gy.letters',
    include: 'A-Z',
  );
}
