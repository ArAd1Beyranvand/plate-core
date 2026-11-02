import 'package:plate_core/plate_core.dart';

import '../plate_alphabet.dart';

/// Costa Rican plates carry Western digits and Latin capitals only.
abstract final class CostaRicaAlphabets {
  static const PlateAlphabet digits = PlateAlphabetDigits.english;
  static const PlateAlphabet letters = PlateAlphabet.latinUppercase;
}
