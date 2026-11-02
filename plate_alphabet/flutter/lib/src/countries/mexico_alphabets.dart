import 'package:plate_core/plate_core.dart';

import '../plate_alphabet.dart';

/// Mexican plates carry Western digits and Latin capitals.
abstract final class MexicoAlphabets {
  static const PlateAlphabet digits = PlateAlphabetDigits.english;
  static const PlateAlphabet letters = PlateAlphabet.latinUppercase;
}
