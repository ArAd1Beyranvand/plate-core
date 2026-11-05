import 'package:plate_core/plate_core.dart';

import '../plate_alphabet.dart';

/// The alphabets behind Bahamian slots: Western digits, and the class letter
/// (`T`, truck) that precedes the serial on some series. All of A–Z is accepted;
/// which letters are issued is the validator's business.
abstract final class BahamasAlphabets {
  static const PlateAlphabet digits = PlateAlphabetDigits.english;

  static const PlateAlphabet letters = PlateAlphabet.pattern(
    id: 'bs.letters',
    include: 'A-Z',
  );
}
