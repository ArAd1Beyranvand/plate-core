import 'package:plate_core/plate_core.dart';

import '../plate_alphabet.dart';

/// Saba's plates carry Latin capitals and Western digits. The prefix is the
/// island letter `S`; the article says the first letter can also be `R` or `D`
/// depending on the vehicle type.
abstract final class SabaIslandAlphabets {
  static const PlateAlphabet letters = PlateAlphabet.latinUppercase;
  static const PlateAlphabet digits = PlateAlphabetDigits.english;
}
