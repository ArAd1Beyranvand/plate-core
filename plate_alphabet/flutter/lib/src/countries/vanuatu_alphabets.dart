import 'package:plate_core/plate_core.dart';

import '../plate_alphabet.dart';

/// The alphabets behind Vanuatu slots. Plates use Latin letters and Western
/// digits; the diplomatic series' letters are a fixed set of mission codes
/// that the article does not list, so [letters] is all of A–Z and the
/// validator reports rather than bars.
abstract final class VanuatuAlphabets {
  static const PlateAlphabet digits = PlateAlphabetDigits.english;

  static const PlateAlphabet letters = PlateAlphabet.pattern(
    id: 'vu.letters',
    include: 'A-Z',
  );
}
