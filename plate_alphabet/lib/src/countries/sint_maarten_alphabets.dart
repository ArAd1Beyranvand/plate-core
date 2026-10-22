import 'package:plate_core/plate_core.dart';

import '../plate_alphabet.dart';

/// Sint Maarten plates carry Latin capitals and Western digits. The prefix is
/// the vehicle type (`V`, `TX`, `D`, `AB`) or a plain letter (`P`, `M`).
abstract final class SintMaartenAlphabets {
  static const PlateAlphabet letters = PlateAlphabet.latinUppercase;
  static const PlateAlphabet digits = PlateAlphabetDigits.english;
}
