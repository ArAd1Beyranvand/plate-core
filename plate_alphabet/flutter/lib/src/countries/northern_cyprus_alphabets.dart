import 'package:plate_core/plate_core.dart';

import '../plate_alphabet.dart';

/// Northern Cypriot plates print Latin capitals and Western digits.
abstract final class NorthernCyprusAlphabets {
  static const PlateAlphabet digits = PlateAlphabetDigits.english;
  static const PlateAlphabet letters = PlateAlphabetLatin.typed;
}
