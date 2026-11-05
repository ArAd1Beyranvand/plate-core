import 'package:plate_core/plate_core.dart';

import '../plate_alphabet.dart';

/// The alphabets behind Brunei slots.
///
/// [letters] is all of A–Z. The article says I and O are never issued, but a
/// military plate is `MOD 1925`, so a keypad that refused O could not type
/// one: the rule lives in `BruneiValidator`, which reports rather than bars.
abstract final class BruneiAlphabets {
  static const PlateAlphabet digits = PlateAlphabetDigits.english;

  static const PlateAlphabet letters = PlateAlphabet.pattern(
    id: 'bn.letters',
    include: 'A-Z',
  );
}
