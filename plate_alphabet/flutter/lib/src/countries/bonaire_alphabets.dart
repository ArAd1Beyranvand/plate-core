import 'package:plate_core/plate_core.dart';

import '../plate_alphabet.dart';

/// Caribbean Netherlands plates carry Latin capitals and Western digits. The
/// article names no excluded letter; the prefix is the island (`B`, `E`, `S`)
/// or the vehicle type (`AB`, `BF`, `D`, `H`, `MF`, `TX`, `V`, `Z`).
abstract final class BonaireAlphabets {
  static const PlateAlphabet letters = PlateAlphabet.latinUppercase;
  static const PlateAlphabet digits = PlateAlphabetDigits.english;
}
