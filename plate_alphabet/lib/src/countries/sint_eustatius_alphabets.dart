import 'package:plate_core/plate_core.dart';

import '../plate_alphabet.dart';

/// Sint Eustatius plates carry Latin capitals and Western digits. The prefix
/// is the island letter `E`; the article names no excluded letter.
abstract final class SintEustatiusAlphabets {
  static const PlateAlphabet letters = PlateAlphabet.latinUppercase;
  static const PlateAlphabet digits = PlateAlphabetDigits.english;
}
