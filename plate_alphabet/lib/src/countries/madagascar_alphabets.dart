import 'package:plate_core/plate_core.dart';

import '../plate_alphabet.dart';

/// The characters a Malagasy plate is composed of: Latin capitals and Western
/// digits (`1234 TAK`, `009 PE 895`).
abstract final class MadagascarAlphabets {
  static const PlateAlphabet letters = PlateAlphabet.latinUppercase;
  static const PlateAlphabet digits = PlateAlphabetDigits.english;
}
