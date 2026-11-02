import 'package:plate_core/plate_core.dart';

import '../plate_alphabet.dart';

/// The alphabets behind Dominican slots. Every plate prints Latin digits and
/// Latin capitals; which series use which letters is a rule for
/// `DominicanRepublicValidator`, not a bar here.
abstract final class DominicanRepublicAlphabets {
  static const PlateAlphabet digits = PlateAlphabetDigits.english;

  static const PlateAlphabet letters = PlateAlphabetLatin.typed;
}
