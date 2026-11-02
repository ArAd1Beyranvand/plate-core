import 'package:plate_core/plate_core.dart';

import 'france_alphabets.dart';

/// The alphabets behind French Polynesia's slots, which uses French stamping
/// dies: six digits and a serial letter from France's Latin set without
/// I, O and U.
abstract final class FrenchPolynesiaAlphabets {
  static const PlateAlphabet digits = PlateAlphabet.latinDigits;
  static const PlateAlphabet letters = FranceAlphabets.letters;
}
