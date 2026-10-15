import 'package:plate_core/plate_core.dart';

import '../plate_alphabet.dart';

/// Jordan prints Latin digits and Latin capitals; the Arabic on a plate is
/// fixed wording, never a slot.
abstract final class JordanAlphabets {
  /// The code and serial digits.
  static const PlateAlphabet digits = PlateAlphabetDigits.english;

  /// The two-letter code of a government, diplomatic or Aqaba plate
  /// (`PM`, `PR`, `JC`, `GV`, `AQ`, `CD`).
  static const PlateAlphabet letters = PlateAlphabet.latinUppercase;
}
