import 'package:plate_core/plate_core.dart';

/// The alphabets behind Panamanian slots.
///
/// The motorcycle plate prints a single letter `M` before its digits; the
/// article names no excluded letter, so [letters] is the full Latin set.
abstract final class PanamaAlphabets {
  static const PlateAlphabet letters = PlateAlphabet.latinUppercase;
  static const PlateAlphabet digits = PlateAlphabet.latinDigits;
}
