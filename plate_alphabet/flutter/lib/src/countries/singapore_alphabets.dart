import 'package:plate_core/plate_core.dart';

import '../plate_alphabet.dart';

/// The alphabets behind Singaporean slots.
///
/// [letters] is all of A–Z: the series never issue I and O (and skip some
/// vowels), and a checksum letter is never F, I, N, O, Q, V or W. Those rules
/// live in `SingaporeValidator`, which reports rather than bars.
abstract final class SingaporeAlphabets {
  static const PlateAlphabet digits = PlateAlphabetDigits.english;

  static const PlateAlphabet letters = PlateAlphabet.pattern(
    id: 'sg.letters',
    include: 'A-Z',
  );
}
