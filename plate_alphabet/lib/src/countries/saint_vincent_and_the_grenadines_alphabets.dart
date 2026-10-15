import 'package:plate_core/plate_core.dart';

/// The alphabets behind Vincentian slots. Plates are Latin capitals and ASCII
/// digits; the format is one letter and four digits (`A 1234`).
abstract final class SaintVincentAndTheGrenadinesAlphabets {
  static const PlateAlphabet letters = PlateAlphabet.latinUppercase;

  static const PlateAlphabet digits = PlateAlphabet.latinDigits;
}
